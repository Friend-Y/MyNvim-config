# 主体色插件更换颜色
## 自动更换
更换壁纸->matugen后台自动提取颜色->Neovim自动热重载
## 手动操作
### 从图片生成
matugen image /path/to/your/new/wallpaper.jpg
### 从颜色值生成
matugen color hex "#ff0000"
### 在Neonvim内部手动热重载
:MatugenReload
# lazygit外部diff工具(nvim)优化显示的设置方式
## 1. 准备目录
如果新电脑已有 Neovim 配置，先备份：
mv ~/.config/nvim ~/.config/nvim.bak
## 2. Clone 仓库
git clone <你的仓库地址> ~/.config/nvim
## 3. 给脚本加执行权限
Git 通常会保留可执行位，但 clone 后最好确认：
chmod +x ~/.config/nvim/scripts/lazygit-nvim-diff.sh
## 4. 配置 LazyGit
mkdir -p ~/.config/lazygit
创建或编辑：
~/.config/lazygit/config.yml
内容：
git:
  diffRenderers:
    - type: extDiff
      command: '~/.config/nvim/scripts/lazygit-nvim-diff.sh'
如果已经有配置文件，只合并这段 diffRenderers，不要覆盖其他设置。
## 5. 首次启动 Neovim
打开一次 Neovim，让 lazy.nvim 根据 lazy-lock.json 安装插件：
nvim
首次安装需要网络。diff 高亮本身不依赖插件，但你的完整配置需要 LSP、Treesitter 等。
## 6. 验证
cd /path/to/some/git/repo
lazygit
按 Ctrl+T，然后在 Neovim 里检查：
:hi DiffAdd
:hi DiffDelete

# Sidekick + Claude Code 键盘操作

`lua/plugins/sidekick.lua` 把 Claude Code 放在右侧 35% 的终端窗口里。窗口切换和 Claude Code 内部的输入区/transcript 切换是两套独立键位。

## 窗口切换

| 场景 | 快捷键 | 说明 |
|---|---|---|
| 编辑器 → Claude Code | `<C-S-z>` | 聚焦/切换到 CLI（CLI 已打开时）；CLI 内同一个键返回编辑器 |
| 编辑器 → Claude Code | `<leader>af` | 聚焦/失焦切换（备用） |
| 编辑器 → Claude Code | `<leader>at` | 打开/切换右侧终端窗口 |
| Claude Code → 编辑器 | `<C-S-z>` | 回到上一个窗口，终端和会话保留（sidekick `blur`） |
| Claude Code → 左侧窗口 | `<C-h>` | 仅当左侧存在窗口时生效 |
| 隐藏 Claude Code | `<C-.>` | 关闭窗口，进程保留 |
| 进入 Neovim normal 模式 | `<C-q>` | 再按 `q` 隐藏窗口 |

说明：

- 编辑器里的 `<C-z>` 仍然是 `lua/core/Keymap.lua` 的 undo；新增 `<C-S-z>` 作为主切换键。`<C-S-z>` 在编辑器里聚焦 CLI，在 CLI 里 blur 回上一个窗口，形成对称切换。CLI 内保留 sidekick 默认的 `<C-z>` 作为兜底 blur，避免 Ctrl+Z 被终端当作挂起；它不影响编辑器里的 undo。
- `<C-S-z>` 依赖终端能区分 Ctrl+Shift+Z；kitty 会以 CSI u 发送，Neovim 0.12 能解析（已验证）。若在其他终端里它被当作 Ctrl+Z，仍可用 `<leader>af` 聚焦、`<C-h>` 返回。
- `<leader>at` / `<leader>af` 故意只映射 normal 模式。终端模式下以空格（leader）开头的映射会截获 Claude 输入里的空格并等待 `timeoutlen`，所以 CLI 内请用 `<C-S-z>` 返回编辑器。
- `<C-h/j/k/l>` 只有在对应方向存在窗口时才由 sidekick 截获。右侧布局下通常只有 `<C-h>` 生效；若在下方/上方/右侧开窗，`<C-j>`（Claude 的换行）、`<C-k>`、`<C-l>` 会被窗口导航占用。
- `<C-S-z>` 在 CLI 内是 sidekick 的 blur，不是 shell 挂起；`<C-q>` 在终端模式是进入 normal，不是隐藏（sidekick 文档这里的描述已过期）。
- 退出：`:q` 只关闭当前窗口，不是退出 Neovim。若不管它，关掉编辑器窗口后 Agent 终端会成为唯一窗口并铺满屏幕。`lua/plugins/sidekick.lua` 里加了 `WinClosed` 自动命令：当关掉的窗口不是 Sidekick 窗口、且屏幕上只剩 Sidekick 窗口时，先 `sidekick.cli.close({ all = true })` 结束会话，再 `quitall`。所以 `:q` / `:wq` / `:x` / `:qa` 都能一步退出；在 Agent 窗口里 `:q` 仍然只关分屏。

