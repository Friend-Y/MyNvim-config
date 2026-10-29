return {
  "nvimdev/lspsaga.nvim",
  cmd = "Lspsaga",
  opts = {
    finder = {
      keys = {
        toggle_or_open = "<CR>",
      },
    },
  },
  keys = {
    { "<leader>lr", "<cmd>Lspsaga rename<cr>", desc = "重命名符号" },
    { "<leader>lc", "<cmd>Lspsaga code_action<cr>", desc = "代码操作" },
    { "<leader>ld", "<cmd>Lspsaga definition<cr>", desc = "跳转到定义" },
    { "<leader>lh", "<cmd>Lspsaga hover_doc<cr>", desc = "查看文档" },
    { "<leader>lR", "<cmd>Lspsaga finder<cr>", desc = "查找引用" },
    { "<leader>ln", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "下一个诊断" },
    { "<leader>lp", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "上一个诊断" },
  },
}
