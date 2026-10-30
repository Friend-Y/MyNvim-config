-- ~/.config/nvim/lua/plugins/diffview-plus.lua
-- 添加diff插件
return {
  "dlyongemallo/diffview-plus.nvim",
  version = "*", -- 建议锁定版本以获得稳定性
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview Plus" },
  },
  opts = {},
}
