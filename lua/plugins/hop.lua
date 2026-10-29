return {
    "smoka7/hop.nvim",
    opts = {
        hint_position = 3,
    },
    keys = {
        -- 修改点：使用 <cmd> 替代冒号，并加上 desc 描述
        { "<leader>hp", "<cmd>HopWord<cr>", desc = "跳转至单词" },
    },
}
