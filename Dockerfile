FROM runpod/worker-comfyui:5.4.1-sdxl

# Sistem paketleri
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates git ffmpeg unzip \
 && rm -rf /var/lib/apt/lists/*

# ComfyUI yolları
ENV COMFYUI_ROOT=/comfyui
ENV COMFYUI_CUSTOM_NODE_PATH=/comfyui/custom_nodes
ENV PYTHONPATH=/comfyui

# Custom nodes
RUN mkdir -p /comfyui/custom_nodes
WORKDIR /comfyui/custom_nodes

# Sağlam klon: git -> zip(main) -> zip(master)
RUN set -e; \
  getrepo() { \
    REPO="$1"; NAME="$2"; \
    git clone --depth=1 "https://github.com/${REPO}" "${NAME}" || { \
      curl -fsSL "https://codeload.github.com/${REPO}/zip/refs/heads/main" -o "/tmp/${NAME}-main.zip" || true; \
      if [ -s "/tmp/${NAME}-main.zip" ]; then unzip -q "/tmp/${NAME}-main.zip" -d /tmp && mv "/tmp/${NAME}-main" "${NAME}"; \
      else \
        curl -fsSL "https://codeload.github.com/${REPO}/zip/refs/heads/master" -o "/tmp/${NAME}-master.zip" || true; \
        [ -s "/tmp/${NAME}-master.zip" ] || { echo "FATAL: ${REPO} neither main nor master"; exit 1; }; \
        unzip -q "/tmp/${NAME}-master.zip" -d /tmp && mv "/tmp/${NAME}-master" "${NAME}"; \
      fi; \
    }; \
  }; \
  getrepo cubiq/ComfyUI_IPAdapter_plus ComfyUI_IPAdapter_plus; \
  getrepo comfyanonymous/ComfyUI-AnimateDiff ComfyUI-AnimateDiff; \
  getrepo Kosinkadink/ComfyUI-AnimateDiff-Evolved ComfyUI-AnimateDiff-Evolved; \
  getrepo Kosinkadink/ComfyUI-VideoHelperSuite ComfyUI-VideoHelperSuite; \
  getrepo kijai/ComfyUI-ADMotionDirector ComfyUI-ADMotionDirector

# Python bağımlılıkları
WORKDIR /comfyui
RUN pip install --no-cache-dir \
      imageio imageio-ffmpeg opencv-python-headless av moviepy \
  && [ -f custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI-AnimateDiff/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-AnimateDiff/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI-AnimateDiff-Evolved/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-AnimateDiff-Evolved/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI_IPAdapter_plus/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI_IPAdapter_plus/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI-ADMotionDirector/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-ADMotionDirector/requirements.txt || true

# Model klasörleri (ComfyUI path)
RUN mkdir -p /comfyui/models/{checkpoints,vae,ipadapter,clip_vision,animatediff_models,animatediff_motion_lora,loras,diffusion_models,text_encoders}

# Başlangıç betiği
COPY start_models.sh /usr/local/bin/start_models.sh
RUN chmod +x /usr/local/bin/start_models.sh

WORKDIR /comfyui
ENTRYPOINT ["/usr/local/bin/start_models.sh"]
