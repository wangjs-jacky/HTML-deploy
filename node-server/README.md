## 前言

本项目主要是完成简单服务器部署。

### 本地部署

在 `package.json` 中给出了三种部署方式：

```json
"scripts": {
    "server": "ts-node-dev server.ts",
    "server-fs": "ts-node-dev server-fs.ts",
    "server-stream": "ts-node-dev server-stream.ts"
},
```

其中：

- `server` ：以字符串的形式返回 `html` 内容。

- `server-fs` ：使用 `fs` 文件系统去读取 `html` 内容。

- `server-stream`：使用 `fs.createReadStream` 以流的形式去读取 `html` 内容。

  > 注：以流的形式读取会存在一个问题，在响应头中，`Transfer-Encoding: chunked` 是 `chunked` 类型，因此在 `response.end()` 时，要额外使用 `stat` 工具，额外计算下 `Content-Length` 并返回。

上面三种方式中，以`server-stream` 的代码比较 `preferred` ，基本代码如下：

```javascript
import * as http from "http";
import { promises as fsp } from "fs";
import * as fs from "fs";

// 需要安装 npm install -D @types/node (由于ts无法识别node.js文件，所以才需要下载声明文件)
import { IncomingMessage, ServerResponse } from "http";

const server = http.createServer();

server.on(
  "request",
  async (request: IncomingMessage, response: ServerResponse) => {
    // request 的用法
    console.log("method:", request.method);
    console.log("url:", request.url);
    console.log("headers:", request.headers);

    const stat = await fsp.stat("./index.html");
    console.log("stat", stat);
    if (request.method === "GET") {
      /* 如果需要处理 stream ，需要额外处理下 Content-Length */
      response.setHeader("content-length", stat.size);
      fs.createReadStream("./index.html").pipe(response);
    }
  },
);

server.listen(8888, () => {
  console.log("服务启动成功，端口号：8888");
});
```

快去执行 `npm run server-stream` 观察下效果吧！



### 补充：静态服务器应有的功能

以 `vercel` 旗下的 `serve` 为例：

1. 内容的传输基于 `stream` 性能更强，并补充 `Content-Length`
2. `serve` 可以作为命令行工具使用，接受指定的端口号，读取目录等。
3. 对找不到的资源，提供 `404` 响应内容。
4. 其余细节功能如下：
   - `trailingSlash`：对于文件夹路径，自动补全 `/`，如 `localhost:3000/abc` 会去寻找服务器地址下，叫 `abc` 的文件夹下的 `index.html` 文件。
   - `cleanUrls`：浏览器文件后缀的清除，比如去访问一个资源时，如`localhost:3000/index.html` 配置后，可省略资源后缀。
   - `rewrite`：对于未找到的资源进行自动重定向，应该用在 `SPA` 应用中的 `history` 模式。
   - `redirect`：将一个页面的资源重定向到一个新的页面，且此过程用户无感知。



### 使用 Docker 部署前端应用

使用 `docker` 的目的：隔离环境。

- 为什么基础镜像的 `tag` 总是携带 `alpine`？

  Alpine 操作系统是一个面向安全的轻型 Linux 发行。相比于其他镜像体积更小，运行时占用的资源更小。

- 为什么可以直接在 node 镜像中使用 yarn 命令行工具？

  - [在官方的 `Node` 镜像中](https://github.com/nodejs/docker-node/blob/90065897cdca681a20c3383f28b436bc2434928f/18/alpine3.15/Dockerfile)，集成了对 `yarn` 的安装。

任务：

1. 任务一：使用 `DockerFile` 部署前端应用

   ```shell
   # 构建镜像
   # 其中 --progress plain 可以查看ADD是否执行成功
   docker build --progress plain --no-cache -t simple-app . -f node.Dockerfile
   # 运行容器
   # --rm 容器停止运行时自动删除
   # -p xxxx(宿主端口):xxxx(容器端口)
   docker run --rm -p 8888:8888 simple-app
   ```

   > 这边推荐安装 `VSCode` 的 `Docker` 插件

2. 任务二：使用 `docker-compose` 部署前端应用

   ```shell
   # 使用 up 指定启动的 Service
   # --build: 每次启动容器前构建镜像
   docker-compose -f docker-compose.yaml up nginx-app --build
   ```