## 输入区 ↔ transcript

Claude Code 的输入区和对话记录不是两个可聚焦窗格：输入区始终是 `Chat`，对话记录是独立的 `Transcript` 视图，按 `Ctrl+O` 进入/退出。

| 快捷键 | 作用 |
|---|---|
| `Ctrl+O` | 在输入区与 transcript 之间切换（`app:toggleTranscript`） |
| `q` / `Esc` / `Ctrl+C` | 在 transcript 内返回输入区 |
| `j` / `k` | transcript 内上/下滚动 |
| `g` / `G` | transcript 顶部/底部 |
| `PageUp` / `PageDown` | transcript 整页滚动 |
| `Ctrl+F` / `Ctrl+B` | transcript 整页下/上滚动 |
| `Space` / `Shift+Space` | transcript 整页下/上滚动 |
| `Ctrl+E` | transcript 内展开/收起全部输出 |
| `Ctrl+J` | 输入区换行 |
| `Shift+Tab` | 切换 Claude Code 权限模式 |
| `Ctrl+R` | 历史搜索 |

## 按键冲突说明

- sidekick 默认把 `<C-b>` / `<C-f>` 用于自己的 buffer/file picker；本配置已禁用这两项，让 Claude Code 的 transcript 整页滚动可用。CLI 内不再有 sidekick 的 buffer/file picker；需要发送文件/缓冲区时，从编辑器用 `<leader>aF` / `<leader>ai` 等。
- `<C-p>` 仍是 sidekick 的 prompt picker，因此 Claude Code 的 `Ctrl+P`（transcript 行上移）被截获；用 `k` 代替。
- `<C-h>` 在 CLI 内是“回到左侧窗口”，不是退格；需要 Ctrl+H 退格时先按 `<C-q>` 进入 normal 模式，或修改 `cli.win.keys.nav_left`。
- `<C-z>` 在 CLI 内仍是 sidekick 的兜底 blur（默认行为），不会影响编辑器里的 undo；主用 `<C-S-z>`。

## 能力边界

transcript 是 Claude Code 的终端 TUI 视图，不是 Neovim buffer：不能用 visual 选择、`/` 搜索、yank 到寄存器，也不能和输入区并排显示。需要“对话区是只读 Neovim buffer、输入区是普通可编辑 buffer、Tab 切换”的完整体验时，参见 `~/Projects/claude-vim-mode/plan.md` 的 agentic.nvim 方案。

# Obsidian 与 Vim Motions

Neovim 侧通过 `lua/plugins/obsidian.lua` 使用 `obsidian.nvim` 编辑 vault：

- 笔记切换/搜索/反向链接/标签走 Telescope：`<leader>mn`（新建）、`<leader>mq`（快速切换）、`<leader>mf`（搜索）、`<leader>ml`（反向链接）、`<leader>mt`（标签）、`<leader>md`（今日笔记）、`<leader>mo`（在 Obsidian 中打开）。
- 链接：`gf` 或普通模式 `<CR>` 跟随光标下的 `[[链接]]`/标签；`<leader>mR` 重命名当前笔记并更新全库引用。
- 图片：`<leader>mP` 把剪贴板截图保存到当前笔记同级 `图片/` 并插入 `![[...]]`；buffer 内由 `snacks.nvim` 的 image 模块预览（需要 kitty 图形协议）。
- 新笔记文件名=标题，不自动写 YAML frontmatter；已有 frontmatter 原样保留。
- vault 内的 Markdown 由 obsidian.nvim 内置的 `obsidian-ls` 处理，marksman 在 `.obsidian` vault 内自动跳过。

