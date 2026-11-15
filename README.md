# dotfiles

macOS configuration shared across machines.

## Setup on a new Mac

```sh
git clone git@github.com:kzmsh/dotfiles ~/go/src/github.com/kzmshx/dotfiles
cd ~/go/src/github.com/kzmshx/dotfiles
./init.sh
```

`init.sh` symlinks every entry in `mapping.json` (requires `jq`). Pull to update; the links keep pointing at the repo.

## u

`bin/u` is linked to `~/.local/bin/u`.

| Command | What it does |
| :- | :- |
| `u` | Update Homebrew, Volta (Node / npm / pnpm 11 and global packages), uv, Rust, Deno, Bun, gcloud; list macOS updates |
| `u clean` | Show cache sizes and delete the ones you confirm |
| `u clean -n` | Show cache sizes only |
| `u clean -y` | Delete every cache without asking |

Tools that are not installed are skipped. A failing step does not stop the rest; failures are listed at the end. The shell reminds you when `u` has not run for 30 days.

`u clean` only touches caches that are downloaded again on demand (Homebrew, uv, npm, pnpm, Bun, Go, Cargo, GHCup, Playwright / Puppeteer browsers, Xcode DerivedData, Docker). It uses each tool's own command where one exists.
