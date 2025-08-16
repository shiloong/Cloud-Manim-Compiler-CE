FROM manimcommunity/manim:v0.19.0

USER root

RUN apt-get update && apt-get install -y \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*


RUN pip install notebook && \
    npm install -g code-server@4.16.1


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
    
