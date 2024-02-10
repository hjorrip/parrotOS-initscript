#!/bin/bash
#This script is executed every time your instance is spawned.

# Install NetExec
    echo "Installing NetExec"
    pipx install git+https://github.com/Pennyw0rth/NetExec

# Update Go version
#    echo "Updating Go Version"
#   mkdir -p ~/Downloads
#    cd ~/Downloads
#    echo "Downloading..."
#    wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
#    echo "Deleting old version"
#    sudo rm -rf ~/go
#    echo "Unpacking"
#    sudo tar -C ~/ -xzf go1.22.0.linux-amd64.tar.gz
#    echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.bashrc

# Install Ligolo
    # Define base directory for ligolo-ng setup and downloads directory for binaries
    BASE_DIR="$HOME/ligolo-ng"
    DOWNLOADS_DIR="$HOME/Downloads"

    # Ensure downloads directory exists
    mkdir -p "$BASE_DIR"
    mkdir -p "$DOWNLOADS_DIR"

    # Function to check available disk space and proceed only if sufficient
    check_disk_space() {
        local required_space_mb=$1 # space required in MB
        local target_dir=$2 # directory to check space in
        local available_space_mb=$(df --output=avail "$target_dir" | tail -n 1 | awk '{print $1 / 1024}')
        
        if (( $(echo "$available_space_mb < $required_space_mb" | bc -l) )); then
            echo "Not enough disk space in $target_dir. Required: ${required_space_mb}MB, Available: ${available_space_mb}MB"
            exit 1
        fi
    }


    # Download and extract ligolo-ng binaries - ensure at least 100MB free for both
    echo "Checking disk space for ligolo-ng binaries..."
    check_disk_space 100 "$DOWNLOADS_DIR"

    echo "Downloading ligolo-ng binaries to $DOWNLOADS_DIR..."
    AGENT_URL="https://github.com/nicocha30/ligolo-ng/releases/download/v0.5.1/ligolo-ng_agent_0.5.1_linux_amd64.tar.gz"
    PROXY_URL="https://github.com/nicocha30/ligolo-ng/releases/download/v0.5.1/ligolo-ng_proxy_0.5.1_linux_amd64.tar.gz"

    wget -O "$DOWNLOADS_DIR/ligolo-agent.tar.gz" "$AGENT_URL"
    wget -O "$DOWNLOADS_DIR/ligolo-proxy.tar.gz" "$PROXY_URL"

    # Extract to BASE_DIR
    echo "Extracting binaries..."
    tar -xzf "$DOWNLOADS_DIR/ligolo-agent.tar.gz" -C "$BASE_DIR"
    tar -xzf "$DOWNLOADS_DIR/ligolo-proxy.tar.gz" -C "$BASE_DIR"

    # Cleanup the tar.gz files is optional here, based on whether you want to keep the archives
    echo "Cleaning up downloaded archives..."
    rm "$DOWNLOADS_DIR/ligolo-agent.tar.gz"
    rm "$DOWNLOADS_DIR/ligolo-proxy.tar.gz"

    # Building ligolo-ng for Linux and Windows (Assumes Go files are ready in $BASE_DIR)
    # No need - downloaded precompiled binaries
    #echo "Building ligolo-ng..."
    #cd "$BASE_DIR" || { echo "Directory $BASE_DIR does not exist."; exit 1; }
    #go build -o agent cmd/agent/main.go || { echo "Building agent failed"; exit 1; }
    #go build -o proxy cmd/proxy/main.go || { echo "Building proxy failed"; exit 1; }

    # Setup tun interface for Linux
    echo "Setting up tun interface for ligolo-ng..."
    sudo ip tuntap add user $(whoami) mode tun ligolo 2>/dev/null || sudo ip link set ligolo up

    echo "Setup complete."
