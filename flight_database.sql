
--Create a table for data on staff.
CREATE TABLE Medarbetare
(AnstNr CHAR(2) NOT NULL,
Förstnamn VARCHAR(35),
Efternamn VARCHAR(35),
Yrkesgrupp VARCHAR(20),
Flygtimmar INTEGER,
PRIMARY KEY(AnstNr)
);

--Create a table for information on staff education/skills.
CREATE TABLE Utbildning
(AnstNr CHAR(2) NOT NULL,
Modell1 VARCHAR(50),
Modell2 VARCHAR(50) DEFAULT NULL,
Modell3 VARCHAR(50) DEFAULT NULL,
Modell4 VARCHAR(50) DEFAULT NULL,
PRIMARY KEY(AnstNr),
FOREIGN KEY(AnstNr) 
REFERENCES Medarbetare(AnstNr)
ON DELETE CASCADE
);

--Create a table for airplane information like name, model, and number of seats.
CREATE TABLE Flygplan
(ID INTEGER IDENTITY(1,1) NOT NULL,
FlygpNamn VARCHAR(35),
ModellNamn VARCHAR(50) NOT NULL,
Sittplatser INTEGER,
PRIMARY KEY(ID),
);

--Create a table for flight information.
CREATE TABLE Flight
(ID CHAR(10) NOT NULL,
FlightNr VARCHAR(10),
AvgDat DATE,
AvgTid TIME,
AnkTid TIME,
AvgOrt VARCHAR(35),
Destination VARCHAR(35),
PRIMARY KEY(ID),
CONSTRAINT DatumCheck CHECK(GETDATE() <= DATEADD(MONTH, 6, GETDATE()))
);

--Create a table for who is working which flights.
CREATE TABLE Jobbar
(ID INTEGER IDENTITY(1,1) NOT NULL,
FlightID CHAR(10) NOT NULL,
AnstNr CHAR(2) NOT NULL,
Uppgift VARCHAR(10) NOT NULL,
PRIMARY KEY(ID),
FOREIGN KEY(AnstNr) 
REFERENCES Medarbetare(AnstNr)
ON DELETE CASCADE,
FOREIGN KEY(FlightID) 
REFERENCES Flight(ID)
ON DELETE CASCADE,
CONSTRAINT MedUppgift CHECK (Uppgift IN
                     ('Pilot1','Pilot2','Pilot3',
					 'Flv1','Flv2','Flv3','Flv4','Annat'))
);

--Create a table for passengers.
CREATE TABLE Passagerare
(ID INTEGER IDENTITY(1,1) NOT NULL,
Förstnamn VARCHAR(35),
Efternamn VARCHAR(35),
Typ VARCHAR(6),
Passning VARCHAR(3) DEFAULT 'Nej',
PassnBeskriv VARCHAR(100),
PRIMARY KEY(ID),
CONSTRAINT TypPassag CHECK(Typ IN('Man','Kvinna','Barn')),
CONSTRAINT Pass CHECK(Passning IN('Ja','Nej'))
);

--Create a table for payment information.
CREATE TABLE Betalningar
(TransaktionsNr INTEGER IDENTITY(1,1) NOT NULL,
FlightID CHAR(10),
PassagerareID INTEGER,
Prisklass VARCHAR(25),
Pris INTEGER,
PRIMARY KEY(TransaktionsNr),
FOREIGN KEY(FlightID)
REFERENCES Flight(ID)
ON DELETE SET NULL,
FOREIGN KEY(PassagerareID)
REFERENCES Passagerare(ID)
ON DELETE SET NULL,
CONSTRAINT PKlass CHECK(Prisklass IN('Återbetalningsbar','Ombokningsbar','Rött'))
);



--Here are two triggers. They need to be the first statement in a query,
--but I included them here for easy reading.

/*
CREATE TRIGGER PilotMin
ON Jobbar
AFTER INSERT
AS
BEGIN
DECLARE @MedAnst CHAR(10);
DECLARE @JobbFlightID CHAR(10);
DECLARE @Roll VARCHAR(10);
DECLARE @Pilot2 VARCHAR(10);
SELECT @MedAnst = AnstNr FROM Medarbetare;
SELECT @JobbFlightID = FlightID FROM Jobbar;
SELECT @Roll = Uppgift FROM INSERTED;
SELECT @Pilot2 = Uppgift FROM Jobbar;
IF @Roll = '1Pilot'
PRINT 'Kom ihåg att varje flight behöver minst två piloter!'
END

CREATE TRIGGER PassningMax
ON Flight
AFTER INSERT
AS
BEGIN
DECLARE @Passning VARCHAR(200);
DECLARE @FlightIDBetal CHAR(10); 
DECLARE @FlightID CHAR(10);
DECLARE @Count INTEGER;
SELECT @Passning = Passning FROM Passagerare;
SELECT @FlightIDBetal = FlightID FROM Betalningar;
SELECT @FlightID = ID FROM INSERTED;
IF @Passning = 'Ja'
SELECT @Count = COUNT(@Passning IN (SELECT * FROM Flight WHERE @FlightID = @FlightIDBetal));
IF @Count > 5 
PRINT 'Antalet passagerare med passning får inte överstiga 5 på en flight.'
ROLLBACK TRANSACTION
END
*/



