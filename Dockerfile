# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""
ARG CIVITAI_API_KEY=""

# install custom nodes into comfyui
RUN git clone https://github.com/ltdrdata/was-node-suite-comfyui /comfyui/custom_nodes/was-node-suite-comfyui && cd /comfyui/custom_nodes/was-node-suite-comfyui && (git checkout afeee09ba44e713ec52a413ac6b105fd06b2d356 2>/dev/null || (git fetch origin afeee09ba44e713ec52a413ac6b105fd06b2d356 --depth=1 && git checkout afeee09ba44e713ec52a413ac6b105fd06b2d356) || echo "WARN: commit afeee09ba44e713ec52a413ac6b105fd06b2d356 unreachable in https://github.com/ltdrdata/was-node-suite-comfyui, falling back to default branch HEAD")

# download models into comfyui
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/fofr/comfyui/resolve/46d59a4e6a24234ccd2e148dcfca9a6c6225f7a5/checkpoints/dreamshaperXL_lightningDPMSDE.safetensors' --relative-path models/checkpoints --filename 'dreamshaperXL_lightningDPMSDE.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="60 300 900 1800 3600" && for i in 1 2 3 4 5; do CIVITAI_API_KEY=$CIVITAI_API_KEY comfy model download --url 'https://b2.civitai.com/file/civitai-modelfiles/model/33669/lineArtFLUXV1.O2Lx.safetensors?Authorization=3_20260701080747_8cb7fc48e5289a4e55781d84_e7aa7feb6d1d2ca873b0f6cb2bd75328df14fb58_004_20260701090747_0042_dnld&b2ContentDisposition=attachment%3B+filename%3D%22Line_Art_FLUX_V1.safetensors%22' --relative-path models/loras --filename 'Line_Art_FLUX_V1.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
