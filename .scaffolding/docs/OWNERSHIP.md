# `.scaffolding/docs/` 歸屬清單

ADR 0014 把三倉拆分時，`.scaffolding/docs/` 下的 25 份文件**預設**留在 ai-zpd，理由記在該 ADR 的 consequences：「沒有乾淨的單一 repo 擁有者」，並註明若發現屬於他處要重新檢討。本檔是那次檢討的結果（[#8](https://github.com/matheme-justyn/ai-zpd/issues/8)、[ADR 0019](adr/0019-scaffolding-docs-ownership.md)）。

新增文件到 `.scaffolding/docs/` 時請一併在此登錄擁有層與理由。

## 留在 ai-zpd（原 25 份中的 7 份，加上後來新增的 1 份）

這些描述的是安裝／執行機制——ai-zpd 在 ADR 0014 下的職責範圍。

| 文件 | 為什麼屬於機制層 |
| --- | --- |
| `MCP_SETUP_GUIDE.md` | MCP server 設定是執行期機制的一部分 |
| `OPENCODE_SETUP_GUIDE.md` | OpenCode 專案資料庫設定，執行期機制 |
| `POST_INSTALL_CLEANUP.md` | 安裝後清理流程 |
| `MIGRATION_GUIDE.md` | 1.x → 2.0.0 升級路徑 |
| `MIGRATION_GUIDE_V3.md` | 2.x → 3.0.0 升級路徑，`smart-install.sh` 仍引用 |
| `QUICK_UPDATE.md` | 既有專案的快速更新指示 |
| `PRD-claude-code-inspired-upgrades.md` | OpenCode 進階功能的設計文件，主題屬機制層 |
| `CONFIG_LAYERS.md` | **後來新增**（[#9](https://github.com/matheme-justyn/ai-zpd/issues/9)）。向使用者說明兩層設定檔的職責邊界。寫在本層是因為使用者是從本層的安裝流程進入的；骨架層另有自己角度的 `.scheme/README.md` |

兩份 migration guide 與 `QUICK_UPDATE.md` 是舊版專案唯一的升級路徑，所以留著。它們的退場條件是 `ai-scheme` 的 `adopt` 生命週期指令落地後接手同一件事——屆時應重新檢討，不是無限期保留。

## 提交給 ai-skill-web（5）

內容屬能力層。**本層只負責提出，接不接由該 repo 決定**，所以在對方接收前檔案仍留在這裡。

| 文件 | 依據 |
| --- | --- |
| `PRD-next-gen-sdd-integration.md` | SDD 內容，SDD 已隨 ADR 0014 遷往 ai-skill-web |
| `PRD-seamless-sdd-integration.md` | 同上 |
| `ONBOARDING_GUIDE.md` | 文件模組格式（`**Status**: Active \| Domain: Collaboration`） |
| `PRODUCTION_READINESS.md` | 文件模組格式（Domain: Quality），`quality = ["production"]` 指向它 |
| `TROUBLESHOOTING.md` | 文件模組格式（Domain: Quality） |

後三份的依據是：**文件模組這一整套已經在 ai-skill-web。** 該 repo 的 `docs/` 下有 `API_DESIGN.md`、`PERFORMANCE_OPTIMIZATION.md`、`ACCESSIBILITY_STANDARDS.md`、`AUTH_IMPLEMENTATION.md`、`REALTIME_PATTERNS.md`、`FILE_HANDLING.md` 等——正是 ai-zpd `config.toml.example` 的 `[modules]` 註解所指的那些檔案。留在這裡的三份是同一批東西的殘留，不是本層的內容。

## 提交給 ai-scheme（2）

`ai-scheme` 側已表示會收，但要求逐份決定，所以這裡只列清單與理由，不直接寫進對方 repo。

前兩份已在本次分類中從 `main` 刪除（commit `c8ca0d3`），內容取用方式：

    git show c8ca0d3^:.scaffolding/docs/RELEASE_PROCESS.md
    git show c8ca0d3^:.scaffolding/docs/SCAFFOLDING_DEV_GUIDE.md

| 文件 | 用途 | 判定屬骨架層的理由 | 對方掛在 |
| --- | --- | --- | --- |
| `RELEASE_PROCESS.md`（339 行，已刪除） | 版本號規則、發版步驟、tag 與 CHANGELOG 的關係 | 發版流程屬骨架層（ADR 0014）。`ai-scheme` #14 正在改寫該 repo 自己的 `docs/RELEASE_PROCESS.md`，本層這份的主題完全落在那個範圍內 | `ai-scheme` #14 |
| `SCAFFOLDING_DEV_GUIDE.md`（424 行，已刪除） | 如何開發與擴充模板本身：目錄慣例、加新模組、測試 | 「開發模板本身」在拆分後主要是骨架層的事——模板結構、CI、conventions 都在那裡。本層只剩安裝／執行機制 | `ai-scheme` #17 |

`TEMPLATE_SYNC.md` 對方看過後**不收**，已刪除。本清單原本把它記為「`sync-template.sh` 的使用說明」——**那是誤判**。實際內容從頭到尾是手動流程：比對版本號、把模板加成 remote、cherry-pick 選檔案、手動改版本號，全篇沒有提到 `sync-template.sh`。那條路正是 `status` → `next_command` → `update --plan` → `--apply-plan` 取代掉的東西，逐段對照沒有還活著的部分；它第 36 行還指向拆分前的 `my-vibe-scaffolding` releases 頁面。`sync-template.sh` 本身留著，由 AGENTS.md 說明。

`generate-pr-template.sh` 對方**不收**：PR 模板產製屬骨架層，但他們的做法是 CLI 產生器而不是 shell 腳本（`ai-scheme` #8 已交付單一結構的 `.github/PULL_REQUEST_TEMPLATE.md`，多語版本在 #36）。該腳本讀的 `.scaffolding/templates/pr/` 已不存在，因此直接刪除，不移交。`generate-readme.sh` 與 `sync-readme.sh` 同理，對方也不收（README 由 i18n 產生在 `ai-scheme` #36）。

## 已刪除（13）

內容保留在 git 歷史與 `.scaffolding/CHANGELOG.md`。

### 拆分前的一次性快照（8）

`DIRECTORY_RESTRUCTURE_2026-03-27.md`、`PHASE_1A_COMPLETION.md`、`PHASE_1B_COMPLETION.md`、`RELEASE_V3.0.0_SUMMARY.md`、`V3.0.0_RELEASE_NOTES.md`、`V3_INTEGRATION_SUMMARY.md`、`V3_PHASE1A_SUMMARY.md`、`MODE_GUIDE.md`

前七份記錄的是某個時點「做完了什麼」，描述的佈局已被三倉拆分取代；其中四份沒有任何其他檔案引用，其餘的引用者也都在這一批之內——它們互相引用，形成一個沒有外部入口的集合。`MODE_GUIDE.md` 說明的是 `[project].mode`，該鍵已於 ADR 0016 移除。

### 被拆分本身取代（5）

| 文件 | 理由 |
| --- | --- |
| `FEATURES.md` | 橫跨三層的功能總覽，徽章停在 3.0.0，描述的 skills／agents 已遷往 ai-skill-web。拆分後沒有任何一個 repo 能正確擁有「整包的功能清單」 |
| `PRD.md` | 拆分前整包的產品需求（v1.0.0，2026-03-03） |
| `RELEASE_PROCESS.md` | 發版流程屬骨架層（ADR 0014）。`ai-scheme` #14 正在改寫該 repo 自己的 `docs/RELEASE_PROCESS.md`，本層這份不需移交也不應保留 |
| `SCAFFOLDING_DEV_GUIDE.md` | 「如何開發 my-vibe-scaffolding」——那個單一 repo 已不存在，開發指引現在分屬三層各自的 AGENTS.md |
| `TEMPLATE_SYNC.md` | 手動同步流程，已被 `status` → `update --plan` → `--apply-plan` 取代。`ai-scheme` 逐段看過後表示沒有需要接收的部分 |

## 尚未解決：`[modules]` 指向另一個 repo 的內容

ai-zpd 的 `config.toml.example` 以 `[modules]` 設定要載入哪些文件模組，但那些模組檔案在 ai-skill-web。`always_enabled` 目前列的五個（`STYLE_GUIDE`、`TERMINOLOGY`、`GIT_WORKFLOW`、`TESTING_STRATEGY`、`SECURITY_CHECKLIST`）在本 repo **一份都不存在**。

ADR 0015 定義了 ai-zpd 與 ai-scheme 之間的設定邊界，沒有涵蓋 ai-zpd 與 ai-skill-web 之間的這一條：機制層持有選擇器，能力層持有被選的內容。本次分類把它揭露出來，但不在 #8 的範圍內解決——那需要兩層一起決定，不是單方面分類文件能處理的。
