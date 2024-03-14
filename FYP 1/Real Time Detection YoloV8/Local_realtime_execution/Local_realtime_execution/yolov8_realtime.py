#install following dependencies before ececuting
#!pip install ultralytics

from ultralytics import YOLO
from ultralytics.utils import ASSETS
from ultralytics.models.yolo.detect import DetectionPredictor
#import cv2

model = YOLO("best_final.pt")

results = model.predict(source="0", show=True, conf=0.5)        # or use this in source 'testing_images/'
# accepts all formats img/folder/vid.
print(results)

# import torch
# from torchvision import transforms
# from PIL import Image
# import json

# # Load the YOLO model
# model = torch.load('best.pt')
# #model.eval()

# # Load and preprocess the image
# image_path = 'image_apple.jpeg'
# image = Image.open(image_path).convert('RGB')

# # Define the transformation
# transform = transforms.Compose([
#     transforms.Resize((416, 416)),
#     transforms.ToTensor(),
# ])

# # Apply the transformation
# input_image = transform(image).unsqueeze(0)

# # Perform inference
# with torch.no_grad():
#     output = model(input_image)

# # Load the class labels
# with open('classes.json', 'r') as f:
#     class_labels = json.load(f)

# # Extract the predicted class index for each detection
# def get_predicted_classes(output, confidence_threshold=0.5):
#     predicted_classes = []
#     scores = output[0][:, 4].cpu().numpy()
#     class_indices = output[0][:, 5:].argmax(1).cpu().numpy()

#     for i in range(len(scores)):
#         if scores[i] > confidence_threshold:
#             predicted_classes.append(class_indices[i])

#     return predicted_classes

# # Get predicted classes
# predicted_classes = get_predicted_classes(output)

# # Map class indices to class labels
# predicted_labels = [class_labels[str(class_idx)] for class_idx in predicted_classes]

# # Print or use the predicted labels as needed
# print("Predicted Classes:", predicted_labels)
