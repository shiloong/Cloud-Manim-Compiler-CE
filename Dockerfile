FROM manimcommunity/manim:v0.19.0

USER root

RUN pip install notebook
RUN pip install jupyter_ai
RUN jupyter labextension install @jupyter-ai/core

ARG NB_USER=manimuser
USER ${NB_USER}

COPY --chown=manimuser:manimuser . /manim

