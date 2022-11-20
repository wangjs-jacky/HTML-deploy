FROM node:14-alpine

# 设置 CMD 和 RUN 指令的工作路径
WORKDIR /code

# 分布构建
ADD ./package.json /code/

RUN yarn

ADD . /code/

CMD yarn server-stream

EXPOSE 3000:8888