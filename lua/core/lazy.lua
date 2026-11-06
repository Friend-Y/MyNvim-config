local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

local plugin_dir = vim.g.vscode and "vscode_plugins" or "plugins"

require("lazy").setup({
    spec = {
        {import = plugin_dir},
    },
    {
        concurrency = 1,
        git = {
            throttle = {
                enable = true,
                rate = 1,
                duration = 15*1000,
            },
        },
    },
})
