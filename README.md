# dotfiles

ergofriend の macOS 向け個人 dotfiles。[chezmoi](https://www.chezmoi.io/) と [mise](https://mise.jdx.dev/) で管理。

## 構成

- `.chezmoiroot` — chezmoi のソースディレクトリを `home/` に指定
- `home/` — chezmoi 管理下のファイル群。`$HOME` を chezmoi の命名規約 (`dot_*` など) でミラー
- `home/run_once_after_bootstrap.sh` — `chezmoi apply` 後に1回だけ実行され、mise/agent plugin/Codex hook などの tooling を初期化

## 新マシンでの初期セットアップ

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ergofriend
```

このコマンド1つで chezmoi のインストール、このリポジトリの clone、ファイル配置、mise インストールフックの実行までを行う。

初回実行時に、マシン固有の git ユーザー情報として `user.name`、`user.email`、署名用の `signingkey` を入力すると、`~/.gitconfig.local` が private file として生成される。push 用の SSH 認証鍵とは別の鍵を指定できる。

`~/.gitconfig` から `[include]` で読み込まれ、署名コミットが有効になる。

## 日常的に使うコマンド

| やりたいこと | コマンド |
|---|---|
| repo と `$HOME` の差分を確認 | `chezmoi diff` |
| repo の内容を `$HOME` に反映 | `chezmoi apply` |
| `$HOME` 側の変更を repo に取り込み | `chezmoi re-add` |
| mise 設定のツールをインストール/更新 | `mise install` |
| agent tooling を再設定 | `mise run agent-tool` |

## Agent Plugins / Superpowers

Superpowers は APM ではなく、各 agent の標準 plugin CLI で管理する。

新マシンでは `home/run_once_after_bootstrap.sh` により、`mise run bootstrap` が自動実行される。
`mise-tasks/agent-tool` が次の標準CLIを `mise exec` 経由で実行する。

```sh
codex plugin add superpowers@openai-curated
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers@superpowers-marketplace --scope user
```

手動で更新する：

```sh
mise run agent-tool
```

Superpowers の skills は Codex CLI と Claude Code の plugin 機構がそれぞれ配置する。
Claude Code 版は plugin に `SessionStart` hook も含まれる。
Codex CLI 版は標準 marketplace plugin としては hook を含まないため、APM 時代の古い Codex hook が残っていれば bootstrap 時に削除する。

## chezmoi の sourceDir

`home/.chezmoi.toml.tmpl` により、`chezmoi init` 時に `sourceDir` は `$HOME/Documents/dev/github.com/ergofriend/dotfiles` に設定される。

`GHQ_ROOT` は `home/dot_config/mise/config.toml` の `[env]` で `$HOME/Documents/dev` に固定してあるので、新マシンでも ghq clone と chezmoi source が同じパスになる。
