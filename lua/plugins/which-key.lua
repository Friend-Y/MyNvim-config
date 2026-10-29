return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    -- 可以在这里进行基础配置，如设置弹出窗口的样式等
  },
  config = function()
    local wk = require("which-key")
    wk.setup({})
    -- 在这里注册你的中文快捷键描述
    wk.add({
      { "<leader>f", group = "查找" }, -- 将 <leader>f 定义为一个组，描述为“查找”
      -- 注意：下面这两行使用了 Telescope 插件，如果你还没装 Telescope，按了会报错，可以先注释掉
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "查找文件" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "实时搜索" },
      { "<leader>w", group = "窗口" },
      { "<leader>wd", "<C-W>c", desc = "关闭窗口" },
      { "<leader>l", group = "LSP" },
    })
  end,
}
