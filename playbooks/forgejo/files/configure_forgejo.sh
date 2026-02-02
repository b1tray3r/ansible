#!/usr/bin/env bash
set -euo pipefail

if [ -f /data/.initialized ]; then
    echo "Forgejo already initialized, skipping..."
    exit 0
fi

echo '==== BEGIN FORGEJO CONFIGURATION ===='

attempt=0
max_attempts=30
until getent hosts db > /dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
        echo "Timeout waiting for db hostname to resolve"
        exit 1
    fi
    echo "Waiting for db hostname to resolve... ($attempt/$max_attempts)"
    sleep 2
done
echo "Database hostname resolved: $(getent hosts db)"

gitea migrate || {
    echo "Forgejo migrate failed"
    exit 1
}

attempt=0
until gitea admin user list 2>/dev/null | head -1; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
        echo "Timeout waiting for database"
        exit 1
    fi
    echo "Waiting for database... ($attempt/$max_attempts)"
    sleep 2
done
echo "Database is ready."

ADMIN_USERNAME="${FORGEJO_ADMIN_USERNAME:-admin}"
ADMIN_PASSWORD="${FORGEJO_ADMIN_PASSWORD:-changeme}"
ADMIN_EMAIL="${FORGEJO_ADMIN_EMAIL:-admin@borgardt.me}"

echo "Checking for admin user..."
if gitea admin user list --admin 2>/dev/null | grep -q "${ADMIN_USERNAME}"; then
    echo "Admin account '${ADMIN_USERNAME}' already exists."
else
    echo "Creating admin user '${ADMIN_USERNAME}'..."
    gitea admin user create \
        --admin \
        --username "${ADMIN_USERNAME}" \
        --password "${ADMIN_PASSWORD}" \
        --email "${ADMIN_EMAIL}" \
        --must-change-password=false
    echo "...created."
fi

touch /data/.initialized
echo '==== END FORGEJO CONFIGURATION ===='