# Development notes
## Phantom system
```mermaid
block-beta
  columns 2

  %% shared components
  block:common:1
    columns 1
    Queen["Queen\nXSLT Processor for Mona\nInterface provider for Mona, Panther and Fox"]
    Navi["Navi\nmanager for panther, crow, noir"]
    nginx["nginx\nReverse Proxy\n/, /_next → Joker\n/docs → Fox\n/images → Mona\n/extra-data → Skull"]
  end

  block:main:4
    columns 1

    %% -----------------------------
    %% Input / Storage Layer
    %% -----------------------------
    block:input_layer
      columns 3
      src_dir[("SRC_DIR\nArchives managed by\nInternet Filing Software)")]
      space
      data_dir[("DATA_DIR\nJSON and Images")]
    end
    space
 
    %% -----------------------------
    %% Core Data Service (Mona)
    %% -----------------------------
    block:mona_layer
      columns 3
      Crow["Crow\nXML → JSON converter"]
      space
      Mona["Mona\nREST data provider\n1:document\n2:full-text\n3:bibliographic items\n4:images information"]
    end
    space
  
    %% -----------------------------
    %% Processing Layer
    %% -----------------------------
    block:processing_layer
      columns 5
      Panther["Panther\njson uploader"]
        space
      Noir["Noir\nLLM-based embedding generator\nembedding uploader"]
        space
      Violet["Violet\nimage analysis"]
    end
    space
  
    %% -----------------------------
    %% Search Engines / Models
    %% -----------------------------
    block:engine_layer
      columns 4
      Elasticsearch["Elasticsearch\n(full-text + vector index)"]
      space:2
      LLM["LLM\n(embedding + query assist)"]
    end
    space

  
    %% -----------------------------
    %% UI Layer
    %% -----------------------------
    block:ui_layer
      columns 8
      block:skull
        columns 1
        Skull["Skull\nExtra-data editor"]
        extra_data_dir[("EXTRA_DATA_DIR\n(sqlite3)")]
      end
        space
      Joker["Joker\nSearch UI")]
        space:3
      Fox["Fox\nHTML renderer"]
    end
  end

  %% -----------------------------
  %% Data Flows
  %% -----------------------------

  %% Crow
  src_dir -- "crawl XML" --> Crow
  Crow -- "store parsed JSON" --> data_dir

  %% Mona
  data_dir --> Mona
  Mona -- "2" --> Panther 
  Mona -- "1,3,4" --> Noir 
  Mona -- "1,3,4" --> Fox 
  Mona -- "1,3,4" --> Noir 
  Mona -- "4" --> Joker

  %% Panther
  Panther -- "upload full-text\nrestore extra-data" --> Elasticsearch

  %% Noir
  LLM -- "embeddings" --> Noir
  Noir -- "embeddings" --> Elasticsearch


  %% Joker
  Elasticsearch -- "search/results" --> Joker

  %% Skull
  Skull -- "extra data" --> Elasticsearch

  %% Elasticsearch

  %% LLM
  LLM --> Joker 
```


joker
fe0000
c21819

mona
2b6bd7
566385

queen
898289
a2a0a5

skull
f9f242
ecd700


panther
de4283
c42a68

navi
5ea048
498a38

noir
a16cba
8c52a9

fox
05d2ff
1eabd9

crow
dedace
cbc6b0

violet
a743d9
9a36cc

### development
install dependencies
```bash
uv add ../queen
```
### building container
```bash
# build crow container in local
# build queen pkg at first 
cd queen
uv build -o ../crow/deps
cd ../crow
docker compose -f docker-compose.dev.yml build crow-dev

# or in github workflows
checkout
cd queen
uv build -o ../crow/deps
cd ../
docker build
```

