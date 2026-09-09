#!/bin/bash
# 配置專案類型和生成 config.toml
# 此腳本會詢問專案類型、功能需求，並生成 config.toml

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║   ⚙️  專案配置精靈                                     ║"
echo "║   Project Configuration Wizard                       ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# 檢查是否已有 config.toml
if [ -f "config.toml" ]; then
    echo -e "${YELLOW}⚠️  config.toml 已存在${NC}"
    read -p "覆蓋現有配置？ (y/N): " overwrite
    if [[ ! $overwrite =~ ^[Yy]$ ]]; then
        echo "已取消"
        exit 0
    fi
    echo ""
fi

# 第一部分：專案類型選擇
echo -e "${BLUE}📦 第 1 步：選擇專案類型${NC}"
echo ""
echo "專案類型決定載入哪些模組（STYLE_GUIDE、FRONTEND_PATTERNS 等）"
echo ""
echo "1) frontend         - React/Vue/Angular 前端應用"
echo "2) backend          - Node.js/Python/Go API 服務"
echo "3) fullstack        - 前後端完整應用（最常見）"
echo "4) cli              - 命令列工具"
echo "5) library          - 函式庫/套件開發"
echo "6) academic         - 學術研究專案（論文、實驗）"
echo "7) documentation    - 純文件專案"
echo ""
read -p "選擇專案類型 (1-7): " project_type_choice

case $project_type_choice in
    1) PROJECT_TYPE="frontend" ;;
    2) PROJECT_TYPE="backend" ;;
    3) PROJECT_TYPE="fullstack" ;;
    4) PROJECT_TYPE="cli" ;;
    5) PROJECT_TYPE="library" ;;
    6) PROJECT_TYPE="academic" ;;
    7) PROJECT_TYPE="documentation" ;;
    *)
        echo -e "${RED}無效選擇，使用預設值：fullstack${NC}"
        PROJECT_TYPE="fullstack"
        ;;
esac

echo -e "${GREEN}✓ 專案類型：$PROJECT_TYPE${NC}"
echo ""

# 第二部分：功能需求（非 academic 類型才詢問）
FEATURES=()
if [ "$PROJECT_TYPE" != "academic" ] && [ "$PROJECT_TYPE" != "documentation" ]; then
    echo -e "${BLUE}📦 第 2 步：選擇功能需求${NC}"
    echo ""
    echo "選擇你的專案會用到的功能（決定載入哪些模組）"
    echo ""
    
    # API
    if [ "$PROJECT_TYPE" = "backend" ] || [ "$PROJECT_TYPE" = "fullstack" ]; then
        read -p "使用 REST/GraphQL API？ (Y/n): " has_api
        if [[ ! $has_api =~ ^[Nn]$ ]]; then
            FEATURES+=("api")
            echo -e "${GREEN}  ✓ API${NC}"
        fi
    fi
    
    # Database
    if [ "$PROJECT_TYPE" = "backend" ] || [ "$PROJECT_TYPE" = "fullstack" ]; then
        read -p "使用資料庫（SQL/NoSQL）？ (Y/n): " has_db
        if [[ ! $has_db =~ ^[Nn]$ ]]; then
            FEATURES+=("database")
            echo -e "${GREEN}  ✓ Database${NC}"
        fi
    fi
    
    # Authentication
    if [ "$PROJECT_TYPE" != "library" ] && [ "$PROJECT_TYPE" != "cli" ]; then
        read -p "需要使用者認證（登入/註冊）？ (y/N): " has_auth
        if [[ $has_auth =~ ^[Yy]$ ]]; then
            FEATURES+=("auth")
            echo -e "${GREEN}  ✓ Authentication${NC}"
        fi
    fi
    
    # i18n
    read -p "需要多語言支援（i18n）？ (y/N): " has_i18n
    if [[ $has_i18n =~ ^[Yy]$ ]]; then
        FEATURES+=("i18n")
        echo -e "${GREEN}  ✓ Internationalization${NC}"
    fi
    
    # Realtime
    if [ "$PROJECT_TYPE" = "backend" ] || [ "$PROJECT_TYPE" = "fullstack" ]; then
        read -p "需要即時通訊（WebSocket/SSE）？ (y/N): " has_realtime
        if [[ $has_realtime =~ ^[Yy]$ ]]; then
            FEATURES+=("realtime")
            echo -e "${GREEN}  ✓ Realtime${NC}"
        fi
    fi
    
    # File handling
    read -p "需要檔案上傳/下載？ (y/N): " has_files
    if [[ $has_files =~ ^[Yy]$ ]]; then
        FEATURES+=("files")
        echo -e "${GREEN}  ✓ File Handling${NC}"
    fi
    
    echo ""
