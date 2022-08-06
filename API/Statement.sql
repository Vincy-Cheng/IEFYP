
CREATE TABLE patient (
	id INTEGER NOT NULL, 
	name VARCHAR(100) NOT NULL, 
	phone_num INTEGER NOT NULL, 
	salt VARCHAR NOT NULL,
	password VARCHAR NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE pill (
	id INTEGER NOT NULL, 
	name VARCHAR(100) NOT NULL, 
	color TEXT NOT NULL, 
	shape TEXT NOT NULL, 
	width TEXT NOT NULL, 
	height TEXT NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (name)
);

CREATE TABLE prescription (
	frequence TEXT NOT NULL, 
	qty TEXT NOT NULL, 
	patient_id INTEGER NOT NULL, 
	pill_id INTEGER NOT NULL, 
	FOREIGN KEY(patient_id) REFERENCES patient (id), 
	FOREIGN KEY(pill_id) REFERENCES pill (id),
	PRIMARY KEY(patient_id,pill_id)
);


CREATE TABLE admin (
	id INTEGER NOT NULL, 
	username VARCHAR(20) NOT NULL,
	salt VARCHAR NOT NULL,
	password VARCHAR NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (username)
);


CREATE TABLE admin (
	id INTEGER NOT NULL, 
	username VARCHAR(20) NOT NULL,
	salt VARCHAR NOT NULL,
	password VARCHAR NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (username)
);


CREATE TABLE user (
	id INTEGER NOT NULL, 
	username VARCHAR(20) NOT NULL,
	salt VARCHAR NOT NULL,
	password VARCHAR NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (username)
);