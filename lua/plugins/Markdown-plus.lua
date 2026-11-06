return {
  "yousefhadder/markdown-plus.nvim",
  ft = "markdown",
  opts = {
    keymaps = { enabled = true },
  },
  config = function(_, opts)
    require("markdown-plus").setup(opts)

    local function find_toc_window()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "markdown-toc" then
          return win
        end
      end
    end

    local function toc_width()
      -- 约占总列宽的 20%，同时保留一个可读的最小宽度
      return math.max(20, math.floor(vim.o.columns * 0.2))
    end

    local function place_toc(win)
      vim.api.nvim_set_current_win(win)
      vim.cmd("wincmd L")
      vim.api.nvim_win_set_width(win, toc_width())
    end

    local function toggle_toc()
      local toc_win = find_toc_window()
      if toc_win then
        place_toc(toc_win)
        return
      end

      -- 先让 markdown-plus 打开它自己的垂直分屏 TOC，
      -- 再把这个窗口移动到最右侧，形成固定在右边的目录栏。
      vim.cmd("Toc")
      toc_win = find_toc_window()
      if toc_win then
        place_toc(toc_win)
      end
    end

    -- 终端窗口缩放后重新保持 20% 宽度
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        local toc_win = find_toc_window()
        if toc_win then
          vim.api.nvim_win_set_width(toc_win, toc_width())
        end
      end,
    })

    local function set_toc_keymap(buf)
      vim.keymap.set("n", "<leader>uo", toggle_toc, {
        buffer = buf,
        desc = "查看 Markdown 目录",
      })
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(args)
        -- 跳过 TOC 自己的 scratch buffer
        if vim.bo[args.buf].buftype == "" then
          set_toc_keymap(args.buf)
        end
      end,
    })

    -- 当前已经打开的 Markdown buffer 不会再次触发 FileType，手动补一次
    if vim.bo.filetype == "markdown" and vim.bo.buftype == "" then
      set_toc_keymap(0)
    end
  end,
}
