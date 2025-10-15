FROM runpod/worker-comfyui:5.4.1-sdxl

# Gerekli paketler
RUN apt-get update && apt-get install -y --no-install-recommends git ffmpeg \
 && rm -rf /var/lib/apt/lists/*

# Dizinleri oluştur
RUN mkdir -p /workspace/ComfyUI/custom_nodes

# Custom nodes
WORKDIR /workspace/ComfyUI/custom_nodes
RUN git clone --depth=1 https://github.com/cubiq/ComfyUI_IPAdapter_plus && \
    git clone --depth=1 https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved && \
    git clone --depth=1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && \
    git clone --depth=1 https://github.com/kijai/ComfyUI-ADMotionDirector

# Model klasörleri
RUN mkdir -p /workspace/ComfyUI/models/{checkpoints,vae,ipadapter,clip_vision,animatediff_models,animatediff_motion_lora,loras,diffusion_models,text_encoders}

# Başlangıç scripti
COPY start_models.sh /usr/local/bin/start_models.sh
RUN chmod +x /usr/local/bin/start_models.sh
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/start_models.sh"]
