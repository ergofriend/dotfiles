# Tooling

## Roles

- chezmoi: dotfiles の配置とテンプレート管理
- mise: 更新頻度が高い CLI、agent tooling、Nix installer、task runner
- Nix/Home Manager: 再現性が必要な package や設定を段階的に管理

## Nix / Home Manager

Nix 本体は mise で導入した `github:NixOS/nix-installer` から入れる。
自動 bootstrap では実行しない。
以下のコマンドは dotfiles repo root で実行する。

```sh
cd "$(dirname "$(chezmoi source-path)")"
mise install
mise run install-nix
```

WSL/Linux:

```sh
nix --extra-experimental-features "nix-command flakes" run github:nix-community/home-manager -- switch --flake .#kasu-linux
```

macOS:

```sh
nix --extra-experimental-features "nix-command flakes" run github:nix-community/home-manager -- switch --flake .#kasu-darwin
```

## SkillSpector

[NVIDIA/SkillSpector](https://github.com/NVIDIA/skillspector) は mise task で導入する。
macOS と WSL/Linux の両方で `mise run install-skillspector` を使う。
Python、uv、git、make は Nix devShell (`.#skillspector`) から供給する。
`mise run install-skillspector` は dotfiles repo root で実行する。

既定では `$GHQ_ROOT/github.com/NVIDIA/skillspector` に clone/update して `.venv` へインストールする。
`GHQ_ROOT` が未設定なら `$HOME/Documents/dev/github.com/NVIDIA/skillspector` を使う。
`skillspector` コマンドは `$HOME/.local/bin/skillspector` へ symlink される。

```sh
cd "$(dirname "$(chezmoi source-path)")"
mise run install-skillspector
skillspector scan ./path/to/skill --no-llm
```

## Agent Plugins / Superpowers

Superpowers は APM ではなく、各 agent の標準 plugin CLI で管理する。
`mise run agent-tool` が次の標準 CLI を `mise exec` 経由で実行する。

```sh
codex plugin add superpowers@openai-curated
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers@superpowers-marketplace --scope user
claude plugin marketplace add kepano/obsidian-skills
claude plugin install obsidian@obsidian-skills --scope user
```

Codex CLI 版は標準 marketplace plugin としては hook を含まないため、APM 時代の古い Codex hook が残っていれば bootstrap 時に削除する。

## Obsidian

Obsidian Desktop は任意で、Home Manager ではインストールしない。
`mise run agent-tool` は [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) を `$GHQ_ROOT/github.com/kepano/obsidian-skills` に clone/update する。
Codex では `~/.codex/skills` に各 skill への symlink を張り、Claude Code では `obsidian@obsidian-skills` plugin を user scope で入れる。
これにより agent は Obsidian Markdown、Bases、JSON Canvas、利用可能な環境では Obsidian CLI を扱える。

`obsidian` コマンドは Obsidian Desktop 1.12+ が必要で、Obsidian 側で有効化する。

1. Obsidian を開く。
2. Settings > General を開く。
3. Command line interface を有効化する。
4. 表示される案内に従って CLI を登録する。

CLI は次で確認する。

```sh
obsidian help
```

## chezmoi sourceDir

`home/.chezmoi.toml.tmpl` により、`chezmoi init` 時に `sourceDir` は `$HOME/Documents/dev/github.com/ergofriend/dotfiles` に設定される。

`GHQ_ROOT` は `home/dot_config/mise/config.toml` の `[env]` で `$HOME/Documents/dev` に固定してある。
