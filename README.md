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

その後、マシン固有の git ユーザー情報を `~/.gitconfig.local` に作成する：

```sh
cp gitconfig.local.example ~/.gitconfig.local
chmod 600 ~/.gitconfig.local
$EDITOR ~/.gitconfig.local   # name / email / signingkey を埋める
```

`~/.gitconfig` から `[include]` で読み込まれ、署名コミットが有効になる。

## 日常的に使うコマンド

| やりたいこと | コマンド |
|---|---|
| repo と `$HOME` の差分を確認 | `chezmoi diff` |
| repo の内容を `$HOME` に反映 | `chezmoi apply` |
| `$HOME` 側の変更を repo に取り込み | `chezmoi re-add` |
| mise 設定のツールをインストール/更新 | `mise install` |

## ghq clone を chezmoi のソースにする（任意）

普段 ghq で repo を扱う場合、chezmoi のデフォルト clone (`~/.local/share/chezmoi`) ではなく ghq clone を直接ソースにできる。

```sh
# bootstrap 後に実行
ghq get ergofriend/dotfiles
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<EOF
sourceDir = "$HOME/Documents/dev/github.com/ergofriend/dotfiles"
EOF
rm -rf ~/.local/share/chezmoi
chezmoi diff   # 動作確認
```

以降 `chezmoi *` は ghq clone を見るので、編集 → `git push` までが1つの clone で完結する。

なお `GHQ_ROOT` は `home/dot_config/mise/config.toml` の `[env]` で `$HOME/Documents/dev` に固定してあるので、新マシンでも同じパスに clone される。
