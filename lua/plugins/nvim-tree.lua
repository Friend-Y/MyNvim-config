-- 文件树插件
return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        actions = {
            open_file = {
                quit_on_open = true,
            },
        },
        on_attach = function(bufnr)
            local api = require("nvim-tree.api")

            -- 先加载 nvim-tree 的默认键位，再覆盖下面三个
            api.map.on_attach.default(bufnr)

            local function opts(desc)
                return {
                    desc = "nvim-tree: " .. desc,
                    buffer = bufnr,
                    noremap = true,
                    silent = true,
                    nowait = true,
                }
            end

            -- l：展开文件夹；已展开则不动；在文件上则打开文件
            vim.keymap.set("n", "l", function()
                local node = api.tree.get_node_under_cursor()
                if not node then
                    return
                end
                if node.type == "directory" then
                    if not node.open then
                        api.node.open.edit(node)
                    end
                else
                    api.node.open.edit(node)
                end
            end, opts("展开文件夹/打开文件"))

            -- h：折叠文件夹；在文件上则回到父文件夹并折叠
            vim.keymap.set("n", "h", function()
                api.node.navigate.parent_close()
            end, opts("折叠文件夹"))

            -- 回车：只打开文件，文件夹交给 l/h
            vim.keymap.set("n", "<CR>", function()
                local node = api.tree.get_node_under_cursor()
                if node and node.type ~= "directory" then
                    api.node.open.edit(node)
                end
            end, opts("打开文件"))
        end,
    },
    keys = {
        { "<leader>uf", ":NvimTreeToggle<CR>", desc = "打开/关闭文件树" },
    },
}
