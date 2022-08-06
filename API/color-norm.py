from scipy.spatial import distance as dist
from imutils import perspective
from imutils import contours
import argparse
import numpy as np
import pandas as pd
import imutils
import cv2
import math
from matplotlib import pyplot as plt
from collections import Counter
from PIL import Image

font = cv2.FONT_HERSHEY_COMPLEX


def midpoint(ptA, ptB):
    return ((ptA[0] + ptB[0]) * 0.5, (ptA[1] + ptB[1]) * 0.5)


def show_image(title, image, destroy_all=True):
    cv2.imshow(title, image)
    cv2.waitKey(0)
    if destroy_all:
        cv2.destroyAllWindows()


index = ["color", "color_name", "hex", "R", "G", "B"]
csv = pd.read_csv('color-norm.csv', names=index, header=None)

# function to calculate minimum distance from all colors and get the most matching color

r = g = b = 0


def getColorName(R, G, B):
    minimum = 10000
    for i in range(len(csv)):
        d = abs(R - int(csv.loc[i, "R"])) + abs(G -int(csv.loc[i, "G"])) + abs(B - int(csv.loc[i, "B"]))
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

def convertScale(img, alpha, beta):
    new_img = img * alpha + beta
    new_img[new_img < 0] = 0
    new_img[new_img > 255] = 255
    return new_img.astype(np.uint8)

def most_frequent(List):
    counter = 0
    num = List[0]
     
    for i in List:
        curr_frequency = List.count(i)
        if(curr_frequency> counter):
            counter = curr_frequency
            num = i
 
    return num

# Automatic brightness and contrast optimization with optional histogram clipping
def automatic_brightness_and_contrast(image, clip_hist_percent=25):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Calculate grayscale histogram
    hist = cv2.calcHist([gray],[0],None,[256],[0,256])
    hist_size = len(hist)

    # Calculate cumulative distribution from the histogram
    accumulator = []
    accumulator.append(float(hist[0]))
    for index in range(1, hist_size):
        accumulator.append(accumulator[index -1] + float(hist[index]))

    # Locate points to clip
    maximum = accumulator[-1]
    clip_hist_percent *= (maximum/100.0)
    clip_hist_percent /= 2.0

    # Locate left cut
    minimum_gray = 0
    while accumulator[minimum_gray] < clip_hist_percent:
        minimum_gray += 1

    # Locate right cut
    maximum_gray = hist_size -1
    while accumulator[maximum_gray] >= (maximum - clip_hist_percent):
        maximum_gray -= 1

    # Calculate alpha and beta values
    alpha = 255 / (maximum_gray - minimum_gray)
    beta = -minimum_gray * alpha

    new_hist = cv2.calcHist([gray],[0],None,[256],[minimum_gray,maximum_gray])
    plt.plot(hist)
    plt.plot(new_hist)
    plt.xlim([0,256])
    plt.show()

    auto_result = convertScale(image, alpha=alpha, beta=beta)
    return (auto_result, alpha, beta)

def img_estim(img, thrshld):
    is_light = np.mean(img) > thrshld
    return 'light' if is_light else 'dark'

# failed transparent image -> check transparent_image.png / New.png
def convertImage(image):
    # img = image
    
    img = Image.fromarray(image)
    # im.save("your_file.jpeg")
    img = img.convert("RGBA")
  
    datas = img.getdata()
  
    newData = []
  
    for item in datas:
        if item[0] == 255 and item[1] == 255 and item[2] == 255:
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)
  
    img.putdata(newData)
    img.save("./transparent_image.png", "PNG")
    # show_image('transparent_imgage', img)
    
    print("Successful")


ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required=True, help="path to the input image")
ap.add_argument("-w", "--width", type=float, required=True,
                help="width of the left-most object in the image (in inches)")
args = vars(ap.parse_args())

#image = cv2.imread(args["image"])

resized = cv2.imread(args["image"])
scaledper = 20
width = int(resized.shape[1]*scaledper/100)
height = int(resized.shape[0]*scaledper/100)
dim = (width, height)
if resized.shape[1] > 1000:
    image = cv2.resize(resized, dim, interpolation=cv2.INTER_AREA)
else:
    image = cv2.imread(args["image"])

original_image = image

gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
gray = cv2.GaussianBlur(gray, (7, 7), 0)
#show_image("GuassianBlur", gray, True)


