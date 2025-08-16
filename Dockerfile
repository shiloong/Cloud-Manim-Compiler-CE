FROM manimcommunity/manim:v0.19.0

USER root

# 安装基础依赖（确保 curl 可用）
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 单独安装 Node.js 和 npm（增加版本验证）
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    # 验证 Node.js 和 npm 安装成功
    node -v && npm -v

# 单独安装 Jupyter Notebook（更新 pip 避免依赖问题）
RUN pip install --upgrade pip && \
    pip install notebook && \
    # 验证 notebook 安装成功
    jupyter --version

# 单独安装 code-server（添加 --unsafe-perm 解决权限问题）
RUN npm install -g --unsafe-perm code-server@4.16.1 && \
    # 验证 code-server 安装成功
    code-server --version

# 配置 Jupyter 代理以访问 code-server
RUN mkdir -p ~/.jupyter/jupyter_server_config.d/ && \
    echo '{ \
      "ServerProxy": { \
        "config": { \
          "code-server": { \
            "command": ["code-server", "--auth", "none", "--port", "${PORT0}"], \
            "timeout": 30, \
            "launcher_entry": { \
              "title": "VS Code" \
            } \
          } \
        } \
      } \
    }' > ~/.jupyter/jupyter_server_config.d/code_server_proxy.json

ARG NB_USER=manimuser
USER ${NB_USER}

COPY --chown=manimuser:manimuser . /manim
    
