# Start from the code-server Debian base image
FROM codercom/code-server:4.10.0
USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install dependencies for building Python
RUN sudo apt-get update -y && \
    sudo apt-get install -y \
    wget \
    build-essential \
    checkinstall \
    libreadline-gplv2-dev \
    libncursesw5-dev \
    libssl-dev \
    libsqlite3-dev \
    tk-dev \
    libgdbm-dev \
    libc6-dev \
    libbz2-dev \
    zlib1g-dev \
    libffi-dev \
    liblzma-dev \
    libgdbm-compat-dev \
    uuid-dev

# Download and build Python 3.10
RUN wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz && \
    tar xzf Python-3.10.12.tgz && \
    cd Python-3.10.12 && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    sudo make altinstall && \
    cd .. && \
    rm -rf Python-3.10.12 Python-3.10.12.tgz

# Install pip for Python 3.10
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.10 get-pip.py && \
    rm get-pip.py

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get install -y \
    git \
    python3-pip \
    wget \
    ffmpeg \
    unzip \
    p7zip-full \
    flac \
    python3-libtorrent && \
    curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# Install VS Code extensions
RUN code-server --install-extension esbenp.prettier-vscode && \
    code-server --install-extension ms-python.python

# Port
ENV PORT=80
ENV PASSWORD=1234

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
