#!/bin/bash

source ~/miniconda3/etc/profile.d/conda.sh
conda activate taps

# ================= 配置区域 =================
# 1. 定义数据所在的文件夹路径 (请修改为你存放 fa 和 gff 的实际路径)
DATA_DIR="./reference_data"

mkdir -p "${DATA_DIR}"
# 定义 JBrowse 的根目录
JBROWSE_ROOT="jbrowse2"      # 存放config
# 定义你想存放 FASTA 的子目录
REF_DIR="reference"       # 存放软链接的地方，相对于config而言
# 1. 确保目录存在
mkdir -p "jbrowse2/$REF_DIR"

# 2. 定义 JBrowse 命令行工具 (如果你用 npx，请改为 "npx @jbrowse/cli")
JBROWSE_CMD="/data/zetian_jia_rawdata_20230405/jbview/.pixi/envs/default/bin/npx @jbrowse/cli "

# 3. 定义要处理的物种列表
SPECIES_LIST=("mm10" "hg38")
# ===========================================

# 检查依赖工具
if ! command -v samtools &> /dev/null || ! command -v bgzip &> /dev/null || ! command -v tabix &> /dev/null; then
    echo "❌ 错误: 缺少必要的生信工具。请确保安装了 samtools, bgzip (htslib) 和 tabix。"
    exit 1
fi

# 初始化 JBrowse (如果 config.json 不存在)


echo "🚀 开始批量处理..."

# 循环处理每个物种
for SP in "${SPECIES_LIST[@]}"; do
    echo "----------------------------------------"
    echo "正在处理物种: $SP"
    
    FA_FILE="${DATA_DIR}/${SP}.fa"
    GFF_FILE="${DATA_DIR}/${SP}.gff"

    ABS_FA_FILE=$(realpath "$FA_FILE")
    # --- 步骤 A: 手动建立软链接到目标子目录 ---
    TARGET_FA_LINK="${REF_DIR}/${SP}.fa"
    # 如果链接不存在，才创建
    if [ ! -e "$TARGET_FA_LINK" ]; then
        echo "🔗 [${SP}] 手动创建软链接到 reference 目录..."
        ln -s "$ABS_FA_FILE" "jbrowse2/$TARGET_FA_LINK"
        # 别忘了索引文件也要链接过去
        ln -s "${ABS_FA_FILE}.fai" "jbrowse2/${TARGET_FA_LINK}.fai"
    fi

    # --- 步骤 1: 检查并索引 FASTA ---
    if [ -f "$FA_FILE" ] || [ -L "$FA_FILE" ]; then
        if [ ! -f "${FA_FILE}.fai" ]; then
            echo "🔨 [${SP}] 正在建立 Fasta 索引 (.fai)..."
            samtools faidx "$FA_FILE"
        fi
        
        echo "➕ [${SP}] 添加 Assembly 到 JBrowse..."
        # --load symlink 确保只创建软链接，不复制大文件
        $JBROWSE_CMD add-assembly "$TARGET_FA_LINK" --name "$SP" --load inPlace --force --out jbrowse2
    else
        echo "⚠️ 跳过 [${SP}]: 找不到文件 $FA_FILE"
        continue
    fi

    # --- 步骤 2: 处理 GFF (排序 -> 压缩 -> 索引) ---
    # JBrowse 需要 .gff.gz 或 .gff.gz 且带有 .tbi 索引
    if [ -f "$GFF_FILE" ]; then
        PROCESSED_GFF="${DATA_DIR}/${SP}.sorted.gff.gz"
        
        # 检查是否已经处理过，避免重复运算
        if [ ! -f "$PROCESSED_GFF" ] || [ ! -f "${PROCESSED_GFF}.tbi" ]; then
            echo "🔨 [${SP}] 正在处理 GFF (排序, 压缩, 索引)... 这可能需要一点时间"
            # grep -v "#" 去掉注释行 (有时注释行会干扰排序)
            # sort -k1,1 -k4,4n 按照染色体和起始位置排序
            grep -v "#" "$GFF_FILE" | sort -k1,1 -k4,4n | bgzip > "$PROCESSED_GFF"
            tabix -p gff "$PROCESSED_GFF"
        else
            echo "✅ [${SP}] GFF 已处理索引，直接使用。"
        fi


        ABS_GFF_FILE=$(realpath "$PROCESSED_GFF")
        # --- 步骤 A: 手动建立软链接到目标子目录 ---
        TARGET_GFF_LINK="${REF_DIR}/${SP}.gff.gz"
        # 如果链接不存在，才创建
        if [ ! -e "$TARGET_GFF_LINK" ]; then
            echo "🔗 [${SP}] 手动创建软链接到 reference 目录..."
            ln -s "$ABS_GFF_FILE" "jbrowse2/$TARGET_GFF_LINK"
            # 别忘了索引文件也要链接过去
            ln -s "${ABS_GFF_FILE}.tbi" "jbrowse2/${TARGET_GFF_LINK}.tbi"
        fi


        echo "➕ [${SP}] 添加 GFF 轨道..."
        $JBROWSE_CMD add-track "$TARGET_GFF_LINK" \
            --name "${SP} Annotations" \
            --category "Genes" \
            --assemblyNames "$SP" \
            --load inPlace \
            --force \
            --out jbrowse2
    else
        echo "⚠️ [${SP}] 未找到 GFF 文件，跳过轨道添加。"
    fi

done

echo "----------------------------------------"
echo "🎉 所有任务完成！"
echo "请运行: npx serve -S . 进行查看"