Vault 路径：

```text
~/Documents/Obsidian/MyVault
```

Obsidian 应用内的 Vim Motions 配置仍是外部文件：

```text
~/.config/obsidian/init.lua
```

它是普通文件（vault 内另有一份 `Vim Motion配置.md` 副本），不是指向 Neovim 配置目录的符号链接。修改后，在 Obsidian 命令面板执行 “Vim Motions: Reload configuration”。

## 前置条件

在 Obsidian 设置 → 编辑器 → **Vim 键位绑定** 中关闭内置 Vim 模式，然后重启 Obsidian。Vim Motions 需要接管 Vim 操作；内置 Vim 模式开启时它不会启用。

## 生效方式

修改 `obsidian/init.lua` 后，在 Obsidian 命令面板执行：

```text
Vim Motions: Reload configuration
```

或者重启 Obsidian。Vim Motions 不会自动监听这个外部文件。

## 快捷键

Leader 是空格，localleader 是逗号。完整映射见 `obsidian/init.lua`。

### 查找

| 快捷键 | 功能 |
|---|---|
| `<leader>ff` | 查找文件 |
| `<leader>fg` | 全库搜索 |
| `<leader>fb` | 切换缓冲区 |
| `<leader>fh` | 搜索标题 |
| `<leader>fo` | 文档大纲 |
| `<leader>fk` | 反向链接 |
| `<leader>ft` | 搜索标签 |
| `<leader>fr` | 最近文件 |
| `<leader>fm` | 跳转标记 |
| `<leader>fR` | 寄存器 |
| `<leader>fp` | 继续上次搜索 |

### 缓冲区与窗口

| 快捷键 | 功能 |
|---|---|
| `<leader>bh` / `<leader>bl` | 上一个 / 下一个缓冲区 |
| `<leader>bp` / `<leader>bd` | 选择 / 关闭缓冲区 |
| `<leader>wd` / `<leader>wo` | 关闭当前 / 其他标签页 |
| `<leader>wv` / `<leader>ws` | 垂直 / 水平分屏 |
| `<leader>wh/j/k/l` | 聚焦左 / 下 / 上 / 右窗格 |

### 导航与文件

| 快捷键 | 功能 |
|---|---|
| `<leader>hp` | 跳转到任意单词（EasyMotion） |
| `<leader>uf` | 切换左侧栏 |
| `<leader>uF` | 在文件浏览器中定位当前文件 |
| `<leader>yy` / `<leader>yc` | 在 Oil 中打开当前目录 / Vault 根目录 |
| `<leader>lg` | 打开 Obsidian Git 视图 |

### Obsidian 笔记

| 快捷键 | 功能 |
|---|---|
| `<leader>md` | 今日笔记 |
| `<leader>ml` | 反向链接 |
| `<leader>mf` | 搜索笔记 |
| `<leader>mq` | 快速切换笔记 |
| `<leader>mn` | 新建笔记 |

### 链接与 Markdown

