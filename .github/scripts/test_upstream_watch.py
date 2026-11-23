"""Tests for upstream_watch.py.

Run with: python3 -m unittest discover -s .github/scripts -p 'test_*.py'
"""

from __future__ import annotations

import copy
import io
import json
import re
import subprocess
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path
from typing import Any, ClassVar
from unittest import mock

import upstream_watch as uw

REPO_ROOT = Path(__file__).resolve().parents[2]


class FakeApi:
    """Answers `get` from a fixed table and records every call."""

    def __init__(self, responses: dict[str, Any]) -> None:
        self.responses = responses
        self.calls: list[str] = []

    def get(self, path: str) -> Any:
        self.calls.append(path)
        if path not in self.responses:
            raise AssertionError(f"unexpected API call: {path}")
        return copy.deepcopy(self.responses[path])


class FailingApi:
    def get(self, path: str) -> Any:
        raise uw.ApiError(f"gh api {path} failed after 3 attempts: HTTP 502")


class SequenceApi:
    """Answers one path with a different response on each call."""

    def __init__(self, path: str, responses: list[Any]) -> None:
        self.path = path
        self.responses = responses

    def get(self, path: str) -> Any:
        if path != self.path:
            raise AssertionError(f"unexpected API call: {path}")
        return self.responses.pop(0)


def completed(
    returncode: int, stdout: str = "", stderr: str = ""
) -> subprocess.CompletedProcess[str]:
    return subprocess.CompletedProcess([], returncode, stdout=stdout, stderr=stderr)


def issue_payload(**overrides: Any) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "state": "open",
        "state_reason": None,
        "labels": [{"name": "stale"}],
        "comments": 2,
        "updated_at": "2026-11-20T18:47:21Z",
    }
    payload.update(overrides)
    return payload


def comment(login: str, created_at: str) -> dict[str, Any]:
    return {"user": {"login": login}, "created_at": created_at}


def topic(watch: list[dict[str, Any]], **overrides: Any) -> dict[str, Any]:
    entry: dict[str, Any] = {
        "id": "t1",
        "title": "Plugin: something breaks",
        "note": "Local workaround in lua/x.lua.",
        "watch": watch,
    }
    entry.update(overrides)
    return entry


ISSUE_5 = {"kind": "issue", "repo": "o/r", "number": 5}
PR_7 = {"kind": "pr", "repo": "o/r", "number": 7}
PATH_X = {"kind": "path", "repo": "o/r", "path": "lua/x.lua"}


class TempDirTestCase(unittest.TestCase):
    def setUp(self) -> None:
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)

    def write_config(self, topics: list[dict[str, Any]]) -> Path:
        path = self.dir / "upstream-watch.json"
        path.write_text(json.dumps({"topics": topics}))
        return path


class ConfigTests(TempDirTestCase):
    def assert_rejected(self, topics: list[dict[str, Any]], message: str) -> None:
        with self.assertRaisesRegex(uw.ConfigError, message):
            uw.load_config(self.write_config(topics))

    def test_the_committed_watch_list_is_valid(self) -> None:
        config = uw.load_config(REPO_ROOT / ".github" / "upstream-watch.json")
        self.assertTrue(config["topics"])

    def test_rejects_an_unknown_kind(self) -> None:
        self.assert_rejected([topic([{"kind": "wiki", "repo": "o/r"}])], "unknown kind")

    def test_rejects_a_missing_field(self) -> None:
        self.assert_rejected([topic([{"kind": "issue", "repo": "o/r"}])], "number")

    def test_rejects_a_field_the_kind_does_not_take(self) -> None:
        self.assert_rejected([topic([{**ISSUE_5, "path": "lua/x.lua"}])], "path")

    def test_rejects_a_number_that_is_not_a_positive_integer(self) -> None:
        for number in (True, 0, "5"):
            with self.subTest(number=number):
                self.assert_rejected([topic([{**ISSUE_5, "number": number}])], "number")

    def test_rejects_a_malformed_repo(self) -> None:
        self.assert_rejected([topic([{**ISSUE_5, "repo": "o/r/x"}])], "repo")

    def test_rejects_the_same_watch_in_two_topics(self) -> None:
        self.assert_rejected(
            [topic([ISSUE_5]), topic([dict(ISSUE_5)], id="t2")],
            "more than once",
        )

    def test_rejects_a_repeated_topic_id(self) -> None:
        self.assert_rejected([topic([ISSUE_5]), topic([PR_7])], "t1")

    def test_rejects_text_that_would_ping_people_or_link_issues(self) -> None:
        for text in (
            "ping @folke",
            "see #145",
            "see GH-12",
            "https://x.y",
            "map <Plug>",
        ):
            for field in ("title", "note"):
                with self.subTest(field=field, text=text):
                    self.assert_rejected([topic([ISSUE_5], **{field: text})], field)


