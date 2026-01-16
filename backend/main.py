"""
Voca 语刻 (Voca Engrave) - Backend API
FastAPI application for vocabulary learning with "3次刻印" mastery system
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database import create_db_and_tables
from routers.learning import router as learning_router

# Create FastAPI app
app = FastAPI(
    title="Voca 语刻 API",
    description="背单词不是浮光掠影，而是通过3次精准反馈将记忆刻入脑海",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS configuration for Flutter web/mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your frontend domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(learning_router)


@app.on_event("startup")
async def on_startup():
    """Initialize database on startup"""
    create_db_and_tables()
    print("🚀 Voca 语刻 API started!")
    print("📚 Database tables created/verified")


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "name": "Voca 语刻",
        "status": "running",
        "version": "0.1.0",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    """Detailed health check"""
    return {
        "status": "healthy",
        "database": "connected",
        "api": "operational"
    }
