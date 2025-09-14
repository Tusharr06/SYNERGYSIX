import os
import json


DATA_DIR = "final_dataset/train"   

OUTPUT_FILE = "class_indices.json"


class_names = sorted(os.listdir(DATA_DIR))
class_indices = {cls: idx for idx, cls in enumerate(class_names)}

with open(OUTPUT_FILE, "w") as f:
    json.dump(class_indices, f, indent=4)

print(f"✅ class_indices.json created with {len(class_indices)} classes:")
for k, v in class_indices.items():
    print(f"  {v}: {k}")
