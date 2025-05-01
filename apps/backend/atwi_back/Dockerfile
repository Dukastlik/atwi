FROM python:3.12

COPY . /app

RUN pip install -r /app/requirements.txt

WORKDIR /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
