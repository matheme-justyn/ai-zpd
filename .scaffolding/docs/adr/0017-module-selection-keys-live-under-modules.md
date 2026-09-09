# ADR 0017: 選擇文件模組的鍵一律放在 `[modules]`

- **狀態**: Accepted
- **日期**: 2026-09-09
- **決策者**: repo owner
- **相關**: [ADR 0012](0012-config-driven-modular-documentation-system.md)、[ADR 0015](0015-two-config-files-ai-scheme-ai-zpd.md)、[#13](https://github.com/matheme-justyn/ai-zpd/issues/13)

## 脈絡

`config.toml` 的文件模組載入機制（ADR 0012）有六個輸入，原本分散在兩個區段：

| 原位置 | 鍵 | 作用 |
| --- | --- | --- |
| `[project]` | `type` | 選一組領域模組的預設集合 |
| `[project]` | `features` | 加上功能模組 |
| `[project]` | `quality` | 加上品質模組 |
| `[modules]` | `always_enabled` | 無條件載入 |
| `[modules]` | `manual_enabled` | 強制加上 |
| `[modules]` | `manual_disabled` | 強制移除 |

六個鍵是同一個機制的六個輸入，卻分成兩區，而且分法沒有規則可循——`features` 和 `manual_enabled` 都是「多載入哪些模組」，只是一個用領域詞彙、一個用模組名稱。

`type` 的名字另有問題。它讀起來像在宣告專案的種類（一項後設資料），實際上是在選擇載入哪些文件模組（一個行為開關）。註解自己就寫著「Project type determines which domain-specific modules load」——名字沒有說出這件事，要靠註解補。

ADR 0015 第 4 條還記了一個跨層約束：`ai-scheme` 同意避開 `project_type` 這個拼法，因為本層的 `[project].type` 已佔住該語意空間。兩層的鍵之間沒有 fallback，寫錯檔案不會有任何反應，所以近名歧義的代價是靜默的。

## 決策

**所有選擇文件模組的鍵移入 `[modules]`，`[project]` 只保留專案後設資料。**

`[project].type` 同時改名為 `[modules].domain`。值不變（`frontend` | `backend` | `fullstack` | `cli` | `library` | `academic` | `documentation` | `translation` | `other`）。

改後的形狀：

```toml
[project]
# name / description / version — 後設資料，不影響模組載入

[modules]
domain   = "fullstack"   # 選哪一個領域的模組
features = [...]         # 加上功能模組
quality  = [...]         # 加上品質模組
always_enabled  = [...]
manual_enabled  = [...]
manual_disabled = [...]
```

`domain` 這個名字說的是「哪一個領域」，而模組是按領域分組的，所以它指向的是分組本身，不是專案的身分。

## 為什麼不只改 `type` 的名字

只改一個鍵會讓 `config.toml` 更難讀，不是更好讀：`[project]` 底下留著兩個仍在選模組的鍵（`features`、`quality`），而 `[modules]` 底下有三個，讀的人得記住這個切分而它沒有理由。#13 的補充也要求先確認 `features` 與 `quality` 是否有同樣的問題——有，而且是同一個問題。

## 後果

- `[project]` 在 `config.toml.example` 中目前只剩註解掉的後設資料鍵。這是刻意的：它是樣板，不是空區段。
- 跨層歧義消失得比 ADR 0015 第 4 條要求的更徹底——`[project]` 底下已經沒有 `type`，所以不需要雙方持續記得避開某個拼法。ADR 0015 第 4 條的約束仍然有效，只是本層這一側已無衝突面。
- `configure-project-type.sh` 產生的 `config.toml` 同步改為新形狀。該腳本原本還會寫入 `mode = "project"`，那個鍵已在 ADR 0016 的變更中移除，一併停止寫入。
- **沒有提供舊鍵的過渡期。** 理由：本層目前沒有已知的外部使用者專案；`config.toml` 由 `configure-project-type.sh` 產生而不是手寫；而且沒有 fallback 才符合 ADR 0015 對跨層鍵的處理原則——靜默相容會讓寫錯位置的設定看起來像有效設定。舊鍵出現時應該是明顯無效，不是安靜地被忽略。
- 腳本名稱 `configure-project-type.sh` 現在與它產生的鍵名不一致。改名會動到多份文件的引用，留待 [#8](https://github.com/matheme-justyn/ai-zpd/issues/8) 對 `.scaffolding/docs/` 的分類一併處理。
