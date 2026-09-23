CREATE DATABASE CarWonders
USE CarWonders

--DROP TABLE RacerCar
--DROP TABLE EventDetail
--DROP TABLE EventSponsor
--DROP TABLE MsRacer
--DROP TABLE EventHeader
--DROP TABLE MsSponsor
--DROP TABLE MsCar
--DROP TABLE MsBrand
--DROP TABLE MsCircuit
--DROP TABLE MsCountry

CREATE TABLE MsCountry (
	CountryId CHAR(5) PRIMARY KEY CHECK (CountryId LIKE 'CY[0-9][0-9][0-9]'),
	CountryName VARCHAR(255) NOT NULL
)

CREATE TABLE MsCircuit (
	CircuitId CHAR(5) PRIMARY KEY CHECK (CircuitId LIKE 'CC[0-9][0-9][0-9]'),
	CircuitName VARCHAR(255) NOT NULL,
	CountryId CHAR(5) FOREIGN KEY REFERENCES MsCountry (CountryId)
)

CREATE TABLE MsBrand (
	BrandId CHAR(5) PRIMARY KEY CHECK (BrandId LIKE 'BR[0-9][0-9][0-9]'),
	BrandName VARCHAR(255) NOT NULL,
	CountryId CHAR(5) FOREIGN KEY REFERENCES MsCountry (CountryId)
)

CREATE TABLE MsCar (
	CarId CHAR(5) PRIMARY KEY CHECK (CarId LIKE 'CR[0-9][0-9][0-9]'),
	CarName VARCHAR(255) NOT NULL,
	CarPower INT NOT NULL CHECK (CarPower >= 300 AND CarPower <= 1000),
	BrandId CHAR(5) FOREIGN KEY REFERENCES MsBrand (BrandId)
)

CREATE TABLE MsSponsor (
	SponsorId CHAR(5) PRIMARY KEY CHECK (SponsorId LIKE 'SP[0-9][0-9][0-9]'),
	SponsorName VARCHAR(255) NOT NULL
)

CREATE TABLE EventHeader (
	EventId CHAR(5) PRIMARY KEY CHECK (EventId LIKE 'EV[0-9][0-9][0-9]'),
	EventName VARCHAR(255) NOT NULL,
	EventDate VARCHAR(255) NOT NULL,
	CircuitId CHAR(5) FOREIGN KEY REFERENCES MsCircuit (CircuitId)
)

CREATE TABLE MsRacer (
	RacerId CHAR(5) PRIMARY KEY CHECK (RacerId LIKE 'RC[0-9][0-9][0-9]'),
	RacerName VARCHAR(255) NOT NULL CHECK (RacerName LIKE '% %'),
	RacerAge INT NOT NULL,
	RacerGender VARCHAR(255) NOT NULL CHECK (RacerGender = 'Male' OR RacerGender = 'Female'),
	RacerAddress VARCHAR(255) NOT NULL,
	CountryId CHAR(5) FOREIGN KEY REFERENCES MsCountry (CountryId)
)

CREATE TABLE EventSponsor (
	EventId CHAR(5) FOREIGN KEY REFERENCES EventHeader (EventId),
	SponsorId CHAR(5) FOREIGN KEY REFERENCES MsSponsor (SponsorId)
)

CREATE TABLE EventDetail (
	EventId CHAR(5) FOREIGN KEY REFERENCES EventHeader (EventId),
	RacerId CHAR(5) FOREIGN KEY REFERENCES MsRacer (RacerId)
)

CREATE TABLE RacerCar (
	RacerId CHAR(5) FOREIGN KEY REFERENCES MsRacer (RacerId),
	CarId CHAR(5) FOREIGN KEY REFERENCES MsCar (CarId)
)

