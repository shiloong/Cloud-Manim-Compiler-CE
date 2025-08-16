# 改用轻量 Python 基础镜像（约 1GB，比原 Manim 镜像小 70%）
FROM python:3.11-slim-bookworm

USER root

# 仅安装 Manim 运行必需的系统依赖（移除非必需工具）
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ffmpeg \  # Manim 渲染必需
    libcairo2 \  # 图形渲染依赖
    && rm -rf /var/lib/apt/lists/*  # 清理缓存，减少体积

# 安装 code-server（指定轻量版本）
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version 4.14.1  # 更稳定的旧版本

# 安装 Manim 核心包（仅必要组件）和 Jupyter
RUN pip install --no-cache-dir \
    manim==0.19.0 \
    notebook ipykernel \
    # 可选：添加 Manim 基础依赖（如无特殊需求可省略）
    # pycairo pango

# 配置 code-server（极简配置）
RUN mkdir -p /home/manimuser/.config/code-server && \
    echo "bind-addr: 0.0.0.0:8888" > /home/manimuser/.config/code-server/config.yaml && \
    echo "auth: none" >> /home/manimuser/.config/code-server/config.yaml && \
    echo "cert: false" >> /home/manimuser/.config/code-server/config.yaml && \
    chown -R 1000:1000 /home/manimuser  # 使用通用用户 ID，避免权限问题

# 创建普通用户（避免 root 运行，符合 Binder 安全策略）
RUN useradd -m -u 1000 manimuser
USER manimuser

# 复制项目文件（仅必要文件）
COPY --chown=manimuser:manimuser Cloud-Manim-Compiler-JupyterLab.ipynb /home/manimuser/
WORKDIR /home/manimuser

# 启动脚本：先启动 code-server，再输出日志（帮助调试）
CMD ["sh", "-c", "code-server --config /home/manimuser/.config/code-server/config.yaml /home/manimuser > code-server.log 2>&1 & tail -f code-server.log"]
