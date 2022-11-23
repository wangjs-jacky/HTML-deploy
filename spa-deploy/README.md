# 部署 SPA 项目

## 前言：部署 `SPA` 与单页 `HTML` 的区别

1. 单页应用如果路由采用 `History` 模式，页面会出现 `404` 无法访问的情况。
2. 单页应用会对静态资源进行 `hash` 命名，对 `hash` 命名的文件，需要设置 `cache-control` 为 `1y` 的强制缓存处理。



## 当前工程可执行的命令

```shell
# 使用 node 环境去执行 npx serve -s build 部署应用（缺点：体积太大）
docker-compose up serve
# 使用 nginx 环境部署应用（采用分阶段构建与构建缓存技巧，从时间和空间两个方面优化构建速度）
docker-compose up nginx
# 新增 nginx.conf 文件 (解决 SPA 的 history 模式, 即 react-routerv6 BrowserRouter 组件)
docker-compose up router
```



## 案例分析：

### 案例：比较 `node` 和 `nginx` 构建后的镜像大小

```shell
# 启动 serve 和 nginx 构建
docker-compose up serve nginx
```

其中，`serve.Dockerfile` 采用 `node+serve` 的方式部署，`nginx.Dockerfile` 采用 `nginx` 部署

分别启动 `http://localhost:3000/` 和 `http://localhost:3005/` 查看部署结果

使用 `docker images` 查看 `images` 大小，截图使用的 `docker` 客户端：

![](https://wjs-tik.oss-cn-shanghai.aliyuncs.com/image-20221122094834164.png)

