#!/bin/bash
# 安裝或更新專案 - 支援初始化和更新模式
# Template-level script: 幫助使用此鷹架的 repo 安裝或更新配置

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 偵測執行模式
if [ -f ".template-version" ]; then
    MODE="update"
else
    MODE="install"
fi

# 顯示標題
echo -e "${BLUE}"
if [ "$MODE" = "install" ]; then
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║   🎯 初始化新專案                                     ║"
    echo "║   Install New Project from Template                  ║"
    echo "╚════════════════════════════════════════════════════════╝"
else
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║   🔄 更新專案配置                                     ║"
    echo "║   Update Project Configuration                       ║"
    echo "╚════════════════════════════════════════════════════════╝"
fi
echo -e "${NC}"
echo ""

# 檢查是否在專案根目錄
if [ ! -f ".scaffolding/VERSION" ]; then
    echo -e "${RED}❌ 錯誤：請在專案根目錄執行此腳本${NC}"
    exit 1
fi

# 讀取模板版本
TEMPLATE_VERSION=$(cat .scaffolding/VERSION)

if [ "$MODE" = "update" ]; then
    OLD_VERSION=$(cat .template-version)
    echo -e "${BLUE}📦 目前專案使用的模板版本: $OLD_VERSION${NC}"
    echo -e "${BLUE}📦 最新模板版本: $TEMPLATE_VERSION${NC}"
    echo ""
    
    if [ "$OLD_VERSION" = "$TEMPLATE_VERSION" ]; then
        echo -e "${GREEN}✓ 已是最新版本${NC}"
        echo ""
        echo "選項："
        echo "  1) 整併既有 agent 配置 (.claude, .roo → .agents)"
        echo "  2) 取消"
        echo ""
        read -p "選擇 (1/2): " -n 1 -r choice
        echo ""
        
        case $choice in
            1)
                ./.scaffolding/scripts/consolidate-agent-configs.sh
                ;;
            2)
                echo "已取消"
                exit 0
                ;;
            *)
                echo "已取消"
                exit 0
                ;;
        esac
        exit 0
    fi
    
    echo -e "${YELLOW}🔄 開始更新流程...${NC}"
    echo ""
    
    # 更新模式：整併 agent 配置
    echo "步驟 1/2: 整併 agent 配置"
    echo ""
    ./.scaffolding/scripts/consolidate-agent-configs.sh
    
    # 更新版本記錄
    echo ""
    echo "步驟 2/2: 更新版本記錄"
    echo "$TEMPLATE_VERSION" > .template-version
    echo -e "${GREEN}✓ 已更新 .template-version → $TEMPLATE_VERSION${NC}"
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✨ 更新完成！                                       ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📝 變更摘要：${NC}"
    echo "   - 模板版本: $OLD_VERSION → $TEMPLATE_VERSION"
    echo "   - Agent 配置已整併到 .agents/"
    echo "   - Git hooks 已更新"
    echo ""
    echo -e "${YELLOW}📚 更新日誌：${NC}"
    echo "   .scaffolding/CHANGELOG.md"
    echo ""
    exit 0
fi

# 安裝模式
echo -e "${BLUE}📋 專案資訊設定${NC}"
echo ""

read -p "專案名稱: " PROJECT_NAME
read -p "專案描述（簡短）: " PROJECT_DESC
read -p "GitHub repo (username/repo-name): " GITHUB_REPO
read -p "主要語言 (typescript/python/go/rust): " MAIN_LANG

echo ""
echo -e "${BLUE}📝 確認專案資訊：${NC}"
echo "   名稱: $PROJECT_NAME"
echo "   描述: $PROJECT_DESC"
echo "   Repo: $GITHUB_REPO"
echo "   語言: $MAIN_LANG"
echo "   模板版本: $TEMPLATE_VERSION"
echo ""

read -p "確認要初始化嗎？ (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

echo ""
echo -e "${BLUE}🚀 開始初始化...${NC}"
echo ""

# 1. 記錄模板版本
echo "步驟 1/9: 記錄模板版本"
echo "$TEMPLATE_VERSION" > .template-version
echo -e "${GREEN}✓ 已建立 .template-version${NC}"
echo ""

# 2. 備份原始 README
echo "步驟 2/9: 備份模板 README"
if [ -f "README.md" ]; then
    mv README.md .scaffolding/docs/TEMPLATE_README.md.backup
    echo -e "${GREEN}✓ 已備份 → .scaffolding/docs/TEMPLATE_README.md.backup${NC}"
fi
echo ""

# 3. 建立新的 README
echo "步驟 3/9: 建立專案 README"
cat > README.md << EOF
# $PROJECT_NAME

> $PROJECT_DESC

[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

---

## 功能特色

- （待補充）

## 技術棧

- **語言**: ${MAIN_LANG}
- **框架**: （待補充）

## 快速開始

### 安裝或更新

\`\`\`bash
# 首次安裝
./.scaffolding/scripts/init-project.sh

# 更新到新版本（整併 agent 配置）
./.scaffolding/scripts/init-project.sh
\`\`\`

此腳本會：
- ✅ 整併既有 agent 配置 (.claude, .roo → .agents)
- ✅ 更新模板版本
- ✅ 重新安裝 Git hooks

### 環境需求

- （待補充）

### 設定

\`\`\`bash
cp .env.example .env
# 編輯 .env
\`\`\`

### 執行

\`\`\`bash
# 開發模式
（待補充）

# 測試
（待補充）
\`\`\`

## 專案結構

\`\`\`
（待補充）
\`\`\`

## 開發指南

參考 [AGENTS.md](./AGENTS.md) 中的編碼規範。

## Agent Skills 系統

本專案支援跨工具的 agent skills：

- **全域 skills**: \`~/.agents/skills/\` (所有專案共享)
- **專案 skills**: \`.agents/skills/\` (團隊共享)

詳見 [AGENTS.md § Skill System](./AGENTS.md#skill-system)

## 貢獻

參考 [CONTRIBUTING.md](./CONTRIBUTING.md)

## 授權

MIT License - 詳見 [LICENSE](./LICENSE)

---

**基於**: [my-vibe-scaffolding](https://github.com/matheme-justyn/my-vibe-scaffolding) v${TEMPLATE_VERSION}

更多關於 README 撰寫的指引，請參考 [.scaffolding/docs/README_GUIDE.md](./.scaffolding/docs/README_GUIDE.md)
EOF

echo -e "${GREEN}✓ 已建立 README.md${NC}"
echo ""

# 4. 建立專案 VERSION（從 0.1.0 開始）
echo "步驟 4/9: 設定專案版本"
echo "0.1.0" > VERSION
echo -e "${GREEN}✓ 已設定為 0.1.0${NC}"
echo ""

# 5. 處理 LICENSE
echo "步驟 5/9: LICENSE 設定"
echo "   鷹架使用 MIT License"
echo "   你的專案可以選擇不同的授權"
echo ""
echo "   1) 使用 MIT License (與鷹架相同)"
echo "   2) 稍後自己決定（參考 .scaffolding/docs/PROJECT_LICENSE_GUIDE.md）"
read -p "   選擇 (1/2): " license_choice

if [[ $license_choice == "1" ]]; then
    cp .scaffolding/LICENSE ./LICENSE
    YEAR=$(date +%Y)
    read -p "   授權擁有者名稱: " owner
    
    # macOS 和 Linux 的 sed 語法不同
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/Copyright (c) [0-9]\{4\} .*$/Copyright (c) $YEAR $owner/" LICENSE
    else
        sed -i "s/Copyright (c) [0-9]\{4\} .*$/Copyright (c) $YEAR $owner/" LICENSE
    fi
    
    echo -e "${GREEN}✓ 已建立 LICENSE（MIT）${NC}"
else
    echo -e "${YELLOW}⏭️  跳過 LICENSE 建立${NC}"
    echo "   📚 稍後參考：.scaffolding/docs/PROJECT_LICENSE_GUIDE.md"
fi
echo ""

# 6-7. CONTRIBUTING.md 和 SECURITY.md（簡化版，僅詢問是否建立）
echo "步驟 6/9: CONTRIBUTING.md 設定"
read -p "建立 CONTRIBUTING.md? (y/N): " create_contrib
if [[ $create_contrib =~ ^[Yy]$ ]]; then
    read -p "接受外部貢獻（PR）? (y/N): " accept_contrib
    
    if [[ $accept_contrib =~ ^[Yy]$ ]]; then
        cat > CONTRIBUTING.md << 'EOF'
# Contributing to PROJECT_NAME_PLACEHOLDER

Thank you for your interest in contributing! 🎉

## How to Contribute

### 🐛 Report Bugs
Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md)

### 💡 Suggest Features  
Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md)

### 🔀 Submit Pull Requests
1. Fork the repository
2. Create your feature branch
3. Commit your changes (follow format in AGENTS.md)
4. Push to your branch
5. Open a Pull Request

## Coding Standards

- Follow conventions in [AGENTS.md](./AGENTS.md)
- Write tests for new features
- Ensure tests pass before submitting PR

---

For more detailed guidance, see [.scaffolding/docs/PROJECT_CONTRIBUTING_GUIDE.md](./.scaffolding/docs/PROJECT_CONTRIBUTING_GUIDE.md)
EOF
    else
        cat > CONTRIBUTING.md << 'EOF'
# Contributing to PROJECT_NAME_PLACEHOLDER

Thank you for your interest! 🙏

## 📢 Important Notice

This is a personal/company project. We are **not accepting pull requests** at this time.

## ✅ What You Can Do

### 🐛 Report Issues
If you find a bug, please open an issue with details.

### 🔄 Fork and Customize
You're encouraged to fork this project for your own use.

---

For guidance on writing your own contributing policy, see [.scaffolding/docs/PROJECT_CONTRIBUTING_GUIDE.md](./.scaffolding/docs/PROJECT_CONTRIBUTING_GUIDE.md)
EOF
    fi
    
    # macOS 和 Linux 的 sed 語法不同
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/" CONTRIBUTING.md
    else
        sed -i "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/" CONTRIBUTING.md
    fi
    
    echo -e "${GREEN}✓ 已建立 CONTRIBUTING.md${NC}"
else
    echo -e "${YELLOW}⏭️  跳過 CONTRIBUTING.md${NC}"
fi
echo ""

echo "步驟 7/9: SECURITY.md 設定"
read -p "建立 SECURITY.md? (y/N): " create_security
if [[ $create_security =~ ^[Yy]$ ]]; then
    read -p "安全問題聯絡 Email: " security_email
    cat > SECURITY.md << EOF
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.x.x   | :white_check_mark: |

## Reporting a Vulnerability

**DO NOT** open a public issue for security vulnerabilities.

Please report security issues to: **${security_email}**

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Potential impact

### Response Time

- We aim to respond within 48 hours
- Critical issues will be prioritized

---

For more guidance, see [.scaffolding/docs/PROJECT_SECURITY_GUIDE.md](./.scaffolding/docs/PROJECT_SECURITY_GUIDE.md)
EOF
    echo -e "${GREEN}✓ 已建立 SECURITY.md${NC}"
else
    echo -e "${YELLOW}⏭️  跳過 SECURITY.md${NC}"
fi
echo ""

# 9. Agent 配置目錄
echo "步驟 8/9: Agent 配置設定"
mkdir -p .agents/skills
echo -e "${GREEN}✓ 已建立 .agents/skills/ 目錄${NC}"
echo "   此目錄用於跨工具的 agent skills（Claude, Cursor, RooCode 等）"
echo ""

# 10. 完成提示
echo "步驟 9/9: 完成"
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   🎉 初始化完成！                                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 下一步：${NC}"
echo "   1. 編輯 README.md 補充專案資訊"
echo "   2. 更新 AGENTS.md 中的編碼規範"
echo "   3. 複製 .env.example → .env 並設定"
echo "   4. 刪除或調整不需要的檔案"
echo "   5. 初始化專案程式碼"
echo "   6. git commit -m \"chore: initialize project from template v${TEMPLATE_VERSION}\""
echo ""
echo -e "${BLUE}📚 參考文件：${NC}"
echo "   - .scaffolding/docs/README_GUIDE.md - README 撰寫指引"
echo "   - .scaffolding/docs/AGENTS_MD_GUIDE.md - Agent skills 說明"
echo "   - .scaffolding/docs/DOCUMENTATION_GUIDELINES.md - 文件組織規範"
echo "   - .scaffolding/docs/TEMPLATE_SYNC.md - 模板同步指南"
echo ""
echo -e "${GREEN}✨ 完成！${NC}"
