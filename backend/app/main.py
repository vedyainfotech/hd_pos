from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers.category import router as category_router
from app.routers.sub_category import router as sub_category_router
from app.routers.item import router as item_router
from app.routers.delivery_person import router as delivery_person_router


app = FastAPI(
    title="HD POS API",
    version="1.0.0",
)


# ============================================================
# ROUTERS
# ============================================================

app.include_router(category_router)
app.include_router(sub_category_router)
app.include_router(item_router)
app.include_router(delivery_person_router)


# ============================================================
# CORS
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# ROOT
# ============================================================

@app.get("/")
def root():
    return {
        "message": "HD POS API is running"
    }


# ============================================================
# HEALTH
# ============================================================

@app.get("/health")
def health():
    return {
        "status": "healthy"
    }
