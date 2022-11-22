FROM node:14-alpine as builder

WORKDIR /code

# [构建缓存]单独分离 package.json，是为了安装依赖可最大限度利用缓存
ADD package.json package-lock.json /code/
RUN yarn

ADD . /code
RUN npm run build

# [分阶段构建] 使用体积更小的 nginx 服务器
FROM nginx:alpine

# 使用 --from=<name> 引用将上一阶段构建的镜像 code/build 文件夹 COPY 到 nginx 的服务器
COPY --from=builder code/build /usr/share/nginx/html