#!/bin/bash

# 颜色变量
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${GREEN}欢迎使用一键脚本：${RESET}"
echo "1、安装依赖环境"
echo "2、查看验证器日志"

read -p "请输入选项 [1-2]: " choice

case $choice in
    1)
        # 检查是否已存在会话
        if screen -list | grep -q "nexus"; then
            echo -e "${RED}验证器已在运行中，请勿重复启动${RESET}"
            exit 1
        fi
        
        echo -e "${GREEN}正在创建screen会话...${RESET}"
        
        # 创建安装脚本
        cat > /tmp/install_nexus.sh << 'EOF'
#!/bin/bash

# 启用错误追踪
set -x

echo "正在安装系统依赖..."
# sudo apt update && sudo apt upgrade -y
sudo apt update
sudo apt install -y build-essential pkg-config libssl-dev git-all
echo "y" | sudo apt install protobuf-compiler

echo "正在安装 Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

echo "环境安装完成！"
echo "请手动执行以下命令启动验证器："
echo "1. curl https://cli.nexus.xyz/ | sh"
echo "2. 同意条款并输入您的 Prover ID"

# 保持会话开启
exec bash
EOF

        chmod +x /tmp/install_nexus.sh
        
        # 在新的screen会话中运行安装脚本，并将输出重定向到日志文件
        screen -L -Logfile /tmp/nexus_screen.log -dmS nexus /tmp/install_nexus.sh
        
        # 检查screen会话是否成功创建
        if ! screen -list | grep -q "nexus"; then
            echo -e "${RED}错误：screen会话创建失败${RESET}"
            echo -e "${RED}请检查 /tmp/nexus_screen.log 文件了解详细错误信息${RESET}"
            exit 1
        fi
        
        echo -e "${GREEN}正在安装依赖环境，请使用选项2查看安装进度${RESET}"
        echo -e "${GREEN}安装完成后，请按照提示手动启动验证器${RESET}"
        echo -e "${GREEN}详细日志保存在 /tmp/nexus_screen.log${RESET}"
        ;;
        
    2)
        # 检查验证器是否在运行
        if ! screen -list | grep -q "nexus"; then
            echo -e "${RED}会话未运行，请先执行选项1安装环境${RESET}"
            exit 1
        fi
        
        echo -e "${GREEN}正在连接到会话...${RESET}"
        echo -e "${GREEN}提示：使用 Ctrl+A+D 组合键可以退出会话${RESET}"
        sleep 2
        screen -r nexus
        ;;
        
    *)
        echo -e "${RED}无效的选项${RESET}"
        exit 1
        ;;
esac
