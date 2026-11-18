local attachment_cache = {}

local function get_obsidian_context(file)
  if rawget(_G, "Obsidian") == nil then
    return nil
  end
  local ok, api = pcall(require, "obsidian.api")
  if not ok then
    return nil
  end
  local ok_ws, ws = pcall(api.find_workspace, file)
  if not ok_ws or not ws or not api.path_is_note(file, ws) then
    return nil
  end
  return api, ws
end

local function resolve_attachment(file, src)
  local api, ws = get_obsidian_context(file)
  if not api then
    return nil
  end
  if src:match("^%a[%w+.-]*://") or src:match("^data:") then
    return nil
  end
  src = src:gsub("^<", ""):gsub(">$", "")

  -- 先按 attachments.folder 规则解析
  local ok, direct = pcall(api.resolve_attachment_path, src, file)
  if ok and direct and vim.uv.fs_stat(direct) then
    return vim.fs.normalize(direct)
  end

  local root = vim.fs.normalize(tostring(ws.root or api.resolve_workspace_dir(file)))
  local note_dir = vim.fs.dirname(file)

  -- 带路径的引用：先按笔记目录，再按 vault 根目录
  if src:find("[/\\]") then
    local paths = {}
    if vim.startswith(src, "/") then
      paths[#paths + 1] = src
      paths[#paths + 1] = vim.fs.joinpath(root, src:sub(2))
    else
      paths[#paths + 1] = vim.fs.joinpath(note_dir, src)
      paths[#paths + 1] = vim.fs.joinpath(root, src)
    end
    for _, path in ipairs(paths) do
      path = vim.fs.normalize(path)
      if vim.uv.fs_stat(path) then
        return path
      end
    end
    return nil
  end

  -- 裸文件名：Obsidian 在整个 vault 内解析；重名时宁可不显示
  local key = root .. "\0" .. src
  local cached = attachment_cache[key]
  if cached ~= nil then
    return cached or nil
  end
  local found = vim.fs.find(src, { path = root, type = "file", limit = 2 })
  local hit = #found == 1 and vim.fs.normalize(found[1]) or nil
  attachment_cache[key] = hit or false
  return hit
end

local cache_group = vim.api.nvim_create_augroup("ObsidianImageResolveCache", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = cache_group,
  pattern = "ObsidianAttachmentAdded",
  callback = function()
    attachment_cache = {}
  end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
  group = cache_group,
  pattern = "*.md",
  callback = function()
    attachment_cache = {}
  end,
})

return {
  "folke/snacks.nvim",
  version = "*",
  lazy = false,
  priority = 1000,
  opts = {
    -- snacks 模块默认关闭；sidekick 的 optional 依赖会传入 picker 配置，
    -- 这里显式关闭，确保只启用 image。
    picker = { enabled = false },
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = true,
        max_width = 80,
        max_height = 40,
        -- 显示图片时隐藏嵌入文本；光标移到该行时恢复源码，便于编辑。
        conceal = function(_, kind)
          return kind == "image"
        end,
      },
      img_dirs = { "图片", "Pictures", "images", "assets", "attachments", "img" },
      math = { enabled = false }, -- LaTeX 交给 render-markdown
      resolve = resolve_attachment,
    },
  },
}
