---
date:
    created: 2025-02-10
---

本文记录了本地部署ragflow+ollama的步骤和注意事项，以及了解到的知识

<!-- more -->

# 部署流程

## 1. 部署ollama
使用cpu：
```bash
docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
```
将/root/.ollama挂载到docker的数据卷中
```bash
docker volume inspect ollama

[
    {
        "CreatedAt": "2025-02-09T23:47:10+08:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/ollama/_data",
        "Name": "ollama",
        "Options": null,
        "Scope": "local"
    }
]
```
将modelfile和gguf文件复制到挂载点
编辑Modelfile
```bash
FROM PATH_TO_MODEL
PARAMETER temperature 0.8
SYSTEM "你是一个专业的AI助手"
```

```bash
sudo cp PATH_TO_MODEL /opt/deepseek/models/
sudo cp PATH_TO_MODELFILE /opt/deepseek/models/

docker exec -it ollama ls /root/.ollama/models #检验模型和配置文件
dockre exec -it ollama create MODEL_NAME -f PATH_TO_MODELFILE
docker exec -it ollama ollama ls #检验ollama模型列表
```

## 2. 部署ragflow

更改端口
9000端口被portainer占用，80端口被apache占用
更改如下文件：
```bash
$ git diff
diff --git a/conf/service_conf.yaml b/conf/service_conf.yaml
index 18b41e16..737bb1a5 100644
--- a/conf/service_conf.yaml
+++ b/conf/service_conf.yaml
@@ -12,7 +12,7 @@ mysql:
 minio:
   user: 'rag_flow'
   password: 'infini_rag_flow'
-  host: 'minio:9000'
+  host: 'minio:9001'
 es:
   hosts: 'http://es01:1200'
   username: 'elastic'
diff --git a/docker/.env b/docker/.env
index 53b4bb6d..07871c57 100644
--- a/docker/.env
+++ b/docker/.env
@@ -56,10 +56,10 @@ MYSQL_PORT=5455
 MINIO_HOST=minio
 # The port used to expose the MinIO console interface to the host machine, 
 # allowing EXTERNAL access to the web-based console running inside the Docker container. 
-MINIO_CONSOLE_PORT=9001
+MINIO_CONSOLE_PORT=9002
 # The port used to expose the MinIO API service to the host machine, 
 # allowing EXTERNAL access to the MinIO object storage service running inside the Docker container. 
-MINIO_PORT=9000
+MINIO_PORT=9001
 # The username for MinIO. 
 # When updated, you must revise the `minio.user` entry in service_conf.yaml accordingly.
 MINIO_USER=rag_flow
@@ -81,7 +81,7 @@ SVR_HTTP_PORT=9380
 
 # The RAGFlow Docker image to download.
 # Defaults to the v0.16.0-slim edition, which is the RAGFlow Docker image without embedding models.
-RAGFLOW_IMAGE=infiniflow/ragflow:v0.16.0-slim
+RAGFLOW_IMAGE=infiniflow/ragflow:v0.16.0
 #
 # To download the RAGFlow Docker image with embedding models, uncomment the following line instead:
 # RAGFLOW_IMAGE=infiniflow/ragflow:v0.16.0
diff --git a/docker/docker-compose-base.yml b/docker/docker-compose-base.yml
index 72951170..4f11b4cb 100644
--- a/docker/docker-compose-base.yml
+++ b/docker/docker-compose-base.yml
@@ -98,10 +98,10 @@ services:
   minio:
     image: quay.io/minio/minio:RELEASE.2023-12-20T01-00-02Z
     container_name: ragflow-minio
-    command: server --console-address ":9001" /data
+    command: server --console-address ":9002" /data
     ports:
-      - ${MINIO_PORT}:9000
-      - ${MINIO_CONSOLE_PORT}:9001
+      - ${MINIO_PORT}:9001
+      - ${MINIO_CONSOLE_PORT}:9002
     env_file: .env
     environment:
       - MINIO_ROOT_USER=${MINIO_USER}
diff --git a/docker/docker-compose.yml b/docker/docker-compose.yml
index 676f167d..9e3b80ad 100644
--- a/docker/docker-compose.yml
+++ b/docker/docker-compose.yml
@@ -10,7 +10,7 @@ services:
     container_name: ragflow-server
     ports:
       - ${SVR_HTTP_PORT}:9380
-      - 80:80
+      - 81:80
       - 443:443
     volumes:
       - ./ragflow-logs:/ragflow/logs
diff --git a/docker/service_conf.yaml.template b/docker/service_conf.yaml.template
index f4acd8bc..47f9dfbb 100644
--- a/docker/service_conf.yaml.template
+++ b/docker/service_conf.yaml.template
@@ -12,7 +12,7 @@ mysql:
 minio:
   user: '${MINIO_USER:-rag_flow}'
   password: '${MINIO_PASSWORD:-infini_rag_flow}'
-  host: '${MINIO_HOST:-minio}:9000'
+  host: '${MINIO_HOST:-minio}:9001'
 es:
   hosts: 'http://${ES_HOST:-es01}:9200'
   username: '${ES_USER:-elastic}'
diff --git a/helm/templates/minio.yaml b/helm/templates/minio.yaml
index 289007d6..5a5adbf5 100644
--- a/helm/templates/minio.yaml
+++ b/helm/templates/minio.yaml
@@ -49,12 +49,12 @@ spec:
               name: {{ include "ragflow.fullname" . }}-env-config
         args:
           - server
-          - "--console-address=:9001"
+          - "--console-address=:9002"
           - "/data"
         ports:
-          - containerPort: 9000
-            name: s3
           - containerPort: 9001
+            name: s3
+          - containerPort: 9002
             name: console
         {{- with .Values.minio.deployment.resources }}
         resources:
@@ -82,10 +82,10 @@ spec:
   ports:
     - name: s3
       protocol: TCP
-      port: 9000
+      port: 9001
       targetPort: s3
     - name: console
       protocol: TCP
-      port: 9001
+      port: 9002
       targetPort: console
   type: {{ .Values.minio.service.type }}
```

