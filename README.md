# dotfiles

ergofriend の macOS 向け個人 dotfiles。[chezmoi](https://www.chezmoi.io/) と [mise](https://mise.jdx.dev/) で管理。

## 構成

- `.chezmoiroot` — chezmoi のソースディレクトリを `home/` に指定
- `home/` — chezmoi 管理下のファイル群。`$HOME` を chezmoi の命名規約 (`dot_*` など) でミラー
- `home/run_once_after_install-mise.sh` — `chezmoi apply` 後に1回だけ実行され、mise 本体と `~/.config/mise/config.toml` で宣言したツールをインストール

## 新マシンでの初期セットアップ

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ergofriend
```

このコマンド1つで chezmoi のインストール、このリポジトリの clone、ファイル配置、mise インストールフックの実行までを行う。

## 日常的に使うコマンド

| やりたいこと | コマンド |
|---|---|
| repo と `$HOME` の差分を確認 | `chezmoi diff` |
| repo の内容を `$HOME` に反映 | `chezmoi apply` |
| `$HOME` 側の変更を repo に取り込み | `chezmoi re-add` |
| mise 設定のツールをインストール/更新 | `mise install` |