--And here is some fake data to insert into the tables.

/*
INSERT INTO Flight 
VALUES ('1000000001', 'LK202', '20130801', '1055', '1155', 'Stockholm', 'Umeå'),
('1000000002', 'SK405', '20130801', '2000', '2205', 'Göteborg', 'Helsingfors'),
('1000000003', 'VR111', '20130801', '1740',	'1150', 'Zürich', 'Rio de Janeiro'),
('1000000004', 'LF550', '20130802', '0850', '0955', 'Köpenhamn', 'Frankfurt'),
('1000000005', 'BA801', '20130801', '1815', '1855', 'Paris', 'London'),
('1000000006', 'AF330', '20130801', '1325', '1410', 'Paris', 'London');


INSERT INTO Medarbetare
VALUES('J1', 'Jet', 'Rågen', 'Flygvärd', 740),
('B1', 'Bibbi', 'Nelson', 'Flygvärd', 80),
('V1', 'Vera', 'Hensel', 'Flygvärd', 390),
('C1', 'Charlie', 'Channing', 'Flygvärd', 495),
('Z1', 'Zebra', 'Wollter', 'Flygvärd', 100),
('A1', 'Agnes', 'Ungert', 'Flygvärd', 1200),
('T1', 'Tennessee', 'Magden', 'Flygvärd',	910),
('E1', 'Eija', 'Merinen', 'Flygvärd', 800),
('U1', 'Ulrika', 'Wales', 'Flygvärd', 200),
('A3', 'Alvar', 'Ihanen', 'Flygvärd', 800),
('L2', 'Lara', 'Esten', 'Flygvärd', 500),
('T2', 'Terese', 'Norman', 'Flygvärd', 600),
('T3', 'Torstein', 'Mattsen', 'Flygvärd', 400),
('V3', 'Vanja', 'Ivanova', 'Flygvärd', 1700),
('E2', 'Emil', 'Urban', 'Flygvärd', 1500),
('T4', 'Tova', 'Svensson', 'Flygvärd', 200),
('A5', 'Amanda', 'Bunkert', 'Flygvärd', 330),
('N1', 'Neil', 'Nelson', 'Pilot', 2900),
('L1', 'Larry', 'Hegetay', 'Pilot', 3400),
('G1', 'Gork', 'Getaway', 'Pilot', 2670),
('A2', 'Amanda', 'Jonsson', 'Pilot', 3100),
('N2', 'Neil', 'Boston', 'Pilot', 2125),
('M1', 'Mary', 'Alstedt', 'Pilot', 1000),
('J2', 'Jouko', 'Uusitalo', 'Pilot', 1200),
('A4', 'Abraham', 'Omar', 'Pilot', 4000),
('V2', 'Vassil', 'Papadimitr', 'Pilot', 1200),
('U2', 'Ugi', 'Abbas', 'Pilot', 4000),
('M2', 'Michelle', 'Easter', 'Pilot', 300),
('M3', 'Mohammed', 'Ebb', 'Pilot', 400);

INSERT INTO Jobbar
VALUES('1000000001', 'G1', 'Pilot1'),
('1000000001', 'N2', 'Pilot2'),
('1000000001', 'V1', 'Flv1'),
('1000000001', 'B1', 'Flv2'),
('1000000004', 'L1', 'Pilot1'),
('1000000004', 'A2', 'Pilot2'),
('1000000004', 'Z1', 'Flv1'),
('1000000004', 'U1', 'Flv2'),
('1000000002', 'M1', 'Pilot1'),
('1000000002', 'J2', 'Pilot2'),
('1000000002', 'E1', 'Flv1'),
('1000000002', 'A3', 'Flv2'),
('1000000003', 'N1', 'Pilot1'),
('1000000003', 'A4', 'Pilot2'),
('1000000003', 'J1', 'Flv1'),
('1000000003', 'A1', 'Flv2'),
('1000000003', 'T1', 'Flv3'),
('1000000003', 'L2', 'Flv4'),
('1000000005', 'V2', 'Pilot1'),
('1000000005', 'U2', 'Pilot2'),
('1000000005', 'C1', 'Flv1'),
('1000000005', 'T2', 'Flv2'),
('1000000005', 'T3', 'Flv3'),
('1000000006', 'M2', 'Pilot1'),
('1000000006', 'M3', 'Pilot2'),
('1000000006', 'V3', 'Flv1'),
('1000000006', 'E2', 'Flv2'),
('1000000004', 'G1', 'Pilot1'),
('1000000004', 'A4', 'Pilot2'),
('1000000004', 'T1', 'Flv1'),
('1000000004', 'J1', 'Flv2');

INSERT INTO Flygplan
VALUES('Zeus', 'Boeing 747', 250),
('Hera', 'Airbus A320', 220),
('Poseidon', 'Boeing 737', 110),
('Ares', 'MD-81', 141),
('Afrodite', 'Fokker 100', 100),
('Pallas-Athena', 'Avro RJ85', 82),
('Hades', 'Avro RJ85', 82);


INSERT INTO Utbildning
VALUES('A1', 'Boeing 747', 'Avro RJ85', 'Boeing 737', NULL),
('A2', 'Boeing 737', 'Airbus A320', 'Avro RJ85', NULL),
('A3', 'Fokker 100', 'Airbus A320', NULL, NULL),
('A4', 'Boeing 747', NULL, NULL, NULL),
('A5', 'MD-81', 'Boeing 737', NULL, NULL),
('B1', 'MD-81', 'Avro RJ85', NULL, NULL),
('C1', 'Airbus A320', 'Boeing 737', NULL, NULL),
('E1', 'Fokker 100', 'Boeing 747', 'Avro RJ85', NULL),
('E2', 'Airbus A320', 'Boeing 747', NULL, NULL),
('G1', 'Boeing 747', 'MD-81', 'Avro RJ85', NULL),
('J1', 'Boeing 747', 'Airbus A320', NULL, NULL),
('J2', 'Fokker 100', 'Avro RJ85', NULL, NULL),
('L1', 'Boeing 737', 'Airbus A320', 'MD-81', NULL),
('L2', 'Boeing 747', 'Avro RJ85', NULL, NULL),
('M1', 'Fokker 100', NULL, NULL, NULL),
('M2', 'Airbus A320', NULL, NULL, NULL),
('M3', 'Airbus A320', NULL, NULL, NULL),
('N1', 'Boeing 747', 'Avro RJ85', NULL, NULL),
('N2', 'Airbus A320', 'Boeing 747', 'Avro RJ85', NULL),
('T1', 'Boeing 747', 'Boeing 737', NULL, NULL),
('T2', 'Avro RJ85', 'Boeing 737', NULL, NULL),
('T3', 'Boeing 737', NULL, NULL, NULL),
('T4', 'MD-81', 'Boeing 737', NULL, NULL),
('U1', 'MD-81', NULL, NULL, NULL),
('U2', 'Boeing 737', 'Airbus 747', NULL, NULL),
('V1', 'Avro RJ85', NULL, NULL, NULL),
('V2', 'Boeing 737', 'Boeing 747', NULL, NULL),
('V3', 'Airbus A320', 'Boeing 737', NULL, NULL),
('Z1', 'MD-81', 'Boeing 737', NULL, NULL);


INSERT INTO Passagerare
VALUES('Marty', 'Feldman', 'Man', 'Nej', NULL),
('Jens', 'Christiansen', 'Man', 'Ja', NULL),
('Martii',	'Turunen', 'Barn', 'Nej', NULL),
('Heino', 'Turunen', 'Man', 'Nej', NULL),
('Regine', 'Fairchild', 'Kvinna', 'Ja', NULL),
('Tina', 'Gottlieb', 'Barn', 'Ja', NULL),
('Måns', 'Uman', 'Man', 'Nej', NULL),
('Collette', 'Ronnan', 'Kvinna', 'Nej', NULL),
('Mary', 'Ottosson', 'Kvinna', 'Nej', NULL),
('Panu', 'Onninen', 'Barn', 'Ja', NULL),
('Gary', 'Eastman', 'Man', 'Nej', NULL),
('Lorry', 'Argunt', 'Kvinna', 'Ja', NULL),
('Jesper', 'Tuborg', 'Man', 'Ja', NULL),
('Toyota', 'Corolla', 'Kvinna', 'Nej', NULL);


INSERT INTO Betalningar
VALUES('1000000004', 1, 'Återbetalningsbar', 2200),
('1000000004', 2, 'Ombokningsbar', 1100),
('1000000002', 3, 'Ombokningsbar', 900),
('1000000002', 4, 'Ombokningsbar', 900),
('1000000003', 5, 'Återbetalningsbar', 4800),
('1000000005', 6, 'Ombokningsbar', 950), 
('1000000001', 7, 'Återbetalningsbar', 1000),
('1000000006', 8, 'Återbetalningsbar', 1600),
('1000000001', 9, 'Rött', 400),
('1000000002', 10, 'Återbetalningsbar', 1800),
('1000000004', 11, 'Återbetalningsbar', 2200),
('1000000003', 12, 'Rött', 2000),
('1000000005', 13, 'Ombokningsbar', 950), 
('1000000004', 14, 'Återbetalningsbar', 2200);
*/