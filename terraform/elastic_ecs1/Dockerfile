FROM docker.elastic.co/beats/filebeat:7.17.0

# Copy your custom config
COPY filebeat.yml /usr/share/filebeat/filebeat.yml

# Set permissions
USER root
RUN chown filebeat:filebeat /usr/share/filebeat/filebeat.yml && \
    chmod 755 /usr/share/filebeat/filebeat.yml

# Filebeat runs as non-root
USER filebeat
