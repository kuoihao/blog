#!/bin/bash
docker run -d --name mkdocs --rm -v ~/docs:/docs -p 10000:8000 --workdir /docs squidfunk/mkdocs-material serve -a 0.0.0.0:8000