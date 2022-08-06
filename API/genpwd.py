from secrets import token_urlsafe


import hashlib
import hmac
key = token_urlsafe(32)
print(key)
pwd = "doctor"
hmac1 = hmac.new(key=key.encode(),msg=pwd.encode(),digestmod=hashlib.sha256)
print(hmac1.hexdigest())

# INSERT INTO admin (username,salt,password) VALUES("Vincy","T7mLNRRFYz7L5KS-pRPQPZdQQ790qER8BGYrpELcrws","afd6bbba1919098e8e63fd301e270383b0e1030c059a9159d9d9175b94435135");
# pwd: pass
# INSERT INTO admin (username,salt,password) VALUES("doctor","H_odShuQkkpoJ9g2mvFralcqp7SfF2LDCFqfBSF6k7Q","89be0ac0746943f0c7e6af5fa684a422c7ae7f7d2e558d5ae754749f97f9cac3");
# pwd: doctor
# Admin
# pwd: admin

# app
# Oldman : 123456
# Oldlady : 123456
# testing : 123456