| 快捷键 | 功能 |
|---|---|
| `<leader>mo` | 打开当前笔记大纲 |
| `<leader>mp` | 切换阅读视图 |
| `<leader>lr` | 重命名当前笔记 |
| `<leader>lc` | 上下文操作 |
| `<leader>ld` | 跳转到链接目标 |
| `<leader>lh` | 预览链接 / 脚注 |
| `<leader>lR` | 查看反向链接 |
| `,mb` / `,mi` / `,mS` | 加粗 / 斜体 / 删除线 |
| `` ,m` `` / `,m=` | 行内代码 / 高亮 |
| `,ml` / `,mc` | 插入链接 / 代码块 |
| `,ms` | 切换标题级别 |
| `,h1` - `,h6` | 设为 H1 - H6 |
| `,h0` / `,hT` | 清除标题 / 打开大纲 |

Obsidian 没有直接对应项的功能：下划线、编辑链接、URL 转链接、引用式链接、行内链接、智能粘贴、切换代码块语言、生成/更新目录。这些键没有映射，使用 Obsidian 原生操作即可。

## 自己添加键位

Vim Motions 的 Lua 配置使用 `vim.keymap.set`：

```lua
vim.keymap.set("n", "<leader>xx", ":ob command-id<CR>", { desc = "说明" })
```

- 第一个参数：`"n"` 普通模式，`"v"` 可视模式，`"o"` operator-pending，也可以写 `{ "n", "v" }`
- 第二个参数：按键序列
- 第三个参数：`:命令<CR>` 字符串，或者 Lua 函数
- `desc` 会显示在 which-key 提示中

在 Obsidian 里执行 `:ob`（不带参数）可以列出所有可用的 Obsidian 命令 ID。修改后执行 **Vim Motions: Reload configuration** 生效。

# 调整语法高亮颜色

终端字体本身（字体族、字号）由终端模拟器决定，Neovim 只能调整语法高亮的颜色和样式。

主要配置文件：

```text
lua/core/syntax_colors.lua
```

这个文件只在当前主题为 `matugen` 时生效，并会从：

```text
~/.cache/matugen/nvim-colors.json
```

读取当前色板。

## 当前颜色分配

| 语法元素 | 颜色 |
|---|---|
| 变量 / 参数 / 属性 | 蓝色 `#96bfe4` |
| 字符串 | 绿色 `#76eb8f` |
| 函数 | 青绿色 `#96e4ce` |
| 类型 | 蜜桃色 `#f7a553` |
| 数字 / 运算符 | 橙色 `#f78453` |
| 关键字 / 常量 | 金色 `#f7d653` |

## Markdown 渲染颜色
matugen 自身的 Markdown 高亮之外，`syntax_colors.lua` 还补充了以下覆盖（颜色会随壁纸色板变化）：

| 元素 | 颜色 |
|---|---|
| H1 / H2 / H3 | 金 / 棕 / 绿（primary / secondary / tertiary） |
| H4 / H5 / H6 | 蓝 `#96bfe4` / 青 `#96e4ce` / 橙 `#f78453`（由 tertiary / primary 派生） |
| 加粗 | 暖棕 `#e7d18c` |
| 斜体 | 柔绿 `#96e4a7` |
| 引用 | `#cdc6b4` 斜体 |
| 行内代码 | 绿 `#76eb8f` |
| 行内 / 块级公式 | 青 `#96e4db` |
| 已勾选任务 | 绿 `#96e4a7` |
| callout success / warn | 绿 / 金 |

H4–H6 与公式颜色用 `shift_hue` 从当前 tertiary/primary 派生，换壁纸后会跟着变；想固定色相可改对应 `shift_hue` 的角度。

## 修改变量颜色

找到：

```lua
local variable_color = shift_hue(p.tertiary, 75)
```

- `75` 表示从当前主题的 tertiary 颜色旋转 75 度色相，得到蓝色
- 改成 `60` 会更偏青色
- 改成 `90` 会更偏紫蓝色

## 修改字符串颜色

```lua
local string_color = adjust_hsl(p.tertiary, 0, 15, -5)
```

`adjust_hsl` 参数：

```text
adjust_hsl(颜色, 色相偏移, 饱和度偏移, 亮度偏移)
```

- 第二项：色相偏移，单位为度
- 第三项：饱和度偏移，单位为百分比
- 第四项：亮度偏移，单位为百分比

想让绿色更鲜艳，可以调整：

```lua
local string_color = adjust_hsl(p.tertiary, 0, 25, -5)
```

## 注意 LSP semantic tokens

LSP 附加后会使用 `@lsp.type.*` 高亮组，它们可能覆盖 Treesitter 的颜色。

修改变量或字符串颜色时，要同时修改：

- Treesitter 组，如 `@variable`、`@string`
- LSP 组，如 `@lsp.type.variable`、`@lsp.type.string`

否则会出现“刚打开时是蓝色，LSP 加载后又变回原色”的现象。

可以用下面的命令查看光标处实际使用的分组：

```vim
:Inspect
```

