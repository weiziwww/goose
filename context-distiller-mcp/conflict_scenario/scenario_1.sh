# 1. Initialize the repo
mkdir test-repo-1 && cd test-repo-1
git init

# 2. Create the Upstream Base
echo 'function authenticate(username, password) {
  return username === "admin" && password === "secret";
}' > auth.js
git add auth.js
git commit -m "chore: initial auth setup"

# 3. Create the Enterprise Fork & Add Custom Logic
git checkout -b internal-fork
echo 'function authenticate(username, password) {
  // CUSTOM QA BYPASS
  if (username.endsWith("@internal.com")) return true;
  return username === "admin" && password === "secret";
}' > auth.js
git add auth.js
git commit -m "feat(PROJ-101): add QA bypass for internal testing"

# 4. Create the Upstream Architectural Change
git checkout main
echo 'function authenticate(requestObject) {
  const { user, pass } = requestObject.body;
  return user === "admin" && pass === "secret";
}' > auth.js
git add auth.js
git commit -m "refactor: switch auth to use request objects"

# 5. Trigger the Conflict!
git checkout internal-fork
git rebase main