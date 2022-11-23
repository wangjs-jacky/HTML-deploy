FROM node:14-alpine as builder

WORKDIR /code

ADD package.json package-lock.json /code/

RUN yarn

# 避免 README.md 和 nginx.config 更新，导致缓存失效，只 ADD 需要的文件
# 构建缓存：分离出 public 文件夹
ADD public /code/public
# 构建缓存：分离出 src 文件夹
ADD src /code/src

RUN npm run build

# [分阶段构建] 使用体积更小的 nginx 服务器
FROM nginx:alpine

# 分布构建 nginx:alpine
ADD nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /code/build /usr/share/nginx/html