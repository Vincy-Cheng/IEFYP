
# from crypt import methods
from datetime import timedelta
import email
from turtle import color, shape, title, width
from unicodedata import name
from flask import Flask, flash, request, jsonify, Response
from flask import Flask, render_template, url_for, redirect, session
from flask_ngrok import run_with_ngrok
import prettytable
from scipy.spatial import distance as dist
from collections import Counter
from imutils import perspective
from imutils import contours
import argparse
import numpy as np
import pandas as pd
import imutils
import cv2
import math
from sqlalchemy import null
import werkzeug
from prettytable import PrettyTable
from flask_sqlalchemy import SQLAlchemy
import sys
import hashlib
import hmac
import json


uploadedimage = ""


def midpoint(ptA, ptB):
    return ((ptA[0] + ptB[0]) * 0.5, (ptA[1] + ptB[1]) * 0.5)


index = ["color", "color_name", "hex", "R", "G", "B"]
csv = pd.read_csv('colors.csv', names=index, header=None)

r = g = b = 0


def getColorName(R, G, B):
    minimum = 10000
    for i in range(len(csv)):
        d = abs(R - int(csv.loc[i, "R"])) + abs(G -
                                                int(csv.loc[i, "G"])) + abs(B - int(csv.loc[i, "B"]))
        if(d <= minimum):
            minimum = d
            cname = csv.loc[i, "color_name"]
    return cname


def convertRGB(x, y, image):
    global b, g, r
    b, g, r = image[y, x]
    # print("BGR",b,g,r)
    b = int(b)
    g = int(g)
    r = int(r)


def averageRGB(a, image):
    B = 0
    G = 0
    R = 0
    global b, g, r
    for u in range(len(a)/2):
        # print("get coordinate: ",a[u][1],"//", a[u][0] )
        blue, green, red = image[int(a[u][1]), int(a[u][0])]
        # print("Exact RGB value of 4 points: ", red, " ", green, " ", blue)
        B += blue
        G += green
        R += red

    B = B//5
    G = G//5
    R = R//5

    b = int(B)
    g = int(G)
    r = int(R)

    # print("new RGB value: ", r, " ", g, " ", r)

def most_frequent(List):
    counter = 0
    num = List[0]

    for i in List:
        curr_frequency = List.count(i)
        if(curr_frequency> counter):
            counter = curr_frequency
            num = i
 
    return num


app = Flask(__name__)
# run_with_ngrok(app)  # Start ngrok when app is run
app.secret_key = "iergfyp"
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///site.db'
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.permanent_session_lifetime = timedelta(minutes=5)
db = SQLAlchemy(app)

# testing connection
# @app.route('/')
# def home():
#     # return "Testing connection !"
#     return render_template('index.html')


# class users(db.Model):
#     _id = db.Column("id", db.Integer, primary_key=True)
#     name = db.Column(db.String(100))
#     email = db.Column(db.String(100))

#     def __init__(self, name, email):
#         self.name = name
#         self.email = email


class Patient(db.Model):
    tablename = 'patient'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    phone_num = db.Column(db.Integer, nullable=False)
    salt = db.Column(db.String, nullable=False)
    password = db.Column(db.String, nullable=False)
    paitent_prescription = db.relationship("Prescription", backref="patient")

    def repr(self):
        return f"Patient('{self.id}')"


class Pill(db.Model):
    tablename = 'pill'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    color = db.Column(db.Text, nullable=False)
    shape = db.Column(db.Text, nullable=False)
    width = db.Column(db.Text, nullable=False)
    height = db.Column(db.Text, nullable=False)
    pill_prescription = db.relationship("Prescription", backref="pill")

    def repr(self):
        return f"Pill('{self.id}','{self.name}', '{self.color}', '{self.shape}', '{self.width}', '{self.height}')"


