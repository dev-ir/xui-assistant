#!/bin/bash

# Function to check if the user is root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root."
        exit 1
    fi
}

# Function to check if the OS is Ubuntu
check_ubuntu() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" != "ubuntu" ]]; then
            echo "This script is designed for Ubuntu only."
            exit 1
        fi
    else
        echo "Unable to detect the operating system."
        exit 1
    fi
}

# Function to install Docker if not installed
install_docker() {
    if command -v docker &> /dev/null; then
        echo "Docker is already installed."
        return
    fi
    
    echo "Docker is not installed. Installing Docker..."
    
    # Update the package index
    apt-get update
    
    # Install required packages to allow apt to use a repository over HTTPS
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Set up the stable repository
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update the package index again after adding the Docker repository
    apt-get update
    
    # Install Docker CE (Community Edition)
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    if [ $? -eq 0 ]; then
        echo "Docker has been successfully installed."
    else
        echo "Failed to install Docker."
        exit 1
    fi
}
install_panels() {
    read -p "How many panels do you want to install? (1-20): " panel_count
    if ! [[ "$panel_count" =~ ^[1-9]$|^1[0-9]$|^20$ ]]; then
        echo "Invalid input. Please enter a number between 1 and 20."
        return
    fi
    
    base_panel_port=20000   # Base Panel Port (5 digits)
    base_sub_port=21000     # Base Sub Port (5 digits)
    base_inbound_port=22000 # Base Example Inbound Port (5 digits)
    port_range=100          # Number of ports to allocate per panel (can be increased)
    
    declare -A panel_ports # Array to store panel names and their ports
    
    for ((i = 1; i <= panel_count; i++)); do
        panel_dir="3x-ui-$i"
        panel_port_start=$((base_panel_port + (i - 1) * port_range))   # Start of Panel Port range
        sub_port_start=$((base_sub_port + (i - 1) * port_range))       # Start of Sub Port range
        inbound_port_start=$((base_inbound_port + (i - 1) * port_range)) # Start of Inbound Port range
        
        # Calculate the end of the port ranges
        panel_port_end=$((panel_port_start + port_range - 1))
        sub_port_end=$((sub_port_start + port_range - 1))
        inbound_port_end=$((inbound_port_start + port_range - 1))
        
        # Ensure ports are within the valid range (1-65535)
        if [[ $panel_port_end -gt 65535 || $sub_port_end -gt 65535 || $inbound_port_end -gt 65535 ]]; then
            echo "Error: Port range exceeds the maximum allowed port number (65535)."
            return
        fi
        
        mkdir -p "$panel_dir"
        cd "$panel_dir" || exit
        
        echo "Cloning repository for panel $i..."
        git clone https://github.com/MHSanaEi/3x-ui.git .
        
        echo "Starting panel $i with port ranges:"
        echo "Panel Ports: $panel_port_start-$panel_port_end"
        echo "Sub Ports: $sub_port_start-$sub_port_end"
        echo "Inbound Ports: $inbound_port_start-$inbound_port_end"
        
        docker run -itd \
        -e XRAY_VMESS_AEAD_FORCED=false \
        -p "$panel_port_start-$panel_port_end:$panel_port_start-$panel_port_end" \
        -p "$sub_port_start-$sub_port_end:$sub_port_start-$sub_port_end" \
        -p "$inbound_port_start-$inbound_port_end:$inbound_port_start-$inbound_port_end" \
        -v $(pwd)/db/:/etc/x-ui/ \
        -v $(pwd)/cert/:/root/cert/ \
        --restart=always \
        --name "3x-ui-$i" \
        ghcr.io/mhsanaei/3x-ui:latest
        
        if [ $? -eq 0 ]; then
            echo "Panel $i has been successfully installed with port ranges:"
            echo "Panel Ports: $panel_port_start-$panel_port_end"
            echo "Sub Ports: $sub_port_start-$sub_port_end"
            echo "Inbound Ports: $inbound_port_start-$inbound_port_end"
            panel_ports["3x-ui-$i"]="Panel Ports: $panel_port_start-$panel_port_end, Sub Ports: $sub_port_start-$sub_port_end, Inbound Ports: $inbound_port_start-$inbound_port_end"
        else
            echo "Failed to install panel $i."
            # Clean up if the panel failed to install
            cd ..
            rm -rf "$panel_dir"
        fi
        
        cd ..
    done
    
    # Display the list of installed panels and their port ranges
    echo "===================="
    echo "Installed Panels:"
    echo "===================="
    for panel in "${!panel_ports[@]}"; do
        echo "Panel: $panel, Ports: ${panel_ports[$panel]}"
    done
}

