FROM golang:1.22-alpine AS build
WORKDIR /src
COPY . .
ARG service
WORKDIR /src/${service}
RUN go build -ldflags="-s -w" -o /out/app

FROM alpine:3.20
ARG service
ARG VERSION
ARG VCS_REF
ARG BUILD_DATE
LABEL org.opencontainers.image.title=${service}
LABEL org.opencontainers.image.description="go service"
LABEL org.opencontainers.image.source="https://github.com/mouhsen-ibrahim/github-actions"
LABEL org.opencontainers.image.documentation="https://github.com/mouhsen-ibrahim/github-actions#readme"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.licenses="MIT"

ENV PORT=8080
EXPOSE 8080
COPY --from=build /out/app /app
ENTRYPOINT ["/app"]