class SnapshotTests(unittest.TestCase):
    def test_issue_records_state_labels_comments_and_the_last_comment(self) -> None:
        api = FakeApi(
            {
                "repos/o/r/issues/5": issue_payload(),
                "repos/o/r/issues/5/comments?per_page=1&page=2": [
                    comment("charliie-dev", "2026-11-20T18:47:21Z")
                ],
            }
        )
        self.assertEqual(
            uw.snapshot_watch(api, ISSUE_5),
            {
                "state": "open",
                "state_reason": "",
                "labels": ["stale"],
                "comments": 2,
                "last_comment": "charliie-dev 2026-11-20T18:47:21Z",
                "updated_at": "2026-11-20T18:47:21Z",
            },
        )

    def test_issue_without_comments_does_not_fetch_comments(self) -> None:
        api = FakeApi({"repos/o/r/issues/5": issue_payload(comments=0, labels=[])})
        snapshot = uw.snapshot_watch(api, ISSUE_5)
        self.assertEqual(snapshot["last_comment"], "")
        self.assertEqual(api.calls, ["repos/o/r/issues/5"])

    def test_a_deleted_commenter_shows_as_ghost(self) -> None:
        api = FakeApi(
            {
                "repos/o/r/issues/5": issue_payload(comments=1),
                "repos/o/r/issues/5/comments?per_page=1&page=1": [
                    {"user": None, "created_at": "2026-11-01T00:00:00Z"}
                ],
            }
        )
        self.assertEqual(
            uw.snapshot_watch(api, ISSUE_5)["last_comment"],
            "ghost 2026-11-01T00:00:00Z",
        )

    def test_an_issue_watch_on_a_pull_request_is_a_config_error(self) -> None:
        api = FakeApi({"repos/o/r/issues/5": issue_payload(pull_request={})})
        with self.assertRaisesRegex(uw.ConfigError, "pull request"):
            uw.snapshot_watch(api, ISSUE_5)

    def test_pull_request_records_merge_reviews_and_reviewers(self) -> None:
        first_page = [
            {"user": {"login": f"r{i}"}, "state": "COMMENTED"} for i in range(100)
        ]
        api = FakeApi(
            {
                "repos/o/r/pulls/7": {
                    "state": "closed",
                    "merged": True,
                    "draft": False,
                    "head": {"sha": "76273c7aabbccddeeff00112233445566778899a"},
                    "labels": [],
                    "requested_reviewers": [{"login": "stevearc"}],
                    "requested_teams": [{"slug": "core"}],
                    "comments": 0,
                    "review_comments": 1,
                    "updated_at": "2026-11-21T00:00:00Z",
                },
                "repos/o/r/pulls/7/reviews?per_page=100&page=1": first_page,
                "repos/o/r/pulls/7/reviews?per_page=100&page=2": [
                    {"user": {"login": "stevearc"}, "state": "APPROVED"}
                ],
            }
        )
        snapshot = uw.snapshot_watch(api, PR_7)
        self.assertEqual(snapshot["state"], "closed")
        self.assertIs(snapshot["merged"], True)
        self.assertIs(snapshot["draft"], False)
        self.assertEqual(snapshot["head"], "76273c7aabbc")
        self.assertEqual(snapshot["requested_reviewers"], ["core", "stevearc"])
        self.assertEqual(len(snapshot["reviews"]), 101)
        self.assertEqual(snapshot["reviews"][-1], "stevearc APPROVED")
        self.assertEqual(snapshot["last_comment"], "")

    def test_pull_request_takes_its_last_comment_from_the_issue_comments(self) -> None:
        api = FakeApi(
            {
                "repos/o/r/pulls/7": {
                    "state": "open",
                    "merged": False,
                    "draft": False,
                    "head": {"sha": "76273c7aabbccddeeff00112233445566778899a"},
                    "labels": [],
                    "requested_reviewers": [],
                    "requested_teams": [],
                    "comments": 3,
                    "review_comments": 0,
                    "updated_at": "2026-11-21T00:00:00Z",
                },
                "repos/o/r/pulls/7/reviews?per_page=100&page=1": [],
                "repos/o/r/issues/7/comments?per_page=1&page=3": [
                    comment("stevearc", "2026-11-22T00:00:00Z")
                ],
            }
        )
        self.assertEqual(
            uw.snapshot_watch(api, PR_7)["last_comment"],
            "stevearc 2026-11-22T00:00:00Z",
        )

    def test_path_records_the_latest_commit_on_the_given_ref(self) -> None:
        watch = {
            "kind": "path",
            "repo": "neovim/neovim",
            "ref": "release-0.12",
            "path": "runtime/lua/vim/lsp.lua",
        }
        api = FakeApi(
            {
                "repos/neovim/neovim/commits?path=runtime%2Flua%2Fvim%2Flsp.lua"
                "&per_page=1&sha=release-0.12": [
                    {
                        "sha": "1ab7732ffffffffffffffffffffffffffffffff0",
                        "commit": {
                            "committer": {"date": "2026-08-07T20:49:12Z"},
                            "message": "fix(lsp): backport\n\nBody text",
                        },
                    }
                ]
            }
        )
        self.assertEqual(
            uw.snapshot_watch(api, watch),
            {
                "sha": "1ab7732fffff",
                "date": "2026-08-07T20:49:12Z",
                "subject": "fix(lsp): backport",
            },
        )

    def test_a_path_without_commits_is_a_config_error(self) -> None:
        api = FakeApi({"repos/o/r/commits?path=lua%2Fx.lua&per_page=1": []})
        with self.assertRaisesRegex(uw.ConfigError, "no commits"):
            uw.snapshot_watch(api, PATH_X)

    def test_search_records_the_count_and_items_by_number(self) -> None:
        query = "repo:neovim/neovim is:pr base:release-0.12 42488"
        api = FakeApi(
            {
                "search/issues?q=repo%3Aneovim%2Fneovim+is%3Apr+base%3Arelease-0.12+42488"
                "&per_page=50": {
                    "total_count": 2,
                    "items": [
                        {"number": 9, "state": "open", "title": "backport b"},
                        {"number": 3, "state": "closed", "title": "backport a"},
                    ],
                }
            }
        )
        self.assertEqual(
            uw.snapshot_watch(api, {"kind": "search", "query": query}),
            {"total_count": 2, "items": ["#3 closed backport a", "#9 open backport b"]},
        )

    def test_search_asks_again_when_results_are_incomplete(self) -> None:
        api = SequenceApi(
            "search/issues?q=x&per_page=50",
            [
                {"incomplete_results": True, "total_count": 0, "items": []},
                {
                    "incomplete_results": False,
                    "total_count": 1,
                    "items": [{"number": 3, "state": "open", "title": "t"}],
                },
            ],
        )
        with mock.patch.object(uw.time, "sleep") as sleep:
            snapshot = uw.snapshot_watch(api, {"kind": "search", "query": "x"})
        self.assertEqual(snapshot["total_count"], 1)
        self.assertEqual(sleep.call_args_list, [mock.call(2)])

    def test_search_fails_when_results_stay_incomplete(self) -> None:
        incomplete: dict[str, Any] = {
            "incomplete_results": True,
            "total_count": 0,
            "items": [],
        }
        api = SequenceApi("search/issues?q=x&per_page=50", [incomplete] * 3)
        with (
            mock.patch.object(uw.time, "sleep") as sleep,
            self.assertRaisesRegex(uw.ApiError, "incomplete"),
        ):
            uw.snapshot_watch(api, {"kind": "search", "query": "x"})
        self.assertEqual(sleep.call_args_list, [mock.call(2), mock.call(4)])

    def test_release_records_the_latest_tag(self) -> None:
        api = FakeApi(
            {
                "repos/neovim/neovim/releases/latest": {
                    "tag_name": "v0.12.6",
                    "published_at": "2026-10-09T15:43:25Z",
                }
            }
        )
        self.assertEqual(
            uw.snapshot_watch(api, {"kind": "release", "repo": "neovim/neovim"}),
            {"tag": "v0.12.6", "published_at": "2026-10-09T15:43:25Z"},
        )


