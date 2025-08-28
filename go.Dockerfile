FROM golang:1.22-alpine AS build
WORKDIR /src
COPY . .
ARG service
WORKDIR /src/${service}
RUN go build -ldflags="-s -w" -o /out/app

FROM alpine:3.20
ENV PORT=8080
EXPOSE 8080
COPY --from=build /out/app /app
ENTRYPOINT ["/app"]
