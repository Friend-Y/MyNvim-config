-- 在 Markdown 缓冲区里把 ```mermaid 代码块内联渲染成字符画（ASCII/Unicode 框线图）。
-- 依赖外部 CLI 渲染器：本机使用 termaid（Python，装在 ~/.local/share/termaid/venv，
-- 并 symlink 到 ~/.local/bin/termaid；重装命令：
--   python3 -m venv ~/.local/share/termaid/venv &&
--   ~/.local/share/termaid/venv/bin/pip install termaid &&
--   ln -sf ~/.local/share/termaid/venv/bin/termaid ~/.local/bin/termaid
-- 也可选 bm（npm i -g beautiful-mermaid-cli）、selkie（cargo install selkie-rs）、
-- mermaid-ascii（npm i -g mermaid-ascii）、merman-cli。本机只装 termaid，配置也把
-- cmd 写死在 termaid 上，不会自动去挑别的后端；:checkhealth render-markdown-mermaid 自检。
-- 选 termaid 而不是 bm 的原因：bm 渲染 `A["text [1, 8] 2"]` 这类标签会吞掉结尾的 `]`
-- 并保留开头的引号（渲染出 `"noise` / `[1, 8, 16, 16, 16`），且密集图上边框会互相穿插；
-- termaid 标签完整、支持 subgraph、边路走正交路由。
return {
  "cavanaug/render-markdown-mermaid.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "MeanderingProgrammer/render-markdown.nvim",
  },
  ft = "markdown",
  keys = {
    {
      "<leader>mz",
      "<cmd>MermaidFocus<cr>",
      desc = "Mermaid: 放大并滚动图表",
    },
    {
      "<leader>mc",
      "<cmd>MermaidToggle<cr>",
      desc = "Mermaid: 切换图表/源码",
    },
  },
  opts = {
    -- 生成字符画用的字符集：unicode 用框线字符，ascii 退化为 +-| 之类
    mode = "unicode",
    -- 图表显示在 mermaid 代码块的哪一侧（above / below）
    placement = "above",
    -- 显式指定后端，避免它按 PATH 顺序自动挑选到意外的东西。
    -- --gap 2：termaid 默认节点间距 4，调小可明显减少图宽高。
    cmd = { "termaid", "--gap", "2" },
    -- 关键：不要让本插件替我们调用 render-markdown.setup()。
    -- 它只会传入自己的 render_markdown 表，会把 lua/plugins/render-markdown.lua 里的
    -- latex 自定义处理器、code.width/left_margin 等配置整体覆盖回默认值。
    auto_setup_render_markdown = false,
    -- 不接管 <CR>：本插件默认会在 Markdown 缓冲区里用 buffer-local 的 <CR> 进入图表焦点模式，
    -- 这会与 obsidian.nvim 的 <CR>（跟随链接 / 换行）以及其它映射互相抢键。
    -- 改用上面的 <leader>mz 手动触发 :MermaidFocus。
    focus_key = false,
    -- 图表替换源码的折叠不由插件做（它的 replace 会在光标进入块或插入模式时失效），
    -- 而是由下面 config 里的 conceal_blocks 自己处理，效果始终一致。
    replace = false,
    -- 图表在窗口内水平居中（与 render-markdown 的公式居中风格一致）
    center = true,
    -- 预览最多占窗口高度的比例，超出时显示视口提示，可用 :MermaidFocus 滚动查看
    max_preview_lines = "75%",
    -- 编辑时延迟多少毫秒重新渲染
    debounce = 150,
    -- 按「源码 + 后端 + 参数」缓存渲染结果，来回移动光标不会重复调用 CLI
    cache = true,
    cli = {
      -- termaid 用到的两个参数：框内左右/上下留白，越小图越紧凑
      padding_x = 2,
      padding_y = 1,
    },
  },
  config = function(_, opts)
    require("render-markdown-mermaid").setup(opts)

    local display = require("render-markdown-mermaid.display")

    -- 全局开关：true = 渲染图表（用图表替换源码），false = 只显示源码
    local enabled = true

    -- 自己的命名空间，用来折叠 mermaid 块那几十行源码。
    -- 不用插件的 replace，是因为它一旦发现光标进入块内或进入插入模式就会把源码展开，
    -- 而这里希望「渲染模式」就是一直只看图表。
    local conceal_ns = vim.api.nvim_create_namespace("mermaid-conceal")

    local function conceal_blocks(buf)
      vim.api.nvim_buf_clear_namespace(buf, conceal_ns, 0, -1)
      local start
      for index, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        if start then
          if line:match("^%s*```%s*$") then
            -- 折叠范围：开启栅栏行 → 闭合栅栏行（行号与原插件使用的 extmark 区间一致）
            vim.api.nvim_buf_set_extmark(buf, conceal_ns, start - 1, 0, {
              end_row = index,
              end_col = 0,
              conceal_lines = "",
              priority = 199,
              strict = false,
            })
            start = nil
          end
        elseif line:match("^%s*```+%s*mermaid%s*$") then
          start = index
        end
      end
    end

    -- 插件本身没有开关，在渲染入口拦一道
    local render = display.render
    display.render = function(buf, config)
      if not enabled then
        vim.api.nvim_buf_clear_namespace(buf, conceal_ns, 0, -1)
        display.clear(buf)
        return
      end
      render(buf, config)
      conceal_blocks(buf)
    end

    local function refresh()
      local config = require("render-markdown-mermaid").config
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
          if enabled then
            display.schedule(buf, config, 0)
          else
            vim.api.nvim_buf_clear_namespace(buf, conceal_ns, 0, -1)
            display.clear(buf)
          end
        end
      end
    end

    -- <leader>mc：在「只看图表」和「只看源码」之间切换
    vim.api.nvim_create_user_command("MermaidToggle", function()
      enabled = not enabled
      refresh()
      vim.notify(enabled and "Mermaid: 渲染图表" or "Mermaid: 显示源码", vim.log.levels.INFO)
    end, { desc = "切换 Mermaid 图表 / 源码显示" })
  end,
}
