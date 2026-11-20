return {
  "nvimdev/lspsaga.nvim",
  cmd = "Lspsaga",
  opts = {
    finder = {
      keys = {
        toggle_or_open = "<CR>",
      },
    },
    -- `:Lspsaga peek_definition` 的悬浮窗：尺寸是当前窗口的比例
    definition = {
      width = 0.6,
      height = 0.5,
      number = true,
      keys = {
        quit = "q", -- 关闭当前这层速览窗
        close = "<Esc>", -- 关闭所有速览窗
        edit = "<C-o>", -- 在速览窗位置打开该定义
      },
    },
  },
  keys = {
    { "<leader>lr", "<cmd>Lspsaga rename<cr>", desc = "重命名符号" },
    { "<leader>lc", "<cmd>Lspsaga code_action<cr>", desc = "代码操作" },
    { "<leader>ld", "<cmd>Lspsaga peek_definition<cr>", desc = "速览定义（悬浮窗）" },
    { "<leader>lD", "<cmd>Lspsaga goto_definition<cr>", desc = "跳转到定义" },
    { "<leader>lh", "<cmd>Lspsaga hover_doc<cr>", desc = "查看文档" },
    { "<leader>lR", "<cmd>Lspsaga finder<cr>", desc = "查找引用" },
    { "<leader>ln", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "下一个诊断" },
    { "<leader>lp", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "上一个诊断" },
  },
}
