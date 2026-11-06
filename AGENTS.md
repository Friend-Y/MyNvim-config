# AGENTS.md

Personal Neovim config loaded from `~/.config/nvim`. There is no build, test suite, CI, linter, or formatter. Changes take effect in the user's live editor.

## Layout and wiring

- `init.lua` requires `core.basic` -> `core.Keymap` -> `core.lazy` in that order. `lua/core/Keymap.lua` sets `vim.g.mapleader` to **space**; keep leader setup before `core.lazy` so lazy-loaded plugin `keys` see it.
- `lua/plugins/*.lua` are auto-imported by lazy.nvim (`{ import = "plugins" }`). Each file must `return` a single plugin spec; there is no registration file to update.
- `lua/core/module.lua` is empty and unused.
- `lazy-lock.json` pins plugin commits. Don't hand-edit it; use `:Lazy restore` to match it or `:Lazy sync` to install/update. lazy.nvim bootstraps itself on first launch (`lua/core/lazy.lua`).
- Restart Neovim after changing plugin specs; re-sourcing the config is not supported by lazy.nvim.

## Conventions and gotchas

- Put plugin keymaps in that plugin's spec (`keys` or `config`), not `core/Keymap.lua`; always include a `desc`.
- UI and `desc` strings are Chinese on purpose, and `core/basic.lua` forces the `zh_CN` locale. Keep new descriptions Chinese; don't remove the locale settings.
- Telescope keys are defined twice: functions in `lua/plugins/telescope.lua` and command strings in `lua/plugins/which-key.lua`. Update both or consolidate.
- `core/Keymap.lua` maps `<C-z>` to undo in normal and insert mode (overrides the default suspend).
- `telescope-fzf-native.nvim` builds with `make`, so a C compiler is required on a fresh machine.
- `lua/core/diff_colors.lua` re-applies high-contrast `Diff*` groups on `ColorScheme`; matugen's template uses `surface_high` for all diff backgrounds and reloads asynchronously, so do not remove this override if diff colors look washed out.
- `lua/core/syntax_colors.lua` derives distinct syntax hues from the matugen palette on every `ColorScheme` (teal functions, peach types, orange numbers, blue variables, green strings); it only applies when `vim.g.colors_name == "matugen"`.
- MarkView skips wide tables when `wrap` is on (>=90% of the window), so `MarkView.lua` sets Markdown buffers to `wrap=false`; `<leader>mw` toggles wrapping. This is a MarkView limitation, not invalid Markdown.
- MarkView math (`$$...$$`, `$...$`) needs the `latex` treesitter parser; `nvim-treesitter.lua` includes `latex` in `ensure_installed`.
- Markdown: `<leader>mo` opens the markdown-plus TOC (`:Toc`) in a right-side vertical split and refocuses it if already open; inside it `<Enter>` jumps, `l`/`h` expand/collapse, `q` closes. markdown-plus defaults use `<localleader>` (comma), so its keys are `,m*`/`,h*`; its `opts.keymaps` table only accepts `enabled`.
- `lua/plugins/mdkite.lua` provides a browser Markdown preview (`<leader>mp` / `:MdKite`), separate from MarkView's inline rendering; it depends on `kitehost.nvim` and loads its browser assets from CDN.
- Obsidian integration lives in the Obsidian app, not in nvim: `lua/plugins/obsidian.lua` and `lua/plugins/obsidian-bridge.lua` were removed. The Obsidian Vim Motions config is `obsidian/init.lua` (leader = space, localleader = comma); `~/.config/obsidian/init.lua` is a symlink to it and is the plugin's configured Custom init.lua path. After editing, run “Vim Motions: Reload configuration” in Obsidian.
- `lua/plugins/MarkView.lua` keeps MarkView's default rendering (no custom hybrid mode); callouts use the Obsidian preset, tables use single borders, LaTeX blocks use `MarkviewLatexBlock`, and horizontal rules keep MarkView's default centered style.

## LSP

- `lua/plugins/mason.lua` owns the stack: Mason installs servers, `mason-lspconfig` maps package names (`lua-language-server` -> `lua_ls`), and the config activates them with `vim.lsp.config` + `vim.lsp.enable`. Do not use the deprecated `require("lspconfig")[name].setup()` API.
- To add a server, install it via Mason and call `setup("<mason-package>", config)` inside `mason.lua`. `automatic_enable` is off so capabilities and `on_attach` are applied first.
- Blink supplies LSP capabilities; formatting capabilities are disabled on Mason-managed servers so `none-ls` (stylua) is the only formatter. `<leader>lf` formats.
- Mason loads on `VeryLazy`, after the first buffer's `FileType`; `mason.lua` re-fires `FileType` so the startup buffer still attaches. Keep that block unless you change Mason's load event.
- LSP keymaps (`<leader>l*`) live in `lua/plugins/lspsaga.lua`; bufferline also shows LSP diagnostics.
- `lua/core/lsp_highlight.lua` implements VS Code-style symbol occurrence highlighting via `vim.lsp.buf.document_highlight()` on `CursorHold`/`CursorHoldI` (300ms) and clears it on cursor movement; it relies on the theme's `LspReference*` groups.

## Treesitter

- `lua/plugins/nvim-treesitter.lua` uses the rewritten `main` branch API: no `nvim-treesitter.configs`, `lazy = false`, and `build = ":TSUpdate"`. Do not use the old `opts.ensure_installed` / `highlight` config.
- The local `ensure_installed` list is only the parsers this machine should auto-install. It is independent of LSP: add `python` for Python highlighting, `markdown` + `markdown_inline` for Markdown, etc. Installed parsers persist; `:TSInstall` can install one without editing the list.
- Requires Neovim 0.12+, `tree-sitter` CLI 0.26.1+ in `PATH`, a C compiler, plus `curl` and `tar`. Parsers install to `~/.local/share/nvim/site`.
- Highlighting is not automatic on `main`; the FileType autocmd calls `vim.treesitter.start()`. Missing parsers are installed asynchronously, so restart after the first install.
- Verify: open a target file and run `:lua =vim.treesitter.get_parser(0)`; `:TSLog` shows install errors, `:TSUpdate` updates installed parsers.

## Verify

- Parse all Lua: `luac -p init.lua lua/core/*.lua lua/plugins/*.lua`
- Load the config headless: `nvim --headless -u init.lua +qa`
- `VeryLazy` never fires in a headless session, so force-load plugins when testing LSP: `nvim --headless -u init.lua lua/plugins/mason.lua "+lua require('lazy').load({plugins={'mason.nvim'}})" "+lua print(#vim.lsp.get_clients({bufnr=0}))" +qa`
- Spot-check a mapping: `nvim --headless -u init.lua "+lua print(vim.fn.maparg('<leader>ff','n'))" +qa`
- Manual diagnostics: `:checkhealth vim.lsp`, `:Lazy health`, `:Mason`, `:lsp`. Nothing else is automated.
