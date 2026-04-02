#!/bin/bash
# Scenario 5: Upstream changes libraries, Fork has custom logic injected in the function.
# Goal: AI must keep the Fork's analytics tracker, but adopt the Upstream's new library.

mkdir test-repo-5 && cd test-repo-5
git init

# 1. Base Project
echo 'const fetch = require("node-fetch");
function getUser() {
  return fetch("/api/user");
}' > api.js
git add api.js
git commit -m "chore: basic api fetcher"

# 2. Enterprise Fork (Injects custom analytics)
git checkout -b internal-fork
echo 'const fetch = require("node-fetch");
const tracker = require("./internal-tracker"); // CUSTOM FORK

function getUser() {
  tracker.log("User data requested"); // CUSTOM FORK
  return fetch("/api/user");
}' > api.js
git add api.js
git commit -m "feat(PROJ-105): add internal telemetry to api calls"

# 3. Upstream Upgrade (Swaps to Axios)
git checkout main
echo 'const axios = require("axios");
function getUser() {
  return axios.get("/api/user");
}' > api.js
git add api.js
git commit -m "refactor: migrate from node-fetch to axios"

# 4. Trigger the Conflict!
git checkout internal-fork
git rebase main