return {
	"mason-org/mason.nvim",
	event = "VeryLazy",
	dependencies = {
		"neovim/nvim-lspconfig",
		-- 关闭自动 enable，等配置好 capabilities / on_attach 后再手动启用
		{ "mason-org/mason-lspconfig.nvim", opts = { automatic_enable = false } },
	},
	opts = {},
	config = function(_, opts)
		require("mason").setup(opts)

		local registry = require("mason-registry")
		local mappings = require("mason-lspconfig").get_mappings().package_to_lspconfig

		local function install(name)
			local success, package = pcall(registry.get_package, name)
			if success and not package:is_installed() then
				package:install()
			end
		end

		local function setup(name, config)
			install(name)

			local lsp = mappings[name]
			if not lsp then
				vim.notify("mason-lspconfig 中没有 " .. name .. " 的映射", vim.log.levels.WARN)
				return
			end

			config = config or {}
			config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)

			local on_attach = config.on_attach
			config.on_attach = function(client, bufnr)
				-- 格式化统一交给 none-ls，避免多个 client 同时提供格式化
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
				if on_attach then
					on_attach(client, bufnr)
				end
			end

			vim.lsp.config(lsp, config)
			vim.lsp.enable(lsp)
		end
		-- 添加其他的lsp是使用[名称]={};
		local servers = {
			["lua-language-server"] = {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			},
			["pyright"] = {},
		}
		for server, config in pairs(servers) do
			setup(server, config)
		end
		vim.diagnostic.config({ update_in_insert = true })

		-- Mason 在 VeryLazy 才加载，此时当前 buffer 的 FileType 已经触发过；
		-- 手动再触发一次，让 vim.lsp.enable() 能附加到启动时打开的 buffer。
		if vim.bo.filetype ~= "" then
			vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
		end
	end,
}
