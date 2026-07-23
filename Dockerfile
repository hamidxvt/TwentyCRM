FROM alpine:latest
RUN apk add --no-cache docker-compose
CMD ["docker-compose", "up", "-d"]
