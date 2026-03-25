FROM python:3.14-slim

ARG USERNAME=pyuser
ARG GROUPNAME=pygroup
ARG UID=1000
ARG GID=1000
ARG LOG_DIR=/var/log/crow
ENV TZ=Asia/Tokyo

### disable multi-threading for tesseract-ocr 
### to avoid low performance on running in multi-processing environment
ENV OMP_THREAD_LIMIT=1

RUN groupadd -g $GID $GROUPNAME && useradd -m -s /bin/bash -u $UID -g $GID $USERNAME
RUN apt-get update && \
    apt-get install -y tesseract-ocr tesseract-ocr-jpn && \
    rm -rf /var/lib/apt/lists/*
RUN pip install uv
RUN mkdir -p $LOG_DIR/api $LOG_DIR/jobs $LOG_DIR/crawling && \
    chown -R $USERNAME:$GROUPNAME $LOG_DIR

USER $USERNAME
WORKDIR /app
COPY --chown=$USERNAME:$GROUPNAME . /app
RUN if [ -n "$(ls deps/queen/queen-*.whl 2>/dev/null)" ]; then uv add "$(ls deps/queen/queen-*.whl | sort -V | tail -n 1)"; uv sync --no-cache --frozen; fi
ENTRYPOINT [ "uv", "run" ]
CMD [ "uvicorn", "crow.server:app", "--host", "0.0.0.0", "--port", "8000" ]
