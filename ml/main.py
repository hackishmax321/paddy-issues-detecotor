import torch
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.encoders import jsonable_encoder
from pathlib import Path
import uvicorn
import cv2
from PIL import Image
import numpy as np
import tensorflow as tf
from tensorflow import keras
import pathlib
from pymongo import MongoClient, DESCENDING
from bson import ObjectId
from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional, Annotated
from datetime import datetime

# Correcting PosixPath issue for Windows
temp = pathlib.PosixPath
pathlib.PosixPath = pathlib.WindowsPath

app = FastAPI()
origins = [
    "http://localhost:3000",
    "http://localhost:3001"
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MONGODB_CONNECTION_URL = "mongodb+srv://dbUser:111222333@cluster0.gner9xh.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

UPLOADS_DIR = "./uploads"
Path(UPLOADS_DIR).mkdir(parents=True, exist_ok=True)

# Mongo DB setup
# MongoDB setup
client = MongoClient(MONGODB_CONNECTION_URL)
db = client["complaints_db"]
complaints_collection = db["complaints"]

# Load custom model
fest_model = torch.hub.load('ultralytics/yolov5', 'custom', 'last.pt', force_reload=True)

class Complaint(BaseModel):
    _id: Optional[str] = Field(None, alias="_id")
    title: str
    details: str
    instruction: str
    area: str
    createdDate: Optional[datetime] = Field(default_factory=datetime.utcnow)

@app.post("/complaints", response_model=Complaint)
async def create_complaint(complaint: Complaint):
    complaint_dict = jsonable_encoder(complaint)
    complaint_dict["createdDate"] = datetime.utcnow()
    
    # Convert datetime to ISO format string
    complaint_dict["createdDate"] = complaint_dict["createdDate"].isoformat()
    
    result = db["complaints"].insert_one(complaint_dict)
    complaint_dict["_id"] = str(result.inserted_id)

    return JSONResponse(status_code=201, content=complaint_dict)

@app.get("/complaints", response_model=List[Complaint])
async def get_complaints():
    complaints = complaints_collection.find().sort("createdDate", DESCENDING)
    complaints_list = []
    for complaint in complaints:
        complaint["_id"] = str(complaint["_id"])
        complaints_list.append(complaint)
    return complaints_list

# Load model with handling for potential custom objects
def load_model_with_custom_objects(model_path, custom_objects=None):
    model = keras.models.load_model(model_path, custom_objects=custom_objects)
    return model

def check_plant(model, image_path):
    img = Image.open(image_path)
    img = img.resize((48, 48))  # Resize the image to match model input size
    img = np.array(img)  # Convert image to numpy array
    img = img / 255.0  # Normalize pixel values
    
    # Make prediction
    prediction = model.predict(np.expand_dims(img, axis=0))
    predicted_class_index = np.argmax(prediction)
    class_names = ['No', 'Nitrogen(N)', 'Phosphorus(P)', 'Potassium(K)']
    predicted_class = class_names[predicted_class_index]
    
    return predicted_class

def check_micro_diseases(model, image_path):
    img = Image.open(image_path)
    img = img.resize((48, 48))  # Resize the image to match model input size
    img = np.array(img)  # Convert image to numpy array
    img = img / 255.0  # Normalize pixel values
    
    # Make prediction
    prediction = model.predict(np.expand_dims(img, axis=0))
    predicted_class_index = np.argmax(prediction)
    class_names = ['Bacterial Leaf blight', 'Brown spot', 'No Issue', 'Leaf Blast', 'Leaf Scald', 'Narrow Brown spot']
    predicted_class = class_names[predicted_class_index]
    
    return predicted_class

@app.post("/predict-paddy-all")
async def upload_image(file: UploadFile = File(...)):
    try:
        # Save the uploaded file
        file_path = f"{UPLOADS_DIR}/{file.filename}"
        with open(file_path, "wb") as buffer:
            buffer.write(await file.read())
        
        # Load the model
        model_path = 'model_paddy_nutrition_healthy.h5'
        model = load_model_with_custom_objects(model_path, custom_objects=None)

        # Load Micro Diseases
        model_path2 = 'model_paddy_micro.h5'
        model_micro = load_model_with_custom_objects(model_path2, custom_objects=None)

        # Make prediction
        predicted_class = check_plant(model, file_path)
        predicted_micro_class = check_micro_diseases(model_micro, file_path)
        predicted_fests = detect_fests(file_path)
        
        return {"predicted_class": predicted_class, "micro": predicted_micro_class, "fests": predicted_fests}
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.post("/predict-paddy-plant")
async def upload_image(file: UploadFile = File(...)):
    try:
        # Save the uploaded file
        file_path = f"{UPLOADS_DIR}/{file.filename}"
        with open(file_path, "wb") as buffer:
            buffer.write(await file.read())
        
        # Load the model
        model_path = 'model_paddy_nutrition_healthy.h5'
        model = load_model_with_custom_objects(model_path, custom_objects=None)

        # Make prediction
        predicted_class = check_plant(model, file_path)
        
        return {"predicted_class": predicted_class}
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.post("/predict-fest-types")
async def upload_image(file: UploadFile = File(...)):
    try:
        # Save the uploaded file
        file_path = f"{UPLOADS_DIR}/{file.filename}"
        with open(file_path, "wb") as buffer:
            buffer.write(await file.read())
        
        # Make prediction
        predicted_class = detect_fests(file_path)
        
        return {"predicted_class": predicted_class}
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

def detect_fests(image_path): 
    image = cv2.imread(image_path)
    if image is None:
        raise ValueError("Could not read the image.")

    new_width, new_height = 1700, 1200
    resized_image = cv2.resize(image, (new_width, new_height))

    results0 = fest_model(resized_image)
    results_table = results0.pandas().xyxy[0]
    identified_classes = results_table['name'].tolist()
    # print(identified_classes)
    
    return identified_classes

if __name__ == "__main__":
    uvicorn.run(app, host="localhost", port=8000)
