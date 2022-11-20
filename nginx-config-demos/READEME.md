## 搭建学习环境

快速构建三个文件：

1. `docker-compose.yaml`
2. `index.html`
3. `nginx.conf`

核心在 `docker-compose.yaml` 的 `volumnes` 配置

```yaml
version: "3"
services:
  # nginx 快速环境搭建
  nginx:
    image: nginx:alpine
    ports:
      - 8001:80
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - .:/usr/share/nginx/html
  # 关于 location 的学习
  location: ...
  # 关于 location 匹配顺序的学习
  order1: ...
```

其中，`image` 拉取 `nginx:alpine` 版本镜像，`ports` 指定映射端口号，而 `80` 是 `http` 服务的默认端口号。`volumes` 是学习 `nginx` 配置的核心字段，主要做了以下两层的映射

1. 将 `nginx.conf` 映射到 `nginx` 默认读取的 `conf` 配置文件上。
2. 将 `.`（本地文件夹）映射到 `nginx` 默认读取的 `html` 根文件夹。

上述准备工作完成后，就可以通过 `docker` 命令启动 `nginx` 服务。

```shell
docker-compose up <service>
# 学习 nginx 学习工程的快速搭建
$ docker-compose up nginx

# 学习关于 location 的配置
$ docker-compose up location
```

> 注：`index.html` 等静态资源的变动会立即被映射到 `docker` 容器内部，而 `nginx` 配置的修改，需要重新执行 `docker-compose up <service>` 指令才会生效。
