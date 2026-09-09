# PR 控制面的 lease 協定

Worktree 隔離的是檔案。它不隔離 pull request 的控制面——ready／draft、label、milestone、merge 都在 GitHub 上，同一張 PR 的每個 session 共用。兩個 session 同時寫入會競速，而輸的那一方的變更**不會有錯誤訊息，就是消失了**。

所以自動化對 PR 控制面的寫入一律經過 `.scaffolding/scripts/pr-lifecycle.sh`，而它會先取得 lease。

- **載體**（ref 命名空間、compare-and-swap、過期回收）屬骨架層：`ai-scheme` 的 `scripts/lease.py`，契約在該層的 `docs/lease-carrier.md`。
- **協定**（什麼必須持有 lease、拿不到時 agent 怎麼辦）屬本層，就是這一份。

決定記在 [ADR 0021](./adr/0021-pr-control-plane-lease-protocol.md)。

## 必須持有 lease 的操作

| 操作 | 指令 |
| --- | --- |
| 標記 ready | `pr-lifecycle.sh ready --pr <n>` |
| 退回 draft | `pr-lifecycle.sh draft --pr <n>` |
| 增刪 label | `pr-lifecycle.sh label --pr <n> --add <l> [--remove <l>]` |
| 設定 milestone | `pr-lifecycle.sh milestone --pr <n> --set <m>` |
| 合併 | `pr-lifecycle.sh merge --pr <n> [--method squash\|merge\|rebase]` |

**agent 不得直接呼叫 `gh pr ready`、`gh pr edit`、`gh pr merge`，或對 `/pulls/` 發 REST `PATCH`／GraphQL mutation。**

## 唯讀，不需要 lease

`gh pr view`、`gh pr list`、`gh pr checks`、`gh pr diff` 以及任何只讀取的查詢。讀取不會覆蓋別人的寫入，加 lease 只會製造沒有必要的競爭。

留言（`gh pr comment`）也不需要：留言是累加的，不會覆寫既有內容。

## 拿不到 lease 時

`--on-conflict` 三選一，**沒有「靜默略過」這個選項**：

| 值 | 行為 |
| --- | --- |
| `report`（預設） | 回報別人持有，不寫入，以 exit `1` 結束 |
| `wait` | 每 5 秒重試，最多 `--wait-seconds`（預設 120）；逾時仍以 exit `1` 結束 |
| `abort` | 立即以 exit `1` 結束 |

三者的共同點是**不會寫入**，而且結束碼不是 0。呼叫端不能把「沒拿到 lease」誤讀成「做完了」。

## Exit code

沿用骨架層的三分法：

| Code | 意義 |
| --- | --- |
| `0` | 完成 |
| `1` | 明確的否定：別人持有、head 前進、merge 條件不成立 |
| `2` | 答不出來：`gh` 失敗、載體不存在或無法解讀 |

`2` **不會**被降級成「沒事做」。答不出來與沒有事情不是同一件事，而 lease 的整個用意就是阻止自動化依據自己證明不了的信念行動。

## head 前進的處理，以及為什麼責任在本層

載體比對的是「呼叫端**宣告**的 head」與「lease **記錄**的 head」。**它從不問 GitHub**——一旦問了它就有了 PR 語意，那就不是載體而是協定了。

所以載體給的保證是：**呼叫端無法在為另一個 head 取得的 lease 底下靜默作業。**

它**不是**「PR 前進時 lease 自動失效」。

差別在於：如果本層把 lease 自己記錄的值宣告回去，檢查每次都會過，而分支早已前進。因此 `pr-lifecycle.sh` 每次寫入前都重新讀取 live head（`gh pr view --json headRefOid`）並宣告那個值；`merge` 在讀完 review、checks 與 merge state 之後會**再驗一次**，因為那幾次查詢期間分支可能前進。

head 變了就是另一份工作：釋放 lease，重新取得，重新驗證條件。不沿用先前的判斷。

## merge 的條件，以及什麼時候停在 human-only

`merge` 在持有 lease 且 head 未變的情況下重讀三件事：

