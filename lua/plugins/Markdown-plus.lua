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

    -- 在 TOC 中按回车跳转到章节后关闭 TOC 窗口。
    -- markdown-plus 默认的 <CR> 只跳转、不关闭；这里在 FileType 阶段先设置
    -- buffer-local <CR>，插件的 keymap_helper 检测到已有映射后会跳过自己的默认映射。
    local function jump_and_close_toc()
      local toc_win = vim.api.nvim_get_current_win()
      local toc_state = require("markdown-plus.headers.toc_state")
      local source_buf = toc_state.state.source_bufnr

      require("markdown-plus.headers.toc_actions").jump_to_header()

      -- jump_to_header 找不到源窗口时会留在 TOC；此时不要关闭。
      if
        source_buf
        and vim.api.nvim_get_current_buf() == source_buf
        and vim.api.nvim_win_is_valid(toc_win)
      then
        vim.api.nvim_win_close(toc_win, true)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("MarkdownPlusTocJumpClose", { clear = true }),
      pattern = "markdown-toc",
      callback = function(args)
        vim.keymap.set("n", "<CR>", jump_and_close_toc, {
          buffer = args.buf,
          desc = "跳转到章节并关闭大纲",
          silent = true,
          nowait = true,
        })
      end,
    })

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
