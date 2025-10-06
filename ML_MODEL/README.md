# Plant Disease Detection System

A deep learning system for detecting plant diseases using MobileNetV2 with transfer learning. This system can classify diseases in wheat, rice, and other crops.

## Features

- **Multi-crop Support**: Wheat, rice, and other plant diseases
- **MobileNetV2 Architecture**: Efficient and lightweight model
- **Transfer Learning**: Pre-trained on ImageNet for better performance
- **Multiple Output Formats**: H5, TFLite for mobile deployment
- **IoT Optimization**: Ultra-small models (< 1MB) for edge devices
- **Cross-platform**: Works on Windows, macOS, and Linux

## Requirements

- Python 3.8-3.10
- 8GB+ RAM (16GB recommended for training)
- GPU support optional but recommended for faster training

## Quick Start

### 1. Clone or Download
```bash
# Download the project files
# Ensure you have the following structure:
# ML_MODEL/
# ├── wheat_rice_disease_detection.ipynb
# ├── requirements.txt
# ├── setup.py
# ├── final_dataset/
# │   ├── train/
# │   ├── val/
# │   └── test/
# └── models/
```

### 2. Install Dependencies
```bash
# Option 1: Use the setup script (recommended)
python setup.py

# Option 2: Manual installation
pip install -r requirements.txt
```

### 3. Prepare Dataset
Ensure your dataset follows this structure:
```
final_dataset/
├── train/
│   ├── class1/
│   ├── class2/
│   └── ...
├── val/
│   ├── class1/
│   ├── class2/
│   └── ...
└── test/
    ├── class1/
    ├── class2/
    └── ...
```

### 4. Run the Notebook
```bash
# Start Jupyter Notebook
jupyter notebook wheat_rice_disease_detection.ipynb

# Or use JupyterLab
jupyter lab wheat_rice_disease_detection.ipynb
```

## Usage

1. **Open the notebook** in Jupyter
2. **Run cells sequentially** from top to bottom
3. **Monitor training progress** in the output
4. **Models will be saved** in the `models/` folder

## Output Files

After running the notebook, you'll get:

- `models/best_model.h5` - Best model during training
- `models/final_model.h5` - Final trained model
- `models/model.tflite` - Mobile-optimized model
- `models/iot_1mb_model.tflite` - Ultra-small IoT model
- `class_indices.json` - Class labels mapping

## Troubleshooting

### Common Issues

1. **NumPy compatibility error**
   ```bash
   pip install "numpy<2.0"
   ```

2. **TensorFlow GPU not detected**
   - Install CUDA toolkit and cuDNN
   - Or use CPU-only version (slower but works)

3. **Dataset not found**
   - Ensure `final_dataset/` folder exists
   - Check folder structure matches requirements

4. **Memory errors during training**
   - Reduce batch size in the notebook
   - Use CPU training instead of GPU

### Performance Tips

- **GPU Training**: Much faster, requires CUDA setup
- **CPU Training**: Slower but works on any machine
- **Batch Size**: Adjust based on available memory
- **Image Size**: Smaller images = faster training

## Model Architecture

- **Base Model**: MobileNetV2 (pre-trained on ImageNet)
- **Input Size**: 224x224x3 (RGB images)
- **Output**: Softmax classification
- **Optimizer**: Adam with learning rate scheduling
- **Augmentation**: Rotation, zoom, brightness, flip

## Customization

### Adding New Classes
1. Add new class folders to train/val/test directories
2. Retrain the model
3. Update class indices

### Changing Model Architecture
Modify the model building section in the notebook:
- Adjust input size
- Change dense layer sizes
- Modify dropout rates

## License

This project is open source. Feel free to use and modify for your needs.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Verify your Python and package versions
3. Ensure dataset structure is correct