class Prescription(db.Model):
    tablename = 'prescription'

    frequence = db.Column(db.Text, nullable=False)
    qty = db.Column(db.Text, nullable=False)

    patient_id = db.Column(db.Integer, db.ForeignKey(
        'patient.id'), nullable=False)
    pill_id = db.Column(db.Integer, db.ForeignKey('pill.id'), nullable=False)
    __mapper_args__ = {
        'primary_key': [patient_id, pill_id]
    }

    def repr(self):
        return f"Prescription('{self.frequence}', '{self.qty}', '{self.patient_id}', '{self.pill_id}')"


class Admin(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(20), unique=True, nullable=False)
    salt = db.Column(db.String, nullable=False)
    password = db.Column(db.String, nullable=False)

    def repr(self):
        return f"Admin('{self.id}', '{self.username}', '{self.password}')"


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/login', methods=["POST", "GET"])
def login():
    print('login')
    print(request.method)
    if request.method == "POST":
        user = request.form["username"]
        user_pwd = request.form["password"]

        print('get-in')
        check_user = Admin.query.filter_by(
            username=user).first()
        if check_user:
            print('get-in')
            salt = check_user.salt
            hashed = hmac.new(key=salt.encode(),
                              msg=user_pwd.encode(), digestmod=hashlib.sha256)
            checkpwd = hashed.hexdigest()
            print(check_user)
            if checkpwd == check_user.password:
                found_user = check_user
                session.permanent = True
                print(found_user.username, found_user.password)
                session["user"] = found_user.username
                session["password"] = found_user.password
                flash("Logged in")
                if found_user.username == "Admin":
                    return redirect(url_for("admin"))
                else:
                    return redirect(url_for("patient"))
        else:
            print('else if')
            flash("Failed login")
            return redirect(url_for("login"))

    else:
        print('get-out')
        if "user" in session:
            if session["user"] == "admin":
                flash("Already Logged in")
                return redirect(url_for("admin"))
            else:
                return redirect(url_for("patient"))
        return render_template("login.html")


@app.route('/view')
def view():
    return render_template('view.html', values=Pill.query.all())


@app.route('/patient', methods=["POST", "GET"])
def patient():
    if "user" in session:
        if request.method == "POST":
            if len(request.form["frequency"])>0 and len(request.form["quan"]) >0:
                prescription = Prescription(
                    frequence=request.form["frequency"], qty=request.form["quan"], patient_id=request.form["uid"], pill_id=request.form["pid"])
                db.session.add(prescription)
                db.session.commit()
                flash("Prescription added")
            else:
                render_template('patient.html', patient=Patient.query.all(), pill=Pill.query.all())

        return render_template('patient.html', patient=Patient.query.all(), pill=Pill.query.all())
    else:
        return redirect(url_for("login"))


# @app.route('/login', methods=["POST", "GET"])
# def login():
#     if request.method == "POST":
#         session.permanent = True
#         user = request.form["nm"]
#         session["user"] = user
#         found_user = users.query.filter_by(name=user).first()
#         # for user in found_user:
#         #     user.delete()
#         if found_user:
#             session["email"] = found_user.email
#         else:
#             usr = users(user,"")
#             db.session.add(usr)
#             db.session.commit()
#         flash("Logged in")
#         return redirect(url_for("user"))
#     else:
#         if "user" in session:
#             flash("Already Logged in")
#             return redirect(url_for("user"))
#         return render_template("login.html")


# @app.route('/user', methods=["POST", "GET"])
# def user():
#     email = None
#     if "user" in session:
#         user = session["user"]

#         if request.method == "POST":
#             email = request.form["email"]
#             session["email"] = email
#             found_user = users.query.filter_by(name=user).first()
#             found_user.email = email
#             db.session.commit()
#             flash("Saved email")
#         else:
#             if "email" in session:
#                 email = session["email"]

#         return render_template("user.html", email=email)
#     else:
#         flash("Fail log in")
#         return redirect(url_for("login"))


