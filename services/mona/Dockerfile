FROM python:3.14-slim

ARG USERNAME=pyuser
ARG GROUPNAME=pygroup
ARG UID=1000
ARG GID=1000
ENV TZ=Asia/Tokyo

RUN groupadd -g $GID $GROUPNAME && useradd -m -s /bin/bash -u $UID -g $GID $USERNAME
RUN pip install uv
RUN mkdir /var/log/mona && chown $USERNAME:$GROUPNAME /var/log/mona

USER $USERNAME
WORKDIR /app
COPY --chown=$USERNAME:$GROUPNAME . /app/
RUN uv sync --no-dev
ENTRYPOINT [ "uv", "run", "uvicorn", "mona.server:app" ]
CMD [ "--host", "0.0.0.0", "--port", "8000" ]
