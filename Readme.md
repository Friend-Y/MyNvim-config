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

# Obsidian 与 Vim Motions

Obsidian 集成现在完全在 Obsidian 应用内完成，不再使用 `obsidian.nvim` 或 `obsidian-bridge.nvim`。Neovim 侧只保留 Vim Motions 的配置文件：

```text
~/.config/nvim/obsidian/init.lua
```

Vault 路径：

```text
~/Documents/Obsidian/MyVault/obsidian_-data
```

Vim Motions 的 **Custom init.lua path** 当前设置为：

```text
~/.config/obsidian/init.lua
```

这个文件是指向上述配置的符号链接：

```text
~/.config/obsidian/init.lua
  -> ~/.config/nvim/obsidian/init.lua
```

如果移动了 Neovim 配置目录，需要重新创建这个链接；也可以删除链接，在 Vim Motions 设置里把 **Custom init.lua path** 直接改为 `~/.config/nvim/obsidian/init.lua`。

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
