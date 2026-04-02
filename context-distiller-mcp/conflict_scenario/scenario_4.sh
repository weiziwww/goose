#!/bin/bash
# Scenario 4: Upstream nests an object, Fork added a property to the flat object.
# Goal: The AI must put the Fork's property inside the new Upstream nested structure.

mkdir test-repo-4 && cd test-repo-4
git init

# 1. Base Project
echo 'const dbConfig = {
  host: "localhost",
  port: 5432
};' > database.js
git add database.js
git commit -m "chore: setup database config"

# 2. Enterprise Fork (Adds a custom property)
git checkout -b internal-fork
echo 'const dbConfig = {
  host: "localhost",
  port: 5432,
  sslCert: "/var/internal/cert.pem" // CUSTOM FORK LOGIC
};' > database.js
git add database.js
git commit -m "feat(PROJ-104): add internal SSL cert requirement"

# 3. Upstream Upgrade (Nests the connection details)
git checkout main
echo 'const dbConfig = {
  connection: {
    host: "localhost",
    port: 5432
  }
};' > database.js
git add database.js
git commit -m "refactor: group db settings into connection object"

# 4. Trigger the Conflict!
git checkout internal-fork
git rebase main