FROM manimcommunity/manim:v0.19.0

USER root

# 安装基础依赖（code-server 运行所需）
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装 code-server（VSCode 服务器版）
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version 4.16.1

# 安装 Jupyter 和必要的 Python 依赖
RUN pip install notebook ipykernel

# 配置 code-server（允许匿名访问，绑定 Binder 端口）
RUN mkdir -p /home/manimuser/.config/code-server \
    && echo "bind-addr: 0.0.0.0:8888" > /home/manimuser/.config/code-server/config.yaml \
    && echo "auth: none" >> /home/manimuser/.config/code-server/config.yaml \
    && echo "cert: false" >> /home/manimuser/.config/code-server/config.yaml \
    && chown -R manimuser:manimuser /home/manimuser/.config

# 安装 VSCode 扩展（可选，提升体验）
RUN code-server --install-extension ms-python.python \
    && code-server --install-extension ms-python.pylance \
    && code-server --install-extension jithurjacob.nbpreviewer  # Jupyter 笔记本预览支持

ARG NB_USER=manimuser
USER ${NB_USER}

# 复制项目文件到容器（保持原权限）
COPY --chown=manimuser:manimuser . /manim
WORKDIR /manim

# 启动命令：用 code-server 替代默认 Jupyter
CMD ["code-server", "--config", "/home/manimuser/.config/code-server/config.yaml", "/manim"]
