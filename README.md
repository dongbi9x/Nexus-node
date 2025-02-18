# Nexus 验证器环境部署脚本

## 快速安装（推荐）
在 Ubuntu 系统上执行以下命令即可一键安装：

```bash
curl -fsSL https://raw.githubusercontent.com/baalisgood/nexus-node/main/install.sh | bash
```

## 快速开始

在 Ubuntu 24.04 系统上执行以下命令：

```bash
# 1. 安装 git
sudo apt update
sudo apt install -y git

# 2. 克隆项目
git clone https://github.com/baalisgood/nexus-node.git

# 3. 进入项目目录
cd nexus-node

# 4. 运行脚本
bash node.sh
```

## 功能说明
本脚本旨在 Ubuntu 24.04 系统上自动完成 Nexus 验证器所需环境依赖的安装工作。

### 脚本功能
- **自动安装系统依赖**：
  - `build-essential`：提供编译工具链等基础构建环境。
  - `pkg-config`：用于辅助管理库的编译和链接选项。
  - `libssl-dev`：与 SSL/TLS 加密相关的开发库。
  - `git-all`：完整的 Git 工具集，方便代码版本管理与获取。
  - `protobuf-compiler`：用于处理 Protocol Buffers 相关的编译任务。
- **自动安装 Rust 环境**：为后续基于 Rust 开发的相关组件提供运行基础。

## 使用说明

### 1. 安装环境依赖
在终端中输入 `bash node.sh`，之后会呈现操作菜单，选择选项 1 可进行依赖环境的安装，若想查看安装进度则选择选项 2。

### 2. 手动启动验证器
当环境安装成功后，依照以下步骤启动验证器：
1. **创建新的 `screen` 会话**：
```bash
screen -S nexus_node
```
此命令创建一个名为 `nexus_node` 的 `screen` 会话，`screen` 可使进程在后台持续运行，即便终端连接断开也不受影响。

2. **在会话中执行命令**：
```bash
curl https://cli.nexus.xyz/ | sh
```
该命令从指定 URL 下载并执行脚本，用于进一步配置验证器相关内容。
3. **按提示操作**：
  - 当出现用户协议提示时，输入 `y` 表示同意。
  - 接着输入您专属的 Prover ID，然后回车以继续后续流程。
4. **退出会话**：
通过按下 `Ctrl+A+D` 组合键，可安全地退出当前 `screen` 会话，此时验证器仍在后台运行。
如果要删除会话，使用`screen -S nexus_node -X quit`即可，如果有重名的会话，使用`screen -ls`查看会话的ID，使用`screen -S <id> -X quit`来删除会话。（把id替换为实际的查询到的id，不要带<>括号）
5. **重新连接会话**：
若需要重新进入验证器所在的 `screen` 会话，执行以下命令：
```bash
screen -x nexus_node
```

## 注意事项
- `Ctrl+A+D` 组合键是安全退出 `screen` 会话的快捷方式，使用此组合键可确保会话内进程持续运行。
- 验证器启动后会一直在 `screen` 会话中运行，可通过重新连接会话进行查看与管理。
- 在启动验证器之前，请务必提前准备好您的 Prover ID，否则将无法顺利完成验证器的启动流程。
