from flask import Flask, Response
import cv2

app = Flask(__name__)

# Global variable to control the stream
isStop = False

def generate_frames():
    # Initialize the webcam
    camera = cv2.VideoCapture(0)  # Use 0 for the default webcam
    while True:
        # Capture frame-by-frame
        success, frame = camera.read()
        if not success:
            break
        else:
            # Encode frame as JPEG
            _, buffer = cv2.imencode('.jpg', frame)
            frame = buffer.tobytes()

            # Use generator to yield frames in byte format
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
        if isStop:
            camera.release()
            # Yield an empty frame or wait
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + b'\r\n')
            break  # Exit the loop to stop streaming

@app.route('/video')
def video_feed():
    # Return the streaming response
    return Response(generate_frames(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/start_stream')
def start_stream():
    global isStop
    isStop = False
    return "Stream started"

@app.route('/stop_stream')
def stop_stream():
    global isStop
    isStop = True
    return "Stream stopped"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)