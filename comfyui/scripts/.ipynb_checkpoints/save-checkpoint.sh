#!/bin/bash

# 源文件夹（需要复制的文件夹）
SOURCE_DIR="/root/autodl-tmp/ComfyUI"
# 目标文件夹（复制的目的地）
DEST_DIR="/root/"

mv /root/ComfyUI /root/ComfyUI_bak
# 写死的忽略文件或文件夹（精确到文件名）
IGNORE_FILES=(
"models/clip/flux"
"models/clip_vision*"
"models/unet"
"models/unet"
"models/controlnet*"
"models/controlnet"
"models/upscale_models"
"models/facerestore_models"
"models/grounding-dino"
"models/insightface"
"models/instantid"
"models/ipadapter"
"models/loras"
"models/vae"
"models/sams"
"models/checkpoints"
"models/inpaint"
"custom_nodes/comfyui_controlnet_aux/ckpts"
"custom_nodes/ComfyUI-WD14-Tagger/models"
"user/default/comfy.settings.json"
)

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Source directory $SOURCE_DIR does not exist!"
  exit 1
fi

# 创建目标目录（如果它不存在）
mkdir -p "$DEST_DIR"

# 构建 rsync 排除参数
EXCLUDE_ARGS=""
for file in "${IGNORE_FILES[@]}"; do
  EXCLUDE_ARGS="$EXCLUDE_ARGS --exclude=$file"
done

# 使用 rsync 复制文件夹，并忽略指定的文件或目录
rsync -av --progress $EXCLUDE_ARGS "$SOURCE_DIR" "$DEST_DIR"

echo "Files copied from $SOURCE_DIR to $DEST_DIR, ignoring: ${IGNORE_FILES[@]}"
