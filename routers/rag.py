import sys
import os
sys.path.append('..')
from pydantic import BaseModel
from fastapi import HTTPException, Depends, APIRouter

from langchain_community.document_loaders import TextLoader
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma
import chromadb
from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

router = APIRouter(
    prefix="/rag",
    tags=['rag'],
    responses={404: {"description": "Not found"}}
)

os.environ['OPENAI_API_KEY'] = {OPEN_API_KEY}

# 입력 데이터 모델 정의
class InputData(BaseModel):
    input: str

def format_docs(docs):
    return '\n\n'.join([d.page_content for d in docs])


loader1 = TextLoader('place_v3.txt') # 가게 리뷰 모음
loader2 = TextLoader('person_v1.txt') # 사용자별 리뷰 모음

data1 = loader1.load()
data2 = loader2.load()    

text_splitter = RecursiveCharacterTextSplitter.from_tiktoken_encoder(
chunk_size=250,
chunk_overlap=50,
encoding_name='cl100k_base'
)

texts1 = text_splitter.split_text(data1[0].page_content)
texts2 = text_splitter.split_text(data2[0].page_content)

embeddings_model = OpenAIEmbeddings(openai_api_key={OPEN_API_KEY})
new_client = chromadb.EphemeralClient()


db1 = Chroma.from_texts(
    texts1,
    embeddings_model,
    collection_name = 'place_v3',
    persist_directory = './db/chromadb',
    client=new_client,
    collection_metadata = {'hnsw:space': 'cosine'}, # l2 is the default
)
db2 = Chroma.from_texts(
    texts2,
    embeddings_model,
    collection_name = 'people_v1',
    persist_directory = './db/chromadb',
    client=new_client,
    collection_metadata = {'hnsw:space': 'cosine'}, # l2 is the default
)


template = '''
            Answer the question based only on the following context :
            {context}

            This is the reviews that this person wrote before; refer to it
            {person}

            <Condition>
            0. You Must Answer with Korean.
            1. You Must include the reason about the answer
            1-1. Answer in the form of recommending this place because the user said he liked it before
            2. If the question is about where to go, must answer with the place name that is specified as 'place title' in origin data.
            3. If the question is about where to go, it would be good to explain the characteristics of this place that are different from other places.
            4. If the question is about where to go, recommend at least 2 places with each place's name. Include comparision between places.
            5. Must include before
            Question: {question}
            '''

prompt = ChatPromptTemplate.from_template(template)

# Model
llm = ChatOpenAI(
    model='gpt-3.5-turbo-0125',
    temperature=0,
    max_tokens=500,
    openai_api_key={OPEN_API_KEY}
)

# Chain
chain = prompt | llm | StrOutputParser()

# 파일 경로 지정
file_path = 'placeinfo_v2.txt'

# 파일 열기
with open(file_path, 'r', encoding='utf-8') as file:
    # 파일 내용 읽기
    data = file.read()

@router.post("/")
def rag(webserverinput: InputData) :
    # Run
    query = webserverinput.input
    docs = db1.similarity_search(query)
    person = db2.similarity_search(query)
    response = chain.invoke({'context': (format_docs(docs)),'person':(format_docs(person)), 'question':query})
    return response

