# 部署 SPA 项目

## 1.准备 `spa` 项目文件

使用 `cra` 创建一个 SPA 项目

```shell
# 创建一个 cra 应用
$ npx create-react-app cra-deploy

# 进入 cra 目录
$ cd cra-deploy

# 进行依赖安装
$ yarn

# 对资源进行构建
$ npm run build
```

## 2.编写 `dockerfile` 和 `docker-compose.yaml` 文件

## 案例：比较 `node` 和 `nginx` 构建后的镜像大小

```shell
# 启动 serve 和 nginx 构建
docker-compose up serve nginx
```

其中，`serve.Dockerfile` 采用 `node+serve` 的方式部署，`nginx.Dockerfile` 采用 `nginx` 部署

分别启动 `http://localhost:3000/` 和 `http://localhost:3005/` 查看部署结果

使用 `docker images` 查看 `images` 大小，截图使用的 `docker` 客户端：

![](https://wjs-tik.oss-cn-shanghai.aliyuncs.com/image-20221122094834164.png)
