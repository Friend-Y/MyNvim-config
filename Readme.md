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
