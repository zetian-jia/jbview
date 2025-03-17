# jbrowse2

## introduction

jbrowse2 based on sif iamge, for large bigdata support.

## install

### software
```bash
sif
```

### clone

```bash
git clone https://github.com/zetian-jia/jbview
```

### build

```bash
cd jbview/src
```

### run

```bash
jbrowse add-assembly hg38.chrom.sizes --alias=hg38 --name=GRCh38 --displayName="Homo sapiens (hg38)" --force --load inPlace --type chromSizes --out ./config.json
```

```bash
jbrowse add-track hg38.gene.bed  --force   --load inPlace   --category "bed"  --assemblyNames=GRCh38 --out ./config.json
```

```bash 
npx serve .
```


## Note

1. if you are the custom in server, in local terminal

```bash
ssh -t jname@212.212.212.21 -L 3000:localhost:3000 
```

open the browser `http://localhost:3000`