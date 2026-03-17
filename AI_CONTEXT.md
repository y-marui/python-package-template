# AI_CONTEXT.md

> このファイルは Claude Code・GitHub Copilot など AI ツールが唯一参照するコンテキストファイルです。
> セッション開始時に必ず読み込んでください。

---

## プロジェクト概要

**目的:** AI支援開発用の Python パッケージ/アプリケーションテンプレート。
Poetry + Claude Code + GitHub Copilot 前提の OSS テンプレート。

**技術スタック:**

| 項目 | バージョン |
|------|-----------|
| Python | ^3.11 |
| Poetry | 最新安定版 |
| pytest | ^8 |
| ruff | ^0.3（linter / formatter, line-length=88） |
| mypy | ^1.8（strict モード） |

**主要ディレクトリ:**

```
src/project_name/   # パッケージ本体
tests/unit/         # 単体テスト
tests/integration/  # 統合テスト
ai/context/         # AI向け制約要約（毎回読み込む）
docs/               # 人間が書き・読む仕様書（AI は参照のみ）
docs/dev-charter/   # 開発憲章（git subtree で取り込み）
examples/           # 実装パターンサンプル
```

**モジュール構成と依存方向:**

```
API → Service → Repository
```
逆依存禁止。循環依存禁止。

**AI コンテキスト読み込み順序:**
1. `AI_CONTEXT.md`（このファイル）
2. `ai/context/`（全ファイル）
3. `docs/specification.md`（詳細が必要な場合のみ）
4. `docs/architecture.md`（詳細が必要な場合のみ）
5. `docs/guardrails.md`

---

## 適用する憲章原則

### コーディング前の確認

不明・未定の項目があれば**作業前に1回でまとめて**質問する。推測で進めない。

**確認必須:**
- ゴール（完了条件）
- 言語・FW・バージョン制約
- 新規 or 既存コード修正
- テストの要否・影響範囲

**確認不要（既存コードに合わせて進める）:**
- コードスタイル / ファイル配置 / 軽微な実装詳細

### コード設計原則

- **変更範囲は必要最小限**（Over-engineering しない）
- **YAGNI**: 今必要ない機能は実装しない
- **DRY の判断**: 2回の重複では抽象化しない、3回目で検討
- **既存コードの再利用**: 新規実装前に類似機能がないか確認
- **TODO/FIXME を残さない**: 実装するか、issue として記録する
- **既存コードのパターンに従う**: 命名規則・アーキテクチャ・ディレクトリ構造

### コーディングルール

- 可読性優先
- 関数は **50行以内**
- 単一責務
- コメントは「なぜそうするか」のみ。コードから自明な処理には書かない

### Git 運用

- **Conventional Commits** 形式（`feat` / `fix` / `refactor` / `docs` / `chore`）
- **WIP 禁止**: 動作しないコードはコミットしない
- コミット粒度: 機能単位・動作確認 OK 後

### エラー・デバッグ対応

- エラー発生時は **原因分析 → 修正方針説明 → 実装** の順で進める
- エラーログ・スタックトレースは必ず全文確認してから対応
- デバッグ用の `print` 文は本番コードに残さない

---

## プロジェクト固有ルール

### docs/ と ai/context/ の役割分担

| ディレクトリ | 役割 | AI の編集 |
|---|---|---|
| `docs/` | 人間が書き・読む詳細仕様書 | **禁止**（参照のみ） |
| `ai/context/` | AI向け制約要約。`docs/` と競合する場合は **こちらを優先** | 更新可 |

### CI / ローカル開発コマンド

```sh
make install   # poetry install
make lint      # ruff check .
make type      # mypy src
make test      # pytest
make all       # lint + type + test
```

CI（GitHub Actions）は push / PR のたびに `ruff check` → `mypy src` → `pytest` を実行。

### pre-commit フック（`.pre-commit-config.yaml`）

セキュリティ・品質チェックが自動で走る。以下が有効:

| フック | 内容 |
|---|---|
| gitleaks | シークレット検出（`.gitleaks.toml` 設定） |
| detect-private-key | SSH 秘密鍵検出 |
| detect-dotenv | `.env` ファイルのコミットをブロック |
| no-hardcoded-local-paths | ローカル絶対パスのハードコードをブロック |
| check-added-large-files | 500 KB 超ファイルをブロック |
| trailing-whitespace / end-of-file-fixer | 空白・改行の正規化 |
| check-yaml / check-json / check-merge-conflict | 構文・競合チェック |
| shellcheck | シェルスクリプト静的解析 |

セットアップ:

```sh
cp docs/dev-charter/.pre-commit-config.yaml .
cp docs/dev-charter/.gitleaks.toml .
pre-commit install   # core.hooksPath 未設定の場合
pre-commit run --all-files  # 動作確認
```

---

## AI ツール分担

| ツール | 担当範囲 |
|---|---|
| **Claude Code** | プロジェクト立ち上げ、大規模なコード変更、アーキテクチャ設計・リファクタリング提案 |
| **GitHub Copilot** | バグ修正、細かな実装・コーディング補助、単体テスト作成 |
| **Gemini CLI** | プライバシーポリシー作成・更新、ストア説明文、審査用ドキュメント、プロジェクト全体のドキュメント管理 |

**AI 並用時のルール:**
- Claude Code 作業中は Copilot 提案を**参考程度**に（盲目的に受け入れない）
- Copilot の提案がプロジェクト規約に反する場合は無視し、Claude Code でレビュー後に採用判断する
- Gemini CLI は自動読み込み不可。使用時に手動でコンテキストを渡すこと

---

## 禁止事項

### セキュリティ制約

- シークレット・API キー・パスワード・トークンを**絶対にコードに書かない**（環境変数または Secret Manager を使う）
- `.env` ファイルをコミットしない（ダミー値のみの `.env.example` をコミットする）
- SSH 秘密鍵・クラウドトークンをコミットしない
- ローカル絶対パス（`/Users/...`、`/home/...`、`C:\Users\...`）をコードにハードコードしない
- 500 KB を超えるファイルをコミットしない
- AI との会話ログをリポジトリにコミットしない
- **シークレットを含むファイルやコードを AI に渡さない**（プロンプト・コンテキスト・スクリーンショット含む）
- **AI が生成したコードは必ずレビューしてからコミットする**

### スコープ外変更の禁止

- **API 仕様変更禁止**: API レスポンス変更・エンドポイント削除（破壊的変更で他サービスに影響）
- **設計変更禁止**: ディレクトリ構造変更・モジュール移動（アーキテクチャの一貫性を保つため）
- **大規模リファクタ禁止**: 意図しない挙動変化を防ぐため（明示的に依頼された場合を除く）
- **依存追加禁止**: ライセンス・セキュリティリスクを人間がレビューするため。必要な場合は Issue を作成する
- **WIP コミット禁止**: 動作しないコードはコミットしない
- `docs/` ディレクトリを AI が直接編集しない（参照のみ）
