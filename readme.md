# ACK Dify
## 背景

Dify 是一个开源的大语言模型（LLM）应用开发平台。其直观的界面结合了 AI 工作流、RAG 管道、Agent、模型管理、可观测性功能等，使开发者可以快速搭建生产级的生成式 AI 应用。  

详细信息可参考 [Dify官方文档](https://docs.dify.ai/)。

## 安装步骤

1. 登陆容器服务控制台。
2. 在控制台左侧点击应用目录，进入应用的主界面。
3. 在搜索框中输入ack-dify，进入ack-dify的主页。
4. 在右侧的创建面板中选择集群，并单击创建。

## 组件说明

ack-dify由以下组件组成:  
- proxy：访问ack-dify的入口，默认是nginx。
- api：ack-dify的后端API Server, 主要功能包括：
   - 处理HTTP请求：提供RESTful API接口，处理用户和LLM应用的各种请求。
   - 数据管理：通过连接数据库和其它存储介质，管理和提供数据服务。
   - 任务调度：接收并派发任务给 Celery worker 进行后台处理
- worker：ack-dify的后端worker，负责启动Celery工作进程，用于处理异步任务和队列中的任务。
- web：ack-dify的前端组件
- sandbox: dify开源的一个安全镜像，用于执行工作流中的用户代码。确保恶意代码不会被执行。
- redis: 用作ack-dify-api 和 ack-dify-worker的默认task queue。
- postgresql： 默认db,存储用户信息、LLM应用配置等数据
- weavaite: 默认向量数据库，存储「嵌入知识库」功能转换后的向量。

## 访问服务

1. 登录容器服务管理控制台，在左侧导航栏选择集群。
2. 在集群列表页面，单击目标集群名称，选择工作负载 > 容器组。
3. 在无状态列表页面，选择ack-dify部署的命名空间，等待所有Pod就绪。
4. 将服务转发到本地，将占用本地的8080端口，参考[port-forward](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/?spm=5176.28197681.0.0.6e535ff60pHceq)。
```bash
export POD_NAME=$(kubectl get pods --namespace dify-system -l "app.kubernetes.io/name=ack-dify,app.kubernetes.io/instance=ack-dify,component=proxy" -o jsonpath="{.items[0].metadata.name}")
export CONTAINER_PORT=$(kubectl get pod --namespace dify-system $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
kubectl --namespace dify-system port-forward $POD_NAME 8080:$CONTAINER_PORT
```
命令执行成功后，输出内容如下。
```text
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```
在本地通过浏览器访问服务http://localhost:8080。

**注意**：在将服务暴露到公网前，建议先通过以上本地访问方式完成ack-dify的初始用户注册。避免服务暴露到公网后，被未经授权的用户注册。

## 配置项
### 依赖项配置

redis [https://github.com/bitnami/charts/tree/main/bitnami/redis/#parameters](https://github.com/bitnami/charts/tree/main/bitnami/redis/#parameters)

postgresql  [https://github.com/bitnami/charts/tree/main/bitnami/postgresql/#parameters](https://github.com/bitnami/charts/tree/main/bitnami/postgresql/#parameters)

weaviate   [https://weaviate.io/developers/weaviate/installation/kubernetes#modify-valuesyaml-as-necessary](https://weaviate.io/developers/weaviate/installation/kubernetes#modify-valuesyaml-as-necessary)
### 镜像配置
| **Key** | **Description** | **Default** |
| --- | --- | --- |
| image.api.image | Dify api image name  | dify-api  |
| image.api.tag | Dify api Image tag | "0.6.13" |
| image.web.image | Dify web image name | dify-web |
| image.web.tag | Dify web Image tag | "0.6.13" |
| image.sandbox.image | Dify sandbox image name | dify-sandbox |
| image.sandbox.tag | Dify sandbox Image tag | "0.2.4" |
| image.proxy.image | Proxy image name | nginx |
| image.proxy.tag | Proxy Image tag | "1.27.0" |

### ack-dify-api 配置
| **Key** | **Description** | **Default** |
| --- | --- | --- |
| api.extraEnv | Extra env vars for ack-dify-api pods ，reference [Dify API Server Env vars](https://docs.dify.ai/getting-started/install-self-hosted/environments#server) |  |
| api.logLevel | The log level for the application. Supported values are `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL` | INFO |
| api.url.consoleApi | The backend URL of the console API, used to concatenate the authorization callback.If empty, it is the same domain. Example: https://api.console.dify.ai | "" |
| api.url.consoleWeb | The front-end URL of the console web, used to concatenate some front-end addresses and for CORS configuration use. If empty, it is the same domain. Example: https://console.dify.ai | "" |
| api.url.serviceApi | Service API Url, used to display Service API Base Url to the front-end. If empty, it is the same domain. Example: https://api.dify.ai | "" |
| api.url.appApi | WebApp API backend Url, used to declare the back-end URL for the front-end API. If empty, it is the same domain. Example: https://app.dify.ai | "" |
| api.url.appWeb | WebApp Url, used to display WebAPP API Base Url to the front-end. If empty, it is the same domain. Example: https://api.app.dify.ai | "" |
| api.url.files | File preview or download URL prefix, used to display the file preview or download URL to the front-end or as a multi-modal model input; In order to prevent others from forging, the image preview URL is signed and has a 5-minute expiration time. | "" |
| api.migration | When enabled, migrations will be executed prior to application startup and the application will start after the migrations have completed. | true |
| api.persistence | Storage for `api` and `worker` |  |

### ack-dify-worker 配置
| **Key** | **Description** | **Default** |
| --- | --- | --- |
| api.extraEnv | Extra env vars for ack-dify-woker pods  |  |
| worker.logLevel | The log level for the application. Supported values are `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL` | INFO |

### ack-dify-proxy 配置
| **Key** | **Description** | **Default** |
| --- | --- | --- |
| proxy.extraEnv | Extra env vars for ack-dify-proxy pods  |  |
| proxy.log.persistence | Storage for Proxy log. | 
 |
| proxy.service.port |  Port for Proxy Service | 80 |

### ack-dify-web 配置
| **Key** | **Description** | **Default** |
| --- | --- | --- |
| web.extraEnv | Extra env vars for ack-dify-web pods  |  |
| web.service.port |  Port for Web Service | 80 |

### ack-dify-sandbox 配置
| **Key** | **Description** | **Default** |
| --- | --- | --- |
| sandbox.extraEnv | Extra env vars for ack-dify-proxy pods  |  |
| sandbox.service.port | Port for Proxy Service | 8194 |
| sandbox.auth.apiKey | API key for code execution service | "dify-sandbox" |
| sandbox.auth.privileged | Determines if the sandbox runs in privileged mode. | false |

### External 配置
#### External Storage Configration
**external Aliyun OSS configration**

| **Key** | **Description** | **Default** |
| --- | --- | --- |
| externalAliyunOSS.enabled | Enables or disables the use of external Alibaba Cloud OSS. | false |
| externalAliyunOSS.bucketName | Name of the OSS bucket to use for storage. | 'your-bucket-name' |
| externalAliyunOSS.accessKey | Access key for authentication to the OSS service. | "" |
| externalAliyunOSS.secretKey | Secret key for authentication to the OSS service. | "" |
| externalAliyunOSS.endpoint | Endpoint URL for accessing the OSS service. | "" |
| externalS3.bucketName | Name of the S3 bucket to use. | "difyai" |
| externalAliyunOSS.region | Region where the OSS bucket is located. | "" |
| externalAliyunOSS.authVersion | Authentication version to use for connecting to OSS service. | v4 |

**external S3**

| **Key** | **Description** | **Default** |
| --- | --- | --- |
| externalS3.enabled | Enables the use of an external S3-compatible storage service. | false |
| externalS3.endpoint | Endpoint URL for the external S3 service. | "https://xxx.r2.cloudflarestorage.com" |
| externalS3.accessKey | Access key for authentication with the S3 service. | "ak-difyai" |
| externalS3.secretKey | Secret key for authentication with the S3 service. | "sk-difyai" |
| externalS3.useSSL | Determines if SSL/TLS should be used to connect to S3. | false |
| externalS3.bucketName | Name of the S3 bucket to use. | "difyai" |
| externalS3.rootPath | Path within the bucket to treat as the root directory. | "" |
| externalS3.useIAM | Enables IAM roles for S3 access instead of access/secret keys. | false |
| externalS3.iamEndpoint | Endpoint for IAM role management. | "" |

**external Azure Blob Storage**

| **Key** | **Description** | **Default** |
| --- | --- | --- |
| externalAzureBlobStorage.enabled | Enables the use of Azure Blob Storage as the external storage service. | false |
| externalAzureBlobStorage.url | The URL of the Azure Blob Storage account. | 'https://<your_account_name>.blob.core.windows.net' |
| externalAzureBlobStorage.account | The account name for Azure Blob Storage. | "https://xxx.r2.cloudflarestorage.com" |
| externalAzureBlobStorage.key | The access key for the Azure Blob Storage account. | "difyai" |
| externalAzureBlobStorage.container | The name of the container within Azure Blob Storage to use. | "difyai-container" |

#### External DB Configration
**external postgres**

| **Key** | **Description** | **Default** |
| --- | --- | --- |
| externalPostgres.enabled | Determines whether the external PostgreSQL configurations are used. When set to true, the application will attempt to connect to an external database instead of using an internal one. | false |
| externalPostgres.username | The username for connecting to the external PostgreSQL database. | "postgres" |
| externalPostgres.password | The password for connecting to the external PostgreSQL database. | "difyai123456" |
| externalPostgres.address | The host address of the external PostgreSQL database. | "localhost" |
| externalPostgres.port | The service port of the external PostgreSQL database. | 5432 |
| externalPostgres.dbName | The name of the database on the external PostgreSQL server to which the connection should be established. | "dify" |
| externalPostgres.maxOpenConns | The maximum number of open connections to the database. This limits the maximum number of simultaneous connections to the database. | 20 |
| externalPostgres.maxIdleConns | The maximum number of connections in the idle connection pool. This is the maximum number of connections that can remain idle in the pool.| 5 |

#### External Task Queue Configration
**external Redis**

| **Key** | **Description** | **Default** |
| --- | --- | --- |
| externalRedis.enabled | Enables external Redis usage instead of the default one. | false |
| externalRedis.host | Hostname or IP of the external Redis server. | INFO |
| externalRedis.port | Port number for the external Redis server. | 6379 |
| externalRedis.username | Username for authentication with the Redis server. | "" |
| externalRedis.password | Password for authentication with the Redis server. | "difyai123456" |
| externalRedis.useSSL | Determines if SSL/TLS should be used to connect to Redis. | false |

#### External Vector DB configuration
 **external Qdrant**

| **Key** | **Description** | **Default** |
| --- | --- | --- |
| externalQdrant.enabled | Enables the use of an external Qdrant vector database. | false |
| externalQdrant.endpoint | The endpoint URL for the Qdrant service. | "https://your-qdrant-cluster-url.qdrant.tech/" |
| externalQdrant.apiKey | The API key for authentication with the Qdrant service. | "ak-difyai" |

**external Milvus**

| **Key** | **Description** | **Default** |
| --- | --- | --- |
| externalMilvus.enabled | Enables the use of an external Milvus vector database. | false |
| externalMilvus.host | The hostname or IP address of the Milvus server. | "your-milvus.domain" |
| externalMilvus.port | The port number for the Milvus server. | 19530 |
| externalMilvus.user | The username for authentication with the Milvus server. | "user" |
| externalMilvus.password | The password for authentication with the Milvus server. | "Milvus" |
| externalMilvus.useTLS | Determines whether to use TLS for secure communication. | false |

**external pgvector**

| **Key** | **Description** | **Default** |
| --- | --- | --- |
| externalPgvector.enabled | Enables the use of an external pgvector database. | false |
| externalPgvector.host | The hostname or IP address of the pgvector database server. | "gp-****-master.gpdb.rds.aliyuncs.com" |
| externalPgvector.port | The port number for the pgvector database server. | 5432 |
| externalPgvector.user | The username for authentication with the pgvector database. | "user" |
| externalPgvector.password | The password for authentication with the pgvector database. | "****" |
| externalPgvector.dbName | The name of the database within the pgvector server. | "dify" |

## Release Note
| **Version** | **Release date** | **Release Note**                                                                                                                |
|-------------|------------------|---------------------------------------------------------------------------------------------------------------------------------|
| v0.1.0      | 2024-07-20       | 发布ack-dify Chart                                                                                                                |
| v0.1.1      | 2024-08-08       | 升级到ack-dify 0.6.14版本                                                                                                            |
| v0.1.2      | 2024-08-16       | 支持修改单个镜像地址                                                                                                                      |
| v0.1.3      | 2024-08-20       | - 支持用户配置ingress的backend字段<br/>- 支持配置ack-dify-woker hpa                                                                          |
| v0.1.4      | 2024-08-26       | - 支持配置nginx proxy的configmap<br/>- 支持配置ack-dify组件的lifycycle字段                                                                    |
| v0.1.5      | 2024-08-29       | 支持配置ack-dify组件的readinessProbe/livenessProbe/startupProbe字段                                                                      |
| v0.1.6      | 2024-09-11       | 升级到ack-dify 0.8.0版本                                                                                                             |
| v0.1.7      | 2024-09-29       | 升级到ack-dify 0.8.3版本                                                                                                             |
| v0.1.8      | 2024-10-10       | 升级到ack-dify 0.9.1版本                                                                                                             |
| v0.1.9      | 2024-10-17       | 升级到ack-dify 0.9.1-fix1版本                                                                                                        |
| v0.1.10     | 2024-10-24       | 升级到ack-dify 0.10.1版本                                                                                                            |
| v0.1.11     | 2024-11-06       | 升级到ack-dify 0.11.0版本                                                                                                            |
| v0.1.12     | 2024-11-29       | - 升级到ack-dify 0.12.1版本<br/>- 支持通过sql方式调用AnalyticDB<br/>- 支持指定redis、Milvus的dbname                                                |
| v0.1.14     | 2024-12-23       | 升级到ack-dify 0.13.2版本                                                                                                            |
| v0.1.15     | 2025-01-06       | - 升级到ack-dify 0.14.0版本<br/>- 支持通过配置redis.metrics.enabled开启redis metrics                                                         |
| v0.1.16     | 2025-02-11       | 升级到ack-dify 0.15.3版本<br/>- 支持DeepSeek Models                                                                                    |                                            |
| v0.1.17     | 2025-02-25       | -升级redis镜像至7.4.2-debian-12-r0<br/>- 升级postgresql镜像至15.4.0-debian-11-r10                                                         |
| v1.0.0      | 2025-03-26       | 升级到ack-dify至1.1.3版本(该版本相比于0.x.x版本变动较大，升级前请确保进行了数据备份，升级步骤参考[Dify社区指导](https://docs.dify.ai/development/migration/migrate-to-v1)) |




## 常见FAQ

1. ack serverless类型的集群，需要参照[文档](https://help.aliyun.com/zh/ack/serverless-kubernetes/user-guide/install-and-update-csi-provisioner?spm=a2c4g.11186623.0.0.75456abdldMCIg)安装csi-provisioner组件。
   对于v1.16等较老版本的ack, 集群中可能默认没有alicloud-disk-topology-alltype storageclass，可以通过以下方式创建
```bash
cat <<EOF | kubectl apply -f -
kind: StorageClass
metadata:
  name: alicloud-disk-topology-alltype
parameters:
  type: cloud_essd,cloud_ssd,cloud_efficiency
provisioner: diskplugin.csi.alibabacloud.com
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
EOF
```

2. 如安装过程中，发现ack-dify-api和ack-dify-worker出现如下报错
```text
Events:
  Type     Reason            Age                  From               Message
  ----     ------            ----                 ----               -------
  Warning  FailedScheduling  3m52s                default-scheduler  0/3 nodes are available: pod has unbound immediate PersistentVolumeClaims. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.,
  Warning  FailedScheduling  3m4s (x2 over 3m7s)  default-scheduler  0/3 nodes are available: pod has unbound immediate PersistentVolumeClaims. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.,
```
且pvc ack-dify出现pending，其原因是集群中未安装支持的nas动态存储卷的storage class, 请使用[文档方式一](https://help.aliyun.com/zh/ack/ack-managed-and-ack-dedicated/user-guide/use-cnfs-to-manage-nas-file-systems?spm=a2c4g.11186623.0.0.40ee108f7h6Qmj#section-n2s-x85-7fu)创建默认的CNFS文件系统以及对应的NAS storage class。

3. 如您卸载ack-dify，请根据需要手动删除pvc
```bash
kubectl delete pvc --all -n dify-system
```  
**注意**：nas存储卷还需要参照[文档操作步骤](https://help.aliyun.com/zh/nas/user-guide/delete-a-file-system?spm=a2c4g.11186623.0.0.3d754e49xvBiG7)手动进行删除。