import * as http from "http";
import * as fs from "fs";

// 需要安装 npm install -D @types/node (由于ts无法识别node.js文件，所以才需要下载声明文件)
import { IncomingMessage, ServerResponse } from 'http';

const server = http.createServer();
const html = fs.readFileSync("./index.html");

server.on('request', (request: IncomingMessage, response: ServerResponse) => {
  // request 的用法
  console.log('method:', request.method);
  console.log('url:', request.url);
  console.log('headers:', request.headers);

  if (request.method === "GET") {
    response.write(html);
    response.end('');
  }
})

server.listen(8888, () => {
  console.log("服务启动成功，端口号：8888")
})
