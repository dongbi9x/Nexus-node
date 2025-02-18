#!/bin/bash
# 设置颜色变量
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

# 检查是否为 Ubuntu 系统
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}错误：此脚本仅支持 Ubuntu 系统${RESET}"
    exit 1
fi

# 安装基本依赖
if ! command -v screen &> /dev/null; then
    echo -e "${GREEN}正在安装 screen...${RESET}"
    sudo apt update && sudo apt install -y screen
fi

# 创建状态文件目录
mkdir -p ~/.nexus_status

# 显示菜单函数
show_menu() {
    echo -e "${GREEN}欢迎使用 Nexus 一键安装脚本：${RESET}"
    echo "1、安装依赖环境"
    echo "2、查看依赖安装进度"
    echo "3、启动 Nexus-CLI"
    echo "4、查看 Nexus-CLI 运行状态"
    echo "q、退出脚本"
}

# 检查依赖安装状态
check_deps_status() {
    if [ -f ~/.nexus_status/deps_installed ]; then
        return 0
    fi
    return 1
}

# 安装依赖环境
install_deps() {
    if check_deps_status; then
        echo -e "${GREEN}依赖环境已安装完成，无需重复安装${RESET}"
        return
    fi

    echo -e "${GREEN}开始安装依赖环境...${RESET}"

    # 删除所有名为 nexus_deps 的会话
    screen -ls | grep "nexus_deps" | awk '{print $1}' | xargs -r screen -S {} -X quit

    # 创建新的 screen 会话
    screen -dmS nexus_deps bash -c '
        # 启用错误追踪
        set -x

        echo "正在安装系统依赖..."
        sudo apt update
        sudo apt install -y build-essential pkg-config libssl-dev git-all
        echo "y" | sudo apt install protobuf-compiler

        echo "正在安装 Rust..."
        curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"

        # 标记依赖安装完成
        touch ~/.nexus_status/deps_installed
        echo "依赖环境安装完成！"
    '
    
    echo -e "${GREEN}依赖安装已在后台启动${RESET}"
    echo -e "${GREEN}请打开新的终端窗口，执行以下命令查看安装进度：${RESET}"
    echo -e "screen -r nexus_deps"
    echo -e "${GREEN}使用 Ctrl+A+D 组合键可以退出会话${RESET}"
}

# 查看依赖安装进度
check_deps_progress() {
    if check_deps_status; then
        echo -e "${GREEN}依赖环境已安装完成！${RESET}"
        return
    fi

    if ! screen -list | grep -q "nexus_deps"; then
        echo -e "${RED}依赖安装会话未运行，请先执行选项1${RESET}"
        return
    fi

    echo -e "${GREEN}正在连接到依赖安装会话...${RESET}"
    echo -e "${GREEN}提示：使用 Ctrl+A+D 组合键可以退出会话${RESET}"
    sleep 2
    # 使用 script 创建伪终端并连接到 screen 会话
    script -q -f -c "screen -r nexus_deps" /dev/null
}

# 启动 Nexus-CLI
start_cli() {
    if ! check_deps_status; then
        echo -e "${RED}请先完成依赖环境的安装（选项1）${RESET}"
        return
    fi

    if screen -list | grep -q "nexus_cli"; then
        echo -e "${RED}Nexus-CLI 已在运行中，请勿重复启动${RESET}"
        return
    fi

    # 获取用户输入的 Prover ID
    read -p "请输入您的 Prover ID: " prover_id < /dev/tty
    if [ -z "$prover_id" ]; then
        echo -e "${RED}Prover ID 不能为空${RESET}"
        return
    fi

    echo -e "${GREEN}正在启动 Nexus-CLI...${RESET}"
    
    # 创建新的 screen 会话运行 CLI
    screen -dmS nexus_cli bash -c '
        # 自动同意协议并输入 Prover ID
        {
            sleep 2
            echo "y"
            sleep 2
            echo "'$prover_id'"
        } | curl https://cli.nexus.xyz/ | sh
    '
    
    echo -e "${GREEN}Nexus-CLI 已在后台启动，使用选项4查看运行状态${RESET}"
}

# 查看 CLI 运行状态
check_cli_status() {
    if ! screen -list | grep -q "nexus_cli"; then
        echo -e "${RED}Nexus-CLI 未运行，请先执行选项3${RESET}"
        return
    fi

    echo -e "${GREEN}正在连接到 Nexus-CLI 会话...${RESET}"
    echo -e "${GREEN}提示：使用 Ctrl+A+D 组合键可以退出会话${RESET}"
    sleep 2
    # 使用 script 创建伪终端并连接到 screen 会话
    script -q -f -c "screen -r nexus_cli" /dev/null
}

# 主循环
show_menu
while true; do
    read -p "请输入选项 [1-4 或 q]: " choice < /dev/tty
    case $choice in
        1)
            install_deps
            ;;
        2)
            check_deps_progress
            ;;
        3)
            start_cli
            ;;
        4)
            check_cli_status
            ;;
        q|Q)
            echo -e "${GREEN}感谢使用！${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效的选项${RESET}"
            ;;
    esac
    echo
    show_menu
done 