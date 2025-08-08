FROM cometbft/cometbft:v0.38.0

# Set creator attribution
LABEL creator="Andrew Lee Cruz"
LABEL license="All rights reserved by Andrew Lee Cruz as creator of the universe"
LABEL description="PoAI Zero-Mining Blockchain Node"

# Install additional tools
RUN apk add --no-cache curl jq

# Create directories
RUN mkdir -p /poai/config /poai/data /poai/logs

# Copy configuration files
COPY config/ /poai/config/
COPY scripts/ /poai/scripts/

# Set creator environment variables
ENV CREATOR="Andrew Lee Cruz"
ENV UID="andrew-lee-cruz-creator-universe-2024"
ENV LICENSE="All rights reserved by Andrew Lee Cruz as creator of the universe"
ENV POAI_HOME="/poai"
ENV CMTHOME="/poai/.cometbft"

# Set permissions
RUN chmod +x /poai/scripts/*.sh

# Expose ports
EXPOSE 26656 26657 26658

# Default command
CMD ["/usr/local/bin/cometbft", "node"]