1. `reviewDecision` 必須是 `APPROVED`。
2. `statusCheckRollup` 的每一項必須是 `SUCCESS`／`NEUTRAL`／`SKIPPED`。
3. `mergeStateStatus` 必須是 `CLEAN`——這是生效中 Ruleset 的判定結果。

任何一項**不成立或無法判定**都停在 human-only，不猜測、不重試繞過。特別是兩種「空」：

- **review decision 為空**——可能是分支要求 review 而它還沒發生，也可能是欄位取不到。兩者都不是 approved。
- **完全沒有 checks 回報**——這與「checks 沒能回報」在這裡分辨不出來，所以不當成通過。

`mergeStateStatus` 為 `UNKNOWN` 或空同理：GitHub 還沒算出來，不代表答案是可以。**unknown 不是 yes。**

## capability 不落地

`acquire` 回傳的 capability 只存在於單次執行的行程記憶體中，永遠不寫入檔案系統。一次操作一個行程，`trap ... EXIT` 保證無論怎麼離開（成功、拒絕、當掉）都會 `release`。

代價是無法跨行程持有 lease。這是刻意的：能跨行程持有就要把 capability 落地，而落在檔案系統上的 capability 是一個沒人在管生命週期的憑證。

**載體並不禁止落地。** 它的假設只有一條：誰出示 capability，誰就持有 lease；沒有長駐行程的預期。所以這是本層的選擇，不是契約的限制——記在這裡是為了讓之後想改的人知道那扇門沒有鎖，以及要付什麼代價才走得過去。

骨架層目前**沒有 capability 輪替機制，也沒有規劃**；若要加，該層會先通知本層再動，因為那會改變儲存形狀。本層現在不存，所以那個變更對這裡是零成本——這也是不落地的一個附帶好處。

行程異常結束而沒有 `release` 的情況，靠的是 TTL 過期後被回收，不是靠載體清理。

## 遠端模式、權限與時鐘

本層**預設 `--remote origin`**，本機 ref 是明確選擇的最佳化。理由：要保護的資源是 GitHub 上的 PR 控制面，本機 ref 只在所有寫入者都在同一台機器時才真的互斥，而 agent session 可能在不同機器或雲端執行。骨架層的載體預設本機——那是對的，載體不該替呼叫端決定風險模型。

兩個由此而來的限制：

**權限。** 持有 remote lease 需要 push 權限；唯讀 token 只能 `inspect`。取得失敗時本層 fail closed——證明不了持有，就等於沒持有，不寫入。

**時鐘。** `expires_at` 是**取得端**時鐘的 Unix 秒，而判斷是否過期用的是**觀察端**的時鐘。兩台機器差 30 秒就可能不同調。compare-and-swap 仍然擋得住雙重持有（輸的一方無論如何都被拒），所以這不是正確性問題，但錯誤訊息可能出現讀起來很怪的剩餘秒數。**`--ttl` 應設得比預期的時鐘偏移寬裕**，預設 300 秒就是為此；載體不同步時鐘，也不假裝有。

## 不走 lease 的自動化

有些 PR 寫入不是 agent 發起的，也不會取得 lease：

| 來源 | 為什麼不走 lease |
| --- | --- |
| dependabot auto-merge | GitHub 原生功能，在 GitHub 內執行，不經過本層任何程式碼。無處插入 lease 取得。 |
| release-please | 在 workflow 內以 GitHub App 身分寫入版本 PR。它與 agent session 不會爭用同一張 PR——它建立並只操作自己的版本 PR。 |
| 分支保護與 Ruleset 的自動行為 | 由 GitHub 執行，不是呼叫端。 |

這些例外**不由本層維護**。骨架層的 `scripts/lease.py scan` 掃描未經 lease 的寫入並 fail closed，例外走該層 `policies/lease-exceptions.json` 的精確路徑加 tracking issue 編號（沒有 glob）。本層不重複實作那份清單——同一個不變量有兩個實作，遲早會有一個是錯的而沒人發現。

**因此本層的保證是有條件的**：`pr-lifecycle.sh` 保證*經過它*的寫入持有 lease；「所有寫入都經過它」這件事由骨架層的 `scan` 在它的 static stage 強制。骨架層未被採用的專案裡，後者不存在。
