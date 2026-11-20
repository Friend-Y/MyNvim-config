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
			-- 安装 snacks.nvim 后默认会改用 snacks picker；继续使用 Telescope，
			-- 保持 <C-p> prompt picker 的现有行为。
			picker = "telescope",
			win = {
				layout = "right",
				split = {
					width = 0, -- 设为 0 以跳过默认的尺寸解析逻辑
				},
				-- sidekick 默认把 <C-b>/<C-f> 用于自己的 buffer/file picker，
				-- 这两个键永远不会到达 Claude Code。禁用后 Claude Code 的
				-- transcript 整页滚动（Ctrl-B/Ctrl-F）可用。
				keys = {
					buffers = false,
					files = false,
					-- 主用 <C-S-z>；保留默认 <C-z> 作为 CLI 内的兜底 blur，
					-- 避免 Ctrl+Z 被终端当作挂起。编辑器里的 <C-z> 仍是 undo。
					blur = { "<C-S-z>", "blur", mode = { "n", "t" }, desc = "离开 CLI 窗口" },
				},
				-- 在 win 内部通过 config 回调动态设置正整数宽度
				config = function(terminal)
					terminal.opts.split.width = math.floor(vim.o.columns * 0.35)
				end,
			},
		},
	},

	keys = {
		-- <leader>at / <leader>af 只映射 normal 模式：终端模式下以空格开头的
		-- leader 序列会截获 Claude 输入中的空格并等待 timeoutlen。
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
			mode = "n",
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
			"<leader>aF",
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
			"<leader>af",
			function()
				require("sidekick.cli").focus()
			end,
			desc = "聚焦到 Agent 窗口",
			mode = "n",
		},
		{
			-- CLI 内的 buffer-local blur 映射优先；这里负责从编辑器聚焦 CLI。
			"<C-S-z>",
			function()
				require("sidekick.cli").focus()
			end,
			desc = "聚焦/切换到 Agent 窗口",
			mode = "n",
		},
	},

	config = function(_, opts)
		-- 手动执行插件 setup，确保 opts 中的配置被加载
		require("sidekick").setup(opts)

		-- 你额外的 Neovim 设置
		vim.o.autoread = true

		-- :q 只关闭当前窗口，不是退出 Neovim。关掉编辑器窗口后 Sidekick 的
		-- 终端分屏就成了唯一窗口，于是铺满整个屏幕。这里在“关掉最后一个非
		-- Sidekick 窗口、屏幕上只剩 Agent 窗口”时，结束会话并直接退出。
		local group = vim.api.nvim_create_augroup("sidekick_quit", { clear = true })
		vim.api.nvim_create_autocmd("WinClosed", {
			group = group,
			callback = function(args)
				local closing = tonumber(args.match)
				-- 在 Agent 窗口里 :q 只关分屏，保持默认行为
				if not closing or (vim.w[closing] and vim.w[closing].sidekick_cli) then
					return
				end
				-- 还有别的普通窗口时也不接管（比如 help、quickfix、浮窗）
				local rest = {}
				for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
					for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
						if win ~= closing then
							rest[#rest + 1] = win
						end
					end
				end
				if #rest == 0 then
					return
				end
				for _, win in ipairs(rest) do
					if not (vim.w[win] and vim.w[win].sidekick_cli) then
						return
					end
				end
				-- WinClosed 触发时窗口还没从布局里移除，延后到布局更新后再操作
				vim.schedule(function()
					require("sidekick.cli").close({ all = true })
					vim.cmd("quitall")
				end)
			end,
		})
	end,
}
