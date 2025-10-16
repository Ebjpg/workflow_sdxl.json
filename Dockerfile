FROM runpod/worker-comfyui:5.4.1-sdxl

# Sistem paketleri
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates git ffmpeg \
 && rm -rf /var/lib/apt/lists/*

# ComfyUI kök
ENV COMFYUI_ROOT=/comfyui
ENV COMFYUI_CUSTOM_NODE_PATH=/comfyui/custom_nodes
ENV PYTHONPATH=/comfyui

# Dizinler
RUN mkdir -p /comfyui/custom_nodes
WORKDIR /comfyui/custom_nodes

# Custom nodes
RUN git clone --depth=1 https://github.com/cubiq/ComfyUI_IPAdapter_plus && \
    git clone --depth=1 https://github.com/comfyanonymous/ComfyUI-AnimateDiff && \
    git clone --depth=1 https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved && \
    git clone --depth=1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && \
    git clone --depth=1 https://github.com/kijai/ComfyUI-ADMotionDirector

# Python bağımlılıkları
WORKDIR /comfyui
RUN pip install --no-cache-dir \
      imageio imageio-ffmpeg opencv-python-headless av moviepy \
  && [ -f custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI-AnimateDiff-Evolved/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-AnimateDiff-Evolved/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI_IPAdapter_plus/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI_IPAdapter_plus/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI-ADMotionDirector/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-ADMotionDirector/requirements.txt || true

# Model klasörleri (DOĞRU DİZİNE)
RUN mkdir -p /comfyui/models/{checkpoints,vae,ipadapter,clip_vision,animatediff_models,animatediff_motion_lora,loras,diffusion_models,text_encoders}

# Başlangıç scripti
COPY start_models.sh /usr/local/bin/start_models.sh
RUN chmod +x /usr/local/bin/start_models.sh

WORKDIR /comfyui
ENTRYPOINT ["/usr/local/bin/start_models.sh"]
