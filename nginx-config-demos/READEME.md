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

## Nginx 路径匹配规则

ocation 用以匹配路由，配置语法如下。

```nginx
location [ = | ~ | ~* | ^~ ] uri { ... }
```

其中 `uri` 前可提供以下修饰符

- `=` 精确匹配，优先级最高。
- `^~` 前缀匹配，优先级其次。如果同样是前缀匹配，走最长路径。
- `~` 正则匹配，优先级再次 (~\* 只是不区分大小写，不单列)。如果同样是正则匹配，走第一个路径。
- `/` 通用匹配，优先级再次。

为了熟悉以上匹配规则，编写了以下案例：

### location1.conf

```shell
 docker-compose up location1
```

分别访问：

- `http://localhost:8002/about.html`：存在 `about.html` 文件，访问成功
- `http://localhost:8002/hello` ： 返回 404 ，无法成功设置头部
- `http://localhost:8002/shengJacky`：存在 `shengJacky 文件`，访问成功
- `http://localhost:8002/sheng`：存在 `sheng` 文件，访问成功

当访问资源时，需设置 `default_type` 为 `text/plain`，避免浏览器自动下载。

### location2.conf

需要启动两个服务：

```shell
 # 同时启动两个服务
 docker-compose up location1 api
 # 等价于
 docker-compose up location1
 docker-compose up api
```

在 `location1.conf` 案例中，存在一个问题：当资源不存的情况下，无法添加 `add_header` 请求，无法通过 `curl --head 地址` 的方式去定位是否命中匹配路径的问题，只有当资源真实存在时，才可对匹配规则进行验证。解决方案如下：

1. 在 `docker-compose.yaml` 添加 `shanyue/whoamI` 镜像

   ```yaml
   api:
     image: shanyue/whoami
     ports:
       - 8888:3000
   ```

   - 对外：该服务主要用于打印请求信息等内容，该服务启动在 `docker` 容器内的 `3000` 端口，外部可通过 `8888` 端口访问。

   - 对内：在 `location2` 容器中，也可直接通过 `service` 名称作为 `hostname` ，即 `http://api:3000` 去访问 api 服务。

2. `.conf` 文件中当资源不存时，进行反向代理，如访问 `http:localhost:8002/test1`，将其代理到 `http://api：3000/test1` 上。

### order.conf

需要启动两个服务：

```shell
 # 同时启动两个服务
 docker-compose up order api
 # 等价于
 docker-compose up order
 docker-compose up api
```

依次执行：

```shell
curl --head http://localhost:8004/order1  # 答案 A
curl --head http://localhost:8004/order2  # 答案 A
curl --head http://localhost:8004/order3  # 答案 A
curl --head http://localhost:8004/order4  # 答案 A
```

结论很简单，能用 `^~ /order4 （前缀匹配）就用前缀匹配，次之用 `~ ^/order` （正则匹配），最后采用 `/order`（通用匹配），如果命中同一规则，则越短越容易匹配上。



