FROM runpod/worker-comfyui:5.4.1-sdxl

# Sistem paketleri
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates git ffmpeg unzip \
 && rm -rf /var/lib/apt/lists/*

# ComfyUI kök ve yollar
ENV COMFYUI_ROOT=/comfyui
ENV COMFYUI_CUSTOM_NODE_PATH=/comfyui/custom_nodes
ENV PYTHONPATH=/comfyui

# Custom nodes klasörü
RUN mkdir -p /comfyui/custom_nodes
WORKDIR /comfyui/custom_nodes

# Robust clone: git -> zip(main) -> zip(master)
RUN set -eux; \
  clone(){ repo="$1"; name="$(basename "$repo")"; \
    git clone --depth=1 "https://github.com/$repo" "$name" || { \
      curl -fsSL "https://codeload.github.com/$repo/zip/refs/heads/main" -o "/tmp/$name-main.zip" || true; \
      if [ -s "/tmp/$name-main.zip" ]; then unzip -q "/tmp/$name-main.zip" -d . && mv "${name}-main" "$name"; \
      else curl -fsSL "https://codeload.github.com/$repo/zip/refs/heads/master" -o "/tmp/$name-master.zip"; \
           unzip -q "/tmp/$name-master.zip" -d . && mv "${name}-master" "$name"; fi; \
    }; \
  }; \
  clone cubiq/ComfyUI_IPAdapter_plus; \
  clone comfyanonymous/ComfyUI-AnimateDiff; \
  clone Kosinkadink/ComfyUI-AnimateDiff-Evolved; \
  clone Kosinkadink/ComfyUI-VideoHelperSuite; \
  clone kijai/ComfyUI-ADMotionDirector

# Python bağımlılıkları
WORKDIR /comfyui
RUN pip install --no-cache-dir \
      imageio imageio-ffmpeg opencv-python-headless av moviepy \
  && [ -f custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI-AnimateDiff/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-AnimateDiff/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI-AnimateDiff-Evolved/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-AnimateDiff-Evolved/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI_IPAdapter_plus/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI_IPAdapter_plus/requirements.txt || true \
  && [ -f custom_nodes/ComfyUI-ADMotionDirector/requirements.txt ] && pip install --no-cache-dir -r custom_nodes/ComfyUI-ADMotionDirector/requirements.txt || true

# Modeller
RUN mkdir -p /comfyui/models/{checkpoints,vae,ipadapter,clip_vision,animatediff_models,animatediff_motion_lora,loras,diffusion_models,text_encoders}

# Entry
COPY start_models.sh /usr/local/bin/start_models.sh
RUN chmod +x /usr/local/bin/start_models.sh
WORKDIR /comfyui
ENTRYPOINT ["/usr/local/bin/start_models.sh"]