CREATE TRIGGER trg_RacerCar_MinCars
ON RacerCar
AFTER INSERT, DELETE
AS
BEGIN
    IF EXISTS (
        SELECT RacerId
        FROM RacerCar
        GROUP BY RacerId
        HAVING COUNT(DISTINCT CarId) < 3
    )
    BEGIN
        RAISERROR('Each racer must have at least 3 different cars', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

CREATE TRIGGER trg_Brand_CarCount
ON MsCar
AFTER INSERT, DELETE
AS
BEGIN
    IF EXISTS (
        SELECT BrandId
        FROM MsCar
        GROUP BY BrandId
        HAVING COUNT(CarId) < 3 OR COUNT(CarId) > 5
    )
    BEGIN
        RAISERROR('Each brand must have between 3 and 5 cars', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

CREATE TRIGGER trg_Event_MinRacers
ON EventDetail
AFTER INSERT, DELETE
AS
BEGIN
    IF EXISTS (
        SELECT EventId
        FROM EventDetail
        GROUP BY EventId
        HAVING COUNT(RacerId) < 15
    )
    BEGIN
        RAISERROR('Each event must have at least 15 racers', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

CREATE TRIGGER trg_Event_MinSponsors
ON EventSponsor
AFTER INSERT, DELETE
AS
BEGIN
    IF EXISTS (
        SELECT EventId
        FROM EventSponsor
        GROUP BY EventId
        HAVING COUNT(SponsorId) < 3
    )
    BEGIN
        RAISERROR('Each event must have at least 3 sponsors', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

-- Countries
INSERT INTO MsCountry VALUES
('CY001','Argentina'),('CY002','Australia'),('CY003','Belgium'),
('CY004','Brazil'),('CY005','Canada'),('CY006','China'),
('CY007','England'),('CY008','France'),('CY009','Germany'),
('CY010','Greece'),('CY011','Italy'),('CY012','Indonesia'),
('CY013','Japan'),('CY014','Netherlands'),('CY015','Portugal'),
('CY016','Russia'),('CY017','Saudi Arabia'),('CY018','Spain'),
('CY019','South Korea'),('CY020','United States');

-- CIRCUIT (>=25 circuits, linked with CYXXX)
INSERT INTO MsCircuit VALUES
('CC001','Velocity Ring','CY007'),
('CC002','Thunder Loop','CY010'),
('CC003','Dragon Trail Circuit','CY013'),
('CC004','Emerald Crest Circuit','CY003'),
('CC005','Sunset Raceway','CY004'),
('CC006','Royal Grand Circuit','CY012'),
('CC007','Dynamiq Raceway','CY006'),
('CC008','Ironclad Circuit','CY009'),
('CC009','Momentum Park','CY018'),
('CC010','Falcon International Circuit','CY017'),
('CC011','Liberty Circuit','CY020'),
('CC012','Southern Cross Circuit','CY002'),
('CC013','Gran Turismo Circuit','CY001'),
('CC014','Maple Leaf Raceway','CY005'),
('CC015','Ocean Crest Circuit','CY015'),
('CC016','Titan Raceway','CY016'),
('CC017','Phoenix Circuit','CY014'),
('CC018','Starlight Circuit','CY017'),
('CC019','Olympus Circuit','CY011'),
('CC020','Endurance Circuit','CY008'),
('CC021','Mirage Circuit','CY020'),
('CC022','Nusantara Circuit','CY012'),
('CC023','Aurora Circuit','CY019'),
('CC024','Tempest Circuit','CY009'),
('CC025','Eiffel Circuit','CY008');

-- BRAND (>=25 brands, some new beyond Aston Martin, Bugatti, Porsche)
INSERT INTO MsBrand VALUES
('BR001','Aston Martin','CY007'),('BR002','Bugatti','CY008'),
('BR003','Porsche','CY009'),('BR004','McLaren','CY007'),
('BR005','Ferrari','CY010'),('BR006','Lamborghini','CY010'),
('BR007','Mercedes-Benz','CY007'),('BR008','BMW','CY009'),
('BR009','Audi','CY009'),('BR010','Toyota','CY011'),
('BR011','Nissan','CY013'),('BR012','Honda','CY013'),
('BR013','Chevrolet','CY020'),('BR014','Ford','CY020'),
('BR015','Dodge','CY020'),('BR016','Hyundai','CY019'),
('BR017','Kia','CY019'),('BR018','Peugeot','CY008'),
('BR019','Renault','CY008'),('BR020','Citroën','CY008'),
('BR021','Mazda','CY013'),('BR022','Subaru','CY011'),
('BR023','Jaguar','CY007'),('BR024','Bentley','CY007'),
('BR025','Rolls-Royce','CY011');

-- CARS (3-4 per brand, power 300–1000)
INSERT INTO MsCar VALUES
-- Aston Martin (BR001)
('CR001','Vantage',503,'BR001'),('CR002','DB11',630,'BR001'),
('CR003','Valhalla',986,'BR001'),
-- Bugatti (BR002)
('CR004','Chiron',1000,'BR002'),('CR005','Veyron',987,'BR002'),
('CR006','Divo',960,'BR002'),
-- Porsche (BR003)
('CR007','911 GT3',502,'BR003'),('CR008','911 Turbo S',650,'BR003'),
('CR009','Cayman GT4',420,'BR003'),('CR010','918 Spyder',887,'BR003'),
-- McLaren (BR004)
('CR011','720S',710,'BR004'),('CR012','Artura',671,'BR004'),
('CR013','P1',903,'BR004'),
-- Ferrari (BR005)
('CR014','488 GTB',661,'BR005'),('CR015','F8 Tributo',710,'BR005'),
('CR016','SF90 Stradale',986,'BR005'),
-- Lamborghini (BR006)
('CR017','Huracan EVO',631,'BR006'),('CR018','Aventador SVJ',759,'BR006'),
('CR019','Gallardo LP560',552,'BR006'),('CR020','Murcielago',640,'BR006'),
-- Mercedes-Benz (BR007)
('CR021','AMG GT R',577,'BR007'),('CR022','C63 AMG',503,'BR007'),
('CR023','SLS AMG',622,'BR007'),
-- BMW (BR008)
('CR024','M5 Competition',617,'BR008'),('CR025','M4 GTS',493,'BR008'),
('CR026','M8 Gran Coupe',617,'BR008'),
-- Audi (BR009)
('CR027','RS7',591,'BR009'),('CR028','R8',602,'BR009'),
('CR029','RS6 Avant',621,'BR009'),
-- Toyota (BR010)
('CR030','Supra GR',382,'BR010'),('CR031','GR Yaris',355,'BR010'),
('CR032','GT86',310,'BR010'),
-- Nissan (BR011)
('CR033','GT-R',565,'BR011'),('CR034','370Z Nismo',350,'BR011'),
('CR035','Skyline R34',450,'BR011'),
-- Honda (BR012)
('CR036','NSX',573,'BR012'),('CR037','Civic Type R',320,'BR012'),
('CR038','S2000',350,'BR012'),
-- Chevrolet (BR013)
('CR039','Camaro ZL1',650,'BR013'),('CR040','Corvette C8',495,'BR013'),
('CR041','Corvette ZR1',755,'BR013'),
-- Ford (BR014)
('CR042','Mustang GT500',760,'BR014'),('CR043','Ford GT',660,'BR014'),
('CR044','Focus RS',350,'BR014'),
-- Dodge (BR015)
('CR045','Challenger Hellcat',717,'BR015'),('CR046','Charger SRT',485,'BR015'),
('CR047','Viper GTS',645,'BR015'),
-- Hyundai (BR016)
('CR048','Veloster N',350,'BR016'),('CR049','i30 N',320,'BR016'),
('CR050','Elantra N',340,'BR016'),
-- Kia (BR017)
('CR051','Stinger GT',365,'BR017'),('CR052','K5 GT',325,'BR017'),
('CR053','EV6 GT',576,'BR017'),
-- Peugeot (BR018)
('CR054','508 PSE',360,'BR018'),('CR055','RCZ R',340,'BR018'),
('CR056','308 GTi',330,'BR018'),
-- Renault (BR019)
('CR057','Megane RS',330,'BR019'),('CR058','Clio RS',320,'BR019'),
('CR059','Alpine A110',300,'BR019'),
-- Citroën (BR020)
('CR060','DS3 Racing',320,'BR020'),('CR061','C4 VTS',305,'BR020'),
('CR062','C-Elysee WTCC',360,'BR020'),
-- Mazda (BR021)
('CR063','RX-7',326,'BR021'),('CR064','RX-8',310,'BR021'),
('CR065','MazdaSpeed3',330,'BR021'),
-- Subaru (BR022)
('CR066','WRX STI',310,'BR022'),('CR067','Impreza 22B',345,'BR022'),
('CR068','BRZ STI',325,'BR022'),
-- Jaguar (BR023)
('CR069','F-Type R',575,'BR023'),('CR070','XKR-S',550,'BR023'),
('CR071','XJ220',542,'BR023'),
-- Bentley (BR024)
('CR072','Continental GT',626,'BR024'),('CR073','Bentayga Speed',626,'BR024'),
('CR074','Flying Spur',542,'BR024'),
-- Rolls-Royce (BR025)
('CR075','Wraith',624,'BR025'),('CR076','Phantom',563,'BR025'),
('CR077','Ghost',563,'BR025');

-- SPONSOR (>=25 sponsors)
INSERT INTO MsSponsor VALUES
('SP001','Bridgestone'),('SP002','Loro Piana'),('SP003','Heineken'),
('SP004','Rolex'),('SP005','Red Bull'),('SP006','Mercedes AMG'),
('SP007','Shell'),('SP008','Tag Heuer'),('SP009','Pirelli'),
('SP010','TotalEnergies'),('SP011','Mobil 1'),('SP012','Castrol'),
('SP013','Goodyear'),('SP014','Monster Energy'),('SP015','Petronas'),
('SP016','Santander'),('SP017','DHL'),('SP018','Hublot'),
('SP019','Oakley'),('SP020','KPMG'),('SP021','Google Cloud'),
('SP022','Microsoft Azure'),('SP023','Oracle'),('SP024','Netflix'),
('SP025','Spotify');

-- RACER (>=25 racers with valid names + gender check + age reasonable)
INSERT INTO MsRacer VALUES
('RC001','Lewis Hamilton',38,'Male','London, UK','CY007'),
('RC002','Max Verstappen',26,'Male','Hasselt, Belgium','CY003'),
('RC003','Sebastian Vettel',36,'Male','Heppenheim, Germany','CY009'),
('RC004','Rio Haryanto',31,'Male','Surakarta, Indonesia','CY012'),
('RC005','Carlos Sainz',29,'Male','Madrid, Spain','CY018'),
('RC006','Robert Rasidy',19,'Male','Jakarta, Indonesia','CY012'),
('RC007','Logan Sargeant',24,'Male','Florida, USA','CY020'),
('RC008','Timo Glock',42,'Male','Lindenfels, Germany','CY009'),
('RC009','George Russell',27,'Male','King’s Lynn, UK','CY007'),
('RC010','Lando Norris',25,'Male','Bristol, UK','CY007'),
('RC011','Pierre Gasly',29,'Male','Rouen, France','CY008'),
('RC012','Esteban Ocon',28,'Male','Évreux, France','CY008'),
('RC013','Yuki Tsunoda',25,'Male','Kanagawa, Japan','CY013'),
('RC014','Zhou Guanyu',26,'Male','Shanghai, China','CY006'),
('RC015','Kevin Magnussen',33,'Male','Roskilde, Denmark','CY009'),
('RC016','Mick Schumacher',27,'Male','Cologne, Germany','CY009'),
('RC017','Daniel Ricciardo',35,'Male','Perth, Australia','CY002'),
('RC018','Oscar Piastri',24,'Male','Melbourne, Australia','CY002'),
('RC019','Nico Hulkenberg',37,'Male','Emmerich, Germany','CY009'),
('RC020','Alexander Albon',29,'Male','London, UK','CY007'),
('RC021','Sophia Floersch',24,'Female','Munich, Germany','CY009'),
('RC022','Ana Beatriz',39,'Female','São Paulo, Brazil','CY004'),
('RC023','Jamie Chadwick',27,'Female','Bath, UK','CY007'),
('RC024','Simona de Silvestro',36,'Female','Thun, Switzerland','CY009'),
('RC025','Alice Powell',30,'Female','Oxford, UK','CY007'),
('RC026','Romain Grosjean',38,'Male','Geneva, Switzerland','CY009'),
('RC027','Felipe Massa',44,'Male','São Paulo, Brazil','CY004'),
('RC028','Kimi Räikkönen',45,'Male','Espoo, Finland','CY009'),
('RC029','Jenson Button',45,'Male','Frome, UK','CY007'),
('RC030','Rubens Barrichello',53,'Male','São Paulo, Brazil','CY004'),
('RC031','Heikki Kovalainen',42,'Male','Suomussalmi, Finland','CY009'),
('RC032','David Coulthard',54,'Male','Twynholm, UK','CY007'),
('RC033','Mark Webber',49,'Male','Queanbeyan, Australia','CY002'),
('RC034','Tiago Monteiro',48,'Male','Porto, Portugal','CY015'),
('RC035','Jarno Trulli',50,'Male','Pescara, Italy','CY011'),
('RC036','Giancarlo Fisichella',52,'Male','Rome, Italy','CY011'),
('RC037','Nick Heidfeld',47,'Male','Mönchengladbach, Germany','CY009'),
('RC038','Jos Verstappen',52,'Male','Montfort, Netherlands','CY014'),
('RC039','Vitaly Petrov',40,'Male','Vyborg, Russia','CY016'),
('RC040','Kamui Kobayashi',38,'Male','Amagasaki, Japan','CY013'),
('RC041','Takuma Sato',48,'Male','Tokyo, Japan','CY013'),
('RC042','Daniil Kvyat',30,'Male','Ufa, Russia','CY016'),
('RC043','Stoffel Vandoorne',33,'Male','Kortrijk, Belgium','CY003'),
('RC044','Jean-Eric Vergne',34,'Male','Pontoise, France','CY008'),
('RC045','Bruno Senna',41,'Male','São Paulo, Brazil','CY004'),
('RC046','Tatiana Shirakawa',28,'Female','Kyoto, Japan','CY013'),
('RC047','Carmen Jordá',36,'Female','Alicante, Spain','CY018'),
('RC048','Beitske Visser',30,'Female','Friesland, Netherlands','CY014'),
('RC049','Susie Wolff',42,'Female','Oban, UK','CY007'),
('RC050','Marta García',24,'Female','Valencia, Spain','CY018');

-- EVENT (>=25 events including Le Mans & Monaco)
INSERT INTO EventHeader VALUES
('EV001','Le Mans 24 Hours','2025-06-14','CC020'),
('EV002','Monaco Grand Prix','2025-05-24','CC006'),
('EV003','Velocity Masters','2024-09-03','CC001'),
('EV004','Apex Cup','2024-10-19','CC002'),
('EV005','Thunder Trophy','2024-11-16','CC003'),
('EV006','Enduro Cup','2024-12-08','CC004'),
('EV007','Racing Festival','2025-01-26','CC005'),
('EV008','Circuit Masters','2025-02-09','CC009'),
('EV009','Racing Classic','2025-03-02','CC025'),
('EV010','Speed Trophy','2025-03-16','CC014'),
('EV011','Motorsport Showdown','2025-04-13','CC011'),
('EV012','Velocity Challenge','2025-04-27','CC012'),
('EV013','Motorsport Cup','2025-05-11','CC013'),
('EV014','Circuit Trophy','2024-08-31','CC015'),
('EV015','Endurance Cup','2024-09-29','CC016'),
('EV016','Thunder Cup','2024-10-06','CC017'),
('EV017','Night Challenge','2024-11-24','CC018'),
('EV018','Racing Invitational','2024-12-22','CC019'),
('EV019','Motorsport Trophy','2025-01-12','CC008'),
('EV020','Jakarta E-Prix','2025-02-23','CC022'),
('EV021','Speed Cup','2025-03-30','CC023'),
('EV022','Dragon Trophy','2025-04-20','CC007'),
('EV023','Desert Challenge','2025-05-18','CC010'),
('EV024','Velocity Cup','2025-06-01','CC021'),
('EV025','Circuit Festival','2025-07-13','CC025');

INSERT INTO RacerCar VALUES
-- Lewis Hamilton
('RC001','CR001'),('RC001','CR022'),('RC001','CR023'),('RC001','CR015'),('RC001','CR013'),('RC001','CR033'),('RC001','CR041'),('RC001','CR050'),('RC001','CR062'),
-- Max Verstappen
('RC002','CR011'),('RC002','CR012'),('RC002','CR013'),('RC002','CR001'),('RC002','CR021'),('RC002','CR031'),('RC002','CR040'),
-- Sebastian Vettel
('RC003','CR027'),('RC003','CR028'),('RC003','CR029'),('RC003','CR017'),('RC003','CR044'),('RC003','CR055'),
-- Rio Haryanto
('RC004','CR014'),('RC004','CR015'),('RC004','CR016'),('RC004','CR022'),('RC004','CR033'),('RC004','CR061'),
-- Carlos Sainz
('RC005','CR014'),('RC005','CR015'),('RC005','CR016'),('RC005','CR025'),('RC005','CR037'),('RC005','CR063'),
-- Robert Rasidy
('RC006','CR039'),('RC006','CR040'),('RC006','CR041'),('RC006','CR019'),
-- Logan Sargeant
('RC007','CR045'),('RC007','CR046'),('RC007','CR047'),('RC007','CR028'),('RC007','CR034'),('RC007','CR072'),
-- Timo Glock
('RC008','CR024'),('RC008','CR025'),('RC008','CR026'),('RC008','CR011'),('RC008','CR036'),('RC008','CR058'),
-- George Russell
('RC009','CR021'),('RC009','CR022'),('RC009','CR023'),('RC009','CR043'),('RC009','CR060'),('RC009','CR073'),
-- Lando Norris
('RC010','CR011'),('RC010','CR012'),('RC010','CR013'),('RC010','CR018'),('RC010','CR027'),('RC010','CR054'),
-- Pierre Gasly
('RC011','CR057'),('RC011','CR058'),('RC011','CR059'),('RC011','CR008'),('RC011','CR038'),
-- Esteban Ocon
('RC012','CR057'),('RC012','CR058'),('RC012','CR059'),('RC012','CR014'),('RC012','CR035'),('RC012','CR075'),
-- Yuki Tsunoda
('RC013','CR030'),('RC013','CR031'),('RC013','CR032'),('RC013','CR013'),('RC013','CR045'),
-- Zhou Guanyu
('RC014','CR033'),('RC014','CR034'),('RC014','CR035'),('RC014','CR020'),
-- Kevin Magnussen
('RC015','CR027'),('RC015','CR028'),('RC015','CR029'),('RC015','CR051'),('RC015','CR074'),
-- Mick Schumacher
('RC016','CR024'),('RC016','CR025'),('RC016','CR026'),
-- Daniel Ricciardo
('RC017','CR011'),('RC017','CR012'),('RC017','CR013'),('RC017','CR027'),
-- Oscar Piastri
('RC018','CR011'),('RC018','CR012'),('RC018','CR013'),('RC018','CR021'),('RC018','CR036'),
-- Nico Hulkenberg
('RC019','CR027'),('RC019','CR028'),('RC019','CR029'),('RC019','CR055'),('RC019','CR072'), ('RC019','CR018'),('RC019','CR061'),
-- Alexander Albon
('RC020','CR030'),('RC020','CR003'),('RC020','CR032'),
-- Sophia Floersch
('RC021','CR066'),('RC021','CR068'),('RC021','CR014'),('RC021','CR035'),
-- Ana Beatriz
('RC022','CR054'),('RC022','CR055'),('RC022','CR056'),('RC022','CR016'),('RC022','CR064'),
-- Jamie Chadwick
('RC023','CR063'),('RC023','CR064'),('RC023','CR021'),('RC023','CR034'),
-- Simona de Silvestro
('RC024','CR002'),('RC024','CR070'),('RC024','CR071'),('RC024','CR042'),('RC024','CR019'),
-- Alice Powell
('RC025','CR060'),('RC025','CR061'),('RC025','CR062'),('RC025','CR009'),('RC025','CR073'),
-- Romain Grosjean
('RC026','CR027'),('RC026','CR043'),('RC026','CR052'),
-- Felipe Massa
('RC027','CR033'),('RC027','CR034'),('RC027','CR035'),('RC027','CR007'),('RC027','CR063'),
-- Kimi Räikkönen
('RC028','CR024'),('RC028','CR025'),('RC028','CR026'),('RC028','CR056'),('RC028','CR077'),
-- Jenson Button
('RC029','CR021'),('RC029','CR022'),('RC029','CR023'),
-- Rubens Barrichello
('RC030','CR033'),('RC030','CR034'),('RC030','CR035'),('RC030','CR046'),('RC030','CR070'), ('RC030','CR017'),('RC030','CR065'),
-- Heikki Kovalainen
('RC031','CR024'),('RC031','CR025'),('RC031','CR026'),('RC031','CR019'),('RC031','CR060'),
-- David Coulthard
('RC032','CR021'),('RC032','CR022'),('RC032','CR023'),('RC032','CR012'),
-- Mark Webber
('RC033','CR011'),('RC033','CR012'),('RC033','CR013'),('RC033','CR044'),('RC033','CR076'),
-- Tiago Monteiro
('RC034','CR045'),('RC034','CR046'),('RC034','CR047'),('RC034','CR001'),('RC034','CR034'),
-- Jarno Trulli
('RC035','CR014'),('RC035','CR015'),('RC035','CR016'),('RC035','CR022'),('RC035','CR054'), ('RC035','CR059'),
-- Giancarlo Fisichella
('RC036','CR014'),('RC036','CR015'),('RC036','CR045'),('RC036','CR071'),
-- Nick Heidfeld
('RC037','CR039'),('RC037','CR040'),('RC037','CR041'),('RC037','CR033'),
-- Jos Verstappen
('RC038','CR042'),('RC038','CR043'),('RC038','CR044'),('RC038','CR023'),('RC038','CR064'),
-- Vitaly Petrov
('RC039','CR048'),('RC039','CR049'),('RC039','CR067'),
-- Kamui Kobayashi
('RC040','CR030'),('RC040','CR031'),('RC040','CR032'),('RC040','CR028'),('RC040','CR076'),
-- Takuma Sato
('RC041','CR030'),('RC041','CR031'),('RC041','CR032'),('RC041','CR008'),('RC041','CR063'), ('RC041','CR052'),('RC041','CR053'),
-- Daniil Kvyat
('RC042','CR051'),('RC042','CR009'),('RC042','CR038'),
-- Stoffel Vandoorne
('RC043','CR054'),('RC043','CR055'), ('RC043','CR033'),('RC043','CR073'),
-- Jean-Eric Vergne
('RC044','CR059'),('RC044','CR036'),('RC044','CR048'),
-- Bruno Senna
('RC045','CR033'),('RC045','CR034'),('RC045','CR035'),('RC045','CR012'),('RC045','CR040'),
-- Tatiana Shirakawa
('RC046','CR030'),('RC046','CR031'),('RC046','CR032'),
-- Carmen Jordá
('RC047','CR060'),('RC047','CR061'),('RC047','CR062'),('RC047','CR002'),('RC047','CR036'),
-- Beitske Visser
('RC048','CR063'),('RC048','CR064'),('RC048','CR065'),('RC048','CR024'),('RC048','CR046'),
-- Susie Wolff
('RC049','CR021'), ('RC049','CR031'),('RC049','CR072'),
-- Marta García
('RC050','CR060'),('RC050','CR061'),('RC050','CR062'),('RC050','CR029'),('RC050','CR075');

-- EVENT-SPONSOR (each event >=3 sponsors, plus random 1–7 extras)
INSERT INTO EventSponsor VALUES
-- EV001
('EV001','SP001'),('EV001','SP004'),('EV001','SP007'),('EV001','SP008'),('EV001','SP021'),
-- EV002
('EV002','SP003'),('EV002','SP005'),('EV002','SP008'),('EV002','SP011'),('EV002','SP024'),('EV002','SP020'),
-- EV003
('EV003','SP009'),('EV003','SP015'),('EV003','SP017'),('EV003','SP002'),('EV003','SP019'),
-- EV004
('EV004','SP002'),('EV004','SP004'),('EV004','SP003'),
-- EV005
('EV005','SP005'),('EV005','SP011'),('EV005','SP012'),('EV005','SP006'),('EV005','SP020'),
-- EV006
('EV006','SP003'),('EV006','SP007'),('EV006','SP018'),
-- EV007
('EV007','SP014'),('EV007','SP015'),('EV007','SP020'),('EV007','SP021'),('EV007','SP009'),
-- EV008
('EV008','SP006'),('EV008','SP009'),('EV008','SP016'),('EV008','SP025'),('EV008','SP003'),
-- EV009
('EV009','SP002'),('EV009','SP003'),('EV009','SP019'),('EV009','SP010'),
-- EV010
('EV010','SP004'),('EV010','SP017'),('EV010','SP021'),('EV010','SP013'),('EV010','SP008'),
-- EV011
('EV011','SP020'),('EV011','SP022'),('EV011','SP023'),('EV011','SP006'),('EV011','SP014'),
-- EV012
('EV012','SP001'),('EV012','SP005'),('EV012','SP007'),('EV012','SP018'),
-- EV013
('EV013','SP003'),('EV013','SP008'),('EV013','SP024'),('EV013','SP019'),('EV013','SP025'),('EV013','SP014'),
-- EV014
('EV014','SP009'),('EV014','SP010'),('EV014','SP025'), ('EV014','SP001'),
-- EV015
('EV015','SP011'),('EV015','SP012'),('EV015','SP013'),('EV015','SP004'),('EV015','SP023'),
-- EV016
('EV016','SP014'),('EV016','SP015'),('EV016','SP016'),('EV016','SP007'),('EV016','SP002'),('EV016','SP011'),
-- EV017
('EV017','SP018'),('EV017','SP019'),('EV017','SP020'),('EV017','SP010'),('EV017','SP021'),
-- EV018
('EV018','SP002'),('EV018','SP004'),('EV018','SP006'),
-- EV019
('EV019','SP007'),('EV019','SP008'),('EV019','SP009'),('EV019','SP005'),('EV019','SP016'),('EV019','SP022'),('EV019','SP006'),
-- EV020
('EV020','SP001'),('EV020','SP021'),('EV020','SP022'),('EV020','SP017'),
-- EV021
('EV021','SP003'),('EV021','SP012'),('EV021','SP023'),
-- EV022
('EV022','SP002'),('EV022','SP017'),('EV022','SP003'),('EV022','SP019'),('EV022','SP009'),
-- EV023
('EV023','SP015'),('EV023','SP018'),('EV023','SP020'),('EV023','SP013'),
-- EV024
('EV024','SP013'),('EV024','SP019'),('EV024','SP024'),('EV024','SP001'),('EV024','SP023'),('EV024','SP007'),
-- EV025
('EV025','SP005'),('EV025','SP009'),('EV025','SP010'),('EV025','SP016'),('EV025','SP012');

-- EVENTDETAIL (>=15 racers per event, randomized distribution)
INSERT INTO EventDetail VALUES
-- EV001
('EV001','RC001'),('EV001','RC002'),('EV001','RC003'),('EV001','RC004'),('EV001','RC005'),
('EV001','RC006'),('EV001','RC007'),('EV001','RC008'),('EV001','RC009'),('EV001','RC010'),
('EV001','RC011'),('EV001','RC012'),('EV001','RC013'),('EV001','RC014'),('EV001','RC015'),
('EV001','RC016'),('EV001','RC017'),('EV001','RC026'),('EV001','RC027'),('EV001','RC028'),
-- EV002
('EV002','RC003'),('EV002','RC005'),('EV002','RC007'),('EV002','RC009'),('EV002','RC011'),
('EV002','RC013'),('EV002','RC015'),('EV002','RC017'),('EV002','RC019'),('EV002','RC020'),
('EV002','RC021'),('EV002','RC022'),('EV002','RC023'),('EV002','RC024'),('EV002','RC025'),
('EV002','RC029'),('EV002','RC030'),
-- EV003
('EV003','RC002'),('EV003','RC004'),('EV003','RC006'),('EV003','RC008'),('EV003','RC010'),
('EV003','RC012'),('EV003','RC014'),('EV003','RC016'),('EV003','RC018'),('EV003','RC019'),
('EV003','RC020'),('EV003','RC021'),('EV003','RC022'),('EV003','RC023'),('EV003','RC025'),
('EV003','RC033'),('EV003','RC034'),('EV003','RC036'),('EV003','RC037'),
-- EV004
('EV004','RC001'),('EV004','RC003'),('EV004','RC005'),('EV004','RC007'),('EV004','RC009'),
('EV004','RC011'),('EV004','RC013'),('EV004','RC015'),('EV004','RC017'),('EV004','RC018'),
('EV004','RC019'),('EV004','RC020'),('EV004','RC021'),('EV004','RC024'),('EV004','RC025'),
-- EV005
('EV005','RC002'),('EV005','RC004'),('EV005','RC006'),('EV005','RC008'),('EV005','RC010'),
('EV005','RC012'),('EV005','RC014'),('EV005','RC016'),('EV005','RC018'),('EV005','RC019'),
('EV005','RC021'),('EV005','RC022'),('EV005','RC023'),('EV005','RC024'),('EV005','RC025'),
('EV005','RC043'),('EV005','RC044'),('EV005','RC045'),('EV005','RC046'),
-- EV006
('EV006','RC001'),('EV006','RC003'),('EV006','RC005'),('EV006','RC007'),('EV006','RC009'),
('EV006','RC011'),('EV006','RC013'),('EV006','RC015'),('EV006','RC017'),('EV006','RC018'),
('EV006','RC019'),('EV006','RC020'),('EV006','RC022'),('EV006','RC023'),('EV006','RC025'),
('EV006','RC047'),('EV006','RC048'),
-- EV007
('EV007','RC002'),('EV007','RC004'),('EV007','RC006'),('EV007','RC008'),('EV007','RC010'),
('EV007','RC012'),('EV007','RC014'),('EV007','RC016'),('EV007','RC018'),('EV007','RC019'),
('EV007','RC020'),('EV007','RC021'),('EV007','RC022'),('EV007','RC023'),('EV007','RC024'),
('EV007','RC026'),('EV007','RC027'),('EV007','RC028'),('EV007','RC029'),('EV007','RC049'),
('EV007','RC050'),('EV007','RC033'),('EV007','RC034'),('EV007','RC030'),('EV007','RC031'),
('EV007','RC032'),
-- EV008
('EV008','RC001'),('EV008','RC003'),('EV008','RC005'),('EV008','RC007'),('EV008','RC009'),
('EV008','RC011'),('EV008','RC013'),('EV008','RC015'),('EV008','RC017'),('EV008','RC018'),
('EV008','RC019'),('EV008','RC021'),('EV008','RC022'),('EV008','RC023'),('EV008','RC025'),
-- EV009
('EV009','RC002'),('EV009','RC004'),('EV009','RC006'),('EV009','RC008'),('EV009','RC010'),
('EV009','RC012'),('EV009','RC014'),('EV009','RC016'),('EV009','RC018'),('EV009','RC019'),
('EV009','RC020'),('EV009','RC021'),('EV009','RC023'),('EV009','RC024'),('EV009','RC025'),
('EV009','RC035'),('EV009','RC036'),('EV009','RC037'),('EV009','RC038'),
-- EV010
('EV010','RC001'),('EV010','RC003'),('EV010','RC005'),('EV010','RC007'),('EV010','RC009'),
('EV010','RC011'),('EV010','RC013'),('EV010','RC015'),('EV010','RC017'),('EV010','RC018'),
('EV010','RC019'),('EV010','RC020'),('EV010','RC021'),('EV010','RC022'),('EV010','RC025'),
('EV010','RC039'),
-- EV011
('EV011','RC002'),('EV011','RC004'),('EV011','RC006'),('EV011','RC008'),('EV011','RC010'),
('EV011','RC012'),('EV011','RC014'),('EV011','RC016'),('EV011','RC018'),('EV011','RC019'),
('EV011','RC020'),('EV011','RC021'),('EV011','RC022'),('EV011','RC023'),('EV011','RC025'),
-- EV012
('EV012','RC001'),('EV012','RC003'),('EV012','RC005'),('EV012','RC007'),('EV012','RC009'),
('EV012','RC011'),('EV012','RC013'),('EV012','RC015'),('EV012','RC017'),('EV012','RC018'),
('EV012','RC019'),('EV012','RC020'),('EV012','RC021'),('EV012','RC022'),('EV012','RC024'),
('EV012','RC047'),('EV012','RC048'),('EV012','RC049'),
-- EV013
('EV013','RC002'),('EV013','RC004'),('EV013','RC006'),('EV013','RC008'),('EV013','RC010'),
('EV013','RC012'),('EV013','RC014'),('EV013','RC016'),('EV013','RC018'),('EV013','RC019'),
('EV013','RC020'),('EV013','RC021'),('EV013','RC022'),('EV013','RC023'),('EV013','RC024'),
('EV013','RC026'),('EV013','RC027'),('EV013','RC028'),('EV013','RC029'),
-- EV014
('EV014','RC001'),('EV014','RC003'),('EV014','RC005'),('EV014','RC007'),('EV014','RC009'),
('EV014','RC011'),('EV014','RC013'),('EV014','RC015'),('EV014','RC017'),('EV014','RC018'),
('EV014','RC019'),('EV014','RC020'),('EV014','RC021'),('EV014','RC023'),('EV014','RC025'),
('EV014','RC030'),('EV014','RC031'),('EV014','RC032'),
-- EV015
('EV015','RC002'),('EV015','RC004'),('EV015','RC006'),('EV015','RC008'),('EV015','RC010'),
('EV015','RC012'),('EV015','RC014'),('EV015','RC016'),('EV015','RC018'),('EV015','RC019'),
('EV015','RC020'),('EV015','RC022'),('EV015','RC023'),('EV015','RC024'),('EV015','RC025'),
('EV015','RC037'),('EV015','RC038'),
-- EV016
('EV016','RC001'),('EV016','RC003'),('EV016','RC005'),('EV016','RC007'),('EV016','RC009'),
('EV016','RC011'),('EV016','RC013'),('EV016','RC015'),('EV016','RC017'),('EV016','RC018'),
('EV016','RC019'),('EV016','RC020'),('EV016','RC021'),('EV016','RC022'),('EV016','RC024'),
('EV016','RC039'),('EV016','RC040'),('EV016','RC041'),('EV016','RC042'),
-- EV017
('EV017','RC002'),('EV017','RC004'),('EV017','RC006'),('EV017','RC008'),('EV017','RC010'),
('EV017','RC012'),('EV017','RC014'),('EV017','RC016'),('EV017','RC018'),('EV017','RC019'),
('EV017','RC020'),('EV017','RC021'),('EV017','RC022'),('EV017','RC023'),('EV017','RC025'),
('EV017','RC043'),('EV017','RC044'),('EV017','RC045'),('EV017','RC046'),
-- EV018
('EV018','RC001'),('EV018','RC003'),('EV018','RC005'),('EV018','RC007'),('EV018','RC009'),
('EV018','RC011'),('EV018','RC013'),('EV018','RC015'),('EV018','RC017'),('EV018','RC018'),
('EV018','RC019'),('EV018','RC020'),('EV018','RC021'),('EV018','RC023'),('EV018','RC024'),
('EV018','RC047'),('EV018','RC048'),('EV018','RC049'),('EV018','RC050'),
-- EV019
('EV019','RC002'),('EV019','RC004'),('EV019','RC006'),('EV019','RC008'),('EV019','RC010'),
('EV019','RC012'),('EV019','RC014'),('EV019','RC016'),('EV019','RC018'),('EV019','RC019'),
('EV019','RC020'),('EV019','RC021'),('EV019','RC022'),('EV019','RC024'),('EV019','RC025'),
('EV019','RC026'),('EV019','RC027'),('EV019','RC028'),('EV019','RC029'),
-- EV020
('EV020','RC001'),('EV020','RC003'),('EV020','RC005'),('EV020','RC007'),('EV020','RC009'),
('EV020','RC011'),('EV020','RC013'),('EV020','RC015'),('EV020','RC017'),('EV020','RC018'),
('EV020','RC019'),('EV020','RC020'),('EV020','RC022'),('EV020','RC023'),('EV020','RC025'),
('EV020','RC030'),('EV020','RC031'),('EV020','RC032'),('EV020','RC033'),('EV020','RC034'),
('EV020','RC035'),('EV020','RC036'),('EV020','RC037'),
-- EV021
('EV021','RC002'),('EV021','RC004'),('EV021','RC006'),('EV021','RC008'),('EV021','RC010'),
('EV021','RC012'),('EV021','RC014'),('EV021','RC016'),('EV021','RC018'),('EV021','RC019'),
('EV021','RC020'),('EV021','RC021'),('EV021','RC023'),('EV021','RC024'),('EV021','RC025'),
('EV021','RC038'),
-- EV022
('EV022','RC001'),('EV022','RC003'),('EV022','RC005'),('EV022','RC007'),('EV022','RC009'),
('EV022','RC011'),('EV022','RC013'),('EV022','RC015'),('EV022','RC017'),('EV022','RC018'),
('EV022','RC019'),('EV022','RC020'),('EV022','RC021'),('EV022','RC022'),('EV022','RC025'),
('EV022','RC039'),('EV022','RC040'),('EV022','RC041'),('EV022','RC042'),
-- EV023
('EV023','RC002'),('EV023','RC004'),('EV023','RC006'),('EV023','RC008'),('EV023','RC010'),
('EV023','RC012'),('EV023','RC014'),('EV023','RC016'),('EV023','RC018'),('EV023','RC019'),
('EV023','RC020'),('EV023','RC021'),('EV023','RC022'),('EV023','RC023'),('EV023','RC024'),
('EV023','RC043'),('EV023','RC044'),
-- EV024
('EV024','RC001'),('EV024','RC003'),('EV024','RC005'),('EV024','RC007'),('EV024','RC009'),
('EV024','RC011'),('EV024','RC013'),('EV024','RC015'),('EV024','RC017'),('EV024','RC018'),
('EV024','RC019'),('EV024','RC020'),('EV024','RC022'),('EV024','RC023'),('EV024','RC025'),
-- EV025
('EV025','RC002'),('EV025','RC004'),('EV025','RC006'),('EV025','RC008'),('EV025','RC010'),
('EV025','RC012'),('EV025','RC014'),('EV025','RC016'),('EV025','RC018'),('EV025','RC019'),
('EV025','RC020'),('EV025','RC021'),('EV025','RC022'),('EV025','RC023'),('EV025','RC024'),
('EV025','RC026'),('EV025','RC027'),('EV025','RC028');


--Q1
SELECT
    CONCAT('ISC', RIGHT(ms.SponsorId, 3), ASCII(ms.SponsorName)) AS [International Sponsor Code],
    ms.SponsorName,
    COUNT(eh.EventId) AS [Total Events]
FROM MsSponsor ms
JOIN EventSponsor es ON es.SponsorId = ms.SponsorId
JOIN EventHeader eh ON eh.EventId = es.EventId
JOIN MsCircuit mci ON mci.CircuitId = eh.CircuitId
JOIN MsCountry mco ON mco.CountryId = mci.CountryId
WHERE mco.CountryName = 'Australia'
GROUP BY ms.SponsorId, ms.SponsorName


--Q2
SELECT DISTINCT mr.RacerName AS [Aston x Bridgestone Event Racer]
FROM MsSponsor ms
JOIN EventSponsor es ON es.SponsorId = ms.SponsorId
JOIN EventHeader eh ON eh.EventId = es.EventId
JOIN EventDetail ed ON ed.EventId = eh.EventId
JOIN MsRacer mr ON mr.RacerId = ed.RacerId
JOIN RacerCar rc ON rc.RacerId = mr.RacerId
JOIN MsCar mc ON mc.CarId = rc.CarId
JOIN MsBrand mb ON mb.BrandId = mc.BrandId
WHERE mb.BrandName = 'Aston Martin'
INTERSECT
SELECT mr.RacerName AS [Aston x Bridgestone Event Racer]
FROM MsSponsor ms
JOIN EventSponsor es ON es.SponsorId = ms.SponsorId
JOIN EventHeader eh ON eh.EventId = es.EventId
JOIN EventDetail ed ON ed.EventId = eh.EventId
JOIN MsRacer mr ON mr.RacerId = ed.RacerId
JOIN RacerCar rc ON rc.RacerId = mr.RacerId
JOIN MsCar mc ON mc.CarId = rc.CarId
JOIN MsBrand mb ON mb.BrandId = mc.BrandId
WHERE ms.SponsorName = 'Bridgestone'


--Q3
SELECT CarName, CarPower
FROM MsCar
ORDER BY CarPower

UPDATE MsCar
SET CarPower = 1.2 * CarPower
WHERE CarPower < 550

SELECT CarName, CarPower
FROM MsCar
ORDER BY CarPower


--Q4
--var1
SELECT
    eh.EventId,
    eh.EventName,
    FORMAT(CAST(eh.EventDate AS DATE), 'MMMM dd, yyyy') AS EventDate
FROM MsSponsor ms
JOIN EventSponsor es ON es.SponsorId = ms.SponsorId
JOIN EventHeader eh ON eh.EventId = es.EventId
WHERE ms.SponsorName IN ('Loro Piana', 'Heineken')
GROUP BY eh.EventId, eh.EventName, EventDate
HAVING COUNT(DISTINCT ms.SponsorName) = 2
ORDER BY CAST(eh.EventDate AS DATE)
--var2
SELECT DISTINCT
    eh.EventId,
    eh.EventName,
    FORMAT(CAST(eh.EventDate AS DATE), 'MMMM dd, yyyy') AS EventDate
FROM EventHeader eh
JOIN EventSponsor es ON eh.EventId = es.EventId
JOIN MsSponsor ms ON ms.SponsorId = es.SponsorId
WHERE ms.SponsorName = 'Loro Piana'
INTERSECT
SELECT DISTINCT
    eh.EventId,
    eh.EventName,
    FORMAT(CAST(eh.EventDate AS DATE), 'MMMM dd, yyyy') AS EventDate
FROM EventHeader eh
JOIN EventSponsor es ON eh.EventId = es.EventId
JOIN MsSponsor ms ON ms.SponsorId = es.SponsorId
WHERE ms.SponsorName = 'Heineken'
ORDER BY EventDate;


--Q5
SELECT
    mr.RacerName AS [Racer Name],
    mc.CountryName AS [Country Name],
    COUNT(*) AS [Number Sponsored]
FROM MsSponsor ms
JOIN EventSponsor es ON es.SponsorId = ms.SponsorId
JOIN EventHeader eh ON eh.EventId = es.EventId
JOIN EventDetail ed ON ed.EventId = eh.EventId
JOIN MsRacer mr ON mr.RacerId = ed.RacerId
JOIN MsCountry mc ON mc.CountryId = mr.CountryId
WHERE ms.SponsorName = 'Rolex'
GROUP BY mr.Racername, mc.CountryName
HAVING COUNT(ms.SponsorName) % 2 = 1


--Q6
SELECT DISTINCT
    CASE 
        WHEN eh.EventName LIKE '%Hours%' 
        THEN REPLACE(eh.EventName, 'Hours', 'Fantastical')
        ELSE eh.EventName
    END AS [world race event],
    mci.CircuitName AS [circuit name]
FROM EventHeader eh
JOIN MsCircuit mci ON mci.CircuitId = eh.CircuitId
JOIN MsCountry mco ON mci.CountryId = mco.CountryId
WHERE mco.CountryName IN ('Germany', 'France')
EXCEPT
SELECT DISTINCT
    CASE 
        WHEN eh.EventName LIKE '%Hours%' 
        THEN REPLACE(eh.EventName, 'Hours', 'Fantastical')
        ELSE eh.EventName
    END AS [world race event],
    mci.CircuitName AS [circuit name]
FROM EventHeader eh
JOIN MsCircuit mci ON mci.CircuitId = eh.CircuitId
JOIN MsCountry mco ON mci.CountryId = mco.CountryId
WHERE mco.CountryName IN ('Germany', 'France') AND DAY(eh.EventDate) BETWEEN 16 AND 31


--Q7
SELECT
    DATENAME(MONTH, EventDate) AS [Event Month],
    CONCAT(COUNT(*),' ', 'event(s)') AS [Existing Event]
FROM EventHeader
WHERE MONTH(EventDate) < 9
GROUP BY DATENAME(MONTH, EventDate), MONTH(EventDate)
ORDER BY MONTH(EventDate)

--Q8
--var1 (original)
SELECT
    mc.CarName AS [car name],
    mb.BrandName AS [brand name],
    COUNT(*) AS [Total Used]
FROM RacerCar rc
JOIN MsCar mc ON mc.CarId = rc.CarId
JOIN MsBrand mb ON mb.BrandId = mc.BrandId
GROUP BY mc.CarName, mb.BrandName
HAVING COUNT(*) BETWEEN 1 AND 3
--var2 (including unused cars)
SELECT
    mc.CarName AS [car name],
    mb.BrandName AS [brand name],
    COUNT(rc.CarId) AS [Total Used]
FROM RacerCar rc
RIGHT JOIN MsCar mc ON mc.CarId = rc.CarId
JOIN MsBrand mb ON mb.BrandId = mc.BrandId
GROUP BY mc.CarName, mb.BrandName;
--var3 (including unused cars)
SELECT
    mc.CarName AS [car name],
    mb.BrandName AS [brand name],
    COUNT(rc.CarId) AS [Total Used]
FROM MsCar mc
JOIN MsBrand mb ON mb.BrandId = mc.BrandId
LEFT JOIN RacerCar rc ON rc.CarId = mc.CarId
GROUP BY mc.CarName, mb.BrandName;


--Q9
SELECT
    LOWER(REVERSE(SUBSTRING(mb.BrandName, LEN(mb.BrandName) / 2 - 1, 3))) AS [Secret Brand Code],
    mb.BrandName AS [Brand Name],
    MAX(mc.CarPower) AS [Highest Rated HP]
FROM MsCar mc
JOIN MsBrand mb ON mb.BrandId = mc.BrandId
JOIN MsCountry mco ON mco.CountryId = mb.CountryId
WHERE CountryName = 'Italy'
GROUP BY mb.BrandName


--Q10
SELECT
    eh.EventName AS [Event Name],
    CONCAT(COUNT(*), ' ', 'Participants') AS Candidates
FROM EventHeader eh
JOIN EventDetail ed ON eh.EventId = ed.EventId
JOIN MsRacer mr ON mr.RacerId = ed.RacerId
GROUP BY eh.EventName


--Q11
SELECT eh.EventName, ms.SponsorName
FROM MsSponsor ms
JOIN EventSponsor es ON es.SponsorId = ms.SponsorId
JOIN EventHeader eh ON eh.EventId = es.EventId
WHERE ms.SponsorName = 'KPMG'

DELETE es
FROM EventSponsor es
JOIN MsSponsor ms ON es.SponsorId = ms.SponsorId
WHERE ms.SponsorName = 'KPMG';

DELETE FROM MsSponsor WHERE SponsorName = 'KPMG'

SELECT eh.EventName, ms.SponsorName
FROM MsSponsor ms
JOIN EventSponsor es ON es.SponsorId = ms.SponsorId
JOIN EventHeader eh ON eh.EventId = es.EventId
WHERE ms.SponsorName = 'KPMG'


--Q12
--var1
SELECT
    mr.RacerName,
    mc.CountryName
FROM MsRacer mr
JOIN MsCountry mc ON mc.CountryId = mr.CountryId
WHERE CHARINDEX('c', LOWER(mr.RacerName)) > 0 AND CHARINDEX('w', LOWER(mr.RacerName)) > 0
--var2
SELECT 
    mr.RacerName,
    mc.CountryName
FROM MsRacer mr
JOIN MsCountry mc ON mc.CountryId = mr.CountryId
WHERE LOWER(mr.RacerName) LIKE '%c%' AND LOWER(mr.RacerName) LIKE '%w%'


--Q13
SELECT 
    UPPER(REPLACE(eh.EventId, 'EV',CONCAT(LEFT(mci.CircuitName, 1), SUBSTRING(mci.CircuitName, CHARINDEX(' ', mci.CircuitName) - 1, 1)))) AS EventId,
    eh.EventName,
    mco.CountryName AS CircuitOrigin
FROM EventHeader eh
JOIN MsCircuit mci ON eh.CircuitId = mci.CircuitId
JOIN MsCountry mco ON mci.CountryId = mco.CountryId
WHERE eh.EventName LIKE '%Hours%'


--Q14
SELECT
    CONCAT(UPPER(SUBSTRING(mco.CountryName,1,3)),REPLACE(mc.CarName, mb.BrandName, '')) AS [Car Nationality],
    CONCAT(REVERSE(mb.BrandName), LOWER(RIGHT(mc.CarName,2))) AS [Car Redeem Code]
FROM MsCar mc
JOIN MsBrand mb ON mb.BrandId = mc.BrandId
JOIN MsCountry mco ON mco.CountryId = mb.CountryId


--Q15
CREATE VIEW IndonesianRacers AS
SELECT TOP 5
    mr.RacerName,
    COUNT(rc.CarId) AS TotalCarsDriven,
    CONCAT(AVG(mc.CarPower), ' HP') AS AvgCarPower
FROM MsRacer mr
JOIN MsCountry mco ON mr.CountryId = mco.CountryId
JOIN RacerCar rc ON mr.RacerId = rc.RacerId
JOIN MsCar mc ON rc.CarId = mc.CarId
WHERE mco.CountryName = 'Indonesia'
GROUP BY mr.RacerName
ORDER BY COUNT(rc.CarId) DESC, AVG(mc.CarPower) DESC

SELECT * FROM IndonesianRacers


--Q16
CREATE VIEW Past5MonthEvent AS
SELECT 
    eh.EventName AS [Event Name],
    COUNT(ed.RacerId) AS [Racer Participation]
FROM EventHeader eh
JOIN EventDetail ed ON eh.EventId = ed.EventId
WHERE DATEDIFF(MONTH, eh.EventDate, GETDATE()) = 5
GROUP BY eh.EventName

SELECT * FROM Past5MonthEvent


--Q17
SELECT DISTINCT
    REPLACE(r.RacerID, 'RC', LOWER(SUBSTRING(r.RacerName, 1, 1) + SUBSTRING(r.RacerName, CHARINDEX(' ', r.RacerName) + 1, 1))) AS ParticipantCode,
    r.RacerName,
    mc.CountryName AS RacerOrigin
FROM MsRacer r
JOIN RacerCar rc ON r.RacerID = rc.RacerID
JOIN MsCar c ON rc.CarID = c.CarID
JOIN MsCountry mc ON mc.CountryId = r.CountryId
JOIN MsBrand mb ON mb.BrandId = mb.BrandId
WHERE mb.BrandName = 'Bugatti'


--Q18
SELECT DISTINCT
    CASE
        WHEN RIGHT(eh.EventName, LEN('Grand Prix')) LIKE 'Grand Prix' THEN CONCAT(REPLACE(eh.EventName, 'Grand Prix', 'Championship'), ' ', mci.CircuitName)
        WHEN RIGHT(eh.EventName, LEN('Hours')) LIKE 'Hours' THEN REPLACE(eh.EventName, 'Hours', LEFT(mci.CircuitName, 5))
        ELSE CONCAT('Super', SUBSTRING(eh.EventName, CHARINDEX(' ', eh.EventName), LEN(eh.EventName)))
    END AS [Race Event],
    mci.CircuitName AS [Circuit Name]
FROM EventHeader eh
JOIN EventDetail ed ON eh.EventId = ed.EventId
JOIN RacerCar rc ON ed.RacerId = rc.RacerId
JOIN MsCar car ON rc.CarId = car.CarId
JOIN MsBrand b ON car.BrandId = b.BrandId
JOIN MsCircuit mci ON eh.CircuitId = mci.CircuitId
WHERE b.BrandName IN ('Porsche', 'Bugatti')


--Q19
--var1
SELECT 
    CONCAT(
        LEFT(r.RacerName, 1),                                              
        LEFT(c.CarName, 1),                                             
        REVERSE(RIGHT(eh.EventName, 1)),   
        CAST(DAY(eh.EventDate) + MONTH(eh.EventDate) AS varchar),        
        LEFT(r.RacerName, 1),                                            
        LOWER(SUBSTRING(r.RacerName, CHARINDEX(' ', r.RacerName) + 1, 1))) AS CredentialsCode,
    CONCAT(r.RacerName, ' (', UPPER(LEFT(co.CountryName, 2)), ')') AS RacerWithCountry,
    c.CarName,
    COUNT(ed.EventId) AS TotalEventsParticipated
FROM MsRacer r
JOIN RacerCar rc ON r.RacerId = rc.RacerId
JOIN MsCar c ON rc.CarId = c.CarId
JOIN MsBrand b ON c.BrandId = b.BrandId
JOIN EventDetail ed ON r.RacerId = ed.RacerId
JOIN EventHeader eh ON ed.EventId = eh.EventId
JOIN MsCircuit ci ON eh.CircuitId = ci.CircuitId
JOIN MsCountry co ON r.CountryId = co.CountryId
GROUP BY r.RacerName, c.CarName, eh.EventName, eh.EventDate, co.CountryName
HAVING (eh.EventName = 'Monaco Grand Prix' AND c.CarName LIKE '% % % %' AND COUNT(ed.EventId) > 10)
        OR
        (eh.EventName = 'Le Mans 24 Hours' AND c.CarName LIKE '% %' AND COUNT(ed.EventId) < 10);
--var2
SELECT 
    CONCAT(
        LEFT(r.RacerName, 1),                                              
        LEFT(c.CarName, 1),                                             
        REVERSE(RIGHT(eh.EventName, 1)),   
        CAST(DAY(eh.EventDate) + MONTH(eh.EventDate) AS varchar),        
        LEFT(r.RacerName, 1),                                            
        LOWER(SUBSTRING(r.RacerName, CHARINDEX(' ', r.RacerName) + 1, 1))
    ) AS CredentialsCode,
    CONCAT(r.RacerName, ' (', UPPER(LEFT(co.CountryName, 2)), ')') AS RacerWithCountry,
    c.CarName,
    COUNT(ed.EventId) AS TotalEventsParticipated
FROM MsRacer r
JOIN RacerCar rc ON r.RacerId = rc.RacerId
JOIN MsCar c ON rc.CarId = c.CarId
JOIN MsBrand b ON c.BrandId = b.BrandId
JOIN EventDetail ed ON r.RacerId = ed.RacerId
JOIN EventHeader eh ON ed.EventId = eh.EventId
JOIN MsCircuit ci ON eh.CircuitId = ci.CircuitId
JOIN MsCountry co ON r.CountryId = co.CountryId
WHERE eh.EventName = 'Monaco Grand Prix' AND c.CarName LIKE '% % % %'
GROUP BY r.RacerName, c.CarName, eh.EventName, eh.EventDate, co.CountryName
HAVING COUNT(ed.EventId) > 10
UNION
SELECT 
    CONCAT(
        LEFT(r.RacerName, 1),                                              
        LEFT(c.CarName, 1),                                             
        REVERSE(RIGHT(eh.EventName, 1)),   
        CAST(DAY(eh.EventDate) + MONTH(eh.EventDate) AS varchar),        
        LEFT(r.RacerName, 1),                                            
        LOWER(SUBSTRING(r.RacerName, CHARINDEX(' ', r.RacerName) + 1, 1))
    ) AS CredentialsCode,
    CONCAT(r.RacerName, ' (', UPPER(LEFT(co.CountryName, 2)), ')') AS RacerWithCountry,
    c.CarName,
    COUNT(ed.EventId) AS TotalEventsParticipated
FROM MsRacer r
JOIN RacerCar rc ON r.RacerId = rc.RacerId
JOIN MsCar c ON rc.CarId = c.CarId
JOIN MsBrand b ON c.BrandId = b.BrandId
JOIN EventDetail ed ON r.RacerId = ed.RacerId
JOIN EventHeader eh ON ed.EventId = eh.EventId
JOIN MsCircuit ci ON eh.CircuitId = ci.CircuitId
JOIN MsCountry co ON r.CountryId = co.CountryId
WHERE eh.EventName = 'Le Mans 24 Hours' AND c.CarName LIKE '% %'
GROUP BY r.RacerName, c.CarName, eh.EventName, eh.EventDate, co.CountryName
HAVING COUNT(ed.EventId) < 10;


--Q20
SELECT TOP 5
    CONCAT(
        LEFT(r.RacerName, CHARINDEX(' ', r.RacerName) - 1), 
        ' ''', co.CountryName, ''' ', 
        RIGHT(r.RacerName, LEN(r.RacerName) - CHARINDEX(' ', r.RacerName))
    ) AS RacerWithCountry,
    AVG(c.CarPower) AS CarStrength
FROM MsRacer r
JOIN RacerCar rc ON r.RacerId = rc.RacerId
JOIN MsCar c ON rc.CarId = c.CarId
JOIN MsCountry co ON r.CountryId = co.CountryId
GROUP BY r.RacerName, co.CountryName
ORDER BY CarStrength DESC