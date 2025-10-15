# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.4.1-base

# download models and put them into the correct folders in comfyui (one RUN per model)
RUN comfy model download --url https://huggingface.co/runwayml/stable-diffusion-xl-1.0/resolve/main/sd_xl_base_1.0.safetensors --relative-path models/checkpoints --filename sdxl.safetensors
RUN comfy model download --url https://huggingface.co/h94/IP-AdapterPlus/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors --relative-path models/checkpoints --filename ip-adapter-plus_sdxl_vit-h.safetensors
RUN comfy model download --url https://huggingface.co/hakurei/magicanimate/resolve/main/mm_sd_v15_v2.safetensors --relative-path models/checkpoints --filename mm_sd_v15_v2.safetensors
RUN comfy model download --url https://huggingface.co/luodian/motiondirector/resolve/main/motiondirector_lora.safetensors --relative-path models/loras --filename motiondirector_lora.safetensors

# copy all input data (like images or videos) into comfyui
COPY input/ /comfyui/input/