@app.route('/logout')
def logout():
    if "user" in session:
        user = session["user"]
        flash(f"{user} have logged out", "info")
    session.pop("user", None)
    session.pop("user_pwd", None)
    return redirect(url_for("login"))


@app.route('/admin', methods=["POST", "GET"])
def admin():
    if "user" in session:
        if request.method == "POST":

            pillname = request.form["name"]
            pillcolor = request.form["color"]
            pillshape = request.form["shape"]
            pillwidth = request.form["width"]
            pillheight = request.form["height"]
            pill = Pill(name=pillname, color=pillcolor, shape=pillshape,
                        width=pillwidth, height=pillheight)
            db.session.add(pill)
            db.session.commit()
            flash("Saved pill")
            return redirect(url_for("view"))
        else:
            return render_template('admin.html')
    else:
        return redirect(url_for("login"))


@app.route('/getprescript', methods=["POST", "GET"])
def getprescript():
    
    print('login')
    print(request.method)
    if request.method == "POST":
        user = request.json["username"]
        user_pwd = request.json["password"]
        print("user:", user)
        print("pwd:", user_pwd)
        print('get-in')
        check_user = Patient.query.filter_by(
            name=user).first()
        if check_user:
            print('get-in2')
            salt = check_user.salt
            hashed = check_user.password
            #print(hashed)
            #print(check_user)
            if hashed == check_user.password:
                found_user = check_user
                print(found_user.name, found_user.password)
                flash("Logged in")
                pid = Patient.query.filter_by(name=found_user.name).first()
                if pid:
                    pre = Prescription.query.filter_by(patient_id=pid.id).all()
                    list = []
                    for row in pre:
                        pill_name = row.pill.name
                        print(pill_name)
                        list.append((
                            {
                                "frequence": row.frequence,
                                "pill_name":pill_name,
                                "pill_id": row.pill_id,
                                "pill_color": row.pill.color,
                                "pill_w": row.pill.width,
                                "pill_h":row.pill.height,
                                "pill_shape":row.pill.shape,
                                "qty": row.qty,
                                "patient_name": pid.name
                            }))
                    print("finish")
                    print(len(pre))
                    session.permanent = True
                    session["user"] = found_user.name
                    session["password"] = found_user.password
                    return jsonify(list)
                else:
                    print("no pid")
                    return redirect(url_for("login"))
            else:
                print('else if')
                flash("Failed login")
                return redirect(url_for("login"))

    else:
        print('get-out')
        if "user" in session:
            if session["user"] == "admin":
                flash("Already Logged in")
                return redirect(url_for("admin"))
            else:
                return redirect(url_for("patient"))
        return render_template("login.html")



# # testing how to query
# @app.route('/data')
# def data():
#     # here we want to get the value of user (i.e. ?user=some-value)

#     # the url = http://127.0.0.1:5000/data?user=12&name=ie
#     # it pass user = 12 && name = ie to server through the parmeter
#     user = request.args.get('user')
#     name = request.args.get('name')
#     s = "user="+ str(user) + "\nname = " + str(name)
#     return jsonify({
#         "user": user,
#         "name": name
#     },
#     {
#         "user": 24,
#         "name": "Json"
#     })


@app.route('/createpatient', methods=["POST"])
def createpatient():
    if(request.method == "POST"):
        pname = request.json["name"]
        PAphone_num = request.json["phone_num"]
        Psalt = request.json["salt"]
        pwd = request.json["password"]
        pat = Patient(name=pname, phone_num=PAphone_num,
                      salt=Psalt, password=pwd)
        db.session.add(pat)
        db.session.commit()
        return jsonify({
            "message": "Patient created Sucessfully"
        })


@app.route('/upload', methods=["POST"])
def upload():
    if(request.method == "POST"):
        imagefile = request.files['image']
        filename = werkzeug.utils.secure_filename(imagefile.filename)
        # python color2.py --image image/pillblack.jpg --width 0.98

        global uploadedimage
        uploadedimage = "images/"+filename
        imagefile.save("./images/"+filename)
        return jsonify({
            "message": "Image Uploaded Sucessfully"
        })


@app.route('/api', methods=['GET'])
def returnascii():

    myTable = PrettyTable(["Pills", "Width", "Height", "Shape", "Color"])
    table = []
    count = 0
    resized = cv2.imread(uploadedimage)
    scaledper = 15
    width = int(resized.shape[1]*scaledper/100)
    height = int(resized.shape[0]*scaledper/100)
    dim = (width, height)
    if resized.shape[1] > 1000:
        image = cv2.resize(resized, dim, interpolation=cv2.INTER_AREA)
    else:
        image = cv2.imread(uploadedimage)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray, (7, 7), 0)

    thresh = cv2.threshold(gray, 45, 255, cv2.THRESH_BINARY)[1]
    thresh = cv2.erode(thresh, None, iterations=2)
    thresh = cv2.dilate(thresh, None, iterations=2)

    cntss = cv2.findContours(
        thresh.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cntss = imutils.grab_contours(cntss)
    cc = max(cntss, key=cv2.contourArea)

    edged = cv2.Canny(gray, 50, 100)
    edged = cv2.dilate(edged, None, iterations=1)
    edged = cv2.erode(edged, None, iterations=1)

    cnts = cv2.findContours(edged, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cnts = imutils.grab_contours(cnts)

    (cnts, _) = contours.sort_contours(cnts)
    pixelPerMetric = None

    for c in cnts:
        if cv2.contourArea(c) < 100:
            continue
        count += 1

        orig = image.copy()
        box = cv2.minAreaRect(c)
        box = cv2.cv.BoxPoints(box) if imutils.is_cv2() else cv2.boxPoints(box)
        box = np.array(box, dtype="int")
        box = perspective.order_points(box)

        (tl, tr, br, bl) = box
        (tltrX, tltrY) = midpoint(tl, tr)
        (blbrX, blbrY) = midpoint(bl, br)
        (tlblX, tlblY) = midpoint(tl, bl)
        (trbrX, trbrY) = midpoint(tr, br)

        dA = dist.euclidean((tltrX, tltrY), (blbrX, blbrY))
        dB = dist.euclidean((tlblX, tlblY), (trbrX, trbrY))
        if pixelPerMetric == None:
            pixelPerMetric = dB / 0.984

        dimA = dA / pixelPerMetric
        dimB = dB / pixelPerMetric

        orig1 = image.copy()
        c1 = max(c, key=cv2.contourArea)

        extLeft = tuple(c[c[:, :, 0].argmin()][0])
        extRight = tuple(c[c[:, :, 0].argmax()][0])
        extTop = tuple(c[c[:, :, 1].argmin()][0])
        extBot = tuple(c[c[:, :, 1].argmax()][0])

        approx = cv2.approxPolyDP(c, 0.01*cv2.arcLength(c, True), True)
        x = approx.ravel()[0]
        y = approx.ravel()[1]

        # mid point of the contour
        (mx, my) = midpoint(midpoint(bl, br), midpoint(tl, tr))

        RGBarray = []

        (tlX, tlY) = tl
        (trX, trY) = tr
        (blX, blY) = bl

        tlX_trX = (trX - tlX)/15
        tlY_trY = (trY - tlY)/15

        tlX_blX = (blX - tlX)/15
        tlY_blY = (blY - tlY)/15

        #color get more point
        for tl_bl in range(1, 15, 1):
            
            check_X = tlX + tl_bl * tlX_blX
            check_Y = tlY + tl_bl * tlY_blY
            for tl_tr in range(1, 15, 1):
                now = ((check_X + (tl_tr * tlX_trX)), (check_Y + (tl_tr * tlY_trY)))
                if cv2.pointPolygonTest(c, now, False) == 1:
                    RGBarray.append(((check_X + (tl_tr * tlX_trX)), (check_Y + (tl_tr * tlY_trY))))

        color_list = []
        for point in RGBarray:
            convertRGB(int(point[0]), int(point[1]), image)

            text = getColorName(r, g, b) # + ' R=' + str(r) + ' G=' + str(g) + ' B=' + str(b)
            color_list.append(text)
            #print(text)

        one_color_list = Counter(color_list)
        print(one_color_list)


        majority_color = most_frequent(color_list)
        print("Color: ", majority_color)

        (melx, mely) = midpoint((mx, my), extLeft)
        (merx, mery) = midpoint((mx, my), extRight)
        (metx, mety) = midpoint((mx, my), extTop)
        (mebx, meby) = midpoint((mx, my), extBot)

        RGBarray.append((mx, my))
        RGBarray.append((melx, mely))
        RGBarray.append((merx, mery))
        RGBarray.append((metx, mety))
        RGBarray.append((mebx, meby))

        if (abs(dimB - dimA) < 0.06):  # circle, square, triangle

            distance_mid_extreme1 = math.dist((mx, my), extLeft)
            distance_mid_extreme2 = math.dist((mx, my), extRight)
            distance_mid_extreme3 = math.dist((mx, my), extTop)
            distance_mid_extreme4 = math.dist((mx, my), extBot)

            if (abs(distance_mid_extreme1 - distance_mid_extreme2) > 1 or abs(distance_mid_extreme3 - distance_mid_extreme2) > 1 or abs(distance_mid_extreme4 - distance_mid_extreme2) > 1):
                itsshape = "Triangle"
            else:
                c_similarity = abs(math.pi*(dB/2)*(dB/2) -
                                   cv2.contourArea(c))  # circle

                if c_similarity < 0:
                    c_similarity = 0 - c_similarity

                s_similarity = abs(dB*dB - cv2.contourArea(c))  # square

                if s_similarity < 0:
                    s_similarity = 0 - s_similarity

                best_similarity = min(c_similarity, s_similarity)

                if best_similarity == c_similarity:
                    itsshape = "Circle"

                else:
                    itsshape = "Square"

        else:
            # if dA>dB:
            #     radi = dB
            # else:
            #     radi = dA
            # sc_similarity = abs(math.pi*(radi/2)*(radi/2)/2 - cv2.contourArea(c))
            # #semi-circle shape
            # if sc_similarity < 0:
            #         sc_similarity = 0 - sc_similarity
            # r_similarity = abs(dB*dB - cv2.contourArea(c))
            # if r_similarity < 0:
            #         r_similarity = 0 - r_similarity
            # bestSCR_similarity = min(sc_similarity, r_similarity)
            # if bestSCR_similarity == sc_similarity:
            #     itsshape = "Semi-Circle"
            # else:
            #     itsshape = "Rectangle"
            itsshape = "Rectangle"

        convertRGB(int(mx), int(my), image)
        #averageRGB(RGBarray, image)
        # + ' R=' + str(r) + ' G=' + str(g) + ' B=' + str(b)
        #text = getColorName(r, g, b)
        if round(dimA, 3) >= round(dimB, 3):
            table.append({
                "count":count,
                "width":round(dimB, 3),
                "height": round(dimA, 3),
                "shape": itsshape,
                "color":majority_color
            })
            #myTable.add_row(
            #[count, round(dimB, 3), round(dimA, 3), itsshape, majority_color])
        else:
            table.append({
                "count":count,
                "width":round(dimA, 3),
                "height": round(dimB, 3),
                "shape": itsshape,
                "color":majority_color
            })
            #myTable.add_row(
            #[count, round(dimA, 3), round(dimB, 3), itsshape, majority_color])

    d = {}
    # inputchr = str(request.args['query'])
    answer = str(myTable)  # str(inputchr)
    d['output'] = answer  # .split("\n")
    return jsonify(table)


if __name__ == "__main__":
    db.create_all()
    app.run(debug=True)

# {{url_for('admin')}}


# ngrok http --region=us --hostname=iefyp.ngrok.io 5000