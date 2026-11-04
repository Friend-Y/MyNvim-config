vim.keymap.set({"n","i"},"<C-z>","<Cmd>undo<CR>",{silent = true})
vim.g.mapleader = " "
vim.g.maplocalleader = ","
-- 在 Visual 模式下，按 Ctrl+C 复制到系统剪贴板
vim.keymap.set('v', '<C-c>', '"+y', { desc = 'Copy to system clipboard' })
