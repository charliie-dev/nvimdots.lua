#!/usr/bin/env python3
"""Report changes in tracked upstream issues, pull requests, paths, searches and releases.

Reads the watch list (.github/upstream-watch.json), takes a snapshot of every watch through
`gh api`, compares it with the recorded state (.github/upstream-watch-state.json) and writes a
Markdown report for the watches that changed. A watch seen for the first time is recorded without
being reported, and fields recorded on only one side are ignored, so adding a watch or a field
does not raise a false alarm. A change in updated_at alone is not reported, nor is a single new
comment by the repository owner (GITHUB_REPOSITORY_OWNER). A recorded watch that now answers
404 or 410 is reported as gone instead of failing the run.

Watch kinds and the fields they take:
  issue    repo, number         state, labels, comment count, last comment, updated_at
  pr       repo, number         the issue fields plus merge, draft, head, reviews, reviewers
  path     repo, path[, ref]    latest commit touching the path (ref defaults to the default branch)
  search   query                search/issues results
  release  repo                 latest release tag

The report only ever shows upstream text inside code spans and links issues and pull requests
through redirect.github.com, so the issue it becomes neither pings anyone nor adds
cross-references to upstream timelines. Topic titles and notes are checked for the same reason.

Exit status: 0 when the check ran (changed or not), 1 on a config, state or API error.
With GITHUB_OUTPUT set and without --dry-run it writes `changed=true|false` and, on a change,
`title=<issue title>`.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import time
import urllib.parse
from collections.abc import Callable, Collection, Mapping, Sequence
from pathlib import Path
from typing import Any

STATE_VERSION = 1
GITHUB_DIR = Path(__file__).resolve().parents[1]
DEFAULT_CONFIG = GITHUB_DIR / "upstream-watch.json"
DEFAULT_STATE = GITHUB_DIR / "upstream-watch-state.json"

REQUIRED_FIELDS: dict[str, tuple[str, ...]] = {
    "issue": ("repo", "number"),
    "pr": ("repo", "number"),
    "path": ("repo", "path"),
    "search": ("query",),
    "release": ("repo",),
}
OPTIONAL_FIELDS: dict[str, tuple[str, ...]] = {"path": ("ref",)}
REPO_RE = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")
# Mentions and issue references would notify people or link upstream issues, links could point
# at upstream issues, and angle brackets could be read as HTML.
UNSAFE_PROSE_RE = re.compile(r"@\w|#\d|\bGH-\d|https?://|[<>]", re.IGNORECASE)
PAGE_SIZE = 100
MAX_PAGES = 10
# `gh api` ends its error message with the status, e.g. "gh: Not Found (HTTP 404)". Other client
# errors will not go away on a retry; 403 and 429 are what rate limits answer with.
HTTP_STATUS_RE = re.compile(r"\(HTTP (\d{3})\)")
RETRY_STATUSES = frozenset({403, 429})
# The search API answers a timed-out query with incomplete_results and partial items.
SEARCH_ATTEMPTS = 3
# Fields that change without any visible activity (a PR's updated_at moves when its base branch
# gets a push), so they are recorded but only reported along with another change.
QUIET_FIELDS = frozenset({"updated_at"})
# Not Found and Gone: the issue was deleted or transferred, the repo renamed or removed, or the
# release taken down. A recorded watch answering with one of these is reported as gone.
GONE_STATUSES = frozenset({404, 410})
GONE_FIELD = "error"


class ConfigError(Exception):
    """The watch list or the recorded state is unusable."""


class ApiError(Exception):
    """A GitHub API call kept failing; status is the HTTP status when gh reported one."""

    def __init__(self, message: str, status: int | None = None) -> None:
        super().__init__(message)
        self.status = status


Runner = Callable[..., "subprocess.CompletedProcess[str]"]


class GhApi:
    """Calls the GitHub REST API through `gh api`, which takes its token from GH_TOKEN."""

    def __init__(
        self,
        run: Runner = subprocess.run,
        sleep: Callable[[float], None] = time.sleep,
        attempts: int = 3,
    ) -> None:
        self.run = run
        self.sleep = sleep
        self.attempts = attempts

    def get(self, path: str) -> Any:
        error = ""
        status = 0
        for attempt in range(1, self.attempts + 1):
            proc = self.run(
                ["gh", "api", "-H", "Accept: application/vnd.github+json", path],
                capture_output=True,
                text=True,
                check=False,
            )
            if proc.returncode == 0:
                try:
                    return json.loads(proc.stdout)
                except json.JSONDecodeError as err:
                    error = f"invalid JSON: {err}"
                    status = 0
            else:
                error = proc.stderr.strip() or f"exit status {proc.returncode}"
                match = HTTP_STATUS_RE.search(error)
                status = int(match[1]) if match else 0
                if 400 <= status < 500 and status not in RETRY_STATUSES:
                    break
            if attempt < self.attempts:
                self.sleep(2**attempt)
        raise ApiError(
            f"gh api {path} failed after {attempt} attempt(s): {error}",
            status=status or None,
        )


def get_all(api: Any, path: str) -> list[Any]:
    items: list[Any] = []
    for page in range(1, MAX_PAGES + 1):
        batch = api.get(f"{path}?per_page={PAGE_SIZE}&page={page}")
        items.extend(batch)
        if len(batch) < PAGE_SIZE:
            return items
    raise ApiError(f"{path} has more than {MAX_PAGES * PAGE_SIZE} entries")


# --- watch list -------------------------------------------------------------------------------


def watch_key(watch: Mapping[str, Any]) -> str:
    kind = watch["kind"]
    if kind in ("issue", "pr"):
        return f"{kind} {watch['repo']}#{watch['number']}"
    if kind == "path":
        ref = watch.get("ref")
        return f"path {watch['repo']}{'@' + ref if ref else ''}:{watch['path']}"
    if kind == "search":
        return f"search {watch['query']}"
    return f"release {watch['repo']}"


def _check_watch(where: str, watch: Any) -> None:
    if not isinstance(watch, dict):
        raise ConfigError(f"{where}: each watch must be an object")
    kind = watch.get("kind")
    if kind not in REQUIRED_FIELDS:
        raise ConfigError(f"{where}: unknown kind {kind!r}")
    required = REQUIRED_FIELDS[kind]
    allowed = {"kind", *required, *OPTIONAL_FIELDS.get(kind, ())}
    for field in sorted(set(watch) - allowed):
        raise ConfigError(f"{where}: kind {kind!r} does not take field {field!r}")
    for field in required:
        if field not in watch:
            raise ConfigError(f"{where}: kind {kind!r} needs field {field!r}")
    for field, value in watch.items():
        if field == "kind":
            continue
        if field == "number":
            if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
                raise ConfigError(f"{where}: number must be a positive integer")
        elif not isinstance(value, str) or not value.strip():
            raise ConfigError(f"{where}: {field} must be a non-empty string")
    if "repo" in watch and not REPO_RE.match(watch["repo"]):
        raise ConfigError(
            f"{where}: repo must look like owner/name, got {watch['repo']!r}"
        )
    if "path" in watch and watch["path"].startswith("/"):
        raise ConfigError(f"{where}: path must be relative to the repository root")


def load_config(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as err:
        raise ConfigError(f"cannot read {path}: {err}") from err
    if not isinstance(data, dict) or set(data) != {"topics"}:
        raise ConfigError(f"{path}: the top level must be an object with only 'topics'")
    topics = data["topics"]
    if not isinstance(topics, list) or not topics:
        raise ConfigError(f"{path}: topics must be a non-empty list")
    ids: set[str] = set()
    keys: set[str] = set()
    for index, topic in enumerate(topics):
        where = f"topic {index + 1}"
        if not isinstance(topic, dict):
            raise ConfigError(f"{where}: must be an object")
        for field in sorted(set(topic) - {"id", "title", "note", "watch"}):
            raise ConfigError(f"{where}: unknown field {field!r}")
        for field in ("id", "title", "note"):
            value = topic.get(field)
            if not isinstance(value, str) or not value.strip():
                raise ConfigError(f"{where}: {field} must be a non-empty string")
        where = f"topic {topic['id']!r}"
        if topic["id"] in ids:
            raise ConfigError(f"{where}: id used more than once")
        ids.add(topic["id"])
        for field in ("title", "note"):
            if UNSAFE_PROSE_RE.search(topic[field]):
                raise ConfigError(
                    f"{where}: {field} must not contain mentions, issue references, links or "
                    f"angle brackets: {topic[field]!r}"
                )
        watches = topic.get("watch")
        if not isinstance(watches, list) or not watches:
            raise ConfigError(f"{where}: watch must be a non-empty list")
        for watch in watches:
            _check_watch(where, watch)
            key = watch_key(watch)
            if key in keys:
                raise ConfigError(f"{where}: {key} is watched more than once")
            keys.add(key)
    return data


# --- snapshots --------------------------------------------------------------------------------


def _login(user: Mapping[str, Any] | None) -> str:
    return user["login"] if user else "ghost"


def _labels(data: Mapping[str, Any]) -> list[str]:
    return sorted(label["name"] for label in data.get("labels") or [])


def _last_comment(api: Any, repo: str, number: int, count: int) -> str:
    if count <= 0:
        return ""
    page = api.get(f"repos/{repo}/issues/{number}/comments?per_page=1&page={count}")
    if not page:
        return ""
    last = page[-1]
    return f"{_login(last.get('user'))} {last['created_at']}"


def _snapshot_issue(api: Any, watch: Mapping[str, Any]) -> dict[str, Any]:
    repo, number = watch["repo"], watch["number"]
    data = api.get(f"repos/{repo}/issues/{number}")
    if "pull_request" in data:
        raise ConfigError(f"{watch_key(watch)} is a pull request; use kind 'pr'")
    return {
        "state": data["state"],
        "state_reason": data.get("state_reason") or "",
        "labels": _labels(data),
        "comments": data["comments"],
        "last_comment": _last_comment(api, repo, number, data["comments"]),
        "updated_at": data["updated_at"],
    }


def _snapshot_pr(api: Any, watch: Mapping[str, Any]) -> dict[str, Any]:
    repo, number = watch["repo"], watch["number"]
    data = api.get(f"repos/{repo}/pulls/{number}")
    reviews = get_all(api, f"repos/{repo}/pulls/{number}/reviews")
    reviewers = [user["login"] for user in data.get("requested_reviewers") or []]
    teams = [team["slug"] for team in data.get("requested_teams") or []]
    return {
        "state": data["state"],
        "merged": bool(data.get("merged")),
        "draft": bool(data.get("draft")),
        "head": data["head"]["sha"][:12],
        "labels": _labels(data),
        "requested_reviewers": sorted(reviewers + teams),
        "reviews": [
            f"{_login(review.get('user'))} {review['state']}" for review in reviews
        ],
        "comments": data["comments"],
        "review_comments": data["review_comments"],
        "last_comment": _last_comment(api, repo, number, data["comments"]),
        "updated_at": data["updated_at"],
    }


def _snapshot_path(api: Any, watch: Mapping[str, Any]) -> dict[str, Any]:
    query: dict[str, Any] = {"path": watch["path"], "per_page": 1}
    if watch.get("ref"):
        query["sha"] = watch["ref"]
    commits = api.get(f"repos/{watch['repo']}/commits?{urllib.parse.urlencode(query)}")
    if not commits:
        raise ConfigError(f"{watch_key(watch)}: no commits touch this path")
    commit = commits[0]
    lines = commit["commit"]["message"].splitlines()
    return {
        "sha": commit["sha"][:12],
        "date": commit["commit"]["committer"]["date"],
        "subject": lines[0][:100] if lines else "",
    }


def _snapshot_search(api: Any, watch: Mapping[str, Any]) -> dict[str, Any]:
    query = urllib.parse.urlencode({"q": watch["query"], "per_page": 50})
    for attempt in range(1, SEARCH_ATTEMPTS + 1):
        data = api.get(f"search/issues?{query}")
        if not data.get("incomplete_results"):
            break
        if attempt < SEARCH_ATTEMPTS:
            time.sleep(2**attempt)
    else:
        raise ApiError(
            f"{watch_key(watch)}: results stayed incomplete after {SEARCH_ATTEMPTS} attempts"
        )
    items = sorted(data["items"], key=lambda item: item["number"])
    return {
        "total_count": data["total_count"],
        "items": [
            f"#{item['number']} {item['state']} {item['title'][:80]}" for item in items
        ],
    }


def _snapshot_release(api: Any, watch: Mapping[str, Any]) -> dict[str, Any]:
    data = api.get(f"repos/{watch['repo']}/releases/latest")
    return {"tag": data["tag_name"], "published_at": data["published_at"]}


SNAPSHOTS: dict[str, Callable[[Any, Mapping[str, Any]], dict[str, Any]]] = {
    "issue": _snapshot_issue,
    "pr": _snapshot_pr,
    "path": _snapshot_path,
    "search": _snapshot_search,
    "release": _snapshot_release,
}


def snapshot_watch(api: Any, watch: Mapping[str, Any]) -> dict[str, Any]:
    return SNAPSHOTS[watch["kind"]](api, watch)


def take_snapshot(
    config: Mapping[str, Any], api: Any, recorded: Collection[str] = frozenset()
) -> dict[str, dict[str, Any]]:
    """Snapshot every watch; a recorded watch that is now gone is kept as an error entry.

    A watch that was never recorded and is not found is more likely a typo in the watch list,
    so that, like any other API error, stops the run.
    """
    snapshot: dict[str, dict[str, Any]] = {}
    for topic in config["topics"]:
        for watch in topic["watch"]:
            key = watch_key(watch)
            try:
                snapshot[key] = snapshot_watch(api, watch)
            except ApiError as err:
                if err.status not in GONE_STATUSES or key not in recorded:
                    raise
                snapshot[key] = {GONE_FIELD: f"HTTP {err.status}"}
    return snapshot


# --- comparison -------------------------------------------------------------------------------

Change = tuple[str, Any, Any]


def _own_comment_only(changed: Sequence[Change], self_login: str | None) -> bool:
    """True when the only news is one new comment, written by self_login."""
    loud = {
        field: (old, new) for field, old, new in changed if field not in QUIET_FIELDS
    }
    if not self_login or set(loud) != {"comments", "last_comment"}:
        return False
    (old_count, new_count), (_, last) = loud["comments"], loud["last_comment"]
    return new_count - old_count == 1 and str(last).startswith(f"{self_login} ")


def diff_watches(
    previous: Mapping[str, Mapping[str, Any]],
    current: Mapping[str, Mapping[str, Any]],
    self_login: str | None = None,
) -> dict[str, list[Change]]:
    changes: dict[str, list[Change]] = {}
    for key, fields in current.items():
        before = previous.get(key)
        if before is None:
            continue
        was, now = before.get(GONE_FIELD), fields.get(GONE_FIELD)
        if was != now:
            changes[key] = [("availability", was or "available", now or "available")]
            continue
        if now:
            continue
        changed = [
            (field, before[field], value)
            for field, value in fields.items()
            if field in before and before[field] != value
        ]
        loud = any(field not in QUIET_FIELDS for field, _, _ in changed)
        if loud and not _own_comment_only(changed, self_login):
            changes[key] = changed
    return changes


# --- report -----------------------------------------------------------------------------------


def _code(text: str) -> str:
    text = text.replace("\r", " ").replace("\n", " ")
    longest = max((len(run) for run in re.findall(r"`+", text)), default=0)
    fence = "`" * (longest + 1)
    if (
        text.startswith("`")
        or text.endswith("`")
        or (text.startswith(" ") and text.strip())
    ):
        text = f" {text} "
    return f"{fence}{text}{fence}"


def _cell(value: Any) -> str:
    if isinstance(value, bool):
        text = "true" if value else "false"
    elif isinstance(value, list):
        text = ", ".join(str(item) for item in value) or "(none)"
    elif value is None or value == "":
        text = "(none)"
    else:
        text = str(value)
    return _code(text).replace("|", "\\|")


def _quote(path: str) -> str:
    return urllib.parse.quote(path, safe="/")


def _watch_heading(watch: Mapping[str, Any], changes: Sequence[Change]) -> str:
    kind = watch["kind"]
    if kind in ("issue", "pr"):
        repo, number = watch["repo"], watch["number"]
        segment, label = (
            ("issues", "Issue") if kind == "issue" else ("pull", "Pull request")
        )
        # redirect.github.com links do not add cross-references to the upstream timeline.
        url = f"https://redirect.github.com/{repo}/{segment}/{number}"
        return f"**{label}** [{_code(f'{repo}#{number}')}]({url})"
    if kind == "path":
        repo, ref = watch["repo"], watch.get("ref") or "HEAD"
        url = f"https://github.com/{repo}/commits/{_quote(ref)}/{_quote(watch['path'])}"
        heading = (
            f"**Commits touching** [{_code(watch['path'])}]({url}) in {_code(repo)}"
        )
        if ref != "HEAD":
            heading += f" on {_code(ref)}"
        for field, old, new in changes:
            if field == "sha":
                compare = (
                    f"https://github.com/{repo}/compare/{_quote(old)}...{_quote(new)}"
                )
                heading += f" ([compare]({compare}))"
        return heading
    if kind == "search":
        kind = "pullrequests" if re.search(r"\bis:pr\b", watch["query"]) else "issues"
        query = urllib.parse.urlencode({"q": watch["query"], "type": kind})
        return (
            f"**Search** [{_code(watch['query'])}](https://github.com/search?{query})"
        )
    repo = watch["repo"]
    return f"**Latest release** of [{_code(repo)}](https://github.com/{repo}/releases)"


def render_report(
    config: Mapping[str, Any],
    changes: Mapping[str, Sequence[Change]],
    run_url: str | None,
) -> tuple[str, str]:
    topics = [
        topic
        for topic in config["topics"]
        if any(watch_key(watch) in changes for watch in topic["watch"])
    ]
    count = f"{len(topics)} topic{'' if len(topics) == 1 else 's'}"
    title = f"Upstream watch: {count} changed"
    lines = [f"The weekly upstream watch found changes in {count}."]
    if run_url:
        lines += ["", f"Run: {run_url}"]
    for topic in topics:
        lines += ["", f"## {topic['title']}", "", topic["note"]]
        for watch in topic["watch"]:
            watch_changes = changes.get(watch_key(watch))
            if not watch_changes:
                continue
            lines += [
                "",
                _watch_heading(watch, watch_changes),
                "",
                "| field | before | after |",
                "| --- | --- | --- |",
            ]
            lines += [
                f"| {field} | {_cell(old)} | {_cell(new)} |"
                for field, old, new in watch_changes
            ]
    lines += [
        "",
        "---",
        "",
        (
            "Watch list: `.github/upstream-watch.json`. "
            "Recorded state: `.github/upstream-watch-state.json`."
        ),
    ]
    return title, "\n".join(lines) + "\n"


# --- state and entry point --------------------------------------------------------------------


def load_state(path: Path) -> dict[str, Any]:
    if not Path(path).exists():
        return {"version": STATE_VERSION, "watches": {}}
    try:
        data = json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as err:
        raise ConfigError(f"cannot read {path}: {err}") from err
    if not isinstance(data, dict) or data.get("version") != STATE_VERSION:
        raise ConfigError(f"{path}: expected state version {STATE_VERSION}")
    if not isinstance(data.get("watches"), dict):
        raise ConfigError(f"{path}: watches must be an object")
    return data


def write_state(path: Path, watches: Mapping[str, Any]) -> None:
    text = json.dumps(
        {"version": STATE_VERSION, "watches": watches}, indent=2, sort_keys=True
    )
    text += "\n"
    path = Path(path)
    if not path.exists() or path.read_text(encoding="utf-8") != text:
        path.write_text(text, encoding="utf-8")


def run_url(environ: Mapping[str, str]) -> str | None:
    parts = [
        environ.get(name)
        for name in ("GITHUB_SERVER_URL", "GITHUB_REPOSITORY", "GITHUB_RUN_ID")
    ]
    if not all(parts):
        return None
    server, repo, run_id = parts
    return f"{server}/{repo}/actions/runs/{run_id}"


def main(
    argv: Sequence[str] | None = None,
    api: Any = None,
    environ: Mapping[str, str] | None = None,
) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
    parser.add_argument("--state", type=Path, default=DEFAULT_STATE)
    parser.add_argument(
        "--report", type=Path, required=True, help="where to write the report"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="report only; leave the state and outputs alone",
    )
    args = parser.parse_args(argv)
    environ = os.environ if environ is None else environ

    try:
        config = load_config(args.config)
        previous = load_state(args.state)
        current = take_snapshot(
            config, api or GhApi(), recorded=previous["watches"].keys()
        )
    except (ConfigError, ApiError) as err:
        print(f"error: {err}", file=sys.stderr)
        return 1

    changes = diff_watches(
        previous["watches"], current, self_login=environ.get("GITHUB_REPOSITORY_OWNER")
    )
    outputs = ["changed=false"]
    if changes:
        title, body = render_report(config, changes, run_url(environ))
        args.report.write_text(body, encoding="utf-8")
        print(title, body, sep="\n\n")
        outputs = ["changed=true", f"title={title}"]
    else:
        print("No tracked upstream changes.")

    if not args.dry_run:
        write_state(args.state, current)
        output_file = environ.get("GITHUB_OUTPUT")
        if output_file:
            with open(output_file, "a", encoding="utf-8") as handle:
                handle.write("".join(f"{line}\n" for line in outputs))
    return 0


if __name__ == "__main__":
    sys.exit(main())
