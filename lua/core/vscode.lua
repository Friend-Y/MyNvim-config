-- VSCode + vscode-neovim 专用配置
-- 普通 Neovim 不会加载本文件（见 init.lua 的 vim.g.vscode 分支）。
--
-- 原则：
--   * 编辑类插件（surround / hop / which-key）保留
--   * Markdown 类插件（markdown-plus / mdkite）保留
--   * 文件/搜索类插件（telescope / nvim-tree / yazi）保留，但主键
--     使用 VSCode 原生功能；插件放在次要键上备用
--   * LSP、补全、高亮、状态栏、主题等交给 VSCode 原生功能

vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.timeoutlen = 300
vim.opt.scrolloff = 5

-- 加载 lua/vscode_plugins 下的插件子集
require("core.lazy")

--- 调用 VSCode 命令
---@param name string
---@return function
local function action(name)
  return function()
    require("vscode").action(name)
  end
end

local map = vim.keymap.set

-- 查找 / 文件 --------------------------------------------------------
map("n", "<leader>ff", action("workbench.action.quickOpen"), { desc = "查找文件（VSCode）" })
map("n", "<leader>fg", action("workbench.action.findInFiles"), { desc = "全库搜索（VSCode）" })
map("n", "<leader>fb", action("workbench.action.showAllEditors"), { desc = "切换缓冲区（VSCode）" })
map("n", "<leader>fh", action("workbench.action.showCommands"), { desc = "命令面板（VSCode）" })
map("n", "<leader>fo", action("workbench.action.gotoSymbol"), { desc = "文档大纲 / 符号（VSCode）" })
map("n", "<leader>fr", action("workbench.action.openRecent"), { desc = "最近文件（VSCode）" })
map("n", "<leader>fk", action("editor.action.findReferences"), { desc = "查找引用（VSCode）" })
map("n", "<leader>fF", "<cmd>Telescope find_files<cr>", { desc = "Telescope 查找文件（实验）" })
map("n", "<leader>fG", "<cmd>Telescope live_grep<cr>", { desc = "Telescope 实时搜索（实验）" })

-- 缓冲区 --------------------------------------------------------------
map("n", "<leader>bh", action("workbench.action.previousEditor"), { desc = "上一个编辑器" })
map("n", "<leader>bl", action("workbench.action.nextEditor"), { desc = "下一个编辑器" })
map("n", "<leader>bp", action("workbench.action.showAllEditors"), { desc = "选择编辑器" })
map("n", "<leader>bd", action("workbench.action.closeActiveEditor"), { desc = "关闭当前编辑器" })

-- 窗口 ----------------------------------------------------------------
map("n", "<leader>wd", action("workbench.action.closeActiveEditor"), { desc = "关闭当前编辑器" })
map("n", "<leader>wo", action("workbench.action.closeOtherEditors"), { desc = "关闭其他编辑器" })
map("n", "<leader>wv", action("workbench.action.splitEditorRight"), { desc = "向右分屏" })
map("n", "<leader>ws", action("workbench.action.splitEditorDown"), { desc = "向下分屏" })
map("n", "<leader>wh", action("workbench.action.focusLeftGroup"), { desc = "聚焦左侧组" })
map("n", "<leader>wj", action("workbench.action.focusBelowGroup"), { desc = "聚焦下方组" })
map("n", "<leader>wk", action("workbench.action.focusAboveGroup"), { desc = "聚焦上方组" })
map("n", "<leader>wl", action("workbench.action.focusRightGroup"), { desc = "聚焦右侧组" })

-- 文件浏览器 / 界面 ---------------------------------------------------
map("n", "<leader>uf", action("workbench.action.toggleSidebarVisibility"), { desc = "切换侧边栏" })
map("n", "<leader>uF", action("workbench.files.action.showActiveFileInExplorer"), { desc = "在资源管理器中定位当前文件" })
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "NvimTree 文件树（实验）" })

-- 文件管理 ------------------------------------------------------------
-- 主键使用 VSCode 资源管理器；Yazi 放在次要键上备用。
map("n", "<leader>yy", action("workbench.files.action.showActiveFileInExplorer"), { desc = "在资源管理器中定位当前文件" })
map("n", "<leader>yc", action("workbench.view.explorer"), { desc = "打开资源管理器" })
map("n", "<leader>yY", "<cmd>Yazi<cr>", { desc = "Yazi 当前文件（实验）" })
map("n", "<leader>yC", "<cmd>Yazi cwd<cr>", { desc = "Yazi 当前目录（实验）" })

-- LSP（交给 VSCode 原生）----------------------------------------------
map("n", "<leader>lr", action("editor.action.rename"), { desc = "重命名符号" })
map("n", "<leader>lc", action("editor.action.quickFix"), { desc = "代码操作 / 快速修复" })
map("n", "<leader>ld", action("editor.action.revealDefinition"), { desc = "跳转到定义" })
map("n", "<leader>lh", action("editor.action.showHover"), { desc = "查看文档 / 悬停" })
map("n", "<leader>lR", action("editor.action.findReferences"), { desc = "查找引用" })
map("n", "<leader>ln", action("editor.action.marker.nextInFiles"), { desc = "下一个诊断" })
map("n", "<leader>lp", action("editor.action.marker.prevInFiles"), { desc = "上一个诊断" })
map("n", "<leader>lf", action("editor.action.formatDocument"), { desc = "格式化当前文件" })

-- Git ----------------------------------------------------------------
map("n", "<leader>lg", action("workbench.view.scm"), { desc = "打开源代码管理" })

-- Markdown -----------------------------------------------------------
map("n", "<leader>mo", action("workbench.action.gotoSymbol"), { desc = "Markdown 大纲（VSCode）" })
map("n", "<leader>uo", action("workbench.action.gotoSymbol"), { desc = "Markdown 大纲（VSCode）" })
map("n", "<leader>mP", action("markdown.showPreviewToSide"), { desc = "VSCode Markdown 预览" })
map("n", "<leader>mn", action("workbench.action.files.newUntitledFile"), { desc = "新建文件" })
map("n", "<leader>mq", action("workbench.action.quickOpen"), { desc = "快速切换" })
map("n", "<leader>mf", action("workbench.action.findInFiles"), { desc = "搜索笔记" })
-- <leader>mp 由 mdkite 提供；Telescope / NvimTree / Yazi 的实验键见上。
