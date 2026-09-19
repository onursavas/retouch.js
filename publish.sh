#!/usr/bin/env bash
# Release both packages to npm, in dependency order.
#
# Prerequisites: `npm login` (publishing prompts for an OTP), a clean tree on
# `main`, and versions already bumped (package.json ×2 + src/constants.ts —
# tests/version.test.ts keeps constants.ts honest).
#
# `pnpm publish` (not `npm publish`) is essential for @retouchjs/ml: it
# rewrites the `workspace:^` peer range to the real core version. Core goes
# first because that range points at it.
set -euo pipefail

echo "── Typecheck ──"
pnpm run typecheck

echo "── Lint ──"
pnpm run check

echo "── Test ──"
pnpm test

echo "── Build ──"
pnpm run build:all

echo "── Smoke (dist + tarballs) ──"
pnpm run smoke

echo "── Publish @retouchjs/core ──"
pnpm publish --access public

echo "── Publish @retouchjs/ml ──"
pnpm --filter @retouchjs/ml publish --access public

core_version=$(node -p "require('./package.json').version")
ml_version=$(node -p "require('./packages/ml/package.json').version")
echo "✓ Published @retouchjs/core@${core_version} and @retouchjs/ml@${ml_version}"
