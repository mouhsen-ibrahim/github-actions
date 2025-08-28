FROM python:3.11-slim
WORKDIR /app
ARG service
COPY ${service} /app/
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8000
CMD ["python", "main.py"]
