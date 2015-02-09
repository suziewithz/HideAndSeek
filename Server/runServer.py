from flask import Flask, request
from flaskext.mysql import MySQL
import random
import json

mysql = MySQL()
app = Flask(__name__)
app.config['MYSQL_DATABASE_USER'] = 'suz'
app.config['MYSQL_DATABASE_PASSWORD'] = 'suziewithz'
app.config['MYSQL_DATABASE_DB'] = 'hideandseek'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)

def fileIDGenerator():
	arr = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"]
	fileID = ""
	for i in range (0,16):
		fileID = fileID + random.choice(arr)
	return fileID

@app.route('/hide', methods=['GET','POST'])
def handleHide():
	reqJson = request.get_json(force=True)
	print reqJson
	print "xCoordinate: " + str(reqJson['xCoordinate'])
	xCoordinate = float(reqJson['xCoordinate'])
	yCoordinate = float(reqJson['yCoordinate'])
	key = str(reqJson['key'])
	password = str(reqJson['password'])

	print (xCoordinate, yCoordinate, key, password)

	checkFileIDQuery = "SELECT COUNT(fileID) from hideandseek WHERE fileid = '%s'"
	putDataQuery = "INSERT INTO hideandseek (fileID, xCoordinate, yCoordinate, encryptKey, password ) values ( '%s', %f , %f , '%s' , '%s' )"

	conn = mysql.connect()
	cursor = conn.cursor()

	while True:
		fileID = fileIDGenerator()
		print (checkFileIDQuery % (fileID))
		cursor.execute(checkFileIDQuery % (fileID))
		result = cursor.fetchone()[0]
		print result
		if ( result == 0) :
			print (putDataQuery % (fileID, xCoordinate, yCoordinate, key, password))
			cursor.execute(putDataQuery % (fileID, xCoordinate, yCoordinate, key, password))
			conn.commit()
			break
	return fileID

@app.route('/seek', methods=['GET','POST'])
def handleSeek():
	fileID = str(request.form['fileID'])
	current_xCoordinate = float(request.form['xCoordinate'])
	current_yCoordinate = float(request.form['yCoordinate'])
	pswd = str(request.form['password'])

	cursor = mysql.connect().cursor()
	verifyQuery = "SELECT xCoordinate, yCoordinate, password FROM hideandseek WHERE fileId = '%s'"
	findKeyQuery = "SELECT encryptKey FROM hideandseek WHERE fileID = '%s'"

	cursor.execute(verifyQuery, (fileID))
	result = cursor.fetchone()[0]

	if result is None :
		return "there are no file exist in database"
	for (xCoordinate, yCoordinate, password) in cursor :
		distance = (sqrt (xCoordinate - current_xCoordinate)**2 + (yCoordinate - current_yCoordinate)**2)
		print "distance: " + str(distance)
		if pswd == password :
			if distance < 0.0000001 :
				cursor.execute(fineKeyQuery, (fileID))
				return encryptKey in cursor
			else :
				return "wrong distance"
		else:
			return "wrong password"




if __name__ == '__main__':
	app.debug = True
	app.run(host='0.0.0.0')