FROM node:14-alpine as builder
# ACCESS 连接到阿里云
ARG ACCESS_KEY_ID
ARG ACCESS_KEY_SECRET
ENV ACCESS_KEY_ID $ACCESS_KEY_ID
ENV ACCESS_KEY_SECRET $ACCESS_KEY_SECRET
# ARG ENDPOINT
# 设置 process.env.PUBLIC_URL
ENV PUBLIC_URL https://cdn-pic-wjs.oss-cn-shanghai.aliyuncs.com/

WORKDIR /code

# 为了更好的缓存，把它放在前边
# RUN wget http://gosspublic.alicdn.com/ossutil/1.7.7/ossutil64 -O /usr/local/bin/ossutil \
#  && chmod 755 /usr/local/bin/ossutil \
#  && ossutil config -i $ACCESS_KEY_ID -k $ACCESS_KEY_SECRET -e $ENDPOINT

# 单独分离 package.json，是为了安装依赖可最大限度利用缓存
ADD package.json yarn.lock /code/

# 下载依赖
RUN yarn

ADD . /code

# 构建并将资源上传至 OSS 服务器
RUN npm run build && npm run oss:script

# 选择更小体积的基础镜像
FROM nginx:alpine

# 使用 nginx.conf 部署 SPA 项目
ADD nginx.conf /etc/nginx/conf.d/default.conf

# 其实不需要完整的拷贝
COPY --from=builder code/build /usr/share/nginx/html