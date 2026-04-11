FROM python:3.14-slim

ARG USERNAME=pyuser
ARG GROUPNAME=pygroup
ARG UID=1000
ARG GID=1000
ENV TZ=Asia/Tokyo

# install nodejs for building interfaces
RUN apt-get update && \
    apt-get install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/*

RUN pip install uv
RUN groupadd -g $GID $GROUPNAME && useradd -m -s /bin/bash -u $UID -g $GID $USERNAME
RUN pip install uv

USER $USERNAME
WORKDIR /app
COPY --chown=$USERNAME:$GROUPNAME . ./
RUN uv sync
RUN chmod +x ./entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
