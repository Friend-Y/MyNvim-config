return {
  "yousefhadder/markdown-plus.nvim",
  ft = "markdown",
  opts = {
    keymaps = { enabled = true },
  },
  config = function(_, opts)
    require("markdown-plus").setup(opts)
  end,
}
