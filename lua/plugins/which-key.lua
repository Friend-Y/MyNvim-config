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

    local localleader = vim.g.maplocalleader or "\\"

    -- markdown-plus 的默认键位使用 <localleader>（当前是逗号）。
    -- 这里的 desc 只影响 which-key 的显示，不会改变实际按键。
    local markdown_plus_descriptions = {
      mb = "加粗",
      mi = "斜体",
      mS = "删除线",
      ["m`"] = "行内代码",
      ["m="] = "高亮",
      mu = "下划线",
      mF = "清除格式",
      ml = "插入链接",
      me = "编辑链接",
      ma = "URL 转链接",
      mR = "转为引用式链接",
      mI = "转为行内链接",
      mp = "智能粘贴",
      mc = "插入/包裹代码块",
      mC = "切换代码块语言",
      ms = "切换标题样式",
      ht = "生成目录",
      hu = "更新目录",
      hT = "打开目录窗口",
      h1 = "设为 H1",
      h2 = "设为 H2",
      h3 = "设为 H3",
      h4 = "设为 H4",
      h5 = "设为 H5",
      h6 = "设为 H6",
    }

    local configured_markdown_buffers = {}

    local function add_markdown_specs(buf)
      if configured_markdown_buffers[buf] then
        return
      end
      configured_markdown_buffers[buf] = true

      local specs = {
        { "<leader>m", group = "Markdown 文档", buffer = buf },
        { "<leader>mb", group = "Obsidian Bridge", buffer = buf },
        { localleader .. "m", group = "Markdown 编辑", buffer = buf },
        { localleader .. "h", group = "Markdown 标题", buffer = buf },
      }

      for key, desc in pairs(markdown_plus_descriptions) do
        table.insert(specs, {
          localleader .. key,
          desc = desc,
          buffer = buf,
        })
      end

      wk.add(specs)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(args)
        if vim.bo[args.buf].buftype == "" then
          add_markdown_specs(args.buf)
        end
      end,
    })

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if
        vim.api.nvim_buf_is_loaded(bufnr)
        and vim.bo[bufnr].filetype == "markdown"
        and vim.bo[bufnr].buftype == ""
      then
        add_markdown_specs(bufnr)
      end
    end

    -- 其他全局快捷键
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
