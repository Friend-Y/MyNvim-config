-- Separate related syntax colors that matugen maps to nearly identical tones.
-- Derived hues come from the active matugen palette, so they still follow the
-- current wallpaper while remaining distinguishable from keywords/variables.
local function rgb_to_hsl(r, g, b)
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l = 0, 0, (max + min) / 2
  local d = max - min

  if d ~= 0 then
    s = l > 0.5 and d / (2 - max - min) or d / (max + min)
    if max == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h / 6
  end
  return h, s, l
end

local function hue_to_rgb(p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if t < 1 / 6 then return p + (q - p) * 6 * t end
  if t < 1 / 2 then return q end
  if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
  return p
end

local function hsl_to_hex(h, s, l)
  local r, g, b
  if s == 0 then
    r, g, b = l, l, l
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue_to_rgb(p, q, h + 1 / 3)
    g = hue_to_rgb(p, q, h)
    b = hue_to_rgb(p, q, h - 1 / 3)
  end
  return string.format("#%02x%02x%02x", math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
end

local function adjust_hsl(hex, dh, ds, dl)
  if type(hex) ~= "string" or not hex:match("^#%x%x%x%x%x%x$") then
    return hex
  end
  local r = tonumber(hex:sub(2, 3), 16) / 255
  local g = tonumber(hex:sub(4, 5), 16) / 255
  local b = tonumber(hex:sub(6, 7), 16) / 255
  local h, s, l = rgb_to_hsl(r, g, b)
  h = (h + (dh or 0) / 360) % 1
  s = math.max(0, math.min(1, s + (ds or 0) / 100))
  l = math.max(0, math.min(1, l + (dl or 0) / 100))
  return hsl_to_hex(h, s, l)
end

local function shift_hue(hex, degrees)
  return adjust_hsl(hex, degrees, 0, 0)
end

local function read_palette()
  local path = "~/.cache/matugen/nvim-colors.json"
  local ok, matugen = pcall(require, "matugen")
  if ok and matugen.opts and matugen.opts.palette_path then
    path = matugen.opts.palette_path
  end
  path = vim.fn.expand(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end
  local lines = vim.fn.readfile(path)
  local decoded, palette = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not decoded or type(palette) ~= "table" then
    return nil
  end
  return palette
end

local function set(groups, color, extra)
  if not color then return end
  local opts = vim.tbl_extend("force", extra or {}, { fg = color })
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

local function apply()
  -- Do not touch another colorscheme's syntax palette.
  if vim.g.colors_name ~= "matugen" then
    return
  end

  local p = read_palette()
  if not p or not p.primary or not p.secondary or not p.tertiary then
    return
  end

  -- Gold keywords, teal functions, peach types, orange numbers,
  -- blue variables, green strings.
  local function_color = shift_hue(p.tertiary, 30)
  local type_color = shift_hue(p.primary, -18)
  local number_color = shift_hue(p.primary, -30)
  local string_color = adjust_hsl(p.tertiary, 0, 15, -5)
  local variable_color = shift_hue(p.tertiary, 75)

  set({ "Function", "@function", "@function.call", "@function.macro", "@function.method", "@function.method.call" }, function_color)
  set({ "@function.builtin" }, function_color, { italic = true })
  set({ "Type", "Structure", "Typedef", "@type", "@type.definition", "@constructor" }, type_color)
  set({ "@type.builtin" }, type_color, { italic = true })
  set({ "Number", "Float", "@number", "@number.float" }, number_color)
  set({ "Operator", "@operator", "@keyword.operator" }, number_color)
  set({ "@constant", "@constant.macro", "Constant" }, p.primary, { bold = true })
  set({
    "Identifier",
    "@variable",
    "@variable.member",
    "@variable.parameter",
    "@variable.other.member",
    "@property",
    "@field",
    -- LSP semantic tokens override Treesitter groups after the server attaches,
    -- so mirror the same colors here or variables revert to matugen defaults.
    "@lsp.type.variable",
    "@lsp.type.parameter",
    "@lsp.type.property",
    "@lsp.type.field",
  }, variable_color)
  set({
    "String",
    "Character",
    "@string",
    "@character",
    "@string.regexp",
    "@string.special",
    "@string.special.symbol",
    "@lsp.type.string",
    "@lsp.type.regexp",
  }, string_color, { italic = true })
  set({ "@lsp.type.function", "@lsp.type.method" }, function_color)
  set({
    "@lsp.type.class",
    "@lsp.type.struct",
    "@lsp.type.type",
    "@lsp.type.interface",
    "@lsp.type.typeParameter",
  }, type_color)
  set({ "@lsp.type.number" }, number_color)
  set({ "@lsp.type.operator" }, number_color)

  -- Make rendered LaTeX stand out from the Markdown text instead of blending in.
  set({ "@markup.math" }, p.on_surface)
  vim.api.nvim_set_hl(0, "MarkviewLatexBlock", {
    fg = p.on_surface,
    bg = p.surface_high,
  })
  vim.api.nvim_set_hl(0, "MarkviewLatexLabel", {
    fg = p.primary,
    bg = p.surface_high,
    bold = true,
  })
end

apply()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("SyntaxColorTweaks", { clear = true }),
  callback = apply,
  desc = "Separate similar matugen syntax colors",
})
