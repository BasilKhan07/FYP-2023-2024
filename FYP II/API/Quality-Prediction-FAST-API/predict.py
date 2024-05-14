from fastapi import FastAPI, File, UploadFile
from keras.models import load_model
import numpy as np
from PIL import Image
import io
from datetime import datetime

# To execute this API : uvicorn predict:app --reload --host 0.0.0.0 --port 8000
# Loading CNN model
try:
    mobilenet_model = load_model('mobilenet_FYP_model.h5')    #only works with keras and tensorflow 2.15.0
    print("model loaded.")
except Exception as e:
    print("\n\n Error loading model: ", e)

# func to predict class using CNN model
def predict_class(image_arr):
    predictions = mobilenet_model.predict(image_arr) 

    # Normalize prediction scores to percentages
    total_score = np.sum(predictions)
    normalized_scores = (predictions / total_score) * 100

    # Get most likely class
    predicted_classes = np.argmax(predictions, axis=1)
    # Assuming the model returns a list of classes with probabilities
    # You may need to adjust this part based on your model's output format
    class_labels = ['Apple_blotch','Apple_healthy', 'Apple_rotten','Apple_scab',
                    'Banana_firm','Banana_heavilybruised','Banana_slightlybruised',
                    'GreenChilli_damaged','GreenChilli_dried','GreenChilli_old','GreenChilli_ripe',
                    'Orange_greening','Orange_healthy','Orange_rotten',
                    'Tomato_old','Tomato_ripe','Tomato_rotten','Tomato_unripe']  # Provide your class names here
    predicted_classes = [class_labels[i] for i in np.argmax(predictions, axis=1)]

    return predicted_classes, normalized_scores


# preprocess image
def preprocess_image(image):
    image = image.resize((224, 224))  # Resize the image to match the input size of the model
    image_arr = np.array(image) / 255.0  # Normalize pixel values to [0, 1]
    image_arr = np.expand_dims(image_arr, axis=0)  # Add batch dimension
    return image_arr

# Define the FastAPI endpoint
app = FastAPI()

@app.post("/predict/")                          #uvicorn package is used to let your API running as a server
async def predict(image: UploadFile = File(...)):
    # Read the uploaded image file
    contents = await image.read()
    
    # Convert the image data to a PIL Image object
    img = Image.open(io.BytesIO(contents))
    
    # Preprocess the image
    img_arr = preprocess_image(img)
    
    # Make predictions using the model
    predicted_classes, normalized_scores = predict_class(img_arr)
    
    # To print time for logs
    timestamp = datetime.now().strftime("%d %B %Y %H:%M:%S")
    print(str(timestamp) + "  --------  " + str({"predictions": predicted_classes}))
    
    # Return predictions along with normalized scores
    return {"predictions": predicted_classes, "normalized_scores": normalized_scores}

