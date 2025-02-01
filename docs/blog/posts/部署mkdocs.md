---
date: 
  created: 2024-02-01

categories:
  - mkdocs

links:
    - Homepage: index.md
    - Blog index: blog/index.md
    - External links:
      - Material documentation: https://squidfunk.github.io/mkdocs-material

tags:
  - mkdocs
  - python
  - github page
  
---

# mkdocs部署技术
本文记录了mkdocs在本地的部署过程以及部署到github pages的过程
<!-- more -->

!!!info "首先进行本地部署，使用docker方式部署"

1. 为方便修改文件，将容器相应目录挂载到本地，新建~/docs作为mkdocs工作目录的映射
2. 首先生成配置文件
```bash
docker run  -it --rm -v ~/docs:/docs squidfunk/mkdocs-material new .
```
3. 测试运行mkdocs
```bash
docker run -it --name mkdocs --rm -v ~/docs:/docs -p 10000:8000 --workdir /docs squidfunk/mkdocs-material serve -a 0.0.0.0:8000
```
4. 运行mkdocs
```bash
docker run -d --name mkdocs --rm -v ~/docs:/docs -p 10000:8000 --workdir /docs squidfunk/mkdocs-material serve -a 0.0.0.0:8000
```

!!! info "部署到github page"
[官方参考网址](https://squidfunk.github.io/mkdocs-material/publishing-your-site/#with-github-actions)
使用workflow自动生成gh-deploy分支，然后将github page的部署分支指向gh-deploy的/root

```yaml linenums="1" hl_lines="28 30"
name: ci 
on:
  push:
    branches:
      - master 
      - main
permissions:
  contents: write
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Configure Git Credentials
        run: |
          git config user.name github-actions[bot]
          git config user.email 41898282+github-actions[bot]@users.noreply.github.com
      - uses: actions/setup-python@v5
        with:
          python-version: 3.x
      - run: echo "cache_id=$(date --utc '+%V')" >> $GITHUB_ENV 
      - uses: actions/cache@v4
        with:
          key: mkdocs-material-${{ env.cache_id }}
          path: .cache
          restore-keys: |
            mkdocs-material-
      - run: pip install mkdocs # (1)!
      - run: pip install mkdocs-material 
      - run: pip install mkdocs-blogging-plugin  
      - run: mkdocs gh-deploy --force
```

1. 注意标亮的这两行，加上这两行github page的构建才不会出错



!!! info "参考网站"
[mkdocs-material](https://squidfunk.github.io/mkdocs-material/)

[Admonitions使用](https://squidfunk.github.io/mkdocs-material/reference/admonitions/#supported-types)

