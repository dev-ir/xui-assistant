    local db_file="/etc/x-ui/x-ui.db"

    read -p "Destination SERVER IP (e.g., 127.0.0.1): " dest_ip
    read -p "Destination SERVER USER (e.g., root) [default: root]: " dest_user
    read -p "Destination SERVER PORT (e.g., 22) [default: 22]: " dest_port

    dest_user=${dest_user:-root}
    dest_port=${dest_port:-22}

    echo "Transferring database..."
    scp -P "$dest_port" "$db_file" "$dest_user@$dest_ip:/etc/x-ui"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Transfer completed successfully.${NC}"
    else
        echo -e "${RED}Transfer failed.${NC}"
    fi