将minio的端口修改至9001,9002.将登陆的端口修改至81





!!! note "以下启动服务器内容引用自ragflow的中文readme部分"
### 🚀 启动服务器

1. 确保 `vm.max_map_count` 不小于 262144：

   > 如需确认 `vm.max_map_count` 的大小：
   >
   > ```bash
   > $ sysctl vm.max_map_count
   > ```
   >
   > 如果 `vm.max_map_count` 的值小于 262144，可以进行重置：
   >
   > ```bash
   > # 这里我们设为 262144:
   > $ sudo sysctl -w vm.max_map_count=262144
   > ```
   >
   > 你的改动会在下次系统重启时被重置。如果希望做永久改动，还需要在 **/etc/sysctl.conf** 文件里把 `vm.max_map_count` 的值再相应更新一遍：
   >
   > ```bash
   > vm.max_map_count=262144
   > ```

2. 克隆仓库：

   ```bash
   $ git clone https://github.com/infiniflow/ragflow.git
   ```

3. 进入 **docker** 文件夹，利用提前编译好的 Docker 镜像启动服务器：

   > 运行以下命令会自动下载 RAGFlow slim Docker 镜像 `v0.16.0-slim`。请参考下表查看不同 Docker 发行版的描述。如需下载不同于 `v0.16.0-slim` 的 Docker 镜像，请在运行 `docker compose` 启动服务之前先更新 **docker/.env** 文件内的 `RAGFLOW_IMAGE` 变量。比如，你可以通过设置 `RAGFLOW_IMAGE=infiniflow/ragflow:v0.16.0` 来下载 RAGFlow 镜像的 `v0.16.0` 完整发行版。

   ```bash
   $ cd ragflow
   $ docker compose -f docker/docker-compose.yml up -d
   ```

   | RAGFlow image tag | Image size (GB) | Has embedding models? | Stable?                  |
   | ----------------- | --------------- | --------------------- | ------------------------ |
   | v0.16.0           | &approx;9       | :heavy_check_mark:    | Stable release           |
   | v0.16.0-slim      | &approx;2       | ❌                    | Stable release           |
   | nightly           | &approx;9       | :heavy_check_mark:    | _Unstable_ nightly build |
   | nightly-slim      | &approx;2       | ❌                    | _Unstable_ nightly build |

   > [!TIP]
   > 如果你遇到 Docker 镜像拉不下来的问题，可以在 **docker/.env** 文件内根据变量 `RAGFLOW_IMAGE` 的注释提示选择华为云或者阿里云的相应镜像。
   >
   > - 华为云镜像名：`swr.cn-north-4.myhuaweicloud.com/infiniflow/ragflow`
   > - 阿里云镜像名：`registry.cn-hangzhou.aliyuncs.com/infiniflow/ragflow`

4. 服务器启动成功后再次确认服务器状态：

   ```bash
   $ docker logs -f ragflow-server
   ```

   _出现以下界面提示说明服务器启动成功：_

   ```bash
        ____   ___    ______ ______ __
       / __ \ /   |  / ____// ____// /____  _      __
      / /_/ // /| | / / __ / /_   / // __ \| | /| / /
     / _, _// ___ |/ /_/ // __/  / // /_/ /| |/ |/ /
    /_/ |_|/_/  |_|\____//_/    /_/ \____/ |__/|__/

    * Running on all addresses (0.0.0.0)
    * Running on http://127.0.0.1:9380
    * Running on http://x.x.x.x:9380
    INFO:werkzeug:Press CTRL+C to quit
   ```

   > 如果您跳过这一步系统确认步骤就登录 RAGFlow，你的浏览器有可能会提示 `network anormal` 或 `网络异常`，因为 RAGFlow 可能并未完全启动成功。

5. 在你的浏览器中输入你的服务器对应的 IP 地址并登录 RAGFlow。
   > 上面这个例子中，您只需输入 http://IP_OF_YOUR_MACHINE 即可：未改动过配置则无需输入端口（默认的 HTTP 服务端口 80）。
6. 在 [service_conf.yaml.template](./docker/service_conf.yaml.template) 文件的 `user_default_llm` 栏配置 LLM factory，并在 `API_KEY` 栏填写和你选择的大模型相对应的 API key。

   > 详见 [llm_api_key_setup](https://ragflow.io/docs/dev/llm_api_key_setup)。
在界面添加ollama的模型服务即可，ollama的端口是11434,ip地址可以参考docker bridge的地址，或者直接填写本机的局域网ip地址。




