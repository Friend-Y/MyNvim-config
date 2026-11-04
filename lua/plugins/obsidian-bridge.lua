return {
  "oflisback/obsidian-bridge.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = {
    "BufReadPre *.md",
    "BufNewFile *.md",
  },
  keys = {
    { "<leader>mbo", "<cmd>ObsidianBridgeOpenCurrentActiveFile<cr>", desc = "Bridge: 打开 Obsidian 当前笔记" },
    { "<leader>mbt", "<cmd>ObsidianBridgeToggle<cr>", desc = "Bridge: 切换启用状态" },
    { "<leader>mbn", "<cmd>ObsidianBridgeOn<cr>", desc = "Bridge: 启用" },
    { "<leader>mbf", "<cmd>ObsidianBridgeOff<cr>", desc = "Bridge: 停用" },
    { "<leader>mbd", "<cmd>ObsidianBridgeDailyNote<cr>", desc = "Bridge: 打开今日笔记" },
    { "<leader>mbg", "<cmd>ObsidianBridgeOpenGraph<cr>", desc = "Bridge: 打开关系图" },
    { "<leader>mbv", "<cmd>ObsidianBridgeOpenVaultMenu<cr>", desc = "Bridge: 切换 Vault" },
    { "<leader>mbp", "<cmd>ObsidianBridgePickCommand<cr>", desc = "Bridge: 选择 Obsidian 命令" },
  },
  opts = {
    -- 必须与 Obsidian 的 Local REST API 设置一致。
    -- 默认是非加密 HTTP 端口 27123。
    obsidian_server_address = "http://localhost:27123",

    -- 滚动同步需要打过补丁的 Local REST API；
    -- 没有安装补丁版时保持 false，否则会提示连接/同步失败。
    scroll_sync = true,

    -- 配置有问题时显示警告
    warnings = true,

    -- 与上面的选择保持一致
    picker = "telescope",
  },
}
