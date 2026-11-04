return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = function()
    return {
      -- 你的实际 vault 路径
      workspaces = {
        {
          name = "MyVault",
          path = "~/Documents/Obsidian/MyVault/obsidian_-data",
        },
      },
      legacy_commands = false,
      -- 新笔记使用可读的标题作为文件名，而不是随机 zettel ID
      note_id_func = require("obsidian.builtin").title_id,
      -- 使用当前已安装的 Telescope 作为 picker
      picker = {
        name = "telescope.nvim",
      },
    }
  end,
  keys = {
    { "<leader>mc", "<cmd>Obsidian check<cr>", desc = "Obsidian: 检查配置" },
    { "<leader>mn", "<cmd>Obsidian new<cr>", desc = "Obsidian: 新建笔记" },
    { "<leader>mq", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian: 快速切换" },
    { "<leader>md", "<cmd>Obsidian today<cr>", desc = "Obsidian: 今日笔记" },
    { "<leader>ml", "<cmd>Obsidian backlinks<cr>", desc = "Obsidian: 反向链接" },
    { "<leader>mf", "<cmd>Obsidian search<cr>", desc = "Obsidian: 搜索笔记" },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)

    -- obsidian.nvim 的 UI 功能需要 conceallevel=2
    local function set_conceal()
      vim.wo.conceallevel = 2
    end

    vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
      pattern = "markdown",
      callback = set_conceal,
      desc = "Set conceallevel for Obsidian UI",
    })

    if vim.bo.filetype == "markdown" then
      set_conceal()
    end
  end,
}
