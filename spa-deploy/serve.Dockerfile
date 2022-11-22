FROM node:14-alpine

WORKDIR /code

# [构建缓存] 单独分离 package.json，是为了安装依赖可最大限度利用缓存
ADD package.json package-lock.json /code/

RUN yarn

ADD . /code

RUN yarn build

# 使用 node 的方式启动方式 build 静态文件（缺点：后续该为 nginx）
CMD npx serve -s build -p 3005

EXPOSE 3005

