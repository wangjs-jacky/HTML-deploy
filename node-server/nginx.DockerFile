FROM nginx:alpine

ADD index.html /usr/share/nginx/html

EXPOSE 4000