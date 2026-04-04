#!/bin/bash
# Scenario 9: Hidden cross-file breakage — signature changes upstream; fork caller never conflicts.

mkdir test-repo-9 && cd test-repo-9
git init
git config user.email "scenario@example.com"
git config user.name "Scenario Bot"

# Step 1 (Base): math.js with positional args
cat > math.js <<'EOF'
function calculate(a, b) {
  return a + b;
}
module.exports = { calculate };
EOF
git add math.js
git commit -m "chore: add calculate(a, b)"

# Step 2 (Fork): new file calls calculate(100, 50)
git checkout -b internal-fork
cat > enterprise-billing.js <<'EOF'
const { calculate } = require('./math.js');
console.log('Enterprise billing line item:', calculate(100, 50));
EOF
git add enterprise-billing.js
git commit -m "feat(PROJ-901): wire billing to shared math helper"

# Step 3 (Upstream): object signature on main (callers must pass { a, b })
git checkout main
cat > math.js <<'EOF'
function calculate(options) {
  if (typeof options !== 'object' || options === null) {
    throw new Error('calculate expects an object: { a, b }');
  }
  return options.a + options.b;
}
module.exports = { calculate };
EOF
git add math.js
git commit -m "refactor!: calculate now takes an options object"

# Step 4 (The Trap): rebase fork — Git is clean; runtime is not
git checkout internal-fork
git rebase main

# Step 5 (The Proof): should throw — proves hidden breakage
node enterprise-billing.js
