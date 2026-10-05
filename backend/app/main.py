from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers.category import router as category_router
from app.routers.payment_modes import router as payment_modes_router
from app.routers.roles import router as roles_router
from app.routers.sub_category import router as sub_categories_router
from app.routers.item import router as items_router
from app.routers.unit import router as unit_router
from app.routers.inventory_category import router as inventory_category_router
from app.routers.inventory_subcategory import router as inventory_subcategory_router



app = FastAPI(
    title="HD POS API",
    version="1.0.0",
)


app.include_router(category_router)
app.include_router(payment_modes_router)
app.include_router(roles_router)
app.include_router(sub_categories_router)
app.include_router(items_router)
app.include_router(unit_router)
app.include_router(inventory_category_router)
app.include_router(inventory_subcategory_router)


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