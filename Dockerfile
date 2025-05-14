FROM vastai/base-image:cuda-12.8.1-auto

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/conda/bin:$PATH"

# ---------- System Dependencies ----------
RUN apt-get update && \
    apt-get install -y wget git ffmpeg libsox-dev curl && \
    rm -rf /var/lib/apt/lists/*

# ---------- Install Miniconda ----------
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh

# ---------- Create Conda Environment ----------
COPY environment.yml /tmp/environment.yml
RUN conda update -n base -c defaults conda && \
    conda env create -f /tmp/environment.yml && \
    conda clean -afy

# ---------- Set default shell to use conda env ----------
SHELL ["conda", "run", "-n", "LivePortrait", "/bin/bash", "-c"]

# ---------- Clone LivePortrait and Install ----------
WORKDIR /app
RUN git clone https://github.com/KwaiVGI/LivePortrait.git && \
    cd LivePortrait && \
    pip install --upgrade pip && \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 && \
    pip install -r requirements.txt && \
    huggingface-cli download KwaiVGI/LivePortrait --local-dir pretrained_weights --exclude "*.git*" "README.md" "docs"

WORKDIR /app/LivePortrait

CMD ["/bin/bash"]
