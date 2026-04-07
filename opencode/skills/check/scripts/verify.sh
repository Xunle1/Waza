#!/usr/bin/env bash
# Auto-detect a reasonable verification command for the current repo.
set -euo pipefail

if [ -f opencode/scripts/verify.sh ]; then
  bash opencode/scripts/verify.sh
elif [ -f Cargo.toml ]; then
  cargo check
  cargo test
elif [ -f package.json ] && grep -q '"typecheck"' package.json; then
  npm run typecheck
  if grep -q '"test"' package.json; then
    npm test
  fi
elif [ -f tsconfig.json ]; then
  npx tsc --noEmit
  if [ -f package.json ] && grep -q '"test"' package.json; then
    npm test
  fi
elif [ -f package.json ] && grep -q '"test"' package.json; then
  npm test
elif [ -f Makefile ] && grep -q '^test:' Makefile; then
  make test
elif [ -f pytest.ini ] || [ -f pyproject.toml ] || find . -maxdepth 2 -name 'test_*.py' | grep -q .; then
  pytest
else
  echo '(no verification command detected, ask the user what should serve as the gate)'
  exit 1
fi
