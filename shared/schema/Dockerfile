FROM python:3.12-slim

RUN apt-get update && \
    apt-get install -y nodejs npm jq wget unzip openjdk-25-jre && \
    apt-get clean

# setup Saxon-HE
RUN wget https://sourceforge.net/projects/saxon/files/Saxon-HE/10/Java/SaxonHE10-8J.zip/download -O /tmp/SaxonHE10-8J.zip && \
    unzip /tmp/SaxonHE10-8J.zip -d /opt/saxon-he && \
    rm /tmp/SaxonHE10-8J.zip
 
# setup python
RUN pip install --no-cache-dir 'datamodel-code-generator[ruff]' lxml pydantic ruff

WORKDIR /schema
COPY . .

# setup nodejs
RUN npm install

RUN addgroup pyuser && adduser --ingroup pyuser pyuser
USER pyuser
ENTRYPOINT ["sh", "build-all.sh"]
