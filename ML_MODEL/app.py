import streamlit as st
import tensorflow as tf
import numpy as np
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from PIL import Image
import cv2
import os
import json
import warnings
import matplotlib.pyplot as plt

warnings.filterwarnings('ignore')

st.set_page_config(
    page_title="Plant Disease Detection",
    page_icon="🌱",
    layout="wide",
    initial_sidebar_state="expanded"
)

MODEL_PATH = "models/best_model.h5"
if not os.path.exists(MODEL_PATH):
    st.error("❌ Trained model not found at path: models/best_model.h5")
    st.stop()

@st.cache_resource
def load_model():
    return tf.keras.models.load_model(MODEL_PATH)

model = load_model()
st.success("✅ Model loaded successfully!")

CLASS_INDEX_PATH = "class_indices.json"
if not os.path.exists(CLASS_INDEX_PATH):
    st.error("❌ class_indices.json not found! Please export it during training.")
    st.stop()

with open(CLASS_INDEX_PATH) as f:
    class_indices = json.load(f)

CLASS_NAMES = [k for k, v in sorted(class_indices.items(), key=lambda item: item[1])]
NUM_CLASSES = len(CLASS_NAMES)

st.sidebar.markdown("### Dataset Info")
st.sidebar.write(f"**Classes detected:** {NUM_CLASSES}")
for i, cls in enumerate(CLASS_NAMES, start=1):
    st.sidebar.write(f"{i}. {cls}")

def preprocess_image(image, target_size=(224, 224)):
    try:
        img_array = np.array(image.convert("RGB"))
        img_resized = cv2.resize(img_array, target_size)
        img_preprocessed = preprocess_input(img_resized.astype(np.float32))
        img_batch = np.expand_dims(img_preprocessed, axis=0)
        return img_batch
    except Exception as e:
        st.error(f"⚠️ Error preprocessing image: {str(e)}")
        return None

def predict(image):
    img_batch = preprocess_image(image)
    if img_batch is None:
        return None, None, None

    preds = model.predict(img_batch)
    num_model_classes = preds.shape[1]

    if num_model_classes != len(CLASS_NAMES):
        st.error(f"❌ Mismatch: Model outputs {num_model_classes} classes but class_indices.json has {len(CLASS_NAMES)}")
        return None, None, None

    top_indices = preds[0].argsort()[-3:][::-1]
    top_classes = [CLASS_NAMES[i] for i in top_indices]
    top_confidences = [float(preds[0][i]) for i in top_indices]

    return top_classes, top_confidences, preds

st.markdown("<h1 class='main-header'>🌱 Plant Disease Detection</h1>", unsafe_allow_html=True)
st.markdown("Upload a plant leaf image to detect its health condition.")

uploaded_file = st.file_uploader("📤 Upload Image", type=["jpg", "jpeg", "png"])

if uploaded_file:
    image = Image.open(uploaded_file)
    st.image(image, caption="Uploaded Image", use_column_width=True)

    if st.button("🔍 Predict"):
        with st.spinner("Analyzing image..."):
            top_classes, top_confidences, preds = predict(image)

        if top_classes:
            st.success(f"✅ Predicted: **{top_classes[0]}** ({top_confidences[0]*100:.2f}% confidence)")

            fig, ax = plt.subplots()
            ax.barh(top_classes[::-1], [c*100 for c in top_confidences[::-1]], color="green")
            ax.set_xlabel("Confidence (%)")
            ax.set_title("Top-3 Predictions")
            st.pyplot(fig)
        else:
            st.error("❌ Could not make a prediction. Please try again.")
