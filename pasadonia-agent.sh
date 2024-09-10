#!/bin/bash

# Prompt for user inputs
read -p "Enter your WebSocket Token: " WEBSOCKET_TOKEN
read -p "Enter your Agent Secret Key: " AGENT_SECRET_KEY
read -p "Enter your AgentIP: " AGENTIP
read -p "Enter your GitHub Token: " GITHUB_TOKEN


# Install the network-agent package from GitHub
# sudo pip install git+https://github.com/asadsamar1107/network-agent.git
sudo pip install git+https://$GITHUB_TOKEN@github.com/tachyonsecurity/network-agent.git



NETWORK_AGENT_PATH=$(which network-agent)
P_Working_DIR=$(pwd)

# check before  proceeding
if [ -z "$NETWORK_AGENT_PATH" ]; then
    echo "Error: network-agent command not found. Exiting."
    exit 1
fi

# Create .env file
cat > "$P_Working_DIR/.env" <<EOL
WEBSOCKET_TOKEN=$WEBSOCKET_TOKEN
AGENT_SECRET_KEY=$AGENT_SECRET_KEY
AGENTIP=$AGENTIP
EOL

#give the permission to .env
chmod 600 "$P_Working_DIR/.env"

# Create the systemd service file dynamically
sudo tee /etc/systemd/system/pasadonia_agent.service > /dev/null <<EOL
[Unit]
Description=Pasadonia Agent Service
After=network-online.target

[Service]
EnvironmentFile=$P_Working_DIR/.env
ExecStart=$NETWORK_AGENT_PATH
WorkingDirectory=$P_Working_DIR
Restart=on-failure
RestartSec=30
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOL

# Reload, enable, and start the service
sudo systemctl daemon-reload
sudo systemctl enable --now pasadonia_agent.service

echo "Pasadonia Agent installed and running as a systemd service."
