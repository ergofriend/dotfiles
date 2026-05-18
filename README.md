# dotfiles

ergofriend の macOS 向け個人 dotfiles。[chezmoi](https://www.chezmoi.io/) と [mise](https://mise.jdx.dev/) と [APM](https://github.com/microsoft/apm) で管理。

## 構成

- `.chezmoiroot` — chezmoi のソースディレクトリを `home/` に指定
- `home/` — chezmoi 管理下のファイル群。`$HOME` を chezmoi の命名規約 (`dot_*` など) でミラー
- `home/run_once_after_install-mise.sh` — `chezmoi apply` 後に1回だけ実行され、mise 本体と `~/.config/mise/config.toml` で宣言したツールをインストール
- `home/dot_apm/` — APM の user-scope manifest。Codex 向け Superpowers を管理

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
| APM 管理の agent tooling を再展開 | `apm install -g` |

## APM / Superpowers

`home/dot_apm/apm.yml` で `obra/superpowers#v5.1.0` を Codex target 向けに pin している。

新マシンでは `home/run_once_after_install-mise.sh` により、`mise install` 後に自動で APM 管理の内容も反映される。

手動で再展開する：

```sh
apm install -g
```

これにより Superpowers の skills/hooks が user scope に展開される。

## chezmoi の sourceDir

`home/.chezmoi.toml.tmpl` により、`chezmoi init` 時に `sourceDir` は `$HOME/Documents/dev/github.com/ergofriend/dotfiles` に設定される。

`GHQ_ROOT` は `home/dot_config/mise/config.toml` の `[env]` で `$HOME/Documents/dev` に固定してあるので、新マシンでも ghq clone と chezmoi source が同じパスになる。
