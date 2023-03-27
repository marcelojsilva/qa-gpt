FROM python:3-slim
WORKDIR /app

ENV PATH="/root/.cargo/bin:${PATH}"

RUN apt update && apt install -y gcc curl
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && apt-get install --reinstall libc6-dev -y
RUN pip install --upgrade pip && pip install tiktoken
RUN apt install -y build-essential python3-dev musl-dev && rm -rf /var/lib/apt/lists/* 

COPY requirements.txt config.yaml .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./api ./api
ENV FLASK_APP=api/app.py

EXPOSE 8080

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=8080"]