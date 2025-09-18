from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import tensorflow as tf
import numpy as np
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from PIL import Image
import io
import os
import json

app = FastAPI(title="Plant Disease Detection API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MODEL_PATH = "models/best_model.h5"
CLASS_INDEX_PATH = "class_indices.json"

if not os.path.exists(MODEL_PATH):
    raise RuntimeError("Trained model not found at path: models/best_model.h5")
if not os.path.exists(CLASS_INDEX_PATH):
    raise RuntimeError("class_indices.json not found! Please export it during training.")

model = tf.keras.models.load_model(MODEL_PATH)
with open(CLASS_INDEX_PATH) as f:
    class_indices = json.load(f)
CLASS_NAMES = [k for k, v in sorted(class_indices.items(), key=lambda item: item[1])]

def preprocess_image_bytes(image_bytes: bytes, target_size=(224, 224)):
    try:
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        img_array = np.array(image)
        img_resized = tf.image.resize(img_array, target_size).numpy().astype(np.float32)
        img_preprocessed = preprocess_input(img_resized)
        img_batch = np.expand_dims(img_preprocessed, axis=0)
        return img_batch
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error preprocessing image: {str(e)}")

@app.get("/")
def root():
    return {"status": "ok", "num_classes": len(CLASS_NAMES)}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    if file.content_type not in ("image/jpeg", "image/png", "image/jpg"):
        raise HTTPException(status_code=415, detail="Unsupported file type")

    image_bytes = await file.read()
    img_batch = preprocess_image_bytes(image_bytes)

    preds = model.predict(img_batch)
    if preds.ndim != 2 or preds.shape[1] != len(CLASS_NAMES):
        raise HTTPException(status_code=500, detail="Model output shape mismatch with class indices")

    top_indices = preds[0].argsort()[-3:][::-1]
    results = [
        {
            "class": CLASS_NAMES[i],
            "confidence": float(preds[0][i])
        }
        for i in top_indices
    ]
    return {"predictions": results}

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8000"))
    uvicorn.run("app:app", host="0.0.0.0", port=port, reload=False)

