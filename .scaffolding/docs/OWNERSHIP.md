# `.scaffolding/docs/` 歸屬清單

ADR 0014 把三倉拆分時，`.scaffolding/docs/` 下的 25 份文件**預設**留在 ai-zpd，理由記在該 ADR 的 consequences：「沒有乾淨的單一 repo 擁有者」，並註明若發現屬於他處要重新檢討。本檔是那次檢討的結果（[#8](https://github.com/matheme-justyn/ai-zpd/issues/8)、[ADR 0019](adr/0019-scaffolding-docs-ownership.md)）。

新增文件到 `.scaffolding/docs/` 時請一併在此登錄擁有層與理由。

## 留在 ai-zpd（8）

這些描述的是安裝／執行機制——ai-zpd 在 ADR 0014 下的職責範圍。

| 文件 | 為什麼屬於機制層 |
| --- | --- |
| `MCP_SETUP_GUIDE.md` | MCP server 設定是執行期機制的一部分 |
| `OPENCODE_SETUP_GUIDE.md` | OpenCode 專案資料庫設定，執行期機制 |
| `TEMPLATE_SYNC.md` | `sync-template.sh` 的使用說明，安裝／更新機制 |
| `POST_INSTALL_CLEANUP.md` | 安裝後清理流程 |
| `MIGRATION_GUIDE.md` | 1.x → 2.0.0 升級路徑 |
| `MIGRATION_GUIDE_V3.md` | 2.x → 3.0.0 升級路徑，`smart-install.sh` 仍引用 |
| `QUICK_UPDATE.md` | 既有專案的快速更新指示 |
| `PRD-claude-code-inspired-upgrades.md` | OpenCode 進階功能的設計文件，主題屬機制層 |

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

## 已刪除（12）

內容保留在 git 歷史與 `.scaffolding/CHANGELOG.md`。

### 拆分前的一次性快照（8）

`DIRECTORY_RESTRUCTURE_2026-03-27.md`、`PHASE_1A_COMPLETION.md`、`PHASE_1B_COMPLETION.md`、`RELEASE_V3.0.0_SUMMARY.md`、`V3.0.0_RELEASE_NOTES.md`、`V3_INTEGRATION_SUMMARY.md`、`V3_PHASE1A_SUMMARY.md`、`MODE_GUIDE.md`

前七份記錄的是某個時點「做完了什麼」，描述的佈局已被三倉拆分取代；其中四份沒有任何其他檔案引用，其餘的引用者也都在這一批之內——它們互相引用，形成一個沒有外部入口的集合。`MODE_GUIDE.md` 說明的是 `[project].mode`，該鍵已於 ADR 0016 移除。

### 被拆分本身取代（4）

| 文件 | 理由 |
| --- | --- |
| `FEATURES.md` | 橫跨三層的功能總覽，徽章停在 3.0.0，描述的 skills／agents 已遷往 ai-skill-web。拆分後沒有任何一個 repo 能正確擁有「整包的功能清單」 |
| `PRD.md` | 拆分前整包的產品需求（v1.0.0，2026-03-03） |
| `RELEASE_PROCESS.md` | 發版流程屬骨架層（ADR 0014）。`ai-scheme` #14 正在改寫該 repo 自己的 `docs/RELEASE_PROCESS.md`，本層這份不需移交也不應保留 |
| `SCAFFOLDING_DEV_GUIDE.md` | 「如何開發 my-vibe-scaffolding」——那個單一 repo 已不存在，開發指引現在分屬三層各自的 AGENTS.md |

## 尚未解決：`[modules]` 指向另一個 repo 的內容

ai-zpd 的 `config.toml.example` 以 `[modules]` 設定要載入哪些文件模組，但那些模組檔案在 ai-skill-web。`always_enabled` 目前列的五個（`STYLE_GUIDE`、`TERMINOLOGY`、`GIT_WORKFLOW`、`TESTING_STRATEGY`、`SECURITY_CHECKLIST`）在本 repo **一份都不存在**。

ADR 0015 定義了 ai-zpd 與 ai-scheme 之間的設定邊界，沒有涵蓋 ai-zpd 與 ai-skill-web 之間的這一條：機制層持有選擇器，能力層持有被選的內容。本次分類把它揭露出來，但不在 #8 的範圍內解決——那需要兩層一起決定，不是單方面分類文件能處理的。
