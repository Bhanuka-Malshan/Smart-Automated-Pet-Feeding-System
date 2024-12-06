import pandas as pd  # type: ignore
from sklearn.tree import DecisionTreeClassifier  # type: ignore
import joblib

cars_data = pd.read_csv('cars.csv')

X = cars_data.drop(columns=['vehicle_type']).values  # Input Data

y = cars_data['vehicle_type']  # Output Data

model = DecisionTreeClassifier()

model.fit(X, y)

# Make a prediction with example input data
predictions = model.predict([[21, 1]])
print(f"Prediction for input [21, 1]: {predictions[0]}")

# Persist the model to a file
joblib.dump(model, 'car-recommender.joblib')

# Load the persisted model from the file
model = joblib.load('car-recommender.joblib')

# Make a prediction using the loaded model
predictions = model.predict([[22, 1]])
print(f"Prediction for input [22, 1]: {predictions[0]}")
