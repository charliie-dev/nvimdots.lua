# SSH Clipboard: Windows Terminal Workaround

## Background

When SSHing from Windows Terminal to a remote Linux server and running nvim,
copy/paste behaves strangely (e.g. `"+p` hangs with
`Waiting for OSC 52 response from the terminal`). The same setup works fine
from macOS.

### Root cause

The remote nvim's `vim.g.clipboard` (`lua/core/init.lua`) detects `SSH_TTY` and
uses OSC 52 for both copy and paste. OSC 52 *write* is widely supported, but
OSC 52 *read* is not implemented in Windows Terminal (security default). nvim
sends the read query and blocks until timeout, producing the stuck-paste
behavior.

macOS terminals (iTerm2 / WezTerm with the option enabled) reply to OSC 52
reads, which is why it works there.

## Fix

Detect Windows Terminal via the `WT_SESSION` environment variable forwarded
through SSH, and fall back to nvim's unnamed register for paste only when
running under Windows Terminal. OSC 52 copy is preserved everywhere.

This requires three pieces of configuration.

### 1. nvim config

`lua/core/init.lua`, SSH_TTY branch:

```lua
elseif os.getenv("SSH_TTY") then
    local osc52 = require("vim.ui.clipboard.osc52")
    -- Windows Terminal does not implement OSC 52 read; fall back to the
    -- unnamed register so `"+p` does not block waiting for a reply.
    local is_wt = os.getenv("WT_SESSION") ~= nil
    local register_paste = function()
        return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
    end
    vim.g.clipboard = {
        name = "OSC 52",
        copy = {
            ["+"] = osc52.copy("+"),
            ["*"] = osc52.copy("*"),
        },
        paste = {
            ["+"] = is_wt and register_paste or osc52.paste("+"),
            ["*"] = is_wt and register_paste or osc52.paste("*"),
        },
    }
```

Apply on **every machine** that runs nvim under SSH (both local and remote).

### 2. Local SSH client (Windows)

`~/.ssh/config` (i.e. `C:\Users\<user>\.ssh\config`):

```ssh-config
Host pluto
    HostName ...
    User ...
    SendEnv WT_SESSION
```

Or apply globally:

```ssh-config
Host *
    SendEnv WT_SESSION
```

### 3. Remote sshd

`/etc/ssh/sshd_config`, append `WT_SESSION` to `AcceptEnv`:

```
AcceptEnv LANG LC_* WT_SESSION
```

Reload:

```bash
sudo systemctl reload sshd   # or: sudo systemctl reload ssh
```

Verify:

```bash
sudo sshd -T | grep -i acceptenv
```

## Reconnect

Close any existing SSH session before testing. If `ControlMaster` is in use:

```bash
ssh -O exit pluto
```

Then `ssh pluto` again.

## Verification

In the remote shell:

```bash
echo "$WT_SESSION"
```

Expected: a GUID string.

In remote nvim:

```vim
:lua print(os.getenv("WT_SESSION"))
:lua print(vim.inspect(vim.g.clipboard))
```

`vim.g.clipboard.paste["+"]` should be the `register_paste` function, not
`osc52.paste`.

## Behavior summary

| Action | Result |
|---|---|
| `y` / `"+y` in nvim | Written to Windows clipboard via OSC 52 |
| `p` / `"+p` in nvim | Reads from nvim's unnamed register; no terminal round-trip |
| Paste Windows clipboard into nvim | Use Windows Terminal **Ctrl+Shift+V** (bracketed paste) |
| SSH from macOS | `WT_SESSION` absent, falls through to original OSC 52 paste; behavior unchanged |

## Trade-off

`"+p` no longer reflects the system clipboard from inside nvim. To bring an
external clipboard value into nvim, use the terminal's paste keybinding
(Ctrl+Shift+V), which goes through bracketed paste and is unaffected.
