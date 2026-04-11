FROM python:3.14-slim

ARG USERNAME=pyuser
ARG GROUPNAME=pygroup
ARG UID=1000
ARG GID=1000
ENV TZ=Asia/Tokyo

RUN groupadd -g $GID $GROUPNAME && useradd -m -s /bin/bash -u $UID -g $GID $USERNAME
RUN pip install uv

WORKDIR /app
COPY . /app
RUN uv sync --no-cache --frozen
USER $USERNAME
EXPOSE 8000
ENTRYPOINT [ "uv", "run" ]
CMD [ "uvicorn", "navi.server:app", "--host", "0.0.0.0", "--port", "8000" ]
