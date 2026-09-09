# ADR 0021: PR 控制面寫入一律經過 lease 協定

- **狀態**: Accepted
- **日期**: 2026-09-09
- **決策者**: repo owner
- **相關**: [ADR 0014](0014-repo-split-ai-scheme-ai-zpd-ai-skill-web.md)、[ADR 0020](0020-consume-the-skeleton-status-interface.md)、[#4](https://github.com/matheme-justyn/ai-zpd/issues/4)、`ai-scheme` [#19](https://github.com/matheme-justyn/ai-scheme/issues/19)
- **外部契約**: `ai-scheme` 的 `docs/lease-carrier.md`
- **協定文件**: [`../PR_LEASE_PROTOCOL.md`](../PR_LEASE_PROTOCOL.md)

## 脈絡

多個 agent session 各自在獨立 worktree 工作時，檔案是隔離的，但 GitHub 上的 PR 控制面是共用的。兩個 session 同時對同一張 PR 寫入會競速，而輸的一方**不會收到錯誤**——變更就是消失了。這是先前 POC 已知會出問題的地方。

依 `ai-scheme` ADR 0007 的邊界，這件事拆成兩張：載體（ref 命名空間、compare-and-swap、過期回收、`scan`）屬骨架層，因為它需要 repo 設定與 CI；協定（什麼必須持有 lease、拿不到時怎麼辦）屬本層，因為它管的是 agent session 之間的協調行為。

載體已於 2026-09-09 交付（`ai-scheme` PR #51）。本 ADR 記錄協定側的決定。

## 決策

**自動化對 PR 控制面的寫入一律經過 `.scaffolding/scripts/pr-lifecycle.sh`，而它先取得 lease。** 唯讀查詢不需要 lease。

以下五個決定各自解決一個具體的失效模式。

### 1. head 由本層重新讀取後宣告，不是把 lease 記錄的值宣告回去

載體比對的是「呼叫端宣告的 head」與「lease 記錄的 head」，而且**它從不問 GitHub**——一旦問了它就有了 PR 語意，那就不是載體了。

所以載體給的保證是「呼叫端無法在為另一個 head 取得的 lease 底下靜默作業」，**不是**「PR 前進時 lease 自動失效」。這兩者的差別是本層的責任所在：把 lease 自己記錄的值宣告回去，檢查每次都會通過，而分支早已前進。

因此每次寫入前重讀 `gh pr view --json headRefOid` 並宣告該值；`merge` 在讀完 review、checks 與 merge state **之後再驗一次**，因為那幾次查詢期間分支可能前進。

drift fixture 因此測的是**本層有沒有去問**，不只是載體會拒絕不符的 head——後者只證明載體。

### 2. 拿不到 lease 時沒有「靜默略過」

`--on-conflict` 三個值 `report`／`wait`／`abort`，共同點是不寫入且結束碼非 0。呼叫端不能把「沒拿到 lease」誤讀成「做完了」。

### 3. 兩種「空」都不算通過

`merge` 停在 human-only 的條件包含兩種容易被當成 pass 的空值：

- **review decision 為空**——可能是分支要求 review 而它還沒發生，也可能是欄位取不到。兩者都不是 approved。
- **完全沒有 checks 回報**——這與「checks 沒能回報」在此分辨不出來。

`mergeStateStatus` 為 `UNKNOWN` 或空同理。**unknown 不是 yes。** 這是本 repo 這一輪反覆出現的同一個錯誤形狀（ADR 0020 的 `drift: "unknown"` 不得讀成 `[]`），在這裡的第三次出現。

### 4. exit code 沿用骨架層的三分法

`0` 完成、`1` 明確的否定、`2` 答不出來。`2` 不會被降級成「沒事做」，也不會被重試——重試一個答不出來的問題只會得到同一個答不出來。

### 5. capability 不落地

`acquire` 回傳的 capability 只存在於單次執行的行程記憶體，`trap ... EXIT` 保證無論怎麼離開都 `release`。

代價是無法跨行程持有 lease。這是刻意的：能跨行程持有就要把 capability 寫進檔案系統，而那是一個沒人在管生命週期的憑證。TTL 只保證 lease 會過期，不保證那個檔案會消失。

## 本層的保證是有條件的

`pr-lifecycle.sh` 保證**經過它**的寫入持有 lease。「所有寫入都經過它」這件事由骨架層的 `scripts/lease.py scan` 在其 static stage 強制，例外走該層的 `policies/lease-exceptions.json`。

**本層不重複實作那份掃描。** 同一個不變量有兩個實作，遲早會有一個是錯的而沒人發現——這正是 `check-version-sync.sh` 的下場（ADR 0016）。

代價是：在沒有採用骨架層的專案裡，沒有東西阻止未來新增的腳本繞過 `pr-lifecycle.sh`。這個殘餘缺口寫在協定文件裡，不假裝不存在。

## 替代方案

**在每個呼叫點各自取得 lease。** 否決：那會讓「什麼算 PR 控制面寫入」散落在各處，而該判斷正是最容易在下一次新增功能時被漏掉的部分。集中在一支指令，缺口就只有「有沒有走這支指令」一個。

**merge 前沿用先前的條件判斷。** 否決：那些判斷是在取得 lease 之前做的，也就是關於另一個時刻的判斷。lease 的意義正是「在這段期間內狀態是我看到的那樣」，在它之外做的判斷不在那段期間內。

**本層自己實作 `scan`。** 否決：見上。
