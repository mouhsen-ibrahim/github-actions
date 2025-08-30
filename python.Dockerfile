FROM python:3.11-slim
WORKDIR /app
ARG service
ARG VERSION
ARG VCS_REF
ARG BUILD_DATE
LABEL org.opencontainers.image.title=${service}
LABEL org.opencontainers.image.description="python service test"
LABEL org.opencontainers.image.source="https://github.com/mouhsen-ibrahim/github-actions"
LABEL org.opencontainers.image.documentation="https://github.com/mouhsen-ibrahim/github-actions#readme"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.licenses="MIT"
COPY ${service} /app/
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8000
CMD ["python", "main.py"]
