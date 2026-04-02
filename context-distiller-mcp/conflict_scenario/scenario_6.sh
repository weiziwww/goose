#!/bin/bash
# Scenario 6: Both branches added different imports to the top of the file.
# Goal: AI must keep both the Upstream logger and the Fork's custom auth.

mkdir test-repo-6 && cd test-repo-6
git init

# 1. Base Project
echo 'const { helper } = require("./utils");

function run() {
  return helper();
}' > index.js
git add index.js
git commit -m "chore: initial setup"

# 2. Enterprise Fork (Adds Custom Auth)
git checkout -b internal-fork
echo 'const { customAuth } = require("./enterprise-security"); // FORK
const { helper } = require("./utils");

function run() {
  customAuth.verify();
  return helper();
}' > index.js
git add index.js
git commit -m "feat(PROJ-106): require enterprise auth before running"

# 3. Upstream Upgrade (Adds Logger)
git checkout main
echo 'const { logger } = require("./logger"); // UPSTREAM
const { helper } = require("./utils");

function run() {
  logger.info("Running system...");
  return helper();
}' > index.js
git add index.js
git commit -m "feat: add system logging"

# 4. Trigger the Conflict!
git checkout internal-fork
git rebase main