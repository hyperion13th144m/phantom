FROM python:3.14-slim

ARG USERNAME=pyuser
ARG GROUPNAME=pygroup
ARG UID=1000
ARG GID=1000
ENV TZ=Asia/Tokyo

### disable multi-threading for tesseract-ocr 
### to avoid low performance on running in multi-processing environment
ENV OMP_THREAD_LIMIT=1

RUN groupadd -g $GID $GROUPNAME && useradd -m -s /bin/bash -u $UID -g $GID $USERNAME
RUN apt-get update && \
    apt-get install -y tesseract-ocr tesseract-ocr-jpn && \
    rm -rf /var/lib/apt/lists/*
RUN pip install uv
RUN mkdir /var/log/mona && chown $USERNAME:$GROUPNAME /var/log/mona

USER $USERNAME
WORKDIR /app
COPY --chown=$USERNAME:$GROUPNAME mona /app/
COPY --chown=$USERNAME:$GROUPNAME queen /queen
RUN cd /queen && uv build && \
    cd /app && uv add /queen/dist/queen-*.whl
RUN uv sync --frozen --no-cache
ENTRYPOINT [ "uv", "run", "src/mona/main.py" ]
