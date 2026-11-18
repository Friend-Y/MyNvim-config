return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },

  opts = {
    legacy_commands = false, -- 使用 :Obsidian new/quick_switch/... 现代命令

    workspaces = {
      {
        name = "MyVault",
        path = vim.fs.normalize(vim.fn.expand("~/Documents/Obsidian/MyVault")),
      },
    },

    new_notes_location = "current_dir",

    -- 文件名=标题（保留中文和空格）；重名时追加 -2、-3。
    note_id_func = function(title, dir)
      if type(title) ~= "string" or vim.trim(title) == "" then
        return require("obsidian.builtin").zettel_id()
      end
      local base = vim.trim(title):gsub("%.md$", "")
      if base == "" then
        return require("obsidian.builtin").zettel_id()
      end
      if not dir then
        return base
      end
      local candidate, i = base, 2
      while vim.uv.fs_stat(vim.fs.joinpath(tostring(dir), candidate .. ".md")) do
        candidate = base .. "-" .. i
        i = i + 1
      end
      return candidate
    end,

    -- 新笔记不自动写 YAML frontmatter；已有 frontmatter 原样保留。
    note = { template = vim.NIL },
    frontmatter = { enabled = false },

    -- 粘贴图片直接存到当前笔记同级 图片/，不弹窗确认文件名。
    attachments = {
      folder = "./图片",
      confirm_img_paste = false,
    },

    link = { style = "wiki", format = "shortest" },

    ui = { enable = false },
    footer = { enabled = false },
    statusline = { enabled = false },

    picker = { name = "telescope.nvim" },
    completion = { min_chars = 2, create_new = true },
    checkbox = { create_new = false },

    callbacks = {
      enter_note = function()
        local buf = vim.api.nvim_get_current_buf()

        -- 光标在链接上时跟随，否则保留原生 gf。
        vim.keymap.set("n", "gf", function()
          if require("obsidian.api").cursor_link() then
            vim.cmd("Obsidian follow_link")
          else
            vim.cmd("normal! gf")
          end
        end, { buffer = buf, desc = "跟随 Wiki 链接" })

        -- 链接/标签上回车跳转，普通行仍是换行。
        vim.keymap.set("n", "<CR>", function()
          local api = require("obsidian.api")
          if api.cursor_link() then
            return "<cmd>Obsidian follow_link<cr>"
          elseif api.cursor_tag() then
            return "<cmd>Obsidian tags<cr>"
          end
          return "<CR>"
        end, { expr = true, buffer = buf, desc = "跟随链接 / 换行" })

        vim.keymap.set("n", "<leader>mR", "<cmd>Obsidian rename<cr>", {
          buffer = buf,
          desc = "重命名笔记并更新链接",
        })
      end,
    },
  },

  keys = {
    { "<leader>mn", "<cmd>Obsidian new<cr>", desc = "新建笔记" },
    { "<leader>mq", "<cmd>Obsidian quick_switch<cr>", desc = "快速切换笔记" },
    { "<leader>mf", "<cmd>Obsidian search<cr>", desc = "搜索笔记" },
    { "<leader>ml", "<cmd>Obsidian backlinks<cr>", desc = "反向链接" },
    { "<leader>md", "<cmd>Obsidian today<cr>", desc = "今日笔记" },
    { "<leader>mt", "<cmd>Obsidian tags<cr>", desc = "标签搜索" },
    { "<leader>mP", "<cmd>Obsidian paste_img<cr>", desc = "粘贴图片到附件" },
    { "<leader>mo", "<cmd>Obsidian open<cr>", desc = "在 Obsidian 中打开" },
  },
}
