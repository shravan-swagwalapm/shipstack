# Playbook: Python AI/RAG Pipeline

> Patterns from a production RAG system with 160K+ vector embeddings.

## 1. Cache-First Pipeline

**Problem**: Full RAG pipeline costs $0.10-0.50 per query. Many questions are repeated.

**Solution**: Check a local index before running the pipeline.

```python
from __future__ import annotations  # Required for Python 3.9 compat
import json
from pathlib import Path

INDEX_PATH = Path("question_index.json")

def get_cached_answer(question: str) -> dict | None:
    """Check if we've already answered this question."""
    if not INDEX_PATH.exists():
        return None
    index = json.loads(INDEX_PATH.read_text())
    # Normalize for matching
    normalized = question.strip().lower().rstrip("?")
    for entry in index:
        if entry["question"].strip().lower().rstrip("?") == normalized:
            return entry
    return None

def cache_answer(question: str, answer: str, audio_path: str | None = None):
    """Save answer to index for future instant retrieval."""
    index = json.loads(INDEX_PATH.read_text()) if INDEX_PATH.exists() else []
    index.append({
        "question": question,
        "answer": answer,
        "audio": audio_path,
        "cached_at": datetime.now().isoformat()
    })
    INDEX_PATH.write_text(json.dumps(index, indent=2))

# Usage: always check cache first
cached = get_cached_answer("What is the meaning of dharma?")
if cached:
    print(f"Cache hit! Playing {cached['audio']}")
else:
    answer = run_full_pipeline(question)  # Expensive
    cache_answer(question, answer, audio_path)
```

## 2. FAISS Vector Search

```python
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer

# Build index (one-time)
model = SentenceTransformer('all-MiniLM-L6-v2')
texts = load_all_documents()  # Your corpus
embeddings = model.encode(texts, show_progress_bar=True)

index = faiss.IndexFlatIP(embeddings.shape[1])  # Inner product (cosine after normalization)
faiss.normalize_L2(embeddings)
index.add(embeddings.astype('float32'))
faiss.write_index(index, "knowledge.faiss")

# Query (per request)
def search(query: str, top_k: int = 5) -> list[tuple[str, float]]:
    query_vec = model.encode([query]).astype('float32')
    faiss.normalize_L2(query_vec)
    scores, indices = index.search(query_vec, top_k)
    return [(texts[i], float(scores[0][j])) for j, i in enumerate(indices[0])]
```

## 3. Voice Synthesis via HTTP (Not SDK)

**Problem**: The ElevenLabs Python SDK hangs on long text. Direct HTTP is reliable.

```python
import httpx
from pathlib import Path

ELEVENLABS_API_KEY = os.environ["ELEVENLABS_API_KEY"]
VOICE_ID = os.environ["ELEVENLABS_VOICE_ID"]

def synthesize_speech(text: str, output_path: str) -> Path:
    """Synthesize speech via ElevenLabs HTTP API (not SDK — SDK hangs)."""
    response = httpx.post(
        f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE_ID}",
        headers={
            "xi-api-key": ELEVENLABS_API_KEY,
            "Content-Type": "application/json",
        },
        json={
            "text": text,
            "model_id": "eleven_v3",  # Required for Instant Voice Clone
            "voice_settings": {
                "stability": 0.5,
                "similarity_boost": 1.0,
            },
        },
        timeout=60.0,
    )
    response.raise_for_status()
    path = Path(output_path)
    path.write_bytes(response.content)
    return path
```

## 4. Key Rules

- **`from __future__ import annotations`** in every file (Python 3.9 compat for `X | Y` type syntax)
- **Whisper on CPU**: MPS backend garbles long audio — always force CPU
- **Cache index check FIRST**: Before running any expensive pipeline
- **HTTP over SDK**: When SDKs hang or have breaking changes, raw HTTP is more reliable
- **Env vars for all API keys**: Never hardcode credentials
