FROM ubuntu:18.04
SHELL ["/bin/bash", "-c"]

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update and install pre-reqs
RUN apt-get update && \
    apt-get install -y locales

# Install packages for trunk-recorder
RUN apt-get install -y \
    ffmpeg \
    lame \
    gnuradio-dev \
    gr-osmosdr \
    libhackrf-dev \
    libuhd-dev \
    cmake \
    build-essential \
    libboost-all-dev \
    libusb-1.0-0.dev \
    libssl-dev

# Install packages for trunk-player
RUN apt-get install -y \
    python3-dev \
    virtualenv \
    redis-server \
    python3-pip \
    libpq-dev \
    postgresql-client \
    postgresql-client-common git

# Install packages for liquidsoap
RUN apt-get install -y \
    liquidsoap \
    socat

# Install tools
RUN apt-get install -y \
    gettext \
    git

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Fix locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Get and build trunk-recorder
RUN git clone https://github.com/robotastic/trunk-recorder.git /opt/recorder && \
    cd /opt/recorder && \
    cmake ./ && \
    make

# Get and configure trunk-player
RUN git clone https://github.com/ScanOC/trunk-player.git /opt/player && \
    cd /opt/player && \
    virtualenv -p python3 env --prompt='(Trunk Player)' && \
    source env/bin/activate && \
    pip install -r requirements.txt

# Setup container
COPY src_files/* ./

RUN mkdir -p /app/media /app/encoded /app/liquidsoap /logs && \
    chmod 0777 /logs

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]


CMD ["test"]
