#!/bin/bash
# Scenario 7: Both branches added a new item to the end of an array.
# Goal: AI must merge the array to include both "sso-saml" and "dark-mode".

mkdir test-repo-7 && cd test-repo-7
git init

# 1. Base Project
echo 'const activeFeatures = [
  "dashboard",
  "profile"
];' > config.js
git add config.js
git commit -m "chore: default features"

# 2. Enterprise Fork (Adds SSO)
git checkout -b internal-fork
echo 'const activeFeatures = [
  "dashboard",
  "profile",
  "sso-saml" // FORK CUSTOM FEATURE
];' > config.js
git add config.js
git commit -m "feat(PROJ-107): enable SAML Single Sign-On"

# 3. Upstream Upgrade (Adds Dark Mode)
git checkout main
echo 'const activeFeatures = [
  "dashboard",
  "profile",
  "dark-mode" // UPSTREAM NEW FEATURE
];' > config.js
git add config.js
git commit -m "feat: release dark mode feature"

# 4. Trigger the Conflict!
git checkout internal-fork
git rebase main