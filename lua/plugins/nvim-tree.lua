-- 文件树插件
return{
    "nvim-tree/nvim-tree.lua",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    opts = {
        actions = {
            open_file = {
                quit_on_open = true
            }
        }
    },
    keys = {
        {"<leader>uf",":NvimTreeToggle<CR>",desc = "打开/关闭文件树"}
    }
}
