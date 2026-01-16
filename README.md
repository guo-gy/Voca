<div align="center">
  <h1>🔮 Voca 语刻</h1>
  <p><strong>Engrave Your Vocabulary</strong></p>
  <p>背单词不是浮光掠影，而是通过 <b>3 次精准反馈</b>将记忆刻入脑海</p>
  
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter" alt="Flutter">
    <img src="https://img.shields.io/badge/FastAPI-0.109+-009688?logo=fastapi" alt="FastAPI">
    <img src="https://img.shields.io/badge/License-Apache%202.0-blue" alt="License">
  </p>
</div>

---

## ✨ 特性

- **3 次刻印系统** - 每个单词需要连续答对 3 次才能"刻入"记忆
- **AI 语境编织** - 使用 GPT 生成个性化故事，将单词融入有趣的语境中
- **全平台支持** - Web、Windows、macOS、Linux、iOS、Android
- **极简暗黑风格** - 荧光青高亮，沉浸式学习体验

## 🏗️ 架构

```
Voca/
├── backend/          # FastAPI + SQLModel
│   ├── main.py       # API 入口
│   ├── models.py     # 数据模型
│   ├── routers/      # API 路由
│   └── services/     # AI 服务
│
├── frontend/         # Flutter 跨平台应用
│   └── lib/
│       ├── core/     # 主题配置
│       ├── models/   # 数据模型
│       ├── providers/# Riverpod 状态管理
│       └── pages/    # UI 页面
│
└── docs/             # 文档
```

## 🚀 快速开始

### 后端

```bash
cd backend
pip install -r requirements.txt

# 初始化词库
python seed_data.py

# 启动服务
uvicorn main:app --reload
```

### 前端

```bash
cd frontend
flutter pub get
flutter run
```

## 💡 商业模式 (Freemium)

| 功能 | 免费版 | Pro 版 |
|------|--------|--------|
| 每日刻印 | 20 词 | 无限 |
| 词库 | 考研/GRE 基础 | 全部词库 |
| AI 语境故事 | ❌ | ✅ |
| 进度云同步 | ❌ | ✅ |
| 主题自定义 | ❌ | ✅ |

## 📄 License

Apache License 2.0
