# ADR 0018: README 直接維護，移除產生器

- **狀態**: Accepted
- **日期**: 2026-09-09
- **決策者**: repo owner
- **相關**: [ADR 0016](0016-single-version-source-scaffolding-version.md)、[#14](https://github.com/matheme-justyn/ai-zpd/issues/14)

## 脈絡

AGENTS.md 第 6 節以全大寫寫著「README files are auto-generated from i18n translations. DO NOT edit README.md directly」，並標注「This is MANDATORY. No exceptions.」。指定的產生器是 `generate-readme.sh`。

實際檢查該腳本後，這段指示的三個前提全部不成立，而且照做會造成破壞：

1. **宣稱的來源不存在。** 腳本第 25 行宣告 `local toml_file="$PROJECT_ROOT/.scaffolding/i18n/locales/en-US/readme.toml"`，但 `.scaffolding/i18n/` 這個目錄在本 repo 中不存在。
2. **`toml_file` 宣告後從未被讀取。** README 內容是寫死在腳本的 heredoc 裡的，不是從 TOML 來的。
3. **寫死的內容是改名前的。** 標題是 `# My Vibe Scaffolding`，連結指向舊 repo。**照 AGENTS.md 的指示執行這支腳本，會把目前的 README 覆蓋成拆分前的文字。**

同時，`.scaffolding/README.md` 與 `.scaffolding/README.zh-TW.md` 是該腳本 `sync_to_scaffolding()` 產生的複本，版本徽章停在 `3.2.0`，標題同樣是改名前的 `My Vibe Scaffolding`，且沒有任何東西讀它們。

三份 README 的版本徽章因此各自落後：根目錄兩份落後兩個 patch（`4.0.0` vs `4.0.2`），`.scaffolding/` 那份落後一整個主版本（`3.2.0`）。徽章原本是由產生器從 `TEMPLATE_VERSION` 寫入的，所以「徽章寫死」這件事本身就是產生器失效的症狀，不是有人手動改壞。

## 決策

**`README.md` 與 `README.zh-TW.md` 改為直接維護。**

1. `generate-readme.sh` 刪除。
2. `.scaffolding/README.md` 與 `.scaffolding/README.zh-TW.md` 刪除。
3. AGENTS.md 第 6 節改寫，明說改為直接編輯，並記錄原本那段指示為什麼會造成破壞——刪掉指示而不說明，下一個人會重新發明同一個產生器。
4. `ci.yml` 檢查兩份 README 的版本徽章是否等於 `.scaffolding/VERSION`，不等則失敗。

第 4 點是這個決策能成立的條件。改為手動維護會把徽章的正確性交還給人，而徽章落後正是「交給人記得」的失敗紀錄。加上檢查之後，手動維護的失敗方式是 CI 紅燈，不是安靜的過期。

## 為什麼不修好產生器

修好意味著要先有翻譯來源。`.scaffolding/i18n/` 不存在，內容也沒有留在別處——腳本裡的 heredoc 是唯一的內容，而它已經過期。所以這不是修復，是重新設計一套 i18n README 產生機制。那件事值得做的話應該有自己的 Issue 與需求，不該以「還原一支壞掉的腳本」的形式偷渡。

## 後果

- README 的兩個語言版本現在可能內容漂移（產生器至少保證兩者同時被寫）。這個風險以人工審閱承擔；若之後證明不夠，再談產生機制。
- 版本徽章成為發版流程的一部分：改 `.scaffolding/VERSION` 就必須同時改兩份 README，否則 CI 失敗。`ai-scheme` #14 的 release-please 落地後，這一步可以自動化。
- AGENTS.md 少了一段以「MANDATORY. No exceptions.」措辭寫成、但會導致資料損失的指示。這類指示的危險在於它的強度與正確性無關——語氣愈強，愈不會有人去驗證前提。
