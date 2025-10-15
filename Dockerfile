FROM runpod/worker-comfyui:5.4.0-sdxl

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus && \
    git clone https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && \
    git clone https://github.com/kijai/ComfyUI-ADMotionDirector

RUN mkdir -p /workspace/ComfyUI/models/{checkpoints,vae,ipadapter,clip_vision,animatediff_models,animatediff_motion_lora,loras,diffusion_models,text_encoders}

COPY start_models.sh /usr/local/bin/start_models.sh
RUN chmod +x /usr/local/bin/start_models.sh
ENTRYPOINT ["/usr/local/bin/start_models.sh"]
