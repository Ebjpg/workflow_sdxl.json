FROM runpod/worker-comfyui:5.4.1-sdxl

# Sistem paketleri
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates git ffmpeg \
 && rm -rf /var/lib/apt/lists/*

# ComfyUI yol ortam değişkenleri (keşfi zorlamamız için)
ENV COMFYUI_ROOT=/workspace/ComfyUI
ENV COMFYUI_CUSTOM_NODE_PATH=/workspace/ComfyUI/custom_nodes
ENV PYTHONPATH=/workspace/ComfyUI

# Dizinler
RUN mkdir -p /workspace/ComfyUI/custom_nodes
WORKDIR /workspace/ComfyUI/custom_nodes

# Custom nodes
RUN git clone --depth=1 https://github.com/cubiq/ComfyUI_IPAdapter_plus && \
    git clone --depth=1 https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved && \
    git clone --depth=1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && \
    git clone --depth=1 https://github.com/kijai/ComfyUI-ADMotionDirector

# Python bağımlılıkları (VHS/AD/IPAdapter/MotionDirector)
WORKDIR /workspace/ComfyUI
RUN pip install --no-cache-dir \
      imageio imageio-ffmpeg opencv-python-headless av moviepy \
  && [ -f custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI-AnimateDiff-Evolved/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-AnimateDiff-Evolved/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI_IPAdapter_plus/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI_IPAdapter_plus/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI-ADMotionDirector/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-ADMotionDirector/requirements.txt || true

# Model klasörleri
RUN mkdir -p /workspace/ComfyUI/models/{checkpoints,vae,ipadapter,clip_vision,animatediff_models,animatediff_motion_lora,loras,diffusion_models,text_encoders}

# Başlangıç scripti
COPY start_models.sh /usr/local/bin/start_models.sh
RUN chmod +x /usr/local/bin/start_models.sh

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/start_models.sh"]
