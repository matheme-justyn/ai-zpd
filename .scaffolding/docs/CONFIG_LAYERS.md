# 你的專案裡為什麼有兩個設定檔

用了兩層的專案，根目錄會同時出現 `config.toml` 與 `.scheme/config.yml`。**這是設計，不是遷移沒做完。**

| 檔案 | 由哪一層擁有 | 格式 | 管什麼 |
| --- | --- | --- | --- |
| `config.toml` | 機制層（`ai-zpd`，本 repo） | TOML | 能力怎麼載入與執行：要載入哪些文件模組、OpenCode 設定、服務能力與 fallback |
| `.scheme/config.yml` | 骨架層（[`ai-scheme`](https://github.com/matheme-justyn/ai-scheme)） | YAML | repo 長什麼樣：專案識別、語言設定、分支策略、README 策略、治理階段、協作模式、可見性、選用功能 |

決定記在本層 [ADR 0015](./adr/0015-two-config-files-ai-scheme-ai-zpd.md) 與 `ai-scheme` ADR 0008。

## 三條規則

**兩層互不讀取對方的檔案。** `ai-zpd` 的腳本從不解析 `.scheme/config.yml`；`ai-scheme` 的 CLI 從不解析 `config.toml`。這不只是約定——是雙方實作出來的：`ai-scheme` 的 CLI 只保留一個常數指向 `config.toml` 的路徑，用來回報「偵測到機制層設定檔存在」，不讀內容。

**同名的鍵各自獨立，沒有 fallback。** 如果一個鍵在兩邊都出現，它們是不同的東西，兩個值各自成立。寫錯檔案不會有任何反應——這是刻意的：靜默相容會讓放錯位置的設定看起來像有效設定。

**偵測不等於讀取。** `ai-scheme status` 會回報你的專案有沒有機制層的設定檔（`mechanism_config_detected`）與交付目錄（`mechanism_layer_detected`），因為使用者應該知道自己專案裡有什麼。它不打開那些檔案，內容也不影響它的狀態判斷。

## 我該改哪一個？

問你要改的是什麼。

- 改**這個 repo 本身**的樣子——名稱、語言、分支策略、release 階段、要不要發布決策網站——改 `.scheme/config.yml`，然後跑 `ai-scheme config validate`。
- 改**agent 工具的行為**——載入哪些文件模組、OpenCode 怎麼跑、有哪些服務可用——改 `config.toml`。

不確定時，`ai-scheme config get <key>` 會告訴你那個鍵是不是骨架層的：不是的話它以 exit code `2` 加 `no such key` 回答。

## 鍵名為什麼看起來不像

兩層刻意避開會被誤讀成同一件事的名字。

本層的模組選擇鍵全部放在 `[modules]` 底下（[ADR 0017](./adr/0017-module-selection-keys-live-under-modules.md)）：`domain`、`features`、`quality`，加上 `always_enabled`／`manual_enabled`／`manual_disabled`。`[project]` 只留專案後設資料。

`domain` 原本叫 `[project].type`。改名有兩個理由：`type` 讀起來像在宣告專案的種類（一項後設資料），實際上是在選擇載入哪些文件模組（一個行為開關）；而它與骨架層的鍵近到會被誤讀成同一件事。骨架層那側對應的是 `languages`，而且該層同意不使用 `project_type` 這個拼法。

## 版本也是兩條軸

同一個道理延伸到版本。你的專案要跟上兩件事：

| 軸 | 涵蓋 | 版本記在 | 問誰 |
| --- | --- | --- | --- |
| 骨架 | CI、policies、conventions、release flow | `.scheme/config.yml` | `ai-scheme status --json` |
| 機制 | agent 工具與它的交付目錄 | `.template-version` | `./.scaffolding/scripts/init-project.sh` |

`init-project.sh` 會先印出骨架層的狀態再做自己的事，但它**不會代你執行**骨架層的 `next_command`——那些指令都先產生 plan，而 plan 是給人看的。細節見 [ADR 0020](./adr/0020-consume-the-skeleton-status-interface.md)。

`.template-version` 與 `.scaffolding/` 屬於機制層，是**現行**的東西，不是舊版殘留。

## 你可能還會看到的檔案

`ai-scheme` 建立或採用專案後，`.scheme/` 底下還會有：

- `README.md` — 該層對兩個設定檔的說明（與本頁互補，那份從骨架層的角度寫）。
- `provenance.json` — 這個專案是從哪一個 release 套用的：來源、tag、sha、套用時間、CLI 版本、attestation。`mode: development` 表示來源沒有釘 tag。

完整的鍵擁有權對照表在 `ai-scheme` 隨模板交付的 `docs/config-boundary.md`。

## 為什麼不合併成一個檔

考慮過三種做法：統一格式但分開放、合併成單一檔案再分區段、兩個檔案加一份寫清楚的邊界。

第三種勝出的理由是 Copier 原生就把 answers 寫成 YAML。合併成一個檔意味著其中一層要維護一個格式轉換層，而且兩層會在 `update` 期間寫同一個檔案——衝突處理本來就是最難的部分。

代價是你會看到兩個檔案。這一頁就是在付那個代價。
