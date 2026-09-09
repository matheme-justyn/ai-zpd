#!/bin/bash
# scheme-status.sh — ask the skeleton layer what state this project is in.
#
# This layer (ai-zpd, the mechanism layer) must not decide for itself whether a
# project needs adopting or updating at the skeleton level. It asks, and it
# reports the answer verbatim. See ai-scheme's docs/status-interface-contract.md
# and ADR 0020.
#
# Two things this script deliberately does NOT do:
#
#   1. Guess. If ai-scheme is not installed, or says it could not answer
#      (exit 2), that is what gets printed. An unanswered question is not an
#      invitation to infer one from the filesystem.
#   2. Run next_command. Every lifecycle command produces a plan first, and the
#      plan is for a person to see. This script prints the command; it does not
#      execute it.
#
# Usage:
#   ./.scaffolding/scripts/scheme-status.sh            # human-readable report
#   ./.scaffolding/scripts/scheme-status.sh --field state
#   ./.scaffolding/scripts/scheme-status.sh --raw      # the JSON, unmodified
#
# Exit codes mirror the contract where an answer exists, plus one of our own:
#   0  answered (any state, including one that needs work)
#   2  ai-scheme could not answer
#   3  ai-scheme is not installed here (our code, not the contract's)

set -u

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

MODE="report"
FIELD=""
case "${1:-}" in
    --raw)   MODE="raw" ;;
    --field) MODE="field"; FIELD="${2:-}"
             if [ -z "$FIELD" ]; then echo "--field needs a name" >&2; exit 64; fi ;;
    "")      ;;
    *)       echo "unknown argument: $1" >&2; exit 64 ;;
esac

if ! command -v ai-scheme >/dev/null 2>&1; then
    if [ "$MODE" = "report" ]; then
        echo -e "${YELLOW}⚠ 骨架層 CLI (ai-scheme) 未安裝${NC}"
        echo "  這個專案的骨架層狀態無法得知。本層不推測——沒有答案就是沒有答案。"
        echo "  安裝後重跑：https://github.com/matheme-justyn/ai-scheme"
    fi
    exit 3
fi

PAYLOAD=$(ai-scheme status --json 2>/dev/null)
RC=$?

if [ "$MODE" = "raw" ]; then
    printf '%s\n' "$PAYLOAD"
    exit $RC
fi

if [ $RC -eq 2 ]; then
    if [ "$MODE" = "report" ]; then
        REASON=$(printf '%s' "$PAYLOAD" | python3 -c 'import json,sys;
try: print(json.load(sys.stdin).get("reason") or "")
except Exception: print("")' 2>/dev/null)
        echo -e "${RED}✗ 骨架層無法判斷此專案的狀態${NC}"
        [ -n "$REASON" ] && echo "  原因：$REASON"
        echo "  這不是可以自行推測的訊號。修好原因後重跑。"
    fi
    exit 2
fi

if [ $RC -ne 0 ]; then
    [ "$MODE" = "report" ] && echo -e "${RED}✗ ai-scheme status 以未預期的 exit code $RC 結束${NC}"
    exit $RC
fi

if [ "$MODE" = "field" ]; then
    printf '%s' "$PAYLOAD" | FIELD="$FIELD" python3 -c '
import json, os, sys
try:
    payload = json.load(sys.stdin)
except Exception:
    sys.exit(2)
value = payload.get(os.environ["FIELD"])
if value is None:
    print("")
elif isinstance(value, (list, tuple)):
    for item in value:
        print(item)
else:
    print(value)
'
    exit $?
fi

REPORT_PY="$(mktemp -t scheme-status-report)"
trap 'rm -f "$REPORT_PY"' EXIT
cat > "$REPORT_PY" <<'PY'
import json, sys

BLUE, GREEN, YELLOW, NC = "\033[0;34m", "\033[0;32m", "\033[1;33m", "\033[0m"

try:
    p = json.load(sys.stdin)
except Exception:
    print("\u2717 ai-scheme status returned something that is not JSON")
    sys.exit(2)

state = p.get("state", "?")
print(f"{BLUE}骨架層狀態：{state}{NC}")

reason = p.get("reason")
if reason:
    print(f"  原因：{reason}")

cur, tgt = p.get("current_version"), p.get("target_version")
if cur or tgt:
    print(f"  版本：{cur or '(未記錄)'} → {tgt or '(未知)'}")

for label, key in (("檔案 drift", "drift"), ("設定 drift", "policy_drift")):
    v = p.get(key)
    if v == "unknown":
        # "unknown" is a real answer: the check could not run. Reading it as
        # "none" would claim something nobody verified.
        print(f"  {label}：{YELLOW}unknown{NC}（檢查跑不起來，不等於沒有差異）")
    elif isinstance(v, list) and v:
        print(f"  {label}：{len(v)} 項")
        for item in v[:10]:
            print(f"    - {item}")
        if len(v) > 10:
            print(f"    … 另有 {len(v) - 10} 項")
    elif isinstance(v, list):
        print(f"  {label}：無")

nxt = p.get("next_command")
if nxt:
    print(f"{YELLOW}  下一步（由你執行，本腳本不代跑）：{NC}")
    print(f"    {nxt}")
else:
    print(f"{GREEN}  骨架層沒有待辦。{NC}")
    print("  這不代表機制層沒有——那是另一條軸。")
PY

printf '%s' "$PAYLOAD" | python3 "$REPORT_PY"
exit 0
