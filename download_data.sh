#!/bin/bash

# ================= 配置区域 =================
DATA_DIR="./reference_data"
mkdir -p "$DATA_DIR"

echo "📂 数据存放目录: $DATA_DIR"
echo "----------------------------------------"

# 检查 wget
if ! command -v wget &> /dev/null; then
    echo "❌ 错误: 未找到 wget，请先安装。"
    exit 1
fi

# ================= 核心功能函数 =================
# 参数1: URL (下载链接)
# 参数2: FINAL_FILENAME (最终解压后的文件名，如 hg38.fa)
download_if_missing() {
    local URL="$1"
    local FINAL_FILE="$DATA_DIR/$2"
    local GZ_FILE="${FINAL_FILE}.gz"

    # 1. 检查最终文件是否存在
    if [ -f "$FINAL_FILE" ]; then
        echo "✅ [跳过] 文件已存在: $2"
        return
    fi

    # 2. 如果不存在，开始下载
    echo "⬇️  [下载] 正在下载 $2 ..."
    wget -c -q --show-progress "$URL" -O "$GZ_FILE"

    # 3. 检查下载是否成功
    if [ $? -eq 0 ]; then
        echo "📦 [解压] 正在解压 $2 ..."
        gunzip -f "$GZ_FILE"
        echo "🎉 完成: $2"
    else
        echo "❌ [失败] 下载失败: $URL"
        rm -f "$GZ_FILE" # 删除损坏的文件
        exit 1
    fi
    echo "----------------------------------------"
}

# ================= 开始任务 =================

# --- 1. Human (hg38) ---
echo "Processing Human (hg38)..."

# hg38 FASTA
download_if_missing \
    "https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz" \
    "hg38.fa"

# hg38 GTF (GENCODE v45)
download_if_missing \
    "https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_45/gencode.v45.annotation.gtf.gz" \
    "hg38.gtf"

download_if_missing \
    "https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_45/gencode.v45.annotation.gff3.gz" \
    "hg38.gff"

# --- 2. Mouse (mm10) ---
echo "Processing Mouse (mm10)..."

# mm10 FASTA
download_if_missing \
    "https://hgdownload.soe.ucsc.edu/goldenPath/mm10/bigZips/mm10.fa.gz" \
    "mm10.fa"

# mm10 GTF (GENCODE vM25 - 对应 mm10 版本)
download_if_missing \
    "https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/gencode.vM25.annotation.gtf.gz" \
    "mm10.gtf"
download_if_missing \
    "https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/gencode.vM25.annotation.gff3.gz" \
    "mm10.gff"

# mm10 GTF (GENCODE vM25 - 对应 mm10 版本)
download_if_missing \
    "https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/gencode.vM25.long_noncoding_RNAs.gff3.gz" \
    "mm10.linRNA.gff"

# ================= 结束 =================
echo "----------------------------------------"
echo "✅ 所有数据准备就绪！"
ls -lh "$DATA_DIR" | grep -E "fa|gtf|gff"