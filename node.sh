#!/bin/bash

# Biến màu sắc
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${GREEN}Chào mừng bạn đến với script tự động:${RESET}"
echo "1. Cài đặt môi trường phụ thuộc"
echo "2. Xem nhật ký trình xác thực"

read -p "Vui lòng nhập tùy chọn [1-2]: " choice

case $choice in
    1)
        # Kiểm tra xem session đã tồn tại chưa
        if screen -list | grep -q "nexus"; then
            echo -e "${RED}Trình xác thực đang chạy, vui lòng không khởi động lại${RESET}"
            exit 1
        fi
        
        echo -e "${GREEN}Đang tạo session screen...${RESET}"
        
        # Tạo script cài đặt
        cat > /tmp/install_nexus.sh << 'EOF'
#!/bin/bash

# Bật theo dõi lỗi
set -x

echo "Đang cài đặt các phụ thuộc hệ thống..."
# sudo apt update && sudo apt upgrade -y
sudo apt update
sudo apt install -y build-essential pkg-config libssl-dev git-all
echo "y" | sudo apt install protobuf-compiler

echo "Đang cài đặt Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

echo "Cài đặt môi trường hoàn tất!"
echo "Vui lòng thực hiện các lệnh sau để khởi động trình xác thực:"
echo "1. curl https://cli.nexus.xyz/ | sh"
echo "2. Đồng ý điều khoản và nhập Prover ID của bạn"

# Giữ session mở
exec bash
EOF

        chmod +x /tmp/install_nexus.sh
        
        # Chạy script cài đặt trong session screen mới và ghi log vào file
        screen -L -Logfile /tmp/nexus_screen.log -dmS nexus /tmp/install_nexus.sh
        
        # Kiểm tra xem session screen có được tạo thành công không
        if ! screen -list | grep -q "nexus"; then
            echo -e "${RED}Lỗi: Không thể tạo session screen${RESET}"
            echo -e "${RED}Vui lòng kiểm tra file /tmp/nexus_screen.log để biết chi tiết lỗi${RESET}"
            exit 1
        fi
        
        echo -e "${GREEN}Đang cài đặt môi trường phụ thuộc, vui lòng sử dụng tùy chọn 2 để xem tiến trình${RESET}"
        echo -e "${GREEN}Sau khi cài đặt hoàn tất, vui lòng làm theo hướng dẫn để khởi động trình xác thực${RESET}"
        echo -e "${GREEN}Nhật ký chi tiết được lưu tại /tmp/nexus_screen.log${RESET}"
        ;;
        
    2)
        # Kiểm tra xem trình xác thực có đang chạy không
        if ! screen -list | grep -q "nexus"; then
            echo -e "${RED}Session không tồn tại, vui lòng chọn tùy chọn 1 để cài đặt môi trường trước${RESET}"
            exit 1
        fi
        
        echo -e "${GREEN}Đang kết nối đến session...${RESET}"
        echo -e "${GREEN}Gợi ý: Sử dụng tổ hợp phím Ctrl+A+D để thoát session${RESET}"
        sleep 2
        screen -r nexus
        ;;
        
    *)
        echo -e "${RED}Tùy chọn không hợp lệ${RESET}"
        exit 1
        ;;
esac
