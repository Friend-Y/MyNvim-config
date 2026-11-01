return {
  "echasnovski/mini.diff",
  version = false, -- 使用最新版
  config = function()
    local diff = require("mini.diff")
    diff.setup({
      -- 开启行内高亮和更细粒度的对比
      view = {
        style = "sign",
        signs = { add = "│", change = "│", delete = "─" },
      },
      -- 自定义高亮，对比非常强烈
      mappings = {
        -- 可选：添加快捷键，如 ]h 跳到下一个差异
        goto_next_hunk = "]h",
        goto_prev_hunk = "[h",
      },
    })
  end,
}
