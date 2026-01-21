# JBrowse 2 Local Development Setup

This repository contains a pre-built JBrowse 2 instance and setup instructions for local development and testing.

## Prerequisites

- [Pixi](https://pixi.sh/) – a cross-platform package manager
- Node.js (installed via Pixi)
- Basic familiarity with the command line

## Quick Start

1. **Install Node.js via Pixi** (if not already installed):

   ```bash
   pixi add nodejs
   ```

2. **Enter the Pixi shell** to activate the environment:

   ```bash
   pixi shell
   ```

3. **Verify the JBrowse CLI** is available:

   ```bash
   npx @jbrowse/cli --version
   ```

## Creating a New JBrowse 2 Instance

If you need to create a fresh JBrowse 2 project (instead of using the pre‑built `jbrowse2/` folder), run:

```bash
npx @jbrowse/cli create jbrowse2
cd jbrowse2/
```

## Serving the JBrowse 2 Application

Start a local development server with:

```bash
npx serve .
```

If you plan to use symlinked data files later, use the `-S` flag to preserve symbolic links:

```bash
npx serve -S .
```
> 命令中的 -S 标志（或 --symlinks）就是给服务员的一张特别通行证。
> 如果你看到指向文件夹外部的软链接（纸条），请放心大胆地顺着它去找文件，我授权你走出这个房间。

The server will print a URL (typically `http://localhost:3000`) where you can open JBrowse 2 in your browser.

## Proxy Configuration (Optional)

If you are behind a corporate proxy or need to route traffic through a local proxy, set the following environment variables before running any `npx` commands:

```bash
export http_proxy="http://127.0.0.1:6789"
export https_proxy="http://127.0.0.1:6789"
```

Alternatively, you can tunnel traffic via SSH:

```bash
ssh -R 6789:127.0.0.1:7890 jiazetian@210.42.120.57
```

## Using with Positron / VS Code

You can launch the local directory directly in Positron or VS Code, which will automatically handle port forwarding and provide a streamlined development experience.

## Pre‑built Instance

This repository already includes a built JBrowse 2 instance in the `jbrowse2/` folder. You can serve it directly without running `create`. The built files are intended for demonstration and testing purposes.

## Notes

- The `pixi.toml` file defines the project dependencies and environment.
- Test data is available under `jbrowse2/test_data/` for exploring JBrowse 2 features.
- For more detailed documentation, visit the [JBrowse 2 official website](https://jbrowse.org/jb2/).



手动增加lincRNA gff文件
```bash
PROCESSED_GFF="mm10.linRNA.sorted.gff.gz"
GFF_FILE="mm10.linRNA.gff"
ABS_GFF_FILE=$(realpath "$PROCESSED_GFF")
TARGET_GFF_LINK="/data/zetian_jia_rawdata_20230405/jbview/jbrowse2/reference/mm10.linRNA.gff.gz"
JBROWSE_CMD="/data/zetian_jia_rawdata_20230405/jbview/.pixi/envs/default/bin/npx @jbrowse/cli "
SP="mm10"


conda activate taps
grep -v "#" "$GFF_FILE" | sort -k1,1 -k4,4n | bgzip > "$PROCESSED_GFF"
tabix -p gff "$PROCESSED_GFF"
ln -s "$ABS_GFF_FILE" "$TARGET_GFF_LINK"
# 别忘了索引文件也要链接过去
ln -s "${ABS_GFF_FILE}.tbi" "${TARGET_GFF_LINK}.tbi"

$JBROWSE_CMD add-track reference/mm10.linRNA.gff.gz \
            --name "${SP} linc Annotations" \
            --category "Genes" \
            --assemblyNames "$SP" \
            --load inPlace \
            --force \
            --out jbrowse2
```

### Indexing feature names for searching
构建搜索
```
npx @jbrowse/cli  text-index --attributes Name,ID,gene_name,gene_id,symbol --out jbrowse2  --force
```