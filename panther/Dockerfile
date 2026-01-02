FROM python:3.14-alpine

ARG USERNAME=pyuser
ARG GROUPNAME=pygroup
ARG UID=1000
ARG GID=1000
ENV TZ=Asia/Tokyo

RUN addgroup -g $GID $GROUPNAME && adduser -D -s /bin/sh -u $UID -G $GROUPNAME $USERNAME
RUN apk add --no-cache bash
RUN python -m pip install --upgrade pip
RUN pip install poetry

USER $USERNAME
WORKDIR /app
COPY --chown=$USERNAME:$GROUPNAME pyproject.toml poetry.lock ./
RUN poetry install --no-root
COPY --chown=$USERNAME:$GROUPNAME . .

ENTRYPOINT [ "poetry", "run", "python", "src/panther/upload_es.py" ]
CMD [ "--data-root", "/data_dir", "--index", "patent-documents", "--use-hash-guard" ]
