FROM ubuntu:22.04

ENV USER="streamlit"
ENV GROUP="streamlit"
ENV HOME_DIR="/home/${USER}"
ENV SRC_DIR="${HOME_DIR}/src" \
    PATH="${HOME_DIR}/.local/bin:${PATH}"

# configures locale
RUN apt update -qq > /dev/null \
    && DEBIAN_FRONTEND=noninteractive apt install -qq --yes --no-install-recommends \
    locales && \
    locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

# system requirements to build most of the recipes
RUN apt update -qq > /dev/null \
    && DEBIAN_FRONTEND=noninteractive apt install -qq --yes --no-install-recommends \
    git \
    python3 \
    python3-pip \
    sudo \
    unzip \
    zip

# prepares non root env
RUN useradd --create-home --shell /bin/bash ${USER}
# with sudo access and no password
RUN usermod -append --groups sudo ${USER}
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER ${USER}
WORKDIR /home/${USER}
RUN echo "alias ls='ls -CFa --color=auto'" >> .bashrc
RUN echo "alias lsl='ls -CFaltr --color=auto'" >> .bashrc
WORKDIR ${SRC_DIR}
RUN chown ${USER}:${GROUP} ${SRC_DIR}
COPY --chown=${USER}:${GROUP} requirements.txt requirements.txt

# install dependencies
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt
