#!/bin/bash
# Scenario 10: Premature cherry-pick — fork picked beta early; upstream tweaked before release; rebase fights near-duplicates.

mkdir test-repo-10 && cd test-repo-10
git init
git config user.email "scenario@example.com"
git config user.name "Scenario Bot"

# Step 1 (Base)
echo 'const port = 8080;' > server.js
git add server.js
git commit -m "chore: initial server port"

# Step 2 (Upstream Future): beta branch + note hash
git checkout -b upstream-beta
cat > server.js <<'EOF'
const port = process.env.PORT || 8080;
const secure = true;
EOF
git add server.js
git commit -m "feat(beta): env-based port and secure flag"

BETA_HASH="$(git rev-parse HEAD)"
echo ""
echo ">>> Cherry-pick this hash in Step 3: ${BETA_HASH}"
echo ""

# Step 3 (Fork Time Travel): from base commit, cherry-pick beta exactly
git checkout main
git checkout -b internal-fork
git cherry-pick "${BETA_HASH}"

# Fork-only follow-up: still on the old `secure` line shape from beta.
# Upstream will rename the symbol before release — replaying this hunk causes a messy conflict.
cat > server.js <<'EOF'
const port = process.env.PORT || 8080;
const secure = true;
console.log("fork: smoke test assumes upstream beta 'secure' flag name");
EOF
git add server.js
git commit -m "chore(fork): smoke test after early cherry-pick of beta"

# Step 4 (Upstream Official): tweak naming on beta, then merge into main
git checkout upstream-beta
cat > server.js <<'EOF'
const port = process.env.PORT || 8080;
const isSecureMode = true;
EOF
git add server.js
git commit -m "refactor(beta): rename secure -> isSecureMode for clarity"

git checkout main
git merge upstream-beta -m "release: merge upstream-beta into main"

# Step 5 (The Trap): rebase fork onto main — cherry-picked beta is skipped as already upstream;
# the fork-only commit replays onto renamed `isSecureMode` and conflicts.
git checkout internal-fork
set +e
git rebase main
REBASE_STATUS=$?
set -e
if [[ "${REBASE_STATUS}" -eq 0 ]]; then
  echo "NOTE: rebase completed without conflict (unexpected for this scenario)." >&2
  exit 1
fi
echo ""
echo ">>> Rebase stopped with conflicts (expected). Inspect with: git status"
echo ">>> Resolve server.js, then: git add server.js && git rebase --continue"
exit "${REBASE_STATUS}"