修改 `syntax_colors.lua` 后需要重启 Neovim；`:MatugenReload` 只重载主题，不会重新加载 Lua 配色模块。

## 调整整体饱和度

matugen 模板：

```text
~/.config/matugen/templates/nvim-colors.json
```

当前使用：

```tera
{{colors.primary.default.hex | saturate: 30.0, hsl}}
```

修改 `30.0` 后需要重新运行 matugen，再用 `:MatugenReload` 或 `SIGUSR1` 让 Neovim 重载主题。

# 速览定义（Peek Definition）

`lua/plugins/lspsaga.lua` 用 lspsaga 自带的 `peek_definition` 实现类 VS Code 的速览定义，不需要额外装插件。

| 快捷键 | 作用 |
|---|---|
| `<leader>ld` | 速览定义：弹出悬浮窗显示光标下符号的定义并定位到该行 |
| `<leader>lD` | 跳转到定义（原来的 `<leader>ld`） |

- 悬浮窗内：`q` 关闭当前这层，`<Esc>` 关闭所有层，`<C-o>` 在悬浮窗位置打开该定义文件；`<C-v>` / `<C-x>` / `<C-t>` 分别是垂直分屏、水平分屏、新标签页打开。
- 悬浮窗里可以继续按 `<leader>ld` 速览再下一层定义（A → B → C），与 VS Code 的嵌套速览一致。
- 窗口尺寸是当前窗口的 6 成宽 5 成高，由 `opts.definition.width` / `height` 控制，`number` 控制行号；`opts.definition.keys` 可改上述悬浮窗内键位。
- 光标不在有 LSP 定义的符号上时（纯文本、Markdown 等），lspsaga 只提示响应为空，不会弹出窗口。
- VSCode 分支（`lua/core/vscode.lua`）用原生的 `editor.action.peekDefinition`，键位一致。

# VSCode + vscode-neovim

`vscode-neovim` 会启动一个嵌入的 Neovim，并加载 `~/.config/nvim/init.lua`。`init.lua` 通过 `vim.g.vscode` 分支：

- 普通 Neovim：加载 `lua/plugins/` 的完整配置
- VSCode：加载 `lua/vscode_plugins/` 的精简配置

## VSCode 中保留的插件

- 编辑类：`nvim-surround`、`hop`、`which-key`
- Markdown：`markdown-plus`、`mdkite`
- 文件/搜索（实验）：`telescope`、`nvim-tree`、`yazi`

LSP、补全、格式化、Treesitter 高亮、状态栏、bufferline、文件树 UI、Git 等使用 VSCode 原生功能。

## 快捷键

查找与文件：

| 快捷键 | 功能 |
|---|---|
| `<leader>ff` | VSCode 快速打开文件 |
| `<leader>fg` | VSCode 全库搜索 |
| `<leader>fb` | VSCode 切换编辑器 |
| `<leader>fh` | VSCode 命令面板 |
| `<leader>fo` | 文档大纲 / 符号 |
| `<leader>fr` | 最近文件 |
| `<leader>fk` | 查找引用 |

缓冲区、窗口与界面：

| 快捷键 | 功能 |
|---|---|
| `<leader>bh` / `<leader>bl` | 上一个 / 下一个编辑器 |
| `<leader>bp` / `<leader>bd` | 选择 / 关闭编辑器 |
| `<leader>wd` / `<leader>wo` | 关闭当前 / 其他编辑器 |
| `<leader>wv` / `<leader>ws` | 向右 / 向下分屏 |
| `<leader>wh/j/k/l` | 聚焦左 / 下 / 上 / 右编辑器组 |
| `<leader>uf` | 切换侧边栏 |
| `<leader>uF` | 在资源管理器中定位当前文件 |
| `<leader>yy` / `<leader>yc` | 在资源管理器中定位 / 打开资源管理器 |

LSP、Git 与 Markdown：

