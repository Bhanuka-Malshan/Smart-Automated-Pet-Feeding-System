import uvicorn
from fastapi import FastAPI
import joblib
from CarUser import CarUser

app = FastAPI()

# Load the machine learning model
joblib_in = open("car-recommender.joblib", "rb")
model = joblib.load(joblib_in)


@app.get("/")
def index():
    return {"message": "Cars Recommender ML API"}


@app.post("/car/predict")
def predict_car_type(data: CarUser):
    # Extract data from the request
    age = data.age
    gender = data.gender

    # Perform prediction
    prediction = model.predict([[age, gender]])

    return {"prediction": prediction[0]}


if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8080)
