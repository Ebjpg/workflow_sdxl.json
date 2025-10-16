set -euxo pipefail

BASE=/comfyui/models
mkdir -p "$BASE"/{checkpoints,vae,ipadapter,clip_vision,animatediff_models,animatediff_motion_lora,loras,diffusion_models,text_encoders}

dl(){ url="$1"; out="$2"; echo ">>> $url -> $out"; [ -f "$out" ] || curl -L --fail --retry 3 "$url" -o "$out"; ls -lh "$out"; }

# SDXL hattı
dl "${SDXL_URL}"        "$BASE/checkpoints/sd_xl_base_1.0.safetensors"
dl "${IPADAPTER_URL}"   "$BASE/ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors"
dl "${CLIP_VISION_URL}" "$BASE/clip_vision/open_clip_pytorch_model.bin"
dl "${AD_MM_URL}"       "$BASE/animatediff_models/mm_sd_v15_v2.ckpt"
dl "${MD_LORA_URL}"     "$BASE/animatediff_motion_lora/motiondirector_lora.safetensors"

echo ">>> starting worker..."
exec /start.sh
