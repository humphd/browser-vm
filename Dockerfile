FROM rastasheep/ubuntu-sshd:18.04

# Buildroot version to use
ARG BUILD_ROOT_RELEASE=2021.02-rc2
# Root password for SSH
ARG ROOT_PASSWORD=browser-vm

# Copy v86 buildroot board config into image.
# NOTE: if you want to override this later to play with
# the config (e.g., run `make menuconfig`), mount a volume:
# docker run ... -v $PWD/buildroot-v86:/buildroot-v86 ...
COPY ./buildroot-v86 /buildroot-v86

# Setup SSH (for Windows users) and prepare apt-get
RUN echo 'root:${ROOT_PASSWORD}' | chpasswd; \
    # Install all Buildroot deps
    sed -i 's|deb http://us.archive.ubuntu.com/ubuntu/|deb mirror://mirrors.ubuntu.com/mirrors.txt|g' /etc/apt/sources.list; \
    dpkg --add-architecture i386; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get -q update;

# Install all Buildroot deps and prepare buildroot
WORKDIR /root
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
    bc \
    build-essential \
    bzr \
    cpio \
    cvs \
    git \
    unzip \
    wget \
    libc6:i386 \
    libncurses5-dev \
    libssl-dev \
    rsync; \
    wget -c http://buildroot.org/downloads/buildroot-${BUILD_ROOT_RELEASE}.tar.gz; \
    tar axf buildroot-${BUILD_ROOT_RELEASE}.tar.gz;

# configure the locales
ENV LANG='C' \
    LANGUAGE='en_US:en' \
    LC_ALL='C' \ 
    NOTVISIBLE="in users profile" \
    TERM=xterm

# Buildroot will place built artifacts here at the end.
VOLUME /build

WORKDIR /root/buildroot-${BUILD_ROOT_RELEASE}
ENTRYPOINT ["/buildroot-v86/build-v86.sh"]
