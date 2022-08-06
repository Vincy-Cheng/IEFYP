from flask import Flask, request, jsonify
from flask_ngrok import run_with_ngrok
import werkzeug
app = Flask(__name__)
run_with_ngrok(app)  # Start ngrok when app is run

@app.route('/upload', methods = ["POST"])
def upload():
    if(request.method == "POST"):
        imagefile = request.files['image']
        filename = werkzeug.utils.secure_filename(imagefile.filename)
        imagefile.save("./uploadedimages"+filename)
        return jsonify({
            "message":"Image Uploaded Sucessfully"
        })


if __name__ == "__main__":
    app.run()
