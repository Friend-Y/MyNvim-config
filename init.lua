if vim.g.vscode then
  -- VSCode + vscode-neovim：只加载适合 VSCode 的插件和快捷键
  require("core.vscode")
else
  require("core.basic")
  require("core.Keymap")
  require("core.diff_colors")
  require("core.lsp_highlight")
  require("core.syntax_colors")
  require("core.lazy")
  vim.opt.clipboard = "unnamedplus"
end
