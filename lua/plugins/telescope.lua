return {
  'nvim-telescope/telescope.nvim',
  version = '*', -- 推荐固定到最新发布版
  dependencies = {
    'nvim-lua/plenary.nvim', -- Telescope 的核心运行时依赖
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make', -- 为了获得更快的排序性能
    },
  },
  config = function()
    local telescope = require('telescope')
    telescope.setup({})
    telescope.load_extension('fzf') -- 加载 fzf-native 扩展
    
    -- 在这里设置你的快捷键
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope 查找文件' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope 实时搜索' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope 查找缓冲区' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope 查找帮助' })
  end,
}
