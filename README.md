# dotfiles

ergofriend の個人 dotfiles。chezmoi で配置し、mise で日常ツールを揃える。
Nix/Home Manager は必要になったものから段階的に寄せる。

## Setup

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ergofriend
```

初回 `chezmoi apply` 後に mise と agent tooling をセットアップする。
Nix は大きめのシステム変更なので自動では入れず、必要なタイミングで手動インストールする。
SkillSpector は Nix 導入後に `mise run install-skillspector` でセットアップする。
Obsidian Desktop は任意で、`mise run agent-tool` は agent 向けの Obsidian skills を設定する。

```sh
cd "$(dirname "$(chezmoi source-path)")"
mise run install-nix
mise run install-skillspector
```

## Windows / Git Bash

Windows native setup は Git Bash 前提で実行する。mise は winget で入れ、chezmoi は Git Bash から installer を実行する。

```powershell
winget install --id jdx.mise
```

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
chezmoi init --apply ergofriend
cd "$(cygpath -u "$(chezmoi source-path)")"
mise install
```

Git Bash の PATH、`GHQ_ROOT`、Windows の symlink 権限については [Tooling](docs/tooling.md) を参照する。Nix と SkillSpector は Linux/macOS 向けの repo root task として扱い、Windows ではまず `mise install` まで通す。
## Commands

`mise run ...` と `nix ... --flake .#...` は、この dotfiles repo root で実行する。

| Task | Command |
|---|---|
| `$HOME` に反映 | `chezmoi apply` |
| `$HOME` 側の変更を取り込み | `chezmoi re-add` |
| 差分を見る | `mise run diff` |
| mise tools を更新 | `mise install` |
| Nix を入れる | `mise run install-nix` |
| Home Manager を反映 | `nix --extra-experimental-features "nix-command flakes" run github:nix-community/home-manager -- switch --flake .#kasu-linux` |
| agent tooling / Obsidian skills を再設定 | `mise run agent-tool` |
| SkillSpector を入れる/更新 | `mise run install-skillspector` |

macOS の Home Manager entry は `.#kasu-darwin`。

## Layout

- `home/` — chezmoi source。`$HOME` を chezmoi 命名規約でミラー
- `home/dot_config/mise/` — global mise config と tasks
- `flake.nix` / `nix/home-manager/` — Home Manager の土台
- `scripts/bootstrap/` — 初回 bootstrap helper
- `tests/` — bootstrap smoke tests

## Notes

- [Tooling](docs/tooling.md)
