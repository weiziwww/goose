#!/bin/bash
# Scenario 2: Upstream and Fork add different logic to the exact same block.
# Base: abc -> Upstream: a1bc -> Fork: ab2c -> Goal: a1b2c

mkdir test-repo-2 && cd test-repo-2
git init

# 1. Base Project
echo 'function generateCode() {
  let result = "a";
  result += "b";
  result += "c";
  return result;
}' > logic.js
git add logic.js
git commit -m "chore: initial base setup (abc)"

# 2. Enterprise Fork (Adds the "2")
git checkout -b internal-fork
echo 'function generateCode() {
  let result = "a";
  result += "b";
  result += "2"; // CUSTOM FORK LOGIC
  result += "c";
  return result;
}' > logic.js
git add logic.js
git commit -m "feat(PROJ-102): add custom string modifier (ab2c)"

# 3. Upstream Upgrade (Adds the "1")
git checkout main
echo 'function generateCode() {
  let result = "a";
  result += "1"; // UPSTREAM UPGRADE
  result += "b";
  result += "c";
  return result;
}' > logic.js
git add logic.js
git commit -m "refactor: upstream logic update (a1bc)"

# 4. Trigger the Conflict!
git checkout internal-fork
git rebase main