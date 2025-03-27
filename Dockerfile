FROM nginx:1.26.3
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80