return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>yy", "<cmd>Yazi<cr>", desc = "Open Yazi at the current file" },
    { "<leader>yc", "<cmd>Yazi cwd<cr>", desc = "Open Yazi in the current working directory" },
  },
  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
  },
}
