#!/bin/zsh
# Simple auto-commit script for RoundsProactive
msg=${1:-"update"}
echo "🔄 Committing: $msg"
git add .
git commit -m "$msg"
git push origin main
echo "✅ All changes pushed to GitHub: https://github.com/loudkatie/RoundsProactive"