fi

# 第三部分：品質需求
QUALITY=()
echo -e "${BLUE}📦 第 3 步：品質需求（選填）${NC}"
echo ""
echo "選擇你想特別關注的品質面向（會載入對應模組）"
echo ""

read -p "需要效能最佳化指引？ (y/N): " needs_perf
if [[ $needs_perf =~ ^[Yy]$ ]]; then
    QUALITY+=("performance")
    echo -e "${GREEN}  ✓ Performance${NC}"
fi

read -p "需要無障礙設計指引（a11y）？ (y/N): " needs_a11y
if [[ $needs_a11y =~ ^[Yy]$ ]]; then
    QUALITY+=("accessibility")
    echo -e "${GREEN}  ✓ Accessibility${NC}"
fi

echo ""

# 第四部分：學術專案額外設定
CITATION_STYLE=""
ACADEMIC_FIELD=""

if [ "$PROJECT_TYPE" = "academic" ]; then
    echo -e "${BLUE}📚 第 4 步：學術專案設定${NC}"
    echo ""
    
    # Citation style
    echo "引用格式（Citation Style）："
    echo "1) APA     - 社會科學、教育、心理學"
    echo "2) MLA     - 文學、藝術、人文"
    echo "3) Chicago - 歷史、藝術、人文"
    echo "4) IEEE    - 工程、資訊科學"
    echo ""
    read -p "選擇引用格式 (1-4): " citation_choice
    
    case $citation_choice in
        1) CITATION_STYLE="APA" ;;
        2) CITATION_STYLE="MLA" ;;
        3) CITATION_STYLE="Chicago" ;;
        4) CITATION_STYLE="IEEE" ;;
        *)
            echo -e "${RED}無效選擇，使用預設值：APA${NC}"
            CITATION_STYLE="APA"
            ;;
    esac
    echo -e "${GREEN}✓ 引用格式：$CITATION_STYLE${NC}"
    echo ""
    
    # Academic field
    echo "研究領域（Research Field）："
    echo "1) computer_science  - 資訊科學"
    echo "2) biology           - 生物學"
    echo "3) physics           - 物理學"
    echo "4) social_science    - 社會科學"
    echo "5) other             - 其他（通用學術術語）"
    echo ""
    read -p "選擇研究領域 (1-5): " field_choice
    
    case $field_choice in
        1) ACADEMIC_FIELD="computer_science" ;;
        2) ACADEMIC_FIELD="biology" ;;
        3) ACADEMIC_FIELD="physics" ;;
        4) ACADEMIC_FIELD="social_science" ;;
        5) ACADEMIC_FIELD="other" ;;
        *)
            echo -e "${RED}無效選擇，使用預設值：computer_science${NC}"
            ACADEMIC_FIELD="computer_science"
            ;;
    esac
    echo -e "${GREEN}✓ 研究領域：$ACADEMIC_FIELD${NC}"
    echo ""
fi

# 第五部分：語言偏好
echo -e "${BLUE}🌐 第 5 步：語言偏好${NC}"
echo ""
echo "選擇 AI agent 溝通語言（影響文件、提示、錯誤訊息）"
echo ""
echo "1) zh-TW - 繁體中文（台灣）"
echo "2) en-US - English (United States)"
echo "3) ja-JP - 日本語（日本）"
echo "4) zh-CN - 简体中文（中国）"
echo ""
read -p "選擇語言 (1-4, 預設 zh-TW): " lang_choice

case $lang_choice in
    1|"") PRIMARY_LOCALE="zh-TW" ;;
    2) PRIMARY_LOCALE="en-US" ;;
    3) PRIMARY_LOCALE="ja-JP" ;;
    4) PRIMARY_LOCALE="zh-CN" ;;
    *)
        echo -e "${YELLOW}使用預設值：zh-TW${NC}"
        PRIMARY_LOCALE="zh-TW"
        ;;