| 快捷键 | 功能 |
|---|---|
| `<leader>lr` | 重命名符号 |
| `<leader>lc` | 快速修复 |
| `<leader>ld` | 速览定义（VSCode peek widget） |
| `<leader>lD` | 跳转到定义 |
| `<leader>lh` | 悬停文档 |
| `<leader>lR` | 查找引用 |
| `<leader>ln` / `<leader>lp` | 下一个 / 上一个诊断 |
| `<leader>lf` | 格式化当前文件 |
| `<leader>lg` | 打开源代码管理 |
| `<leader>mo` / `<leader>uo` | Markdown 大纲 |
| `<leader>mP` | VSCode Markdown 预览 |
| `<leader>mp` | mdkite 浏览器预览 |
| `,m*` / `,h*` | markdown-plus 的编辑和标题快捷键 |

实验性插件（VSCode 下可能显示异常）：

| 快捷键 | 功能 |
|---|---|
| `<leader>fF` / `<leader>fG` | Telescope 查找文件 / 实时搜索 |
| `<leader>e` | NvimTree 文件树 |
| `<leader>yY` / `<leader>yC` | Yazi 当前文件 / 当前目录 |

这些插件的主键仍然使用 VSCode 原生功能；如果不需要实验性插件，可以删除 `lua/vscode_plugins/telescope.lua`、`nvim-tree.lua`、`yazi.lua`，并移除 `lua/core/vscode.lua` 中对应的 `<leader>fF`、`<leader>e`、`<leader>yY` / `<leader>yC` 映射。

如果希望插件占用主键（例如 `<leader>ff` 打开 Telescope），把 `lua/core/vscode.lua` 中的 VSCode action 改成插件的命令即可：

```lua
-- 用 Telescope 替换 VSCode 快速打开
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Telescope 查找文件" })

-- 用 NvimTree 替换 VSCode 侧边栏
map("n", "<leader>uf", "<cmd>NvimTreeToggle<cr>", { desc = "NvimTree 文件树" })

-- 用 Yazi 替换 VSCode 资源管理器
map("n", "<leader>yy", "<cmd>Yazi<cr>", { desc = "Yazi 当前文件" })
```

## 快捷键提示

`which-key.nvim` 在普通 Neovim 中使用浮动窗口，而 vscode-neovim 不会渲染这种浮动窗口，所以按下空格后看不到提示。

VSCode 中安装了一个桥接扩展：

```text
tiago.whichkey-nvim-vscode
```

它不拦截键盘，而是读取 `which-key.nvim` 的映射，在 VSCode 右侧打开一个 **Which Key** Webview 面板，并在状态栏显示当前按键序列。

- 扩展是本地构建的 `0.4.3` VSIX，未上架 Marketplace
- 源码：`https://github.com/Tiag0ss/whichkey-nvim-vscode`
- 需要 `which-key.nvim` 在 VSCode 中加载，因此 `lua/vscode_plugins/which-key.lua` 保持 `lazy = false`
- 首次按下空格后，右侧面板会自动打开；继续按键即可查看下一层映射
- 面板打开一次后会一直保留，关闭后下次按空格会重新打开

如果仍看不到提示：

1. 执行 `Developer: Reload Window`
2. 确认 VSCode 输出面板中的 `Which Key (Neovim)` 没有报错
3. 在 VSCode 中执行 `:lua =require('which-key.view')._whichkey_nvim_vscode`，应返回 `true`
4. 确认 `~/.config/Code/User/settings.json` 中有 `"whichkeyNvim.autoOpen": true`

## VSCode 设置

`~/.config/Code/User/settings.json` 中需要保留：

```jsonc
{
  "vscode-neovim.neovimExecutablePaths.linux": "/usr/bin/nvim",
  "extensions.experimental.affinity": {
    "asvetliakov.vscode-neovim": 1
  },
  "whichkeyNvim.sidebar": "right",
  "whichkeyNvim.autoOpen": true,
  "whichkeyNvim.statusBar": true
}
```

`vscode-neovim.neovimInitVimPaths.linux` 留空，让扩展加载默认的 `~/.config/nvim/init.lua`。

## 测试

```bash
nvim --headless --cmd 'let g:vscode=1' -u init.lua +qa
```

如果 VSCode 中插件行为异常，执行 `Neovim: Restart Extension`，并查看 `Output: Focus on Output View` 中的 `vscode-neovim logs`。
