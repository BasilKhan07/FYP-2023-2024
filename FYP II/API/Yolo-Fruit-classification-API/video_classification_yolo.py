from fastapi import FastAPI, File, UploadFile
from ultralytics import YOLO
import json
import supervision as sv
import numpy as np
import shutil

app = FastAPI()
model = YOLO("best_final.pt")
complete_video_labels = []

def process_frame(frame: np.ndarray, _) -> np.ndarray:
    results = model(frame, imgsz=1280)[0]
    detections = sv.Detections.from_ultralytics(results)
    box_annotator = sv.BoxAnnotator(thickness=4, text_thickness=4, text_scale=2)
    labels = []
    global complete_video_labels

    for detection in detections:
        label = [f"{model.names[detection[3]]} {detection[2]:0.2f}"]
        labels = labels + label
        label_tuple = {"name": model.names[detection[3]], "confidence": f"{detection[2]:0.2f}"}
        complete_video_labels = complete_video_labels + [label_tuple]
    
    frame = box_annotator.annotate(scene=frame, detections=detections, labels=labels)
    return frame

def normalize_occurences(labels_list):
    class_counts = {}
    class_totals = {}

    # Count occurrences for each class
    for item in labels_list:
        name = item['name']
        class_prefix = name.split('_')[0]  # Get the class prefix
        class_counts[class_prefix] = class_counts.get(class_prefix, {})
        class_counts[class_prefix][name] = class_counts[class_prefix].get(name, 0) + 1

    # Calculate total counts for each class
    for class_prefix, class_count in class_counts.items():
        class_totals[class_prefix] = sum(class_count.values())

    normalized_results = {}

    # Normalize counts for each class
    for class_prefix, class_count in class_counts.items():
        for name, count in class_count.items():
            normalized_results[name] = round((count / class_totals[class_prefix]) * 100)

    return normalized_results

@app.post("/upload_video/")
async def upload_video(video_file: UploadFile = File(...)):
    save_path = f"videos/{video_file.filename}"
    with open(save_path, "wb") as buffer:
        shutil.copyfileobj(video_file.file, buffer)

    model = YOLO("best_final.pt")
    VIDEO_PATH = "./videos/" + video_file.filename
    video_info = sv.VideoInfo.from_video_path(VIDEO_PATH)
    global complete_video_labels
    target_video_path = "./output_videos/" + video_file.filename
    sv.process_video(source_path=VIDEO_PATH, target_path=target_video_path, callback=process_frame)
    results = normalize_occurences(complete_video_labels)

    # Flatten the dictionary and save to JSON file
    flat_results = {key: int(value) for key, value in results.items()}  # Convert values to integers
    json_file_path = "./results_json/" + video_file.filename.split(".")[0] + ".json"
    with open(json_file_path, "w") as json_file:
        json.dump(flat_results, json_file, indent=4)
    
    return flat_results

