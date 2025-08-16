FROM manimcommunity/manim:v0.19.0

USER root

# 仅安装必要依赖：curl（用于安装 code-server）和基础工具
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 安装指定版本的 code-server（轻量安装）
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version 4.16.1

# 安装 Jupyter 核心组件（仅保留必要部分）
RUN pip install notebook ipykernel --no-cache-dir

# 配置 code-server 基础设置（仅保留关键配置）
RUN mkdir -p /home/manimuser/.config/code-server && \
    echo "bind-addr: 0.0.0.0:8888" > /home/manimuser/.config/code-server/config.yaml && \
    echo "auth: none" >> /home/manimuser/.config/code-server/config.yaml && \
    echo "cert: false" >> /home/manimuser/.config/code-server/config.yaml && \
    chown -R manimuser:manimuser /home/manimuser/.config

# 仅安装最必要的 VSCode 扩展（Python 支持）
RUN code-server --install-extension ms-python.python

# 切换回普通用户
ARG NB_USER=manimuser
USER ${NB_USER}

# 复制项目文件并设置工作目录
COPY --chown=manimuser:manimuser . /manim
WORKDIR /manim

# 暴露端口并设置启动命令
EXPOSE 8888
CMD ["code-server", "--config", "/home/manimuser/.config/code-server/config.yaml", "/manim"]
    
