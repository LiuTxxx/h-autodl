#!/bin/bash

export PATH="/root/miniconda3/envs/comfyenv/bin:$PATH"
# Define the base directories for models and ComfyUI
model_dir="/root/autodl-tmp/models"
comfyui_dir="/root/autodl-tmp/ComfyUI/models"

# Function to download or prepare model data
# Arguments: 
# $1 = model_type, $2 = data (comma-separated), $3 = repo_name, $4 (optional) = target_dir
function cgdown() {
    local model_type=$1
    local data=$2
    local repo_name=$3
    local target_dir=$4

    # Initialization file to track download completion
    init_file="./.h_init_$model_type"
    if [ -e "$init_file" ]; then
        echo ">>>> $model_type 已经被初始化"
        return
    fi

    # Process each data entry (comma-separated values)
    echo "$data" | while IFS=',' read -r target_file source_file; do
        target_path="$target_dir/$target_file"
        echo "<<<<<$source_file"

        # Download from the repo and move to the target directory
        cg down "LiuTxxx/$repo_name/$source_file" -t "$model_dir"
        mkdir -p "$(dirname "$comfyui_dir/$target_path")"

        # Move the file to the correct location if necessary
        if [ -e "$comfyui_dir/$target_path" ]; then
            echo ">>>> $source_file 已存在"
        else
            mv "$model_dir/$repo_name/$source_file" "$comfyui_dir/$target_path"
        fi
    done

    # clear all dir and files in /models
    rm -r *
    rm -rf .h*

    # Mark download as complete
    echo $(date +%s) > "$init_file"
    echo ">>>> $model_type 下载完毕"
    echo ""
}

# Function to initialize the environment
init_env() {
    echo "初始化环境中..."

    # Create the model directory if it doesn't exist
    mkdir -p "$model_dir"
    cd "$model_dir"
    
    if [ "$(ls -A)" ]; then
        rm -rf *
        rm -rf .h*
    fi
    
    cd ..
    if [ -e "ComfyUI" ]; then
        echo "删除原有ComfyUI环境..."
        rm -r ComfyUI
    fi
    
    cp -r /root/ComfyUI /root/autodl-tmp/
}

# Function to download selected fruit
download() {
    local model_type=$1
    echo "准备下载: $model_type"
    
    cd $model_dir
    
    # Model download logic for different types
    local filename="/root/h-autodl/comfyui/download_guide/$1.txt"
    if [ -f "$filename" ]; then
        # Read the first line for the folder names
        IFS=',' read -r repo_name target_dir < "$filename"
        # Read the rest of the file into the data variable
        local data=$(sed '1d' "$filename")

        # Call cgdown with clear parameters
        cgdown "$model_type" "$data" "$repo_name" "$target_dir"
    else
        echo "模型下载引导文件 $filename 不存在."
    fi
}

# Main logic
if [[ "$1" == "init" ]]; then
    init_env
elif [[ -n "$1" ]]; then
    download "$1"
else
    echo "Usage: $0 {init|[model_name]}"
    exit 1
fi
