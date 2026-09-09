# ADR 0016: `.scaffolding/VERSION` is the single version source

- **狀態**: Accepted
- **日期**: 2026-09-09
- **決策者**: repo owner
- **相關**: [ADR 0014](0014-repo-split-ai-scheme-ai-zpd-ai-skill-web.md)、[ADR 0015](0015-two-config-files-ai-scheme-ai-zpd.md)、[#6](https://github.com/matheme-justyn/ai-zpd/issues/6)、[#11](https://github.com/matheme-justyn/ai-zpd/issues/11)、[#12](https://github.com/matheme-justyn/ai-zpd/issues/12)、[`ai-scheme` #14](https://github.com/matheme-justyn/ai-scheme/issues/14)

## 脈絡

本 repo 長期有兩個版本檔——根目錄 `VERSION` 與 `.scaffolding/VERSION`——必須人工保持一致。維護這個不變量的機制有兩層，兩層都失效：

1. `check-version-sync.sh` 只在 `config.toml` 存在且 `[project].mode = "scaffolding"` 時執行。本 repo 沒有 `config.toml`（只有 `config.toml.example`），所以它一律走預設的 `project` 分支直接 `exit 0`。**從未執行過。**
2. `.github/workflows/ci.yml` 的比對確實每次 push 都執行，但它所在的 workflow 自三倉拆分後在 `main` 常態紅燈，直到 [#7](https://github.com/matheme-justyn/ai-zpd/issues/7) 修復為止。版本真的漂移時，job 狀態從紅變紅，觀察不到差異——涵蓋（covered）成立，示警（signalled）不成立。

在決定要修哪一層之前，先確認了這兩個檔案**是不是真的在說同一件事**。答案是：只在本 repo 內是。

## 兩個檔案的實際語意

| 位置 | 根目錄 `VERSION` | `.scaffolding/VERSION` |
| --- | --- | --- |
| **本 repo（ai-zpd）** | 模板版本的複本，沒有任何讀取者 | 模板版本 |
| **使用者專案** | **該專案自己的版本**。`init-project.sh` 以 `echo "0.1.0" > VERSION` 建立，不是從模板複製 | 模板版本，隨 `.scaffolding/` 一起交付 |

也就是說兩者在使用者專案裡是**語意不同的兩個檔案**，本來就不該一致；而在本 repo 裡它們一致，純粹因為 ai-zpd 自己就是模板，它的「專案版本」與「模板版本」是同一個數字。

決定性的一點：`.scaffolding/VERSION` 是安裝機制的實際輸入（`init-project.sh` 第 44 行讀它得到 `TEMPLATE_VERSION`，寫進使用者專案的 `.template-version`），而且它必須以實體檔案的形式隨 `.scaffolding/` 交付——沒有建置步驟可以在交付時產生它，也不能改成讀根目錄，因為在使用者專案裡根目錄放的是別的東西。

所以可收斂的方向只有一個。

## 決策

**`.scaffolding/VERSION` 是本 repo 模板版本的唯一來源。根目錄 `VERSION` 從本 repo 刪除。**

附帶的：

1. `ci.yml` 的「兩檔比對」改為「`.scaffolding/VERSION` 是合法 SemVer」加上「根目錄 `VERSION` 不存在」。後者讓這個決策有可觀察的失敗，而不是只靠人記得。
2. `check-version-sync.sh`、`bump-version.sh`、`install-hooks.sh` 刪除。整個 version-sync 機制由 `ai-scheme` #14 判定退役且不由骨架層接手，刪除動作依該 Issue 的指示在本層執行。
3. `[project].mode` 從 `config.toml.example` 移除。它是上述兩支腳本的觸發條件，而三倉拆分後這個 scaffolding／project 的二分已無意義——ai-zpd 就是模板本身，不存在「處於 project mode」的狀態。

## 這個決策不影響什麼

- **使用者專案的根目錄 `VERSION` 照舊。** `init-project.sh` 仍會建立它並設為 `0.1.0`。那是使用者專案自己的版本，與本決策無關。
- **文件中描述使用者專案 `VERSION` 的段落照舊**（README、AGENTS.md、`.opencode/INSTALL.md` 中「Creates VERSION, README, LICENSE」那類敘述）。
- **`.scaffolding/CHANGELOG.md` 仍是模板自身的變更紀錄**，根目錄 `CHANGELOG.md` 仍是交付給使用者專案的樣板（它的標頭至今仍是 `## [1.0.0] - YYYY-MM-DD` 佔位）。兩者的關係與 VERSION 不同：根目錄那份是有意的樣板，不是複本。

## 後果

- 不再有需要人工同步的版本檔，#6 的完成條件（選項 A）成立。
- 版本號的位置變得不合慣例：多數工具預期在根目錄找 `VERSION`。這是刻意的取捨——遷就慣例就要保留一個沒有讀取者的檔案，而那正是漂移的來源。若日後採用 release-please（`ai-scheme` #14 的方向），把 `.scaffolding/VERSION` 設為 manifest 目標即可。
- README 徽章仍硬寫版本號（三份，見 [#14](https://github.com/matheme-justyn/ai-zpd/issues/14)）。本 ADR 決定了徽章該指向什麼，但沒有解決徽章自動更新的問題。
- `migrate-to-template-dir.sh` 仍讀 `[project].mode`。這是刻意保留：它遷移的是移除前建立的專案，那些專案的設定檔仍帶著舊鍵，讀它是辨識遷移對象的方式，不是對本 repo 現有鍵的依賴。腳本內已加註。

## 替代方案

**保留兩檔，把 `check-version-sync.sh` 修好。**（#6 的選項 B）否決：這會保留兩個實作同一個不變量的地方，而其中一個在使用者專案裡會對「本來就不該一致」的兩個檔案發出誤報。真正的問題不是檢查沒跑，是這個不變量在本 repo 以外並不成立。

**根目錄 `VERSION` 為單一來源，`.scaffolding/VERSION` 改為衍生。**否決：`.scaffolding/VERSION` 必須以實體檔案交付給使用者專案，而在那裡根目錄放的是使用者自己的版本。衍生關係在交付後就斷了。