# Function to update panels
update_panels() {
    # Get the list of installed panels
    panels=($(docker ps --format "{{.Names}}" | grep "3x-ui-" || true))

    if [ ${#panels[@]} -eq 0 ]; then
        echo "No panels are installed."
        return
    fi

    echo "===================="
    echo "Installed Panels:"
    echo "===================="

    # Display panels with their main port
    for panel_name in "${panels[@]}"; do
        # Get the main port using 'docker port'
        panel_port=$(docker port "$panel_name" 2053 | awk -F':' '{print $2}')
        if [ -z "$panel_port" ]; then
            panel_port="Unknown"
        fi
        echo "Panel: $panel_name, Ports: $panel_port"
    done

    while true; do
        echo ""
        echo "What do you want to do?"
        echo "1. Update a specific panel"
        echo "2. Update all panels"
        echo "3. Back to main menu"
        read -p "Please select an option: " choice

        case $choice in
        1)
            read -p "Enter the name of the panel to update (e.g., 3x-ui-1): " panel_name
            if docker ps --format "{{.Names}}" | grep -q "^$panel_name$"; then
                echo "Updating panel $panel_name..."

                # Determine the directory of the panel
                panel_dir=$(find "$(pwd)" -type d -name "$panel_name" 2>/dev/null)

                if [ -z "$panel_dir" ]; then
                    echo "Directory for panel $panel_name not found."
                    continue
                fi

                # Perform the update
                cd "$panel_dir" || { echo "Failed to access panel directory."; continue; }
                docker compose down
                docker compose pull 3x-ui
                docker compose up -d

                if [ $? -eq 0 ]; then
                    echo "Panel $panel_name has been updated successfully."
                else
                    echo "Failed to update panel $panel_name."
                fi

                cd ..
            else
                echo "Panel $panel_name does not exist."
            fi
            ;;
        2)
            echo "Updating all panels..."
            for panel_name in "${panels[@]}"; do
                echo "Updating panel $panel_name..."

                # Determine the directory of the panel
                panel_dir=$(find "$(pwd)" -type d -name "$panel_name" 2>/dev/null)

                if [ -z "$panel_dir" ]; then
                    echo "Directory for panel $panel_name not found. Skipping..."
                    continue
                fi

                # Perform the update
                cd "$panel_dir" || { echo "Failed to access panel directory. Skipping..."; continue; }
                docker compose down
                docker compose pull 3x-ui
                docker compose up -d

                if [ $? -eq 0 ]; then
                    echo "Panel $panel_name has been updated successfully."
                else
                    echo "Failed to update panel $panel_name."
                fi

                cd ..
            done
            ;;
        3)
            return
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
        esac
    done
}



# Function to remove panels
remove_panels() {
    # Get the list of running panels
    panels=($(docker ps --format "{{.Names}}" | grep "3x-ui-" || true))

    if [ ${#panels[@]} -eq 0 ]; then
        echo "No panels are installed."
        return
    fi

    echo "===================="
    echo "Installed Panels:"
    echo "===================="

    # Display panels with only the main port (Panel Port)
    for panel_name in "${panels[@]}"; do
        # Get the first mapped port using 'docker port'
        panel_port=$(docker port "$panel_name" 2053 | awk -F':' '{print $2}')
        
        if [ -z "$panel_port" ]; then
            panel_port="Unknown"
        fi

        echo "Panel: $panel_name, Ports: $panel_port"
    done

    while true; do
        echo ""
        echo "What do you want to do?"
        echo "1. Remove a specific panel"
        echo "2. Remove all panels"
        echo "3. Back to main menu"
        read -p "Please select an option: " choice

        case $choice in
        1)
            read -p "Enter the name of the panel to remove (e.g., 3x-ui-1): " panel_name
            if docker ps --format "{{.Names}}" | grep -q "^$panel_name$"; then
                echo "Removing panel $panel_name..."
                docker stop "$panel_name" > /dev/null 2>&1
                docker rm "$panel_name" > /dev/null 2>&1
                rm -rf "/$(pwd)/$panel_name"
                echo "Panel $panel_name has been removed successfully."
            else
                echo "Panel $panel_name does not exist."
            fi
            ;;
        2)
            echo "Removing all panels..."
            for panel_name in "${panels[@]}"; do
                echo "Removing panel $panel_name..."
                docker stop "$panel_name" > /dev/null 2>&1
                docker rm "$panel_name" > /dev/null 2>&1
                rm -rf "/$(pwd)/$panel_name"
            done
            echo "All panels have been removed successfully."
            return
            ;;
        3)
            return
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
        esac
    done
}


# Main menu
main_menu() {
    while true; do
        clear
        echo "===================="
        echo "Panel Management Menu"
        echo "===================="
        echo "1. Install Panels"
        echo "2. Update Panels"
        echo "3. Remove Panels"
        echo "4. Exit"
        echo ""
        read -p "Please select an option: " choice
        
        case $choice in
            1)
                install_panels
            ;;
            2)
                update_panels
            ;;
            3)
                remove_panels
            ;;
            4)
                echo "Exiting..."
                exit 0
            ;;
            *)
                echo "Invalid option. Please try again."
            ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Run the checks and start the main menu
check_root
check_ubuntu
install_docker
main_menu