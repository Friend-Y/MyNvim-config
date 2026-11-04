return {
  "selimacerbas/mdkite.nvim",
  -- mdkite 依赖 kitehost.nvim 提供本地 HTTP/SSE 服务
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
    -- 所有实例共用一个浏览器标签页
    instance_mode = "takeover",
    -- 0 表示自动选择端口
    port = 0,
    open_browser = true,
    -- 与当前 Neovim 主题保持一致，使用深色预览
    default_theme = "dark",
    debounce_ms = 300,
  },
  config = function(_, opts)
    require("mdkite").setup(opts)
  end,
}
