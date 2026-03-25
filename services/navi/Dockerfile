FROM python:3.14-slim

ARG USERNAME=pyuser
ARG GROUPNAME=pygroup
ARG UID=1000
ARG GID=1000
ENV TZ=Asia/Tokyo

RUN groupadd -g $GID $GROUPNAME && useradd -m -s /bin/bash -u $UID -g $GID $USERNAME
RUN pip install uv
RUN mkdir /var/log/navi && chown $USERNAME:$GROUPNAME /var/log/navi

USER $USERNAME
WORKDIR /app
COPY --chown=$USERNAME:$GROUPNAME . /app
RUN uv add "$(ls pkgs/crow_api_client-*.whl | sort -V | tail -n 1)"
RUN uv sync --no-cache --frozen
ENTRYPOINT [ "uv", "run" ]
CMD [ "uvicorn", "navi.server:app", "--host", "0.0.0.0", "--port", "8000" ]
