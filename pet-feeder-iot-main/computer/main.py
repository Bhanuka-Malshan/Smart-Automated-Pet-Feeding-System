import firebase_admin
from firebase_admin import credentials, db, messaging
import cv2
import os
from tensorflow.keras.models import load_model
import numpy as np
import vlc
import time

# Load the model
model = load_model('./model_v1.h5')

category_dict={0:'Dog', 1:'Cat'}
# Ensure the data directory exists
if not os.path.exists('./data'):
    os.makedirs('./data')

cred = credentials.Certificate("./pet-feeder-94fe8-firebase-adminsdk-fbsvc-481d31b8f7.json")
# firebase_admin.initialize_app(cred)

# Initialize the Firebase Admin SDK with the database URL
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://pet-feeder-94fe8-default-rtdb.firebaseio.com/'
})

refDoor = db.reference('computer/door')
refToken = db.reference('computer/token')
ref = db.reference('computer')
audioRef = db.reference('esp32')
audioNewRef = db.reference('esp')
alertRef = db.reference('alert')
# ref.set({
#     "value":1
# })

def listener(event):
    print(f'Event type: {event.event_type}')  # can be 'put', 'patch', or 'delete'
    print(f'Path: {event.path}')
    print(f'Value: {event.data}')
    
    # Check if event.data is a dictionary
    if(event.data!=1):
        return
    
    # Initialize the webcam
    cap = cv2.VideoCapture(0)
    
    # Check if the camera is opened correctly
    if not cap.isOpened():
        print("Error: Could not access the camera.")
        return  
    
    # Capture a frame
    ret, frame = cap.read()

    if ret:
        # Save the captured image
        cv2.imwrite('./data/image.jpg', frame)
        print("Image captured and saved as image.jpg")
    else:
        print("Error: Failed to capture image.")
        
    if ret:
        # Preprocess the captured frame
        test_img = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)  # Convert to grayscale
        test_img = cv2.resize(test_img, (50, 50))  # Resize to 50x50
        test_img = test_img / 255.0  # Normalize pixel values to [0, 1]
        test_img = test_img.reshape(1, 50, 50, 1)  # Reshape for model input
        
        # Make prediction
        result = model.predict(test_img)
        label = np.argmax(result, axis=1)[0]  # Get the label with the highest probability
        print(result, label)
        print(category_dict[label])
        ref.update({
            "cat-or-dog":int(label),
            "door":0
        })
                
    # Release the camera resource
    cap.release()
    print("Camera released.")
    

def playAudio():
    player = vlc.MediaPlayer("audio.mp3")
    player.play()
    time.sleep(5)  # Keep script alive


def sendNotification():
    token=refToken.get()
    # fcm_token = 'dgILY0LeTeuAHUYmJRityy:APA91bFtHza8ryBr5OACORUuqliaGCL5Rxt5oecRVMyyv9U4x7rlDTLh3p9jRLNhEFNNxbpPGKeUnBkJuQnPVPb3BPr7vQiPbklrE6lY-_9rNFzaocsWvMs' 
    fcm_token = token
    time.sleep(6)
    # Create the notification message
    message = messaging.Message(
        notification=messaging.Notification(
            title='Pet Feeder',
            body="Your pet hasn't come to eat!",
        ),
        token=fcm_token,
    )

    # Send the notification
    try:
        response = messaging.send(message)
        print('Notification sent successfully:', response)
    except Exception as e:
        print('Error sending notification:', e)


def listenerAudio(event):
    print(f'Event type: {event.event_type}')  # can be 'put', 'patch', or 'delete'
    print(f'Path: {event.path}')
    print(f'Value: {event.data}')
    
    # Check if event.data is a dictionary
    if(event.data!=1):
        return
    sendNotification()
    playAudio()

def listenerAudioNew(event):
    print(f'Event type: {event.event_type}')  # can be 'put', 'patch', or 'delete'
    print(f'Path: {event.path}')
    print(f'Value: {event.data}')
    
    # Check if event.data is a dictionary
    if(event.data!=1):
        return
    playAudio()

def listenerAudioNew(event):
    print(f'Event type: {event.event_type}')  # can be 'put', 'patch', or 'delete'
    print(f'Path: {event.path}')
    print(f'Value: {event.data}')
    
    # Check if event.data is a dictionary
    if(event.data!=1):
        return
    playAudio()

def listenerAlert(event):
    print(f'Event type: {event.event_type}')  # can be 'put', 'patch', or 'delete'
    print(f'Path: {event.path}')
    print(f'Value: {event.data}')
    
    # Check if event.data is a dictionary
    if(event.data!=1):
        return
    sendNotification()


# Set up listener to capture value changes
refDoor.listen(listener)
audioRef.listen(listenerAudio)
audioNewRef.listen(listenerAudioNew)
alertRef.listen(listenerAlert)