class DiffTests(unittest.TestCase):
    def test_a_watch_seen_for_the_first_time_is_not_reported(self) -> None:
        self.assertEqual(uw.diff_watches({}, {"issue o/r#5": {"state": "open"}}), {})

    def test_changed_fields_are_reported_in_snapshot_order(self) -> None:
        previous: dict[str, dict[str, Any]] = {
            "issue o/r#5": {"comments": 2, "labels": ["stale"], "state": "open"}
        }
        current: dict[str, dict[str, Any]] = {
            "issue o/r#5": {"state": "closed", "labels": [], "comments": 2}
        }
        self.assertEqual(
            uw.diff_watches(previous, current),
            {"issue o/r#5": [("state", "open", "closed"), ("labels", ["stale"], [])]},
        )

    def test_fields_recorded_on_only_one_side_are_ignored(self) -> None:
        previous: dict[str, dict[str, Any]] = {
            "issue o/r#5": {"state": "open", "old_field": 1}
        }
        current: dict[str, dict[str, Any]] = {
            "issue o/r#5": {"state": "open", "new_field": 2}
        }
        self.assertEqual(uw.diff_watches(previous, current), {})

    def test_unchanged_watches_are_not_reported(self) -> None:
        state = {"issue o/r#5": {"state": "open"}}
        self.assertEqual(uw.diff_watches(state, copy.deepcopy(state)), {})

    def test_a_change_in_updated_at_alone_is_not_reported(self) -> None:
        previous = {"pr o/r#7": {"state": "open", "updated_at": "2026-02-03T15:43:23Z"}}
        current = {"pr o/r#7": {"state": "open", "updated_at": "2026-11-27T00:00:00Z"}}
        self.assertEqual(uw.diff_watches(previous, current), {})

    def test_updated_at_is_reported_along_with_other_changes(self) -> None:
        previous = {"pr o/r#7": {"state": "open", "updated_at": "a"}}
        current = {"pr o/r#7": {"state": "closed", "updated_at": "b"}}
        self.assertEqual(
            uw.diff_watches(previous, current),
            {"pr o/r#7": [("state", "open", "closed"), ("updated_at", "a", "b")]},
        )

    def comment_change(
        self, added: int, last_by: str
    ) -> tuple[dict[str, dict[str, Any]], dict[str, dict[str, Any]]]:
        previous = {
            "issue o/r#5": {
                "comments": 2,
                "last_comment": "folke t1",
                "updated_at": "a",
            }
        }
        current = {
            "issue o/r#5": {
                "comments": 2 + added,
                "last_comment": f"{last_by} t2",
                "updated_at": "b",
            }
        }
        return previous, current

    def test_a_single_new_comment_by_the_owner_is_not_reported(self) -> None:
        previous, current = self.comment_change(1, "me")
        self.assertEqual(uw.diff_watches(previous, current, self_login="me"), {})

    def test_a_new_comment_by_someone_else_is_reported(self) -> None:
        previous, current = self.comment_change(1, "folke")
        self.assertIn(
            "issue o/r#5", uw.diff_watches(previous, current, self_login="me")
        )

    def test_other_comments_before_the_owners_are_reported(self) -> None:
        previous, current = self.comment_change(2, "me")
        self.assertIn(
            "issue o/r#5", uw.diff_watches(previous, current, self_login="me")
        )

    def test_the_owners_comment_is_reported_with_other_changes(self) -> None:
        previous, current = self.comment_change(1, "me")
        previous["issue o/r#5"]["state"] = "open"
        current["issue o/r#5"]["state"] = "closed"
        self.assertIn(
            "issue o/r#5", uw.diff_watches(previous, current, self_login="me")
        )

    def test_a_watch_that_disappears_or_comes_back_is_reported(self) -> None:
        present = {"issue o/r#5": {"state": "open"}}
        gone = {"issue o/r#5": {"error": "HTTP 404"}}
        self.assertEqual(
            uw.diff_watches(present, gone),
            {"issue o/r#5": [("availability", "available", "HTTP 404")]},
        )
        self.assertEqual(
            uw.diff_watches(gone, present),
            {"issue o/r#5": [("availability", "HTTP 404", "available")]},
        )
        self.assertEqual(uw.diff_watches(gone, copy.deepcopy(gone)), {})


class IssueFailsApi(FakeApi):
    """Fails the call for issue o/r#5 with the given HTTP status, answers the rest."""

    def __init__(self, status: int, responses: dict[str, Any]) -> None:
        super().__init__(responses)
        self.status = status

    def get(self, path: str) -> Any:
        if path == "repos/o/r/issues/5":
            raise uw.ApiError(f"gh: failed (HTTP {self.status})", status=self.status)
        return super().get(path)


class GoneWatchTests(unittest.TestCase):
    CONFIG: ClassVar[dict[str, Any]] = {
        "topics": [topic([ISSUE_5, {"kind": "release", "repo": "o/q"}])]
    }

    def api(self, status: int) -> IssueFailsApi:
        release = {"tag_name": "v1", "published_at": "2026-01-01T00:00:00Z"}
        return IssueFailsApi(status, {"repos/o/q/releases/latest": release})

    def test_a_recorded_watch_that_is_gone_is_recorded_as_gone(self) -> None:
        for status in (404, 410):
            with self.subTest(status=status):
                current = uw.take_snapshot(
                    self.CONFIG, self.api(status), recorded={"issue o/r#5"}
                )
                self.assertEqual(current["issue o/r#5"], {"error": f"HTTP {status}"})
                self.assertEqual(current["release o/q"]["tag"], "v1")

    def test_a_new_watch_that_is_not_found_is_an_error(self) -> None:
        with self.assertRaisesRegex(uw.ApiError, "HTTP 404"):
            uw.take_snapshot(self.CONFIG, self.api(404), recorded=set())

    def test_other_errors_still_stop_the_run(self) -> None:
        with self.assertRaisesRegex(uw.ApiError, "HTTP 502"):
            uw.take_snapshot(self.CONFIG, self.api(502), recorded={"issue o/r#5"})


class CodeSpanTests(unittest.TestCase):
    def test_wraps_text_in_a_code_span_that_keeps_it_literal(self) -> None:
        cases = {
            "plain": "`plain`",
            "has `tick`": "`` has `tick` ``",
            "`lead": "`` `lead ``",
            " lead space": "`  lead space `",
            "a\nb": "`a b`",
        }
        for text, expected in cases.items():
            with self.subTest(text=text):
                self.assertEqual(uw._code(text), expected)


def outside_code_spans(markdown: str) -> str:
    return re.sub(r"(`+).*?\1", "", markdown)


class ReportTests(unittest.TestCase):
    def config(self) -> dict[str, Any]:
        return {
            "topics": [
                topic([ISSUE_5, PR_7], title="First topic"),
                topic([PATH_X], id="t2", title="Second topic"),
                topic(
                    [{"kind": "release", "repo": "o/q"}], id="t3", title="Quiet topic"
                ),
            ]
        }

    def test_lists_only_changed_watches_under_their_topics(self) -> None:
        title, body = uw.render_report(
            self.config(), {"pr o/r#7": [("merged", False, True)]}, run_url=None
        )
        self.assertEqual(title, "Upstream watch: 1 topic changed")
        self.assertIn("## First topic", body)
        self.assertIn("https://redirect.github.com/o/r/pull/7", body)
        self.assertNotIn("issues/5", body)
        self.assertNotIn("Second topic", body)
        self.assertNotIn("Quiet topic", body)
        self.assertIn("| merged | `false` | `true` |", body)

    def test_counts_topics_in_the_title(self) -> None:
        title, _ = uw.render_report(
            self.config(),
            {
                "issue o/r#5": [("state", "open", "closed")],
                "path o/r:lua/x.lua": [("sha", "a", "b")],
            },
            run_url=None,
        )
        self.assertEqual(title, "Upstream watch: 2 topics changed")

    def test_upstream_text_cannot_ping_people_or_link_issues(self) -> None:
        _, body = uw.render_report(
            self.config(),
            {"issue o/r#5": [("last_comment", "", "@alice fixed #12 | `x`")]},
            run_url=None,
        )
        self.assertIn(
            "| last_comment | `(none)` | `` @alice fixed #12 \\| `x` `` |", body
        )
        rest = outside_code_spans(body)
        self.assertNotIn("@", rest)
        self.assertNotRegex(rest, r"#\d")
        self.assertNotIn("https://github.com/o/r/issues/", body)
        self.assertNotIn("https://github.com/o/r/pull/", body)

    def test_lists_render_joined_and_empty_lists_as_none(self) -> None:
        _, body = uw.render_report(
            self.config(), {"issue o/r#5": [("labels", ["a", "b"], [])]}, run_url=None
        )
        self.assertIn("| labels | `a, b` | `(none)` |", body)

    def test_a_path_change_links_the_history_and_the_compare_view(self) -> None:
        _, body = uw.render_report(
            self.config(),
            {"path o/r:lua/x.lua": [("sha", "aaa111", "bbb222")]},
            run_url=None,
        )
        self.assertIn("https://github.com/o/r/commits/HEAD/lua/x.lua", body)
        self.assertIn("https://github.com/o/r/compare/aaa111...bbb222", body)

    def test_headings_for_a_search_a_release_and_a_path_on_a_ref(self) -> None:
        config = {
            "topics": [
                topic(
                    [
                        {"kind": "search", "query": "repo:o/r is:pr 42"},
                        {"kind": "search", "query": "repo:o/r is:issue 43"},
                        {"kind": "release", "repo": "o/q"},
                        {
                            "kind": "path",
                            "repo": "o/r",
                            "ref": "release-0.12",
                            "path": "a b.lua",
                        },
                    ]
                )
            ]
        }
        _, body = uw.render_report(
            config,
            {
                "search repo:o/r is:pr 42": [("total_count", 0, 1)],
                "search repo:o/r is:issue 43": [("total_count", 0, 1)],
                "release o/q": [("tag", "v1", "v2")],
                "path o/r@release-0.12:a b.lua": [("sha", "a1", "b2")],
            },
            run_url=None,
        )
        self.assertIn(
            "**Search** [`repo:o/r is:pr 42`]"
            "(https://github.com/search?q=repo%3Ao%2Fr+is%3Apr+42&type=pullrequests)",
            body,
        )
        self.assertIn(
            "(https://github.com/search?q=repo%3Ao%2Fr+is%3Aissue+43&type=issues)", body
        )
        self.assertIn(
            "**Latest release** of [`o/q`](https://github.com/o/q/releases)", body
        )
        self.assertIn(
            "**Commits touching** [`a b.lua`]"
            "(https://github.com/o/r/commits/release-0.12/a%20b.lua) in `o/r` on `release-0.12`"
            " ([compare](https://github.com/o/r/compare/a1...b2))",
            body,
        )

    def test_links_the_run_when_known(self) -> None:
        _, body = uw.render_report(
            self.config(),
            {"issue o/r#5": [("state", "open", "closed")]},
            run_url="https://github.com/me/repo/actions/runs/1",
        )
        self.assertIn("https://github.com/me/repo/actions/runs/1", body)


class MainTests(TempDirTestCase):
    def setUp(self) -> None:
        super().setUp()
        self.config_path = self.write_config([topic([ISSUE_5])])
        self.state_path = self.dir / "state.json"
        self.report_path = self.dir / "report.md"
        self.output_path = self.dir / "github_output"
        self.output_path.write_text("")

    def api(self, **overrides: Any) -> FakeApi:
        return FakeApi(
            {
                "repos/o/r/issues/5": issue_payload(comments=0, **overrides),
            }
        )

    def record_state(self, **overrides: Any) -> None:
        snapshot = uw.snapshot_watch(self.api(**overrides), ISSUE_5)
        self.state_path.write_text(
            json.dumps({"version": 1, "watches": {"issue o/r#5": snapshot}})
        )

    def run_main(self, api: Any, *extra: str) -> tuple[int, str, str]:
        argv = [
            "--config",
            str(self.config_path),
            "--state",
            str(self.state_path),
            "--report",
            str(self.report_path),
            *extra,
        ]
        out, err = io.StringIO(), io.StringIO()
        with redirect_stdout(out), redirect_stderr(err):
            code = uw.main(
                argv, api=api, environ={"GITHUB_OUTPUT": str(self.output_path)}
            )
        return code, out.getvalue(), err.getvalue()

    def outputs(self) -> str:
        return self.output_path.read_text()

    def test_first_run_records_a_baseline_without_reporting(self) -> None:
        code, out, _ = self.run_main(self.api())
        self.assertEqual(code, 0)
        self.assertIn("No tracked upstream changes", out)
        state = json.loads(self.state_path.read_text())
        self.assertEqual(state["version"], 1)
        self.assertEqual(state["watches"]["issue o/r#5"]["state"], "open")
        self.assertEqual(self.outputs(), "changed=false\n")
        self.assertFalse(self.report_path.exists())

    def test_a_change_writes_the_report_state_and_outputs(self) -> None:
        self.record_state()
        code, out, _ = self.run_main(self.api(state="closed", state_reason="completed"))
        self.assertEqual(code, 0)
        body = self.report_path.read_text()
        self.assertIn("| state | `open` | `closed` |", body)
        self.assertIn(body, out)
        state = json.loads(self.state_path.read_text())
        self.assertEqual(state["watches"]["issue o/r#5"]["state"], "closed")
        self.assertEqual(
            self.outputs(), "changed=true\ntitle=Upstream watch: 1 topic changed\n"
        )

    def test_no_change_leaves_the_state_file_as_it_was(self) -> None:
        self.record_state()
        before = self.state_path.read_text()
        code, _, _ = self.run_main(self.api())
        self.assertEqual(code, 0)
        after = self.state_path.read_text()
        self.assertEqual(json.loads(after), json.loads(before))
        self.assertTrue(after.endswith("}\n"))
        self.assertEqual(self.outputs(), "changed=false\n")

    def test_dry_run_reports_without_writing_state_or_outputs(self) -> None:
        self.record_state()
        before = self.state_path.read_text()
        code, out, _ = self.run_main(self.api(state="closed"), "--dry-run")
        self.assertEqual(code, 0)
        self.assertIn("| state | `open` | `closed` |", out)
        self.assertEqual(self.state_path.read_text(), before)
        self.assertEqual(self.outputs(), "")

    def test_an_api_failure_exits_1_and_keeps_the_state(self) -> None:
        self.record_state()
        before = self.state_path.read_text()
        code, _, err = self.run_main(FailingApi())
        self.assertEqual(code, 1)
        self.assertIn("HTTP 502", err)
        self.assertEqual(self.state_path.read_text(), before)
        self.assertEqual(self.outputs(), "")

    def test_a_state_file_of_another_version_is_an_error(self) -> None:
        self.state_path.write_text(json.dumps({"version": 2, "watches": {}}))
        code, _, err = self.run_main(self.api())
        self.assertEqual(code, 1)
        self.assertIn("version", err)

    def test_watches_dropped_from_the_config_are_dropped_from_the_state(self) -> None:
        self.state_path.write_text(
            json.dumps({"version": 1, "watches": {"issue o/r#99": {"state": "open"}}})
        )
        self.run_main(self.api())
        self.assertEqual(
            list(json.loads(self.state_path.read_text())["watches"]), ["issue o/r#5"]
        )

    def test_a_broken_watch_list_exits_1(self) -> None:
        self.config_path.write_text("{}")
        code, _, err = self.run_main(self.api())
        self.assertEqual(code, 1)
        self.assertIn("topics", err)

    def test_a_recorded_watch_that_is_gone_is_reported(self) -> None:
        self.record_state()
        code, _, _ = self.run_main(IssueFailsApi(404, {}))
        self.assertEqual(code, 0)
        self.assertIn(
            "| availability | `available` | `HTTP 404` |", self.report_path.read_text()
        )
        state = json.loads(self.state_path.read_text())
        self.assertEqual(state["watches"]["issue o/r#5"], {"error": "HTTP 404"})

    def test_the_repository_owners_own_comment_is_not_reported(self) -> None:
        self.record_state()
        api = FakeApi(
            {
                "repos/o/r/issues/5": issue_payload(comments=1),
                "repos/o/r/issues/5/comments?per_page=1&page=1": [
                    comment("me", "2026-11-22T00:00:00Z")
                ],
            }
        )
        argv = ["--config", str(self.config_path), "--state", str(self.state_path)]
        argv += ["--report", str(self.report_path)]
        environ = {
            "GITHUB_OUTPUT": str(self.output_path),
            "GITHUB_REPOSITORY_OWNER": "me",
        }
        with redirect_stdout(io.StringIO()):
            self.assertEqual(uw.main(argv, api=api, environ=environ), 0)
        self.assertEqual(self.outputs(), "changed=false\n")
        state = json.loads(self.state_path.read_text())
        self.assertEqual(state["watches"]["issue o/r#5"]["comments"], 1)


class RunUrlTests(unittest.TestCase):
    def test_builds_the_run_url_from_the_actions_environment(self) -> None:
        environ = {
            "GITHUB_SERVER_URL": "https://github.com",
            "GITHUB_REPOSITORY": "me/repo",
            "GITHUB_RUN_ID": "9",
        }
        self.assertEqual(
            uw.run_url(environ), "https://github.com/me/repo/actions/runs/9"
        )
        self.assertIsNone(uw.run_url({"GITHUB_REPOSITORY": "me/repo"}))


class GhApiTests(unittest.TestCase):
    def test_retries_a_failed_call(self) -> None:
        results = [
            completed(1, stderr="gh: Server Error (HTTP 502)"),
            completed(0, '{"ok": true}'),
        ]
        sleeps: list[float] = []
        api = uw.GhApi(run=lambda *a, **k: results.pop(0), sleep=sleeps.append)
        self.assertEqual(api.get("repos/o/r"), {"ok": True})
        self.assertEqual(sleeps, [2])

    def test_retries_rate_limits(self) -> None:
        for status in (403, 429):
            with self.subTest(status=status):
                results = [
                    completed(1, stderr=f"gh: API rate limit exceeded (HTTP {status})"),
                    completed(0, '{"ok": true}'),
                ]
                api = uw.GhApi(
                    run=lambda *a, _results=results, **k: _results.pop(0),
                    sleep=lambda _: None,
                )
                self.assertEqual(api.get("repos/o/r"), {"ok": True})

    def test_gives_up_after_the_last_attempt(self) -> None:
        calls: list[Any] = []

        def run(*args: Any, **_: Any) -> subprocess.CompletedProcess[str]:
            calls.append(args)
            return completed(1, stderr="gh: Server Error (HTTP 502)")

        with self.assertRaisesRegex(uw.ApiError, "HTTP 502"):
            uw.GhApi(run=run, sleep=lambda _: None).get("repos/o/r")
        self.assertEqual(len(calls), 3)

    def test_does_not_retry_a_client_error(self) -> None:
        calls: list[Any] = []
        sleeps: list[float] = []

        def run(*args: Any, **_: Any) -> subprocess.CompletedProcess[str]:
            calls.append(args)
            return completed(1, stderr="gh: Not Found (HTTP 404)")

        with self.assertRaisesRegex(uw.ApiError, "HTTP 404") as raised:
            uw.GhApi(run=run, sleep=sleeps.append).get("repos/o/r/issues/999")
        self.assertEqual(raised.exception.status, 404)
        self.assertEqual(len(calls), 1)
        self.assertEqual(sleeps, [])

    def test_output_that_is_not_json_is_an_error(self) -> None:
        api = uw.GhApi(run=lambda *a, **k: completed(0, "<html>"), sleep=lambda _: None)
        with self.assertRaisesRegex(uw.ApiError, "invalid JSON"):
            api.get("repos/o/r")

    def test_paging_stops_at_the_page_limit(self) -> None:
        class FullPages:
            def get(self, path: str) -> Any:
                return [{}] * uw.PAGE_SIZE

        with self.assertRaisesRegex(uw.ApiError, "more than"):
            uw.get_all(FullPages(), "repos/o/r/pulls/7/reviews")

    def test_passes_the_path_to_gh_api(self) -> None:
        seen: list[list[str]] = []

        def run(cmd: list[str], **_: Any) -> subprocess.CompletedProcess[str]:
            seen.append(cmd)
            return subprocess.CompletedProcess(cmd, 0, stdout="[]", stderr="")

        uw.GhApi(run=run, sleep=lambda _: None).get("repos/o/r/issues/5")
        self.assertEqual(seen[0][:2], ["gh", "api"])
        self.assertEqual(seen[0][-1], "repos/o/r/issues/5")


if __name__ == "__main__":
    unittest.main()
