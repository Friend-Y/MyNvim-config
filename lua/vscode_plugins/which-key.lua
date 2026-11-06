return {
  "folke/which-key.nvim",
  lazy = false,
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {},
  config = function()
    local wk = require("which-key")
    wk.setup({})

    -- 只添加分组标签，不在这里创建键位，避免覆盖 core.vscode 中的 VSCode 映射。
    wk.add({
      { "<leader>f", group = "查找" },
      { "<leader>b", group = "缓冲区" },
      { "<leader>w", group = "窗口" },
      { "<leader>l", group = "LSP" },
      { "<leader>u", group = "界面" },
      { "<leader>y", group = "文件管理" },
      { "<leader>m", group = "Markdown" },
      { ",m", group = "Markdown 编辑" },
      { ",h", group = "Markdown 标题" },
    })
  end,
}
