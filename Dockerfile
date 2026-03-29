FROM nvidia/cuda:12.8.0-base-ubuntu22.04

# System dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3-pip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv and copy to system-wide location
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    cp /root/.local/bin/uv /usr/local/bin/uv

# Set working directory
WORKDIR /app

# Copy boltz source code
COPY . .

# Create venv first
RUN uv venv

# Install correct torch into venv before uv sync
RUN uv pip install --python /app/.venv/bin/python torch==2.7.1 \
    --index-url https://download.pytorch.org/whl/cu128

## Install correct torch FIRST before uv sync resolves dependencies
#RUN uv pip install --python 3.12 torch==2.7.1 \
#    --index-url https://download.pytorch.org/whl/cu128

# Install boltz and dependencies using uv
RUN uv sync --extra cuda

RUN echo 'source /app/.venv/bin/activate' >> /root/.bashrc

#RUN source .venv/bin/activate
# Permanently add venv to PATH — this replaces needing to "activate"
ENV PATH="/app/.venv/bin:$PATH"
ENV VIRTUAL_ENV="/app/.venv"

# Default command
CMD ["/bin/bash"]
