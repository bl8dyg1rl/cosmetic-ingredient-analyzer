from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.app.routers.ingredients import router as ingredients_router


app = FastAPI(
    title="Cosmetic Ingredient Analyzer API",
    description="API for analyzing cosmetic ingredients and products.",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[],
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(ingredients_router)


@app.get("/")
def root():
    return {
        "message": "Cosmetic Ingredient Analyzer API",
        "version": "0.1.0",
    }


@app.get("/health")
def health_check():
    return {"status": "ok"}
