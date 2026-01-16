# Voca 语刻 API Documentation

Base URL: `http://localhost:8000`

## Endpoints

### GET /api/session
获取学习会话，返回 10 个待刻印的单词。

**Query Parameters:**
- `user_id` (required): 用户 ID
- `level` (optional): 词库等级 (GRE, 考研)，默认 GRE
- `count` (optional): 单词数量，默认 10

**Response:**
```json
[
  {
    "id": 1,
    "text": "arbitrage",
    "definition": "利用不同市场的价格差异获利",
    "phonetic": "/ˈɑːrbɪtrɑːʒ/",
    "options": ["定义1", "定义2", "定义3", "定义4"]
  }
]
```

---

### POST /api/progress
更新单词学习进度。

**Request Body:**
```json
{
  "user_id": "user_001",
  "word_id": 1,
  "correct": true
}
```

**Response:**
```json
{
  "word_id": 1,
  "mastery_count": 2,
  "is_mastered": false
}
```

---

### POST /api/story
生成 AI 语境故事。

**Request Body:**
```json
{
  "word_ids": [1, 2, 3, 4, 5],
  "theme": "量化投资"
}
```

**Response:**
```json
{
  "content": "In the world of **arbitrage**, traders seek...",
  "keywords": ["arbitrage", "volatile", "leverage"],
  "theme": "量化投资"
}
```

---

### GET /api/progress/{user_id}
获取用户学习统计。

**Response:**
```json
{
  "total_words": 20,
  "mastered": 5,
  "in_progress": 8,
  "new": 7
}
```