edged = cv2.Canny(gray, 50, 100)
#show_image("Edged", edged, False)
edged = cv2.dilate(edged, None, iterations=1)
edged = cv2.erode(edged, None, iterations=1)
show_image("erode and dilate", edged, True)

cnts = cv2.findContours(edged, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
cnts = imutils.grab_contours(cnts)

(cnts, _) = contours.sort_contours(cnts)
pixelPerMetric = None


# new_image = np.zeros(image.shape, image.dtype)
# alpha = 1.0 # Simple contrast control
# beta = 0    # Simple brightness control
# # Initialize values
# print(' Basic Linear Transforms ')
# print('-------------------------')
# try:
#     alpha = float(input('* Enter the alpha value [1.0-3.0]: '))
#     beta = int(input('* Enter the beta value [0-100]: '))
# except ValueError:
#     print('Error, not a number')
# for y in range(image.shape[0]):
#     for x in range(image.shape[1]):
#         for c in range(image.shape[2]):
#             new_image[y,x,c] = np.clip(alpha*image[y,x,c] + beta, 0, 255)
# show_image('Original Image', image)
# show_image('New Image', new_image)



# copy_img = original_image
# gray= cv2.cvtColor(copy_img,cv2.COLOR_BGR2GRAY)
# edges= cv2.Canny(gray, 50,200)
# contours, hierarchy= cv2.findContours(edges.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
# sorted_contours= sorted(contours, key=cv2.contourArea, reverse= True)

# for (i,c) in enumerate(sorted_contours):
#     x,y,w,h= cv2.boundingRect(c)
    
#     cropped_contour= original_image[y:y+h, x:x+w]
#     image_name= "output_shape_number_" + str(i+1) + ".jpg"
#     cv2.imwrite(image_name, cropped_contour)
#     readimage= cv2.imread(image_name)
#     cv2.imshow('Image', readimage)
#     cv2.waitKey(0)

# cv2.destroyAllWindows()

#convertImage(original_image)

# load image as grayscale
gray = cv2.cvtColor(original_image, cv2.COLOR_BGR2GRAY)

# threshold input image using otsu thresholding as mask and refine with morphology
ret, mask = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU) 
kernel = np.ones((9,9), np.uint8)
mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)

# put mask into alpha channel of result
result = original_image.copy()
result = cv2.cvtColor(result, cv2.COLOR_BGR2BGRA)
result[:, :, 3] = mask


# save resulting masked image
cv2.imwrite('new_masked.png', result)




auto_result, alpha, beta = automatic_brightness_and_contrast(image)
print('alpha', alpha)
print('beta', beta)
cv2.imshow('auto_result', auto_result)
cv2.imwrite('auto_result.png', auto_result)
# cv2.imshow('result', result)
# cv2.imshow('original',original_image)
*_, alpha = cv2.split(result)
gray_layer = cv2.cvtColor(result, cv2.COLOR_BGR2GRAY)
dst = cv2.merge((gray_layer, gray_layer, gray_layer, alpha))
cv2.imwrite("result.png", dst)
cv2.imshow("rr",dst)
cv2.imshow('image', image)
cv2.waitKey()

#check brightness
print(img_estim(result, 127))

