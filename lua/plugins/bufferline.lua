return {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        -- 这里可以放一些 bufferline 的美化设置，比如：
        options = {
            separator_style = "slant", -- 分隔符样式
            always_show_bufferline = true,
            diagnostics = "nvim_lsp",
            -- 用 snacks.bufdelete 代替 :bdelete：只替换 buffer，不关闭当前窗口。
            -- 否则 sidekick 的终端分屏会成为唯一窗口并铺满屏幕。
            close_command = function(bufnum)
                require("snacks").bufdelete(bufnum)
            end,
            right_mouse_command = function(bufnum)
                require("snacks").bufdelete(bufnum)
            end,
            diagnostics_indicator = function(_, _, diagnostics_dict)
                local indicator = " "
                for level, number in pairs(diagnostics_dict) do
                    local symbol
                    if level == "error" then
                        symbol = " "
                    elseif level == "warning" then
                        symbol = " "
                    else
                        symbol = " "
                    end
                    indicator = indicator .. number .. symbol
                end
                return indicator
            end,
        }
    },
    keys = {
        -- 注意格式：{ "快捷键", "动作", desc = "描述" }
        { "<leader>bh", "<cmd>BufferLineCyclePrev<cr>", desc = "上一个 Buffer" },
        { "<leader>bl", "<cmd>BufferLineCycleNext<cr>", desc = "下一个 Buffer" },
        { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "选择一个 Buffer" },
        {
            "<leader>bd",
            function()
                require("snacks").bufdelete()
            end,
            desc = "关闭当前 Buffer",
        },
    },
    lazy = false,
}