esac
echo -e "${GREEN}✓ 語言偏好：$PRIMARY_LOCALE${NC}"
echo ""

# 第六部分：確認配置
echo -e "${BLUE}📝 配置摘要${NC}"
echo ""
echo "專案類型：$PROJECT_TYPE"
if [ ${#FEATURES[@]} -gt 0 ]; then
    echo "功能需求：${FEATURES[*]}"
else
    echo "功能需求：（無）"
fi
if [ ${#QUALITY[@]} -gt 0 ]; then
    echo "品質需求：${QUALITY[*]}"
else
    echo "品質需求：（無）"
fi
if [ "$PROJECT_TYPE" = "academic" ]; then
    echo "引用格式：$CITATION_STYLE"
    echo "研究領域：$ACADEMIC_FIELD"
fi
echo "語言偏好：$PRIMARY_LOCALE"
echo ""

read -p "確認生成 config.toml？ (Y/n): " confirm
if [[ $confirm =~ ^[Nn]$ ]]; then
    echo "已取消"
    exit 0
fi
echo ""

# 第七部分：生成 config.toml
echo -e "${BLUE}📝 生成 config.toml${NC}"
echo ""

# 準備 features 和 quality 陣列字串
FEATURES_STR=""
if [ ${#FEATURES[@]} -gt 0 ]; then
    FEATURES_STR=$(printf ', "%s"' "${FEATURES[@]}")
    FEATURES_STR="[${FEATURES_STR:2}]"  # 移除開頭的逗號和空格
else
    FEATURES_STR="[]"
fi

QUALITY_STR=""
if [ ${#QUALITY[@]} -gt 0 ]; then
    QUALITY_STR=$(printf ', "%s"' "${QUALITY[@]}")
    QUALITY_STR="[${QUALITY_STR:2}]"
else
    QUALITY_STR="[]"
fi

# 生成 config.toml
cat > config.toml << EOF
# Project Configuration
# Generated by configure-project-type.sh
# Date: $(date +%Y-%m-%d)

[project]
# Project metadata only. Everything that selects documentation modules lives
# under [modules] — see ADR 0017.

EOF

# 學術專案額外配置
if [ "$PROJECT_TYPE" = "academic" ]; then
    cat >> config.toml << EOF
[academic]
# Citation style for references
# Options: APA | MLA | Chicago | IEEE
citation_style = "$CITATION_STYLE"

# Research field (determines which terminology files are loaded)
# Options: computer_science | biology | physics | social_science | other
field = "$ACADEMIC_FIELD"

EOF
fi

# 語言配置
cat >> config.toml << EOF
[locale]
# Primary language for AI agent communication and documentation
# Options: zh-TW | en-US | ja-JP | zh-CN
primary = "$PRIMARY_LOCALE"

# Fallback language when primary translation unavailable
fallback = "en-US"

EOF

# 模組配置
cat >> config.toml << EOF
[modules]
# Which domain's documentation modules to load
# Options: frontend | backend | fullstack | cli | library | academic | documentation
domain = "$PROJECT_TYPE"

# Feature modules to load
# Available: api, database, auth, i18n, realtime, files
features = $FEATURES_STR

# Quality modules to load
# Available: performance, accessibility
quality = $QUALITY_STR

# Modules always loaded regardless of domain
always_enabled = ["STYLE_GUIDE", "TERMINOLOGY", "GIT_WORKFLOW"]

# Force-load additional modules (even if the domain does not suggest them)
manual_enabled = []

# Disable modules even if the domain suggests them
manual_disabled = []

EOF

# README 策略（暫時保留 bilingual，未來版本可能改為 separate）
cat >> config.toml << EOF
[readme]
# README generation strategy
# Options: bilingual | separate
# - bilingual: Single README.md with EN/ZH sections
# - separate: Separate files (README.md, README.zh-TW.md, etc.)
strategy = "separate"

# Sync root README to .scaffolding/ (only in scaffolding mode)
sync_readme = false

EOF

# 服務配置
cat >> config.toml << EOF
[services]
# Services unavailable in this environment (AI agent will use alternatives)
unsupported = ["google-search", "google_search"]

[services.capabilities]
# Available alternatives for each capability
web_search = ["websearch_web_search_exa", "webfetch"]
code_search = ["grep_app_searchGitHub"]
documentation = ["context7_query-docs", "context7_resolve-library-id"]

[services.fallback]
# Fallback behavior when service unavailable
# Options: suggest | auto | fail
mode = "suggest"
log_attempts = true
show_reason = true

EOF

# 系統配置（自動偵測）
cat >> config.toml << EOF
[system]
# Auto-detected by detect-os.sh (DO NOT edit manually)
os_type = "$(uname -s)"
shell = "$SHELL"

EOF

echo -e "${GREEN}✓ config.toml 已生成${NC}"
echo ""

# 第八部分：生成 PR 模板（如果有 .github 目錄）
if [ -d ".github" ]; then
    echo -e "${BLUE}📝 生成 Pull Request 模板${NC}"
    echo ""
    
    # 根據語言選擇主要模板
    PR_TEMPLATE_SOURCE=""
    case $PRIMARY_LOCALE in
        zh-TW) PR_TEMPLATE_SOURCE=".scaffolding/templates/pr/PULL_REQUEST_TEMPLATE.zh-TW.md" ;;
        en-US) PR_TEMPLATE_SOURCE=".scaffolding/templates/pr/PULL_REQUEST_TEMPLATE.en-US.md" ;;
        ja-JP) PR_TEMPLATE_SOURCE=".scaffolding/templates/pr/PULL_REQUEST_TEMPLATE.ja-JP.md" ;;
        zh-CN) PR_TEMPLATE_SOURCE=".scaffolding/templates/pr/PULL_REQUEST_TEMPLATE.zh-CN.md" ;;
    esac
    
    if [ -f "$PR_TEMPLATE_SOURCE" ]; then
        cp "$PR_TEMPLATE_SOURCE" .github/PULL_REQUEST_TEMPLATE.md
        echo -e "${GREEN}✓ PR 模板已生成：.github/PULL_REQUEST_TEMPLATE.md${NC}"
    else
        echo -e "${YELLOW}⚠️  找不到 PR 模板：$PR_TEMPLATE_SOURCE${NC}"
    fi
    echo ""
fi

# 完成
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✨ 配置完成！                                       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📚 下一步：${NC}"
echo ""
echo "1. 查看配置："
echo "   cat config.toml"
echo ""
echo "2. AI agent 會自動載入以下模組："
echo "   - 永遠載入：STYLE_GUIDE, TERMINOLOGY, GIT_WORKFLOW"

if [ "$PROJECT_TYPE" = "frontend" ] || [ "$PROJECT_TYPE" = "fullstack" ]; then
    echo "   - 前端：FRONTEND_PATTERNS"
fi

if [ "$PROJECT_TYPE" = "backend" ] || [ "$PROJECT_TYPE" = "fullstack" ]; then
    echo "   - 後端：BACKEND_PATTERNS"
fi

if [[ " ${FEATURES[*]} " =~ " api " ]]; then
    echo "   - API：API_DESIGN"
fi

if [[ " ${FEATURES[*]} " =~ " database " ]]; then
    echo "   - 資料庫：DATABASE_CONVENTIONS"
fi

if [[ " ${FEATURES[*]} " =~ " auth " ]]; then
    echo "   - 認證：AUTH_IMPLEMENTATION"
fi

if [[ " ${FEATURES[*]} " =~ " i18n " ]]; then
    echo "   - 多語言：I18N_GUIDE"
fi

if [ "$PROJECT_TYPE" = "academic" ]; then
    echo "   - 學術：ACADEMIC_WRITING, CITATION_MANAGEMENT"
    echo "   - 引用格式：$CITATION_STYLE"
    echo "   - 術語檔案：academic/common.md, academic/${ACADEMIC_FIELD}.md"
fi

if [[ " ${QUALITY[*]} " =~ " performance " ]]; then
    echo "   - 效能：PERFORMANCE_OPTIMIZATION"
fi

if [[ " ${QUALITY[*]} " =~ " accessibility " ]]; then
    echo "   - 無障礙：ACCESSIBILITY"
fi

echo ""
echo "3. 如需修改配置，直接編輯 config.toml 或重新執行："
echo "   ./.scaffolding/scripts/configure-project-type.sh"
echo ""
echo "4. 完整模組列表和載入規則："
echo "   docs/adr/0012-module-system-and-conditional-loading.md"
echo ""
