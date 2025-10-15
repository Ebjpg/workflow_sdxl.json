#!/usr/bin/env bash
set -e
BASE=/workspace/ComfyUI/models
mkdir -p $BASE/{checkpoints,vae,ipadapter,clip_vision,animatediff_models,animatediff_motion_lora,loras,diffusion_models,text_encoders}
dl(){ url="$1"; out="$2"; [ -f "$out" ] || curl -L --fail --retry 3 "$url" -o "$out"; }

# SDXL hattı
dl "$SDXL_URL"        "$BASE/checkpoints/sdxl.safetensors"
dl "$IPADAPTER_URL"   "$BASE/ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors"
dl "$CLIP_VISION_URL" "$BASE/clip_vision/CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors"
dl "$AD_MM_URL"       "$BASE/animatediff_models/mm_sd_v15_v2.safetensors"
dl "$MD_LORA_URL"     "$BASE/animatediff_motion_lora/motiondirector_lora.safetensors"

# WAN hattı (şimdilik boş; az sonra ekleyeceğiz)
exec /start.sh
