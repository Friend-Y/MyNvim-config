#!/usr/bin/env bash
# Git 外部 diff 的 7 个参数：path old-file old-hex old-mode new-file new-hex new-mode
# 只取旧文件 $2 和新文件 $5
# diffopt 和高亮统一放在 ~/.config/nvim/lua/core/diff_colors.lua，
# 避免这里的 -c 参数过多，也能覆盖 matugen 的异步主题加载。
exec nvim -d "$2" "$5"

