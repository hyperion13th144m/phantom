FROM python:3.12-slim

# setup Node
RUN apt-get update && apt-get install -y nodejs npm jq && apt-get clean

# setup python
RUN pip install --no-cache-dir 'datamodel-code-generator[ruff]' lxml pydantic ruff

WORKDIR /schema
COPY . .
RUN npm install
RUN addgroup pyuser && adduser --ingroup pyuser pyuser
USER pyuser
ENTRYPOINT ["sh", "build-all.sh"]
