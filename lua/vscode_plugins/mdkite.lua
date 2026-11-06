return {
  "selimacerbas/mdkite.nvim",
  dependencies = {
    "selimacerbas/kitehost.nvim",
  },
  ft = "markdown",
  cmd = { "MdKite" },
  keys = {
    {
      "<leader>mp",
      "<cmd>MdKite toggle<cr>",
      desc = "MdKite: 浏览器预览",
    },
  },
  opts = {
    instance_mode = "takeover",
    port = 0,
    open_browser = true,
    default_theme = "dark",
    debounce_ms = 300,
  },
  config = function(_, opts)
    require("mdkite").setup(opts)
  end,
}
