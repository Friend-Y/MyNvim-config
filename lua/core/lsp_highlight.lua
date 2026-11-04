-- VS Code-like highlighting of the symbol under the cursor.
-- The language server returns all read/write occurrences of the symbol, and
-- Neovim highlights them through LspReference{Text,Read,Write}.
vim.opt.updatetime = 300

-- matugen gives LspReferenceText the same background as CursorLine, which is
-- almost invisible. Reuse the much stronger Visual background instead.
local function apply_reference_highlights()
  vim.api.nvim_set_hl(0, "LspReferenceText", { link = "Visual" })
  vim.api.nvim_set_hl(0, "LspReferenceRead", { link = "Visual" })
  vim.api.nvim_set_hl(0, "LspReferenceWrite", { link = "Visual" })
  vim.api.nvim_set_hl(0, "LspReferenceTarget", { link = "Visual" })
end

apply_reference_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("LspReferenceColors", { clear = true }),
  callback = apply_reference_highlights,
  desc = "Keep LSP occurrence highlights visible after theme reloads",
})

local function attach(buf)
  local group = vim.api.nvim_create_augroup("LspDocumentHighlight_" .. buf, { clear = true })

  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = group,
    buffer = buf,
    callback = vim.lsp.buf.document_highlight,
    desc = "高亮当前符号的所有引用",
  })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
    group = group,
    buffer = buf,
    callback = vim.lsp.buf.clear_references,
    desc = "清除符号引用高亮",
  })
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      attach(args.buf)
    end
  end,
  desc = "Enable symbol occurrence highlighting when a server attaches",
})
