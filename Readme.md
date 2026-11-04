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

# Obsidian 与 obsidian-bridge.nvim

相关配置：

- `lua/plugins/obsidian.lua`
- `lua/plugins/obsidian-bridge.lua`

当前 vault 路径：

```text
~/Documents/Obsidian/MyVault/obsidian_-data
```

如果实际路径不同，修改 `lua/plugins/obsidian.lua` 中的 `workspaces`。

## 前置条件

1. 安装并启用 Obsidian 社区插件 **Local REST API**
2. 默认配置使用非加密 HTTP：

```text
http://localhost:27123
```

需要在 Local REST API 设置中启用非加密 HTTP 服务。

1. 将 API Key 写入 shell 配置：

```bash
export OBSIDIAN_REST_API_KEY="你的 API Key"
```

写入 `~/.bashrc`、`~/.zshrc` 或对应 shell 的配置文件后，重新打开终端和 Neoviml。我的ArchLinux地址为"~/.config/fish/config.fish"

1. 使用 Bridge 时保持 Obsidian 正在运行。

如果使用 HTTPS，则修改 `lua/plugins/obsidian-bridge.lua`：

```lua
opts = {
  obsidian_server_address = "https://127.0.0.1:27124",
  cert_path = "~/.ssl/obsidian.crt",
}
```

## conceallevel

`lua/plugins/obsidian.lua` 会自动为 Markdown buffer 设置：

```lua
vim.wo.conceallevel = 2
```

用于启用 Obsidian 的额外 UI 功能。

## 滚动同步

当前 `lua/plugins/obsidian-bridge.lua` 中：

```lua
scroll_sync = true
```

滚动同步需要作者提供的补丁版 Local REST API：

```text
https://github.com/oflisback/obsidian-local-rest-api
```

如果没有安装补丁版，将配置改为：

```lua
scroll_sync = false
```

否则可能出现滚动不同步或连接警告。

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
