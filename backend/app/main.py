from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers.category import router as category_router
from app.routers.payment_modes import router as payment_modes_router


app = FastAPI(
    title="HD POS API",
    version="1.0.0",
)


app.include_router(category_router)
app.include_router(payment_modes_router)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {
        "message": "HD POS API is running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }