import * as http from "http";
import { promises as fsp } from "fs";
import * as fs from "fs";

// 需要安装 npm install -D @types/node (由于ts无法识别node.js文件，所以才需要下载声明文件)
import { IncomingMessage, ServerResponse } from 'http';

const server = http.createServer();

server.on('request', async (request: IncomingMessage, response: ServerResponse) => {
  // request 的用法
  console.log('method:', request.method);
  console.log('url:', request.url);
  console.log('headers:', request.headers);

  const stat = await fsp.stat("./index.html");
  console.log("stat", stat);
  if (request.method === "GET") {
    /* 如果需要处理 stream ，需要额外处理下 Content-Length */
    response.setHeader("content-length", stat.size);
    fs.createReadStream("./index.html").pipe(response);
  }
})

server.listen(8888, () => {
  console.log("服务启动成功，端口号：8888")
})
