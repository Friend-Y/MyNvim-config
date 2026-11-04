return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  -- 新版 nvim-treesitter 不支持懒加载，必须在启动时加载
  lazy = false,
  -- 插件更新时同步更新已安装的 parser
  build = ":TSUpdate",
  config = function()
    local nvim_treesitter = require("nvim-treesitter")
    nvim_treesitter.setup()

    -- 这里只放你希望自动安装/确保存在的 parser。
    -- 它和 LSP 没有对应关系：装了 Python LSP 不代表一定要装 python parser，
    -- 但想要 Python 的 treesitter 高亮/折叠时就需要。
    local ensure_installed = {
      "lua",
      "toml",
      "python",
      "markdown",
      "markdown_inline",
      "latex",
    }

    local pattern = {}

    for _, parser in ipairs(ensure_installed) do
      -- parser 已安装时，收集它对应的 filetype，供下面的 FileType autocmd 使用
      local has_parser = pcall(vim.treesitter.language.inspect, parser)
      if not has_parser then
        -- 新版 API：异步安装，不阻塞启动。装完后重启 Neovim 即可生效。
        nvim_treesitter.install(parser)
      else
        -- 注意：这里不能用 vim.tbl_extend("keep", ...)，
        -- 它会把第二个 parser 的 filetype 覆盖掉。
        pattern = vim.list_extend(pattern, vim.treesitter.language.get_filetypes(parser))
      end
    end

    -- 新版 nvim-treesitter 不会自动开启高亮，需要自己调用 vim.treesitter.start()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = pattern,
      callback = function()
        vim.treesitter.start()
      end,
    })

    -- 当前 buffer 的 FileType 在配置加载前可能已经触发过，手动补一次
    if vim.bo.filetype ~= "" then
      vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
    end
  end,
}
