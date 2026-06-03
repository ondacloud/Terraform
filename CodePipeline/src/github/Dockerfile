FROM python:3.13-slim
WORKDIR /app
COPY main.py /app/main.py
RUN pip install --no-cache-dir flask
EXPOSE 8080
CMD ["python", "main.py"]