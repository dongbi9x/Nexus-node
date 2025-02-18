#!/bin/bash
# 设置颜色变量
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${GREEN}正在下载 Nexus 安装脚本...${RESET}"

# 创建临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 下载主脚本
curl -fsSL https://raw.githubusercontent.com/baalisgood/nexus-node/main/nexus.sh -o nexus.sh
chmod +x nexus.sh

# 运行主脚本
exec bash nexus.sh 