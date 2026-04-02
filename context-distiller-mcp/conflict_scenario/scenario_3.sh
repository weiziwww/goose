#!/bin/bash
# Scenario 3: Upstream updates a value, but the Fork renamed the variable.
# Base: a=1 -> Upstream: a=3 -> Fork: k=1 -> Goal: k=3

mkdir test-repo-3 && cd test-repo-3
git init

# 1. Base Project
echo 'function getConfig() {
  let maxRetries = 1;
  return maxRetries;
}' > config.js
git add config.js
git commit -m "chore: initial base setup"

# 2. Enterprise Fork (Renames the variable)
git checkout -b internal-fork
echo 'function getConfig() {
  // CUSTOM FORK LOGIC: rename to match internal terminology
  let retryLimit = 1; 
  return retryLimit;
}' > config.js
git add config.js
git commit -m "feat(PROJ-103): update terminology to retryLimit"

# 3. Upstream Upgrade (Increases the retry count)
git checkout main
echo 'function getConfig() {
  let maxRetries = 3; // UPSTREAM UPGRADE: 1 was too low
  return maxRetries;
}' > config.js
git add config.js
git commit -m "fix: increase maxRetries to 3 for better stability"

# 4. Trigger the Conflict!
git checkout internal-fork
git rebase main