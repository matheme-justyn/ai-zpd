<div align="center">

<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# ai-zpd

[![Version](https://img.shields.io/badge/version-4.0.2-blue.svg)](./.scaffolding/VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

[English](./README.md) | 繁體中文

</div>

---

## 🔄 這個 repo 正在拆成三個

`my-vibe-scaffolding` 正在拆分成三個 repo，各自負責這個模板原本打包在一起的「黃金路徑」裡的一層：

- **`ai-scheme`** — repo/CI 骨架層
- **`ai-zpd`** — 能力傳遞機制層（**就是這個 repo**，正在改名中）
- **`ai-skill-web`** — 手寫的 skill／agent 內容層

這個 repo 保留原本的 git 歷史，之後會改名為 `ai-zpd`。另外兩個是新拆出來的，內容正在分階段搬入。

### 為什麼叫 ai-zpd

命名自 Lev Vygotsky 的「**最近發展區**」——俄文 **зона ближайшего развития**（拉丁轉寫：*zona blizhaishego razvitiya*）。有個翻譯上的細節：「ближайший」字面意思更接近「**最近的、緊接著的**」，而不是英文 "proximal" 給人的空間鄰近感——這個區域講的不是遙遠的伸展目標，而是緊接著就會到手的下一層能力。

ZPD 指的是學習者獨立能做到的、跟有適當協助下能做到的之間的落差。這正是這個 repo 之後要做的事：決定該給 agent 什麼樣的能力／協助，正好卡在它獨立還做不到的邊界——不是它運作所在的骨架（`ai-scheme`），也不是 skill 內容本身（`ai-skill-web`）。具體來說就是當那個銜接層:設定一次,底層就會把能力接通到 agent 實際運作的地方——不管是 IDE、CLI 還是別的什麼,呼叫的人不用知道底層線路怎麼接。

### 職業對應:接線生 Telephonist

這個專案家族裡每個名字都是「心理學家的術語」配上「體現這個術語的消失職業」,這一個是**接線生**。

在自動交換機出現以前,你沒辦法自己撥通另一條線——你跟接線生報出想找的名字或號碼,她在交換機板上手動幫你接通線路,你完全不需要知道交換機底下的線路是怎麼接的。1892 年自動交換系統開始出現,到 1980 年代,人工接線這個角色已經幾乎完全消失。

這正是這個 repo 的工作濃縮成一張畫面:你說出想接通的東西,連線就會發生,不管底層平台實際上需要怎麼接。

---

## 📌 這是什麼？

**AI 驅動的專案鷹架模板**，用於快速建立專案並遵循最佳實踐。

取名自教育心理學裡的「鷹架」比喻 — 在需要時提供結構支援，不需要時可以拆除。

> 「鷹架」（scaffolding）一詞由 Wood、Bruner 與 Ross 於 1976 年提出，用來描述更有能力的引導者如何在 Vygotsky 的「最近發展區」（Zone of Proximal Development, ZPD——學習者獨立能做到的、與在協助下能做到的之間的落差）裡支持學習者。Vygotsky 本人其實從未使用過「鷹架」這個詞。

<div align="center">
<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-illustration-american.png" alt="American Style Illustration" width="300"/>
<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-illustration-japanese.png" alt="Japanese Style Illustration" width="300"/>
</div>

### 核心特色

- 🤖 **AI Agent 整合** - `AGENTS.md` + Skills 系統支援 OpenCode/Cursor/Claude
- 📦 **版本管理** - Pre-push hooks 強制執行版本更新
- 🌐 **多語言支援** - BCP 47 i18n 文件國際化
- 🛠️ **智慧設定** - AI agent 自動處理首次設定

---

## 🚀 安裝

**統一 AI Prompt（適用所有情境）：**

```
請從 https://github.com/matheme-justyn/my-vibe-scaffolding 導入鷹架系統到目前專案
```

**AI 會自動偵測情境並處理：**

### 情境 A：現有專案導入鷹架

如果目前目錄已有專案檔案（`.git/`、`package.json` 等）：
1. 從 GitHub 下載 `.scaffolding/` 目錄
2. 下載 `AGENTS.md`、`config.toml.example`
3. 執行 `./.scaffolding/scripts/init-project.sh`
4. 腳本偵測無 `.template-version` → **首次安裝模式**

### 情境 B：建立全新專案

如果要建立全新專案：
1. 在 GitHub 點擊 **"Use this template"**
2. Clone 你的新 repository
3. 執行 `./.scaffolding/scripts/init-project.sh`
4. 腳本偵測無 `.template-version` → **首次安裝模式**

**核心優勢**：一個 prompt 搞定所有情境 — AI 自動處理剩下的

---

## ⚙️ 腳本運作方式

`init-project.sh` 腳本會智慧偵測你的情況：

**首次模式**（無 `.template-version` 檔案）：
- 詢問專案資訊
- 建立 VERSION、README.md、LICENSE
- 設定 Git hooks
- 建立 `.template-version` 追蹤使用的模板版本

**更新模式**（`.template-version` 已存在）：
- 比對目前版本與模板版本
- 整併 agent 配置（`.claude`、`.roo` → `.agents`）
- 重新安裝 Git hooks（可能有新功能）
- 更新 `.template-version`

**何時手動執行：**
- 從 template 建立新專案後
- 想要更新模板功能時
- 需要整併分散的 agent 配置時

---

## 📖 文件

- 📖 **[文件目錄](./.scaffolding/docs/)** - 設定指南、升級路徑與設計文件
- 🗂️ **[文件歸屬](./.scaffolding/docs/OWNERSHIP.md)** - 每份文件由哪一層擁有，以及理由
- 🤖 **[AGENTS.md](./AGENTS.md)** - AI agent 指令和編碼規範
- 📝 **[CHANGELOG.md](./.scaffolding/CHANGELOG.md)** - 版本歷史和變更記錄

---

## 🎯 技術棧

為什麼選擇這些技術？

| 技術 | 原因 | 解決的問題 |
|------|------|-----------|
| **OpenCode**（開源 AI）| 75+ 模型，CLI 優先 | 避免供應商鎖定 |
| **AGENTS.md 標準** | 跨工具相容 | AI 理解專案慣例 |
| **Skills 系統** | 可重用的工作流程 | 編碼最佳實踐 |
| **Bundles & Workflows** | 角色導向的集合 | 快速載入上下文 |

我們使用 [superpowers](https://github.com/ohmyopencode/superpowers) - 社群驅動的 AI 工作流程。

---

## 📄 授權

MIT 授權 - 參閱 [LICENSE](./LICENSE)

---

<div align="center">

**Vygotsky 的 ZPD，Bruner 的鷹架 | AI 驅動 | 為開發者設計**

[文件](./.scaffolding/docs/) | [變更記錄](./.scaffolding/CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
