return {
	"folke/sidekick.nvim",
	version = "*", -- 建议确保实际版本 >= 2.0.0

	dependencies = {
		{
			"folke/snacks.nvim",
			optional = true,
			opts = {
				picker = {
					actions = {
						sidekick_send = function(...)
							return require("sidekick.cli.picker.snacks").send(...)
						end,
					},
					win = {
						input = {
							keys = {
								["<a-a>"] = { "sidekick_send", mode = { "n", "i" } },
							},
						},
					},
				},
			},
		},
	},

	opts = {
		cli = {
			win = {
				layout = "right",
				split = {
					width = 0, -- 设为 0 以跳过默认的尺寸解析逻辑
				},
				-- 在 win 内部通过 config 回调动态设置正整数宽度
				config = function(terminal)
					terminal.opts.split.width = math.floor(vim.o.columns * 0.35)
				end,
			},
		},
	},

	keys = {
		{
			"<leader>aa",
			function()
				require("sidekick.cli").select()
			end,
			desc = "选择并启动 AI Agent",
			mode = { "n", "x" },
		},
		{
			"<leader>at",
			function()
				require("sidekick.cli").toggle({ focus = true })
			end,
			desc = "切换 Agent 终端窗口",
			mode = { "n", "t" },
		},
		{
			"<leader>ad",
			function()
				require("sidekick.cli").hide()
			end,
			desc = "隐藏 Agent 窗口（进程保留）",
			mode = "n",
		},
		{
			"<leader>ai",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			desc = "发送光标上下文给 Agent",
			mode = { "n", "x" },
		},
		{
			"<leader>af",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "发送当前文件给 Agent",
			mode = "n",
		},
		{
			"<leader>av",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			desc = "发送选中代码给 Agent",
			mode = "x",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			desc = "打开预设提示词选择器",
			mode = { "n", "x" },
		},
		{
			"<leader>aF",
			function()
				require("sidekick.cli").focus()
			end,
			desc = "聚焦到 Agent 窗口",
			mode = { "n", "t" },
		},
	},

	config = function(_, opts)
		-- 手动执行插件 setup，确保 opts 中的配置被加载
		require("sidekick").setup(opts)

		-- 你额外的 Neovim 设置
		vim.o.autoread = true
	end,
}
