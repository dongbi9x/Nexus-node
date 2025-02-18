#!/bin/bash
# Thiết lập biến màu sắc
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

# Kiểm tra xem hệ thống có phải là Ubuntu không
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}Lỗi: Script này chỉ hỗ trợ hệ thống Ubuntu${RESET}"
    exit 1
fi

# Cài đặt các phụ thuộc cơ bản
if ! command -v screen &> /dev/null; then
    echo -e "${GREEN}Đang cài đặt screen...${RESET}"
    sudo apt update && sudo apt install -y screen
fi

# Tạo thư mục trạng thái
mkdir -p ~/.nexus_status

# Hiển thị menu
show_menu() {
    echo -e "${GREEN}Chào mừng bạn đến với script cài đặt Nexus:${RESET}"
    echo "1. Cài đặt môi trường phụ thuộc"
    echo "2. Xem tiến trình cài đặt phụ thuộc"
    echo "3. Khởi động Nexus-CLI"
    echo "4. Xem trạng thái chạy của Nexus-CLI"
    echo "q. Thoát script"
}

# Kiểm tra trạng thái cài đặt phụ thuộc
check_deps_status() {
    if [ -f ~/.nexus_status/deps_installed ]; then
        return 0
    fi
    return 1
}

# Cài đặt môi trường phụ thuộc
install_deps() {
    if check_deps_status; then
        echo -e "${GREEN}Môi trường phụ thuộc đã được cài đặt, không cần cài đặt lại${RESET}"
        return
    fi

    echo -e "${GREEN}Bắt đầu cài đặt môi trường phụ thuộc...${RESET}"

    # Xóa tất cả các session có tên nexus_deps
    screen -ls | grep "nexus_deps" | awk '{print $1}' | xargs -r screen -S {} -X quit

    # Tạo session screen mới
    screen -dmS nexus_deps bash -c '
        # Bật theo dõi lỗi
        set -x

        echo "Đang cài đặt các phụ thuộc hệ thống..."
        sudo apt update
        sudo apt install -y build-essential pkg-config libssl-dev git-all
        echo "y" | sudo apt install protobuf-compiler

        echo "Đang cài đặt Rust..."
        curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"

        # Đánh dấu hoàn thành cài đặt phụ thuộc
        touch ~/.nexus_status/deps_installed
        echo "Cài đặt môi trường phụ thuộc hoàn tất!"
    '
    
    echo -e "${GREEN}Cài đặt phụ thuộc đã được khởi động trong nền${RESET}"
    echo -e "${GREEN}Vui lòng mở cửa sổ terminal mới và chạy lệnh sau để xem tiến trình:${RESET}"
    echo -e "screen -r nexus_deps"
    echo -e "${GREEN}Sử dụng tổ hợp phím Ctrl+A+D để thoát session${RESET}"
}

# Xem tiến trình cài đặt phụ thuộc
check_deps_progress() {
    if check_deps_status; then
        echo -e "${GREEN}Môi trường phụ thuộc đã được cài đặt hoàn tất!${RESET}"
        return
    fi

    if ! screen -list | grep -q "nexus_deps"; then
        echo -e "${RED}Session cài đặt phụ thuộc không tồn tại, vui lòng chọn tùy chọn 1 trước${RESET}"
        return
    fi

    echo -e "${GREEN}Đang kết nối đến session cài đặt phụ thuộc...${RESET}"
    echo -e "${GREEN}Gợi ý: Sử dụng tổ hợp phím Ctrl+A+D để thoát session${RESET}"
    sleep 2
    # Sử dụng script để tạo pseudo terminal và kết nối đến session screen
    script -q -f -c "screen -r nexus_deps" /dev/null
}

# Khởi động Nexus-CLI
start_cli() {
    if ! check_deps_status; then
        echo -e "${RED}Vui lòng hoàn tất cài đặt môi trường phụ thuộc trước (tùy chọn 1)${RESET}"
        return
    fi

    if screen -list | grep -q "nexus_cli"; then
        echo -e "${RED}Nexus-CLI đang chạy, vui lòng không khởi động lại${RESET}"
        return
    fi

    # Nhập Prover ID từ người dùng
    read -p "Vui lòng nhập Prover ID của bạn: " prover_id < /dev/tty
    if [ -z "$prover_id" ]; then
        echo -e "${RED}Prover ID không được để trống${RESET}"
        return
    fi

    echo -e "${GREEN}Đang khởi động Nexus-CLI...${RESET}"
    
    # Tạo session screen mới để chạy CLI
    screen -dmS nexus_cli bash -c '
        # Tự động đồng ý thỏa thuận và nhập Prover ID
        {
            sleep 2
            echo "y"
            sleep 2
            echo "'$prover_id'"
        } | curl https://cli.nexus.xyz/ | sh
    '
    
    echo -e "${GREEN}Nexus-CLI đã được khởi động trong nền, sử dụng tùy chọn 4 để xem trạng thái${RESET}"
}

# Xem trạng thái chạy của CLI
check_cli_status() {
    if ! screen -list | grep -q "nexus_cli"; then
        echo -e "${RED}Nexus-CLI không chạy, vui lòng chọn tùy chọn 3 trước${RESET}"
        return
    fi

    echo -e "${GREEN}Đang kết nối đến session Nexus-CLI...${RESET}"
    echo -e "${GREEN}Gợi ý: Sử dụng tổ hợp phím Ctrl+A+D để thoát session${RESET}"
    sleep 2
    # Sử dụng script để tạo pseudo terminal và kết nối đến session screen
    script -q -f -c "screen -r nexus_cli" /dev/null
}

# Vòng lặp chính
show_menu
while true; do
    read -p "Vui lòng nhập tùy chọn [1-4 hoặc q]: " choice < /dev/tty
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
            echo -e "${GREEN}Cảm ơn bạn đã sử dụng!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Tùy chọn không hợp lệ${RESET}"
            ;;
    esac
    echo
    show_menu
done
