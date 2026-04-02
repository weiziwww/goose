#!/bin/bash
# Scenario 8: Upstream deletes/replaces a function that the Fork had customized.
# Goal: AI must move the Fork's custom proxy logic into the new Upstream function.

mkdir test-repo-8 && cd test-repo-8
git init

# 1. Base Project
echo 'function makeNetworkRequest(url) {
  return fetch(url);
}' > network.js
git add network.js
git commit -m "chore: simple network fetcher"

# 2. Enterprise Fork (Modifies the function)
git checkout -b internal-fork
echo 'function makeNetworkRequest(url) {
  // FORK: Route everything through internal proxy
  const proxyUrl = "http://internal-proxy.com/?url=" + url; 
  return fetch(proxyUrl);
}' > network.js
git add network.js
git commit -m "feat(PROJ-108): force all traffic through corporate proxy"

# 3. Upstream Upgrade (Deletes the function, makes a new one)
git checkout main
echo 'function performSecureRequest(requestData) { // UPSTREAM REPLACED IT
  console.log("Securing request...");
  return fetch(requestData.endpoint);
}' > network.js
git add network.js
git commit -m "refactor: replace makeNetworkRequest with performSecureRequest"

# 4. Trigger the Conflict!
git checkout internal-fork
git rebase main