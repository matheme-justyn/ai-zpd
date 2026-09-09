#!/usr/bin/env bash
# 檢測並執行適當的安裝/更新流程
#
# 用途：
#   - 新專案：執行完整初始化 (init-project.sh)
#   - 已有專案：執行增量更新 (只更新 .scaffolding/ 和 OpenCode 配置)
#
# Usage: ./.scaffolding/scripts/smart-install.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 My Vibe Scaffolding 智慧安裝/更新${NC}"
echo "========================================"
echo ""

# 檢測專案狀態
PROJECT_MODE="unknown"

# 檢查 1: 是否有 .template-version 檔案（已使用此 scaffolding）
if [ -f ".template-version" ]; then
    PROJECT_MODE="update"
    CURRENT_VERSION=$(cat .template-version 2>/dev/null || echo "unknown")
    echo -e "${YELLOW}📦 偵測到已有專案（版本: $CURRENT_VERSION）${NC}"
    echo ""
# 檢查 2: 是否是剛 clone 的新專案（有 .scaffolding/ 但沒 .template-version）
elif [ -d ".scaffolding" ] && [ ! -f ".template-version" ]; then
    PROJECT_MODE="new"
    echo -e "${GREEN}🆕 偵測到新專案${NC}"
    echo ""
# 檢查 3: 可能是手動 cherry-pick（只有部分檔案）
else
    PROJECT_MODE="new"
    echo -e "${YELLOW}⚠️  無法確定專案狀態，假設為新專案${NC}"
    echo ""
fi

# 執行對應流程
if [ "$PROJECT_MODE" = "new" ]; then
    echo -e "${BLUE}🚀 執行新專案初始化...${NC}"
    echo ""
    
    # 執行完整初始化
    if [ -f ".scaffolding/scripts/init-project.sh" ]; then
        ./.scaffolding/scripts/init-project.sh
    else
        echo -e "${RED}❌ 找不到 init-project.sh${NC}"
        exit 1
    fi
    
elif [ "$PROJECT_MODE" = "update" ]; then
    echo -e "${BLUE}🔄 執行增量更新...${NC}"
    echo ""
    
    # 讀取當前版本
    CURRENT_VERSION=$(cat .template-version 2>/dev/null || echo "0.0.0")
    TEMPLATE_VERSION=$(cat .scaffolding/VERSION 2>/dev/null || echo "unknown")
    
    echo "當前版本: $CURRENT_VERSION"
    echo "模板版本: $TEMPLATE_VERSION"
    echo ""
    
    # 執行增量更新
    # 這裡原本先找 update-from-template.sh，找不到才走下面的流程。那支腳本
    # 在本 repo 從未存在，所以「找到」的那一支是死碼，實際上一直走的是這條。
    echo "📝 更新關鍵檔案..."
    
    # 1. 更新 OpenCode 配置（不覆蓋使用者設定）
    if [ ! -f ".vscode/settings.json" ] || ! grep -q "opencode.dataDir" .vscode/settings.json 2>/dev/null; then
        echo "  → 設定 OpenCode 專案獨立資料庫..."
        ./.scaffolding/scripts/init-opencode.sh
    else
        echo "  ✓ OpenCode 已配置"
    fi
    
    # 2. 更新 .gitignore（只加新項目，不覆蓋）
    echo "  → 更新 .gitignore..."
    if ! grep -q "^\.opencode-data/$" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        echo "# OpenCode 專案獨立資料庫" >> .gitignore
        echo ".opencode-data/" >> .gitignore
    fi
    
    # 3. 更新版本記錄
    echo "$TEMPLATE_VERSION" > .template-version
    
    echo ""
    echo -e "${GREEN}✅ 更新完成！${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  重要提醒：${NC}"
    echo "  1. 重啟 VSCode 讓 OpenCode 配置生效"
    echo "  2. 檢查 .scaffolding/CHANGELOG.md 查看完整更新內容"
    echo "  3. 兩層設定檔的說明：.scaffolding/docs/CONFIG_LAYERS.md"
fi

echo ""
echo -e "${BLUE}📖 後續步驟：${NC}"
if [ "$PROJECT_MODE" = "new" ]; then
    echo "  1. 編輯 config.toml 設定語言偏好"
    echo "  2. 更新 README.md 為你的專案描述"
else
    echo "  1. 重啟 VSCode"
    echo "  2. 驗證 OpenCode 配置：ls -la .opencode-data/"
    echo "  3. 檢查 CHANGELOG：.scaffolding/CHANGELOG.md"
fi

echo ""
echo -e "${GREEN}🎉 完成！${NC}"
