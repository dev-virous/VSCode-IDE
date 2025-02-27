# Start from the code-server Debian base image
FROM codercom/code-server:4.10.0
USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update -y
RUN sudo apt-get upgrade -y
RUN sudo apt install git -y
RUN sudo apt install python3-pip -y
RUN sudo apt install wget -y
RUN sudo apt install ffmpeg -y
RUN sudo apt install unzip -y
RUN sudo apt install p7zip-full -y
RUN sudo apt install pciutils lshw -y
RUN sudo apt install libarchive-tools -y
RUN sudo apt install cpio -y
RUN sudo apt install build-essential software-properties-common -y
RUN sudo apt-get install flac
RUN sudo apt-get install python3-libtorrent -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
RUN code-server --install-extension esbenp.prettier-vscode
RUN code-server --install-extension ms-python.python

# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# -----------

# Port
ENV PORT=8081
ENV PASSWORD=1234

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
