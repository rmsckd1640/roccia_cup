FROM nginx:stable-alpine

COPY build/web /usr/share/nginx/html

RUN chmod -R 755 /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]