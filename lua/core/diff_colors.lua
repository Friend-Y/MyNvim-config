-- Make built-in diff mode clearly readable.
-- matugen.nvim re-applies DiffAdd/DiffDelete/DiffChange from its palette
-- (often with the same background as Normal), so override them again after
-- every ColorScheme event.
vim.opt.diffopt = "internal,filler,closeoff,algorithm:histogram,linematch:60"

local function apply_diff_highlights()
  vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1b4721", fg = "#aff5b4" })
  vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#4c1d1d", fg = "#ffdcd7" })
  vim.api.nvim_set_hl(0, "DiffChange", { bg = "#3d2f00", fg = "#ffe08a" })
  vim.api.nvim_set_hl(0, "DiffText", { bg = "#7d5a00", fg = "#ffffff" })
end

apply_diff_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("DiffColors", { clear = true }),
  callback = apply_diff_highlights,
  desc = "Keep diff colors readable after colorscheme changes",
})
