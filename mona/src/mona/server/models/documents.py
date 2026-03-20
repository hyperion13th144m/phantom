from typing import List, Optional

from pydantic import BaseModel


### PatentDocument は PatAppDoc などの構造であるが、
### ここでは全プロパティを optional として定義する。
### 正確に PatAppDoc の構造を定義することも可能だが、
### 再帰が深く、/docs の参照で固まる。
### どうせ API を利用する側で 自動生成したインタフェースを利用するから
### fastapi の response_model は簡単に。
class PatentDocument(BaseModel):
    tag: str
    jpTag: Optional[str]
    indentLevel: Optional[str]
    text: Optional[str]
    convertedText: Optional[str]
    number: Optional[str]
    imageKind: Optional[str]
    file: Optional[str]
    isLastSentence: Optional[bool]
    isIndependent: Optional[bool]
    blocks: Optional[List["PatentDocument"]]


PatentDocument.model_rebuild()
