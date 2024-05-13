from fastapi import FastAPI, File, UploadFile
from ultralytics import YOLO
import json
import supervision as sv        # version 0.20.0
import numpy as np
import shutil

# To execute this API : uvicorn video_classification_yolo:app --reload --host 0.0.0.0 --port 8000

complete_video_labels = []

def process_frame(frame: np.ndarray, _) -> np.ndarray:
    results = model(frame, imgsz=1280)[0]
    detections = sv.Detections.from_ultralytics(results)
    box_annotator = sv.BoxAnnotator(thickness=4, text_thickness=4, text_scale=2)
    labels = []
    global complete_video_labels

    for detection in detections:
        # print(detection)
        print('processing........')
        label = [f"{model.names[detection[3]]} {detection[2]:0.2f}"]
        labels = labels + label
        label_tuple = {"name": model.names[detection[3]], "confidence": f"{detection[2]:0.2f}"}     # just for complete video labels
        complete_video_labels = complete_video_labels + [label_tuple]
    
    frame = box_annotator.annotate(scene=frame, detections=detections, labels=labels)
    
    #--------------------
    # labels = [f"{model.names[class_id]} {confidence:0.2f}" for _, _, confidence, class_id, _ in detections]
    # frame = box_annotator.annotate(scene=frame, detections=detections, labels=labels)
    #-----------------
    
    # print("Labels\n---------\n---------")
    # print(labels)
    # print("Frame/\----------\n----------")
    # print(frame)
    return frame

def count_occurences(labels_list):
    # Create a dictionary to store the count of each name
    name_count = {}
    # Iterate through the list of dictionaries
    for item in labels_list:
        # Get the name from the current dictionary
        name = item['name']
        # Increment the count of the name in the dictionary
        name_count[name] = name_count.get(name, 0) + 1

    return name_count


app = FastAPI()
model = YOLO("best_final.pt")

@app.post("/upload_video/")
async def upload_video(video_file: UploadFile = File(...)):
    # Save the uploaded video to disk
    save_path = f"videos/{video_file.filename}"
    with open(save_path, "wb") as buffer:
        shutil.copyfileobj(video_file.file, buffer)

    model = YOLO("best_final.pt")
    VIDEO_PATH = "./videos/" + video_file.filename
    video_info = sv.VideoInfo.from_video_path(VIDEO_PATH)
    global complete_video_labels
    target_video_path = "./output_videos/" + video_file.filename
    sv.process_video(source_path=VIDEO_PATH, target_path=target_video_path, callback=process_frame)
    print(complete_video_labels)
    results = count_occurences(complete_video_labels)
    print(results)

    # Save the results to a JSON file
    json_file_path = "./results_json/" + video_file.filename.split(".")[0] + ".json"
    with open(json_file_path, "w") as json_file:
        json.dump(results, json_file, indent=4)
    
    return results