count = 0
for c in cnts:
    if cv2.contourArea(c) < 100:
        continue
    count += 1

    orig = image.copy()
    box = cv2.minAreaRect(c)
    box = cv2.cv.BoxPoints(box) if imutils.is_cv2() else cv2.boxPoints(box)
    box = np.array(box, dtype="int")
    box = perspective.order_points(box)
    cv2.drawContours(orig, [box.astype("int")], -1, (0, 255, 0), 2)

    for (x, y) in box:
        cv2.circle(orig, (int(x), int(y)), 5, (0, 0, 255), -1)

    (tl, tr, br, bl) = box
    (tltrX, tltrY) = midpoint(tl, tr)
    (blbrX, blbrY) = midpoint(bl, br)
    (tlblX, tlblY) = midpoint(tl, bl)
    (trbrX, trbrY) = midpoint(tr, br)

    cv2.circle(orig, (int(tltrX), int(tltrY)), 5, (255, 0, 0), -1)
    cv2.circle(orig, (int(blbrX), int(blbrY)), 5, (255, 0, 0), -1)
    cv2.circle(orig, (int(tlblX), int(tlblY)), 5, (255, 0, 0), -1)
    cv2.circle(orig, (int(trbrX), int(trbrY)), 5, (255, 0, 0), -1)

    cv2.line(orig, (int(tltrX), int(tltrY)),
             (int(blbrX), int(blbrY)), (255, 0, 255), 2)
    cv2.line(orig, (int(tlblX), int(tlblY)),
             (int(trbrX), int(trbrY)), (255, 0, 255), 2)

    dA = dist.euclidean((tltrX, tltrY), (blbrX, blbrY))
    dB = dist.euclidean((tlblX, tlblY), (trbrX, trbrY))

    if pixelPerMetric is None:
        pixelPerMetric = dB / args["width"]

    dimA = dA / pixelPerMetric
    dimB = dB / pixelPerMetric

    ##################
    # extreme point
    orig1 = image.copy()
    c1 = max(c, key=cv2.contourArea)

    # determine the most extreme points along the contour
    extLeft = tuple(c[c[:, :, 0].argmin()][0])
    extRight = tuple(c[c[:, :, 0].argmax()][0])
    extTop = tuple(c[c[:, :, 1].argmin()][0])
    extBot = tuple(c[c[:, :, 1].argmax()][0])

    # draw the outline of the object, then draw each of the
    # extreme points, where the left-most is red, right-most
    # is green, top-most is blue, and bottom-most is teal
    cv2.drawContours(orig, [c], -1, (0, 255, 255), 2)
    cv2.circle(orig, extLeft, 8, (0, 0, 255), -1)
    cv2.circle(orig, extRight, 8, (0, 255, 0), -1)
    cv2.circle(orig, extTop, 8, (255, 0, 0), -1)
    cv2.circle(orig, extBot, 8, (255, 255, 0), -1)

    # show the output image
    cv2.imshow("Image", orig1)

    ####################
    ####################

    cv2.putText(orig, "{:.2f}in".format(dimA), (int(
        tltrX - 15), int(tltrY - 10)), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
    cv2.putText(orig, "{:.2f}in".format(dimB), (int(
        trbrX + 10), int(trbrY)), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
    print("Dimension:", round(dimA,3), " x ", round(dimB,3))

    # below is shape detection
    approx = cv2.approxPolyDP(c, 0.01*cv2.arcLength(c, True), True)
    cv2.drawContours(image, [approx], 0, (0), 5)
    x = approx.ravel()[0]
    y = approx.ravel()[1]

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

    # (melx, mely) = midpoint((mx, my), extLeft)
    # (merx, mery) = midpoint((mx, my), extRight)
    # (metx, mety) = midpoint((mx, my), extTop)
    # (mebx, meby) = midpoint((mx, my), extBot)

    # RGBarray.append((mx, my))
    # RGBarray.append((melx, mely))
    # RGBarray.append((merx, mery))
    # RGBarray.append((metx, mety))
    # RGBarray.append((mebx, meby))

    if (abs(dimB - dimA) < 0.06):  # circle, square, triangle
        
        distance_mid_extreme1 = math.dist((mx, my), extLeft)
        distance_mid_extreme2 = math.dist((mx, my), extRight)
        distance_mid_extreme3 = math.dist((mx, my), extTop)
        distance_mid_extreme4 = math.dist((mx, my), extBot)

        if (abs(distance_mid_extreme1 - distance_mid_extreme2) > 4 or abs(distance_mid_extreme3 - distance_mid_extreme2) > 4 or abs(distance_mid_extreme4 - distance_mid_extreme2) > 4):
            cv2.putText(image, "Triangle", (x, y), font, 0.5, (255, 255, 255))
            print("Shape: Triangle")
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
                cv2.putText(image, "Circle", (x, y), font, 0.5, (255, 255, 255))
                print("Shape: Circle")

            else:
                cv2.putText(image, "Square", (x, y), font, 0.5, (255, 255, 255))
                print("Shape: Square")

    else:  # rectangle, oval
        if math.pi*(dA/2)*(dB/2) >= cv2.contourArea(c): #oval area
            cv2.putText(image, "Oval", (x, y), font, 0.5, (255, 255, 255))
            print("Shape: Oval")
        else:
            cv2.putText(image, "Rectangle", (x, y), font, 0.5, (255, 255, 255))
            print("Shape: Rectangle")
    #convertRGB(int(mx), int(my))

    # text = getColorName(r, g, b) + ' R=' + str(r) + ' G=' + str(g) + ' B=' + str(b)
    # print("Color: ", text)

    cv2.imshow("Image", orig)
    cv2.waitKey(0)


print("Total contours processed: ", count)