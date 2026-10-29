return {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        -- 这里可以放一些 bufferline 的美化设置，比如：
        options = {
            separator_style = "slant", -- 分隔符样式
            always_show_bufferline = true,
        }
    },
    keys = {
        -- 注意格式：{ "快捷键", "动作", desc = "描述" }
        { "<leader>bh", "<cmd>BufferLineCyclePrev<cr>", desc = "上一个 Buffer" },
        { "<leader>bl", "<cmd>BufferLineCycleNext<cr>", desc = "下一个 Buffer" },
        { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "选择一个 Buffer" },
        { "<leader>bd", "<cmd>bdelete<cr>", desc = "关闭当前 Buffer" },
    },
    lazy = false,
}
