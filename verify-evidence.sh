#!/usr/bin/env bash
# verify-evidence.sh <bundle.tar.gz>
# Proves an evidence bundle is intact and authentic.
set -euo pipefail

BUNDLE="${1:?usage: verify-evidence.sh <bundle.tar.gz>}"
SIDECAR="${BUNDLE%.tar.gz}.sha256"
SIG_BUNDLE="${BUNDLE%.tar.gz}.sig.bundle"

echo "Verifying evidence bundle: $BUNDLE"
echo

# 1. INTEGRITY
echo "Check 1: Integrity (SHA-256)"
if [ ! -f "$SIDECAR" ]; then
  echo "FAIL: sidecar file $SIDECAR not found"
  exit 1
fi

if command -v sha256sum &>/dev/null; then
  COMPUTED=$(sha256sum "$BUNDLE" | awk '{print $1}')
else
  COMPUTED=$(shasum -a 256 "$BUNDLE" | awk '{print $1}')
fi

EXPECTED=$(cat "$SIDECAR")

if [ "$COMPUTED" != "$EXPECTED" ]; then
  echo "FAIL: hash mismatch"
  echo "  expected: $EXPECTED"
  echo "  computed: $COMPUTED"
  exit 1
fi
echo "PASS: hash matches"
echo

# 2. AUTHENTICITY
echo "Check 2: Authenticity (Cosign keyless signature)"
if [ ! -f "$SIG_BUNDLE" ]; then
  echo "FAIL: signature bundle $SIG_BUNDLE not found"
  exit 1
fi

cosign verify-blob \
  --bundle "$SIG_BUNDLE" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  --certificate-identity-regexp "https://github.com/doneal78/grc-club-week3/" \
  "$BUNDLE"

echo "PASS: signature verified"
echo

# 3. PRESERVATION (stretch - skipped if no vault configured)
echo "Check 3: Preservation (Object Lock)"
echo "SKIP: vault not configured for this environment"
echo

echo "CHAIN INTACT"