#!/bin/bash
# Thiết lập biến màu sắc
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${GREEN}Đang tải xuống script cài đặt Nexus...${RESET}"

# Tạo thư mục tạm thời
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Tải xuống script chính
curl -fsSL https://raw.githubusercontent.com/dongbi9x/nexus-node/main/nexus.sh -o nexus.sh
chmod +x nexus.sh

# Chạy script chính
exec bash nexus.sh
