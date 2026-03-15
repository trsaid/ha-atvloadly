FROM bitxeno/atvloadly:latest

# Install avahi-daemon inside the container (not available on HA OS host)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        avahi-daemon \
        avahi-utils \
        dbus && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create required directories for dbus and avahi
RUN mkdir -p /var/run/dbus /var/run/avahi-daemon

# Configure avahi for container operation
COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf

# Copy custom entrypoint
COPY run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]