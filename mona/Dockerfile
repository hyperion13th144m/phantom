FROM python:3.14-slim

ARG USERNAME=pyuser
ARG GROUPNAME=pygroup
ARG UID=1000
ARG GID=1000
ENV TZ=Asia/Tokyo

RUN groupadd -g $GID $GROUPNAME && useradd -m -s /bin/sh -u $UID -g $GID $USERNAME
RUN apt-get update && \
    apt-get install -y bash tesseract-ocr tesseract-ocr-jpn && \
    rm -rf /var/lib/apt/lists/*
RUN python -m pip install --upgrade pip
RUN pip install --no-cache-dir poetry

USER $USERNAME
WORKDIR /app
COPY --chown=$USERNAME:$GROUPNAME pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.in-project true
RUN poetry install --no-root
COPY --chown=$USERNAME:$GROUPNAME . .

ENTRYPOINT [ "poetry", "run", "python", "src/mona/main.py" ]
