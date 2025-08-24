FROM manimcommunity/manim:v0.19.0

USER root

# 安装中文字体
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    fonts-arphic-ukai \
    fonts-arphic-uming \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装notebook
RUN pip install notebook

ARG NB_USER=manimuser
USER ${NB_USER}

COPY --chown=manimuser:manimuser . /manim
