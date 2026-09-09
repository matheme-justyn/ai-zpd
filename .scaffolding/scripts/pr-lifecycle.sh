#!/bin/bash
# pr-lifecycle.sh — the only way automation writes to a pull request's control plane.
#
# Worktrees isolate files. They do not isolate ready/draft, labels, milestone
# or merge: those live on GitHub and every session working the same pull
# request shares them. Two sessions writing at once race, and the loser's
# change disappears without an error.
#
# So every write goes through here, and here holds a lease first. The lease
# carrier is the skeleton layer's (ai-scheme scripts/lease.py, contract in its
# docs/lease-carrier.md). This file is the protocol: what must hold a lease,
# and what an agent does when it cannot get one. See ADR 0021.
#
# Usage:
#   pr-lifecycle.sh ready     --pr <n>
#   pr-lifecycle.sh draft     --pr <n>
#   pr-lifecycle.sh label     --pr <n> --add <label> [--remove <label>]
#   pr-lifecycle.sh milestone --pr <n> --set <milestone>
#   pr-lifecycle.sh merge     --pr <n> [--method squash|merge|rebase]
#
# Options:
#   --on-conflict report|wait|abort   somebody else holds the lease (default: report)
#   --wait-seconds <n>                with --on-conflict wait (default: 120)
#   --ttl <n>                         lease TTL in seconds (default: 300)
#   --local                           local ref only; default is --remote origin
#
# Exit codes, the same three the skeleton layer uses:
#   0  done
#   1  a definite no: lease held elsewhere, head moved, merge conditions not met
#   2  could not determine: gh failed, lease carrier missing or unreadable
#
# 2 is never downgraded to "nothing to do". Not being able to tell is not the
# same as there being nothing there, and the whole point of the lease is to
# stop automation from acting on a belief it cannot support.

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

die_unknown() { echo -e "${RED}✗ $*${NC}" >&2; exit 2; }
refuse()      { echo -e "${YELLOW}✗ $*${NC}" >&2; exit 1; }

ACTION="${1:-}"; shift || true
case "$ACTION" in
    ready|draft|label|milestone|merge) ;;
    *) echo "usage: pr-lifecycle.sh ready|draft|label|milestone|merge --pr <n> [...]" >&2; exit 64 ;;
esac

PR=""; ADD=""; REMOVE=""; MILESTONE=""; METHOD="squash"
ON_CONFLICT="report"; WAIT_SECONDS=120; TTL=300; REMOTE_ARGS=(--remote origin)

while [ $# -gt 0 ]; do
    case "$1" in
        --pr)           PR="${2:-}"; shift 2 ;;
        --add)          ADD="${2:-}"; shift 2 ;;
        --remove)       REMOVE="${2:-}"; shift 2 ;;
        --set)          MILESTONE="${2:-}"; shift 2 ;;
        --method)       METHOD="${2:-}"; shift 2 ;;
        --on-conflict)  ON_CONFLICT="${2:-}"; shift 2 ;;
        --wait-seconds) WAIT_SECONDS="${2:-}"; shift 2 ;;
        --ttl)          TTL="${2:-}"; shift 2 ;;
        --local)        REMOTE_ARGS=(); shift ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

[ -n "$PR" ] || { echo "--pr is required" >&2; exit 64; }
case "$ON_CONFLICT" in report|wait|abort) ;; *) echo "--on-conflict must be report, wait or abort" >&2; exit 64 ;; esac

# The lease carrier ships with the skeleton layer. Without it we cannot prove
# we hold a lease, and an unprovable lease is not a lease — refuse rather than
# fall back to writing unprotected.
LEASE="scripts/lease.py"
[ -f "$LEASE" ] || die_unknown "lease carrier not found at $LEASE. It ships with the skeleton layer (ai-scheme). Without it this layer cannot prove it holds a lease, and will not write unprotected."
command -v gh >/dev/null 2>&1 || die_unknown "gh is not installed; the pull request state cannot be read."

live_head() { gh pr view "$PR" --json headRefOid --jq .headRefOid 2>/dev/null; }
base_branch() { gh pr view "$PR" --json baseRefName --jq .baseRefName 2>/dev/null; }

HEAD_SHA="$(live_head)"
[ -n "$HEAD_SHA" ] || die_unknown "could not read the head SHA of PR #$PR."
BASE="$(base_branch)"
[ -n "$BASE" ] || die_unknown "could not read the base branch of PR #$PR."

# --- acquire -----------------------------------------------------------------
CAPABILITY=""
acquire_once() {
    CAPABILITY="$(python3 "$LEASE" acquire --pr "$PR" --base "$BASE" --head "$HEAD_SHA" --ttl "$TTL" "${REMOTE_ARGS[@]+"${REMOTE_ARGS[@]}"}" 2>/dev/null)"
    return $?
}

acquire_once; RC=$?
if [ $RC -eq 2 ]; then
    die_unknown "the lease carrier could not answer for PR #$PR. Not retried: exit 2 means the question failed, not that the answer was no."
fi
if [ $RC -ne 0 ]; then
    case "$ON_CONFLICT" in
        abort)  refuse "PR #$PR is leased by another session. Aborting as asked." ;;
        report) refuse "PR #$PR is leased by another session. No write attempted. Re-run with --on-conflict wait to queue." ;;
        wait)
            echo -e "${BLUE}⏳ PR #$PR is leased elsewhere; waiting up to ${WAIT_SECONDS}s${NC}"
            DEADLINE=$(( $(date +%s) + WAIT_SECONDS ))
            while [ "$(date +%s)" -lt "$DEADLINE" ]; do
                sleep 5
                acquire_once; RC=$?
                [ $RC -eq 0 ] && break
                [ $RC -eq 2 ] && die_unknown "the lease carrier stopped being able to answer while waiting."
            done
            [ $RC -eq 0 ] || refuse "still leased after ${WAIT_SECONDS}s. Giving up without writing."
            ;;
    esac
