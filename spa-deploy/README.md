# 部署 SPA 项目

## 前言：部署 `SPA` 与单页 `HTML` 的区别

1. 单页应用如果路由采用 `History` 模式，页面会出现 `404` 无法访问的情况。
2. 单页应用会对静态资源进行 `hash` 命名，对 `hash` 命名的文件，需要设置 `cache-control` 为 `1y` 的强制缓存处理。【Long Term Cache】



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



## 扩展问题

1. `no-cache` 与 `no-store` 的区别

   > 注：这里的缓存控制，是服务器通过响应头 `Cache-Control` 传递给客户端的过程。虽然客户端也可以设置 `Cache-Control` 但是作用不是很明显，资源缓存这块还是以服务器为主。

   - `no-cahce`：允许客户端对资源进行缓存，但是每次都需要去服务端做新鲜度校验（协商缓存），如果发现资源已过期，则返回状态码 `200`，如果未过期则通过状态码 `304` 告知服务端沿用缓存资源。
     - 对 `index.html` 以及 `public` 资源文件，均需要设置 `Cache-Control:no-cache`，每次都去做新鲜度校验，也即等价设置缓存头：`Cache-Control: max-age=0, must-revalidate`
   - `no-store`：**永远不要在客户端存储资源**，每次都是从上游服务器中去获取资源。
