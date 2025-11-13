#!/bin/bash

echo "=== Removing comments in lib/ ==="

# 1. Remove lines that START with //
find lib -name "*.dart" -type f -exec sed -i '/^[[:space:]]*\/\//d' {} \;

# 2. Remove inline // comments (but keep URLs like http://)
find lib -name "*.dart" -type f -exec sed -i -E '
s:([^:])//.*$:\1: 
' {} \;

echo "=== Running dart format ==="
dart format lib

echo "=== Done! Cleaned all comments safely. ==="
