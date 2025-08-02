FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=C.UTF-8

RUN apt update && apt upgrade -y && \
    apt install -y openjdk-17-jdk git-core gnupg flex bison build-essential \
    zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
    lib32ncurses5-dev libx11-dev lib32z1-dev libgl1-mesa-dev \
    libxml2-utils xsltproc unzip fontconfig ccache liblz4-tool lzop \
    squashfs-tools pngcrush schedtool rsync bc python-is-python3 \
    libncurses5-dev libssl-dev libelf-dev && \
    apt clean

RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo && \
    chmod a+x /usr/local/bin/repo

RUN useradd -m builder && \
    mkdir -p /home/builder/android/lineage && \
    chown -R builder:builder /home/builder

USER builder
WORKDIR /home/builder/android/lineage