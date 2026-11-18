-- 按窗口文本区宽度居中显示 $$...$$ 块级公式。
-- render-markdown.nvim 内置的 latex 渲染不支持多行块的窗口居中：
-- position = 'center' 只对单行公式有效，多行块会回退为左对齐显示在块上方。
-- 这里通过 custom_handlers.latex 接管块级公式：先转换，再按当前窗口宽度补前导空格。
local latex_cache = {}

local function latex_commands(converter)
  local list = type(converter) == "table" and converter or { converter }
  local commands = {}
  for _, cmd in ipairs(list) do
    if vim.fn.executable(cmd) == 1 then
      commands[#commands + 1] = cmd
    end
  end
  return commands
end

local function convert(cmd, input)
  local key = cmd .. "\0" .. input
  if latex_cache[key] == nil then
    local ok, result = pcall(function()
      local output = vim.system({ cmd }, { stdin = input, text = true }):wait()
      if output.code == 0 and output.stdout and output.stdout ~= "" then
        return output.stdout
      end
    end)
    latex_cache[key] = ok and result or false
  end
  return latex_cache[key] or nil
end

local function parse_latex(ctx)
  local config = require("render-markdown.state").get(ctx.buf)
  if not config.latex.enabled then
    return {}
  end

  local text = vim.treesitter.get_node_text(ctx.root, ctx.buf)
  -- 只处理 $$...$$ 块，行内 $...$ 仍交给插件内置处理
  if not text:match("^%s*%$%$") then
    return {}
  end

  local commands = latex_commands(config.latex.converter)
  if #commands == 0 then
    return {}
  end

  local formula = vim.trim(text:gsub("^%s*%$+%s*", ""):gsub("%s*%$+%s*$", ""))
  if formula == "" then
    return {}
  end

  local output = convert(commands[1], formula)
  if not output then
    return {}
  end

  local lines = vim.split(output, "\n", { plain = true })
  while #lines > 0 and lines[1]:match("^%s*$") do
    table.remove(lines, 1)
  end
  while #lines > 0 and lines[#lines]:match("^%s*$") do
    table.remove(lines)
  end
  if #lines == 0 then
    return {}
  end

  for _ = 1, config.latex.top_pad do
    table.insert(lines, 1, "")
  end
  for _ = 1, config.latex.bottom_pad do
    lines[#lines + 1] = ""
  end

  -- 窗口文本区宽度（扣除行号、sign 等列）
  local win = vim.fn.bufwinid(ctx.buf)
  local width
  if win ~= -1 then
    local info = vim.fn.getwininfo(win)[1]
    width = vim.api.nvim_win_get_width(win) - ((info and info.textoff) or 0)
  else
    width = vim.o.columns
  end

  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end
  local pad = math.max(0, math.floor((width - max_width) / 2))

  local rendered = {}
  for _, line in ipairs(lines) do
    rendered[#rendered + 1] = {
      { string.rep(" ", pad) .. line, config.latex.highlight },
    }
  end

  local start_row, start_col, end_row, end_col = ctx.root:range()
  return {
    {
      conceal = true,
      start_row = start_row,
      start_col = start_col,
      opts = {
        end_row = end_row,
        end_col = end_col,
        conceal_lines = "",
      },
      replace = rendered,
    },
  }
end

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  ft = 'markdown',
  opts = {
    code = {
      -- 保持 full 宽度：背景和顶部语言栏仍占满窗口；
      -- 代码文字按 (窗口宽度 - 代码宽度) 的 50% 右移，实现水平居中。
      width = 'full',
      left_margin = 0.5,
    },
    latex = {
      enabled = true,
      -- 需要系统里存在 latex2text（python-pylatexenc）或 utftex 之一
      converter = { 'latex2text', 'utftex' },
      inline = true,
      -- 块级公式由下面的 custom_handlers.latex 接管，关闭内置块渲染避免重复
      block = false,
      position = 'center',
    },
    custom_handlers = {
      latex = {
        extends = true,
        parse = parse_latex,
      },
    },
  },
}
