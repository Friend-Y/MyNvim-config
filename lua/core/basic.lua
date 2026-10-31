vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.autoread = true
-- 搜索时忽略大小写；如果输入中包含大写则区分大小写
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- 搜索后不要持续高亮匹配项
vim.opt.hlsearch = false
vim.env.LANGUAGE = "zh_CN:en_US"
vim.cmd('language zh_CN.utf8')
vim.opt.showmode = false
