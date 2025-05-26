import time
import subprocess
from pyngrok import ngrok
from firebase_admin import credentials, db
import firebase_admin

cred = credentials.Certificate("./pet-feeder-94fe8-firebase-adminsdk-fbsvc-481d31b8f7.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://pet-feeder-94fe8-default-rtdb.firebaseio.com/'
})

ref = db.reference('stream')

def start_ngrok_flask():
    while True:  # Infinite loop to restart if an error occurs
        try:
            print("Starting ngrok...")
            public_url = ngrok.connect(addr="5000", proto="http", bind_tls=True)
            print(f"Ngrok URL: {public_url}")
            ref.set({"url": public_url.public_url})

            print("Starting Flask server...")
            flask_process = subprocess.Popen(["python", "stream.py"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            while True:
                time.sleep(3600)  # Keep running and update Firebase every hour

        except Exception as e:
            print(f"Error occurred: {e}. Restarting in 10 seconds...")
            time.sleep(10)  # Wait before restarting
        except KeyboardInterrupt:
            print("Stopping Flask and ngrok...")
            flask_process.terminate()
            ngrok.kill()
            break  # Exit loop if user manually stops the program

if __name__ == "__main__":
    start_ngrok_flask()


# from pyngrok import ngrok
# import subprocess
# import time
# from firebase_admin import credentials, db
# import firebase_admin

# cred = credentials.Certificate("./pet-feeder-6d546-firebase-adminsdk-fbsvc-d0f6a846ee.json")
# firebase_admin.initialize_app(cred, {
#     'databaseURL': 'https://pet-feeder-6d546-default-rtdb.firebaseio.com/'
# })

# ref = db.reference('stream')
# # Function to start ngrok and Flask server
# def start_ngrok_flask():
#     print("Starting ngrok and Flask server...")

#     # Start ngrok and get the public URL
#     print("Starting ngrok...")
#     try:
#         # Start ngrok on port 5000 (Flask's default port)
#         public_url = ngrok.connect(addr="5000", proto="http", bind_tls=True)
#         print(f"Ngrok URL: {public_url}")
#     except Exception as e:
#         print(f"Failed to start ngrok: {e}")
#         return None, None, None

#     # Start Flask server
#     print("Starting Flask server...")
#     try:
#         flask_process = subprocess.Popen(["python", "stream.py"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
#     except Exception as e:
#         print(f"Failed to start Flask server: {e}")
#         ngrok.kill()  # Stop ngrok if Flask fails to start
#         return None, None, None

#     print("Flask server and ngrok are up and running.")
#     return flask_process, public_url

# # Main function to run everything
# if __name__ == "__main__":
#     # Start ngrok and Flask
#     flask_process, public_url = start_ngrok_flask()

#     if public_url is not None:
#         try:
#             while True:
#                 # Continuously print the current ngrok URL
#                 print(f"Current ngrok URL: {public_url}")
#                 ngrok_url = public_url.public_url
#                 ref.set({"url":ngrok_url})
#                 # Wait for some time before checking again (e.g., every 5 seconds)
#                 time.sleep(3600)
            
#         except KeyboardInterrupt:
#             print("Stopping Flask and ngrok...")
#             # Terminate the Flask process and stop ngrok
#             flask_process.terminate()
#             ngrok.kill()