fi
[ -n "$CAPABILITY" ] || die_unknown "the lease carrier reported success but returned no capability."

# The capability never touches disk. One process per operation, released on the
# way out however we leave — including a refusal or a crash.
cleanup() { python3 "$LEASE" release --pr "$PR" --capability "$CAPABILITY" "${REMOTE_ARGS[@]+"${REMOTE_ARGS[@]}"}" >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo -e "${GREEN}✓ lease held on PR #$PR at ${HEAD_SHA:0:12}${NC}"

# --- prove the head has not moved -------------------------------------------
# The carrier compares the head we *declare* against the head the lease
# records. It never asks GitHub. So the check is only worth something if we
# re-read the live head here and declare that — declaring the lease's own value
# back to it would pass every time while the branch moved underneath.
assert_head_unmoved() {
    local now; now="$(live_head)"
    [ -n "$now" ] || die_unknown "could not re-read the head SHA of PR #$PR."
    if [ "$now" != "$HEAD_SHA" ]; then
        refuse "head moved ${HEAD_SHA:0:12} → ${now:0:12} while the lease was held. The work this lease covers is not the work that is there now; release and take a new one."
    fi
    python3 "$LEASE" renew --pr "$PR" --capability "$CAPABILITY" --head "$now" "${REMOTE_ARGS[@]+"${REMOTE_ARGS[@]}"}" >/dev/null 2>&1
    local rc=$?
    [ $rc -eq 2 ] && die_unknown "the lease carrier could not answer while renewing."
    [ $rc -ne 0 ] && refuse "the lease no longer covers this work (renew refused)."
    return 0
}

assert_head_unmoved

# --- the writes --------------------------------------------------------------
case "$ACTION" in
    ready)
        gh pr ready "$PR" >/dev/null 2>&1 || die_unknown "gh pr ready failed for PR #$PR."
        echo -e "${GREEN}✓ PR #$PR marked ready${NC}" ;;
    draft)
        gh pr ready "$PR" --undo >/dev/null 2>&1 || die_unknown "gh pr ready --undo failed for PR #$PR."
        echo -e "${GREEN}✓ PR #$PR returned to draft${NC}" ;;
    label)
        [ -n "$ADD" ] || [ -n "$REMOVE" ] || { echo "label needs --add or --remove" >&2; exit 64; }
        ARGS=()
        [ -n "$ADD" ]    && ARGS+=(--add-label "$ADD")
        [ -n "$REMOVE" ] && ARGS+=(--remove-label "$REMOVE")
        gh pr edit "$PR" "${ARGS[@]}" >/dev/null 2>&1 || die_unknown "gh pr edit failed for PR #$PR."
        echo -e "${GREEN}✓ PR #$PR labels updated${NC}" ;;
    milestone)
        [ -n "$MILESTONE" ] || { echo "milestone needs --set" >&2; exit 64; }
        gh pr edit "$PR" --milestone "$MILESTONE" >/dev/null 2>&1 || die_unknown "gh pr edit --milestone failed for PR #$PR."
        echo -e "${GREEN}✓ PR #$PR milestone set to $MILESTONE${NC}" ;;
    merge)
        # Everything below is re-read now, inside the lease, against the head
        # the lease covers. A judgement made before the lease was held is a
        # judgement about a different moment.
        REVIEW="$(gh pr view "$PR" --json reviewDecision --jq '.reviewDecision // ""' 2>/dev/null)" \
            || die_unknown "could not read the review decision for PR #$PR."
        [ -n "$REVIEW" ] || refuse "the review decision for PR #$PR is empty — the branch may require review that has not happened, or the field is unavailable. Stopping for a human rather than guessing."
        [ "$REVIEW" = "APPROVED" ] || refuse "review decision is $REVIEW, not APPROVED. Stopping for a human."

        CHECKS="$(gh pr view "$PR" --json statusCheckRollup --jq '[.statusCheckRollup[]? | (.conclusion // .state // "PENDING")] | join(" ")' 2>/dev/null)"
        RC=$?
        [ $RC -eq 0 ] || die_unknown "could not read the checks for PR #$PR."
        if [ -z "$CHECKS" ]; then
            refuse "PR #$PR reports no checks at all. That is indistinguishable here from checks that failed to report, so it is not treated as passing. Stopping for a human."
        fi
        for c in $CHECKS; do
            case "$c" in
                SUCCESS|NEUTRAL|SKIPPED) ;;
                *) refuse "a check is $c on PR #$PR. Stopping for a human." ;;
            esac
        done

        MERGEABLE="$(gh pr view "$PR" --json mergeStateStatus --jq '.mergeStateStatus // ""' 2>/dev/null)"
        case "$MERGEABLE" in
            CLEAN) ;;
            "" |UNKNOWN) refuse "GitHub reports the merge state as '${MERGEABLE:-empty}'. The active ruleset cannot be shown to be satisfied, so this stops for a human — an unknown is not a yes." ;;
            *) refuse "merge state is $MERGEABLE, not CLEAN. Stopping for a human." ;;
        esac

        assert_head_unmoved

        gh pr merge "$PR" "--$METHOD" >/dev/null 2>&1 || die_unknown "gh pr merge failed for PR #$PR after its conditions were verified."
        echo -e "${GREEN}✓ PR #$PR merged ($METHOD)${NC}" ;;
esac

exit 0
