# dotfiles

Personal configuration for shell, git, tmux, vim and the terminal, installed
by symlinking into `$HOME`.

## Requirements

`git`, `bash`, `make`. `fc-cache` to register fonts, `tmux` and `nvim` to use
the tmux/vim integration. None are installed for you — `make libs` can build
tmux, neovim and their dependencies from source if the system versions are
too old or absent.

## Installation

```sh
git clone <this repo> ~/.dotfiles
cd ~/.dotfiles
```

**1. See what would be replaced.** Every existing file is backed up, but look
first — `~/.bashrc`, `~/.zshrc` and `~/.gitconfig` are usually displaced:

```sh
find home -type f | sed "s|^home|$HOME|" | while IFS= read -r f; do
  [ -e "$f" ] && [ ! -L "$f" ] && echo "WILL BACK UP: $f"
done
```

**2. Install.**

```sh
make install
```

**3. Set your git identity.** This is required, not optional — see below.

```sh
$EDITOR ~/.gitconfig.local
```

**4. Restart tmux** so the terminal and plugin settings take effect:

```sh
tmux kill-server && tmux
```

**5. In nvim**, install plugins with `:PlugInstall`.

## What gets installed, and where

| from | to | how |
|---|---|---|
| every file under `home/` | the same path under `$HOME` | symlink |
| `home/.local/share/fonts/` (96 fonts) | `~/.local/share/fonts/` | symlink, then `fc-cache -f` |
| `skel/.gitconfig.local` | `~/.gitconfig.local` | copy, mode 600, **only if absent** |
| `skel/.bash_aliases.local` | `~/.bash_aliases.local` | copy, mode 600, **only if absent** |
| `skel/.ssh/config` | `~/.ssh/config` | copy, mode 600 in a 700 dir, **only if absent** |
| `lib/tmux-resurrect-central.sh` | `~/.tmux/plugins/tmux-resurrect/strategies/{vim,nvim}_central.sh` | symlink |
| github: `tmux-plugins/tpm` | `~/.tmux/plugins/tpm` | `git clone` |
| the `@plugin` lines in `home/.tmux.conf` | `~/.tmux/plugins/` | `git clone` |

Parent directories are created as real directories, so `~/.ssh` and `~/.vnc`
stay yours — only the files inside them are symlinks.

Anything displaced is copied to `<name>.bk.0` (then `.bk.1`, and so on)
before being replaced. Re-running is idempotent: nothing is backed up twice.

### Not installed

| | why |
|---|---|
| `bin/` | add `~/.dotfiles/bin` to `PATH` yourself |
| `themes/` | applied by hand, see below |
| `st/config.h` | copied into the st source tree by `make st` |
| `lib/git-completion.tcsh`, `lib/tmux_git_prompt_command.csh` | kept for reference; nothing currently sources them |

## What you have to do yourself

**Fill in `~/.gitconfig.local`.** `home/.gitconfig` sets
`user.useConfigOnly = true`, so **git refuses to commit until this file has a
name and email**. That is deliberate — a fresh clone should not commit under
a guessed `login@host` identity. The same file is where site-specific
settings go:

```gitconfig
[user]
    name = Your Name
    email = you@example.com
[include]
    path = /path/to/site/gitconfig
[safe]
    directory = /path/to/shared/repo
[http]
    proxy = HTTPS://proxy.example.net:3128
```

**Fill in `~/.bash_aliases.local`** if you want the `docker_bash` alias; it is
only defined when `DOCKER_IMAGE` is set there.

**Put `bin/` on your `PATH`** if you want those scripts. `am-vnc` and
`am-x11` additionally need `VNC_HOST` / `X11_HOST` set.

**Pick a theme.** X resources:

```sh
xrdb -merge ~/.dotfiles/themes/xresources/solarized-dark
```

The files under `themes/putty/` are Windows registry exports; import them on
the Windows side.

**Pick a font** in your terminal — one of the Powerline/Nerd faces installed
in step 2. The statusline and lint indicators need one.

**Run `:ObsessionHere` once per project** in nvim if you want tmux-resurrect
to restore that pane's splits and buffers.

## Make targets

| target | does |
|---|---|
| `install` | links `home/`, seeds `skel/`, refreshes fonts, installs tmux plugins |
| `links` | links and seeds only |
| `plugins` | tmux plugins only |
| `libs` | builds every tool into `$(PREFIX)` |
| `<tool>` | builds one: help2man automake ncurses libevent htop tmux neovim |
| `st` | builds the st terminal from `st/config.h` |
| `libs-clean` | drops build stamps so `make libs` rebuilds |

## Building tools from source

For hosts with no root access. Packages are built into `~/usr/local`
(`PREFIX`) from sources unpacked in `~/work/src/tmp` (`SRC_DIR`). Each is
tracked by a stamp file, so an interrupted run resumes instead of starting
over, and prerequisites are declared — tmux waits for libevent, ncurses and
automake — so `make -j` is safe.

```sh
make libs
make tmux
make libs PREFIX=/some/other/prefix
```

Add `~/usr/local/bin` to `PATH` to use what it builds.

`make st` builds the suckless terminal, copying `st/config.h` into the source
tree first. It is deliberately not part of `make libs`: st needs X11, Xft and
fontconfig headers, which cannot be built here, and a host without them
should not fail the whole run.

## tmux and vim

Prefix is `C-s`. `C-h/j/k/l` move between panes and pass through to vim when
the pane is running it; the vim half lives in
[sivim](https://github.com/zkalves/sivim).

tmux-resurrect saves sessions, continuum auto-saves every 15 minutes, and
`lib/tmux-resurrect-central.sh` is a custom restore strategy that keeps vim
session files in `~/.local/share/nvim-sessions/<git work tree>/` instead of
writing a `Session.vim` into each project. Its path convention is mirrored by
`s:SessionFile()` in sivim's `init.vim` — change one and you must change the
other.

## Uninstalling

There is no uninstall target. Remove the symlink and restore the backup:

```sh
rm ~/.bashrc && mv ~/.bashrc.bk.0 ~/.bashrc
```

The `.local` files in `$HOME` are copies, not symlinks, so they survive.

## Note

Inside a Claude Code session the sandbox bind-mounts `/dev/null` over
repo-root config files, which then appear as phantom untracked entries.
`git add -A` fails on them; add by explicit path instead.
