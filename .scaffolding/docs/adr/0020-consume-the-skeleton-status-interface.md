# ADR 0020: 骨架層狀態一律用 `ai-scheme status --json` 取得

- **狀態**: Accepted
- **日期**: 2026-09-09
- **決策者**: repo owner
- **相關**: [ADR 0014](0014-repo-split-ai-scheme-ai-zpd-ai-skill-web.md)、[ADR 0015](0015-two-config-files-ai-scheme-ai-zpd.md)、[ADR 0016](0016-single-version-source-scaffolding-version.md)、[#5](https://github.com/matheme-justyn/ai-zpd/issues/5)、`ai-scheme` [#4](https://github.com/matheme-justyn/ai-scheme/issues/4)
- **外部契約**: `ai-scheme` 的 `docs/status-interface-contract.md`

## 脈絡

ADR 0014 把三倉拆分後，依賴方向是單向的：ai-zpd 呼叫 ai-scheme 的 CLI，ai-scheme 不知道 ai-zpd 存在。唯一介面是 `ai-scheme status --json`。

本層原本的 `init-project.sh` 以 `.template-version` 是否存在來判斷 install／update，而 AGENTS.md 與 `.opencode/INSTALL.md` 都以「一個指令涵蓋所有情境」為賣點。拆分後這個說法不再成立——那一個指令涵蓋的是機制層，骨架層完全沒被涵蓋。

## 過程中修正的一個誤解

`ai-scheme` 契約初版的第 4 條寫「Never infer a state from the filesystem, from `.template-version`, from a `VERSION` file」，第 8 節寫 legacy sentinel「never takes part in a version comparison」。照字面遵守，本層會失去判斷**自己**那條軸的能力。

本層據此提出：版本是兩條軸，契約只涵蓋一條。

- **骨架軸**——CI、policies、conventions、release flow，版本記在 `.scheme/config.yml`，由 `ai-scheme status` 回答。
- **機制軸**——本層的 agent 工具與交付目錄，版本記在 `.template-version`（來源 `.scaffolding/VERSION`），由本層回答。

`ai-scheme` 採納並修改契約（其 #41／PR #44）：第 4 條限定為只約束骨架層，新增「Two version axes」一節，明寫 `.template-version` 與 `.scaffolding/` 屬機制層、是**現行**不是殘留，且該層無從知道機制層的 target 版本因此不回答那條軸。

同時移除了 `migrate` 狀態。本層原本只指出它的措辭把 `.scaffolding/` 說成 previous layout 與 ADR 0015 的兩層並存矛盾；對方判斷問題更深——那個狀態的觸發條件偵測到的其實是「另一層裝好了」，而骨架層在此之前沒有交付過任何前身，沒有可以 migrate 的東西。沒有 answers 檔的專案一律 `adopt`。

## 決策

**骨架層的狀態一律向 `ai-scheme status --json` 取得，原樣轉述，不推測。機制層讀自己的版本檔。**

實作：

1. 新增 `.scaffolding/scripts/scheme-status.sh`，包裝該查詢並轉成可讀報告。
2. `init-project.sh` 在做自己的事之前先執行它並印出結果。
3. AGENTS.md 的統一 prompt 與 `.opencode/INSTALL.md` 改寫成兩軸兩指令，並標明順序。

### 三件刻意不做的事

- **不猜。** `ai-scheme` 未安裝、或 `status` 以 exit `2` 表示答不出來時，報告就是「不知道」。沒有答案不是自行推導答案的許可。
- **不代跑 `next_command`。** 每個 lifecycle 指令都先產生 plan，而 plan 是給人看的。腳本印出指令，不執行。
- **不把 `"unknown"` 讀成 `[]`。** `drift` 與 `policy_drift` 回 `"unknown"` 表示檢查跑不起來。當成「沒有差異」等於宣稱一件沒人驗過的事。

### 骨架層查詢失敗不阻擋機制層

兩條軸互相獨立，所以 `scheme-status.sh` 的非零結束不會中斷 `init-project.sh`。但也不會被靜靜吞掉——訊息一定會印出來。

## 後果

- 「一個指令涵蓋所有情境」這個賣點在文件中改為「一個指令涵蓋這一條軸」。這是準確度換取的簡潔度損失，值得。
- 本層對 `ai-scheme` CLI 產生一個軟相依：未安裝時功能不失效，但骨架層狀態就是未知。這符合單向依賴——ai-zpd 呼叫 ai-scheme，反之不成立。
- exit code `3`（CLI 未安裝）是本層自己的碼，不在契約內。契約只定義 `0`／`1`／`2`。
- `scheme-status.sh` 依賴 `python3` 解析 JSON。本 repo 的 CI 已經要求 `python3`（`config.toml.example` 的 TOML 驗證），所以不是新的相依。

## 替代方案

**在 `init-project.sh` 內直接解析 JSON。** 否決：那會把契約的細節（`"unknown"` 的處理、exit code 的語意、不代跑 `next_command`）散在一支已經很長的腳本裡，而這些正是最容易被下一個人簡化掉的部分。獨立成一支腳本讓它們有一個可指認的位置。

**自動執行 `next_command`。** 否決：違反契約第 3 條（plan 先於 apply），而且那是另一層的生命週期，本層代為決定等於把單向依賴變成代理執行。
