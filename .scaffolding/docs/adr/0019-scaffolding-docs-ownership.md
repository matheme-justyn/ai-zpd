# ADR 0019: `.scaffolding/docs/` 的歸屬分類

- **狀態**: Accepted
- **日期**: 2026-09-09
- **決策者**: repo owner
- **相關**: [ADR 0014](0014-repo-split-ai-scheme-ai-zpd-ai-skill-web.md)、[ADR 0016](0016-single-version-source-scaffolding-version.md)、[#8](https://github.com/matheme-justyn/ai-zpd/issues/8)
- **清單**: [`../OWNERSHIP.md`](../OWNERSHIP.md)

## 脈絡

ADR 0014 拆分三倉時，`.scaffolding/docs/` 下的 25 份文件全數留在 ai-zpd。該 ADR 的 consequences 明說這是**預設**而非判斷：「沒有乾淨的單一 repo 擁有者」，並註明若發現屬於他處要重新檢討。

沒有擁有者的文件會持續產生成本：讀者無法判斷哪一份還算數，而其他東西會繼續引用它們。這已經有具體事例——`ci.yml` 曾把一份遷往 ai-skill-web 的 ADR 列為必要檔案，使該 workflow 自拆分後常態紅燈（[#7](https://github.com/matheme-justyn/ai-zpd/issues/7)）。

## 分類依據

逐份判斷「這份文件描述的東西，在三層之中由誰擁有」。逐份結果與理由在 [`OWNERSHIP.md`](../OWNERSHIP.md)；此處只記依據本身。

**留在 ai-zpd**：描述安裝／執行機制的文件。這是 ADR 0014 給本層的職責。

**提交給 ai-skill-web**：SDD 內容，以及文件模組。後者的依據不是主題判斷而是既成事實——ai-skill-web 的 `docs/` 下已經有 `API_DESIGN.md`、`PERFORMANCE_OPTIMIZATION.md`、`ACCESSIBILITY_STANDARDS.md`、`AUTH_IMPLEMENTATION.md`、`REALTIME_PATTERNS.md`、`FILE_HANDLING.md`，正是本 repo `config.toml.example` 的 `[modules]` 註解所指的那些檔案。**整套文件模組已經在那裡**，留在這裡的三份（`ONBOARDING_GUIDE.md`、`PRODUCTION_READINESS.md`、`TROUBLESHOOTING.md`）是同一批東西的殘留，可由檔頭格式辨認（`**Status**: Active | Domain: …`）。

依 #8 的範圍，本層只負責提出移交，接不接由對方決定，所以這五份在對方接收前仍留在原處。

**刪除**：分兩類。一是拆分前的一次性快照——記錄某個時點「做完了什麼」，而它們描述的佈局已被拆分取代；這一批有四份沒有任何外部引用，其餘的引用者也都在這一批之內，互相引用而沒有外部入口。二是被拆分本身取代的文件，最典型的是 `FEATURES.md`：它是橫跨三層的功能總覽，拆分後**沒有任何一個 repo 能正確擁有它**。

## 決策

25 份文件分類為：留在 ai-zpd 8 份、提交給 ai-skill-web 5 份、刪除 12 份。逐份清單與理由記在 `.scaffolding/docs/OWNERSHIP.md`，該檔同時作為日後新增文件的登錄處。

## 為什麼用一份清單檔而不是只寫在 ADR 裡

ADR 記錄的是某個時點的決定，不應該隨後續變動改寫。但歸屬需要在新增文件時持續維護。分成兩份：ADR 記依據，`OWNERSHIP.md` 記狀態。

## 後果

- 每份文件都有明確擁有層，或已被刪除。#8 的完成條件成立。
- 刪除的內容保留在 git 歷史與 `.scaffolding/CHANGELOG.md`。
- ADR 0012 與 ADR 0014 的內文提到部分已刪除的檔名。**這些不修改**——ADR 記錄的是決策當時的事實，改寫會讓紀錄失真。它們是純文字提及而非 markdown 連結，所以不構成死連結。
- 兩份 README 指向 `FEATURES.md` 的連結是本次唯一的實際死連結，已改指文件目錄與 `OWNERSHIP.md`。

## 揭露但未解決：`[modules]` 指向另一個 repo 的內容

本次分類揭露了一條 ADR 0015 沒有涵蓋的邊界。ai-zpd 的 `config.toml.example` 以 `[modules]` 選擇要載入哪些文件模組，而那些模組檔案在 ai-skill-web；`always_enabled` 目前列的五個（`STYLE_GUIDE`、`TERMINOLOGY`、`GIT_WORKFLOW`、`TESTING_STRATEGY`、`SECURITY_CHECKLIST`）在本 repo 一份都不存在。

機制層持有選擇器、能力層持有被選的內容——這個關係需要兩層一起定義，就像 ADR 0015 為 ai-zpd 與 ai-scheme 定義設定邊界那樣。不在 #8 的範圍內解決，記在此處與 `OWNERSHIP.md` 以免再次遺失。
