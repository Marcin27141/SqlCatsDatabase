//obiekty osob i adresow
CREATE OR REPLACE TYPE ADRESY AS OBJECT
(ulica VARCHAR2(25),
nr_domu NUMBER(2));

ALTER TYPE ADRESY REPLACE AS OBJECT
(ulica VARCHAR2(25),
nr_domu NUMBER(2),
MEMBER FUNCTION Daj_ulice RETURN VARCHAR2);

DESC ADRESY

CREATE OR REPLACE TYPE BODY ADRESY AS
    MEMBER FUNCTION Daj_ulice RETURN VARCHAR2 IS
    BEGIN
        RETURN ulica;
    END;
END;

CREATE OR REPLACE TYPE OSOBY AS OBJECT
(imie VARCHAR2(15),
adres ADRESY,
MAP MEMBER FUNCTION Porownaj RETURN VARCHAR2,
MEMBER FUNCTION Dane RETURN VARCHAR2,
PRAGMA RESTRICT_REFERENCES(Dane,RNDS,WNDS,RNPS,WNPS))
NOT FINAL;

CREATE OR REPLACE TYPE BODY OSOBY AS
    MAP MEMBER FUNCTION Porownaj RETURN VARCHAR2 IS
    BEGIN
        RETURN imie||adres.ulica||adres.nr_domu;
    END;
    MEMBER FUNCTION Dane RETURN VARCHAR2 IS
    BEGIN
        RETURN imie||', '||adres.ulica||' '||adres.nr_domu;
    END Dane;
END;

CREATE TABLE Mety
(pseudo VARCHAR2(15) CONSTRAINT me_pk PRIMARY KEY CONSTRAINT me_ko_fk REFERENCES Kocury(pseudo),
osoba OSOBY);

//INSERT dodawanie obiektow do relacji
INSERT INTO Mety VALUES('TYGRYS', OSOBY('JAN', ADRESY('POLNA', 2)));
INSERT INTO Mety VALUES('LOLA', OSOBY('JAN', ADRESY('POLNA', 2)));
INSERT INTO Mety VALUES('BOLEK', OSOBY('ZOFIA', ADRESY('KOZIA', 7)));
INSERT INTO Mety VALUES('MALY', OSOBY('ADAM', ADRESY('MOKRA', 21)));

SELECT pseudo, M.osoba.Dane() "Meta"
FROM Mety M
ORDER BY osoba;

SELECT pseudo, M.osoba.Dane()
FROM Mety M NATURAL JOIN Kocury
WHERE plec='M'

//GROUP BY grouping objects
SELECT M.osoba.dane() "Osoba", COUNT(*) "Liczba kotow"
FROM Mety M
GROUP BY osoba;

SELECT M.osoba.imie, COUNT(*)
FROM Mety M
GROUP BY M.osoba.imie

//UPDATE modifying objects
UPDATE Mety
SET osoba=OSOBY('KAROLA', ADRESY('ZIELONA', 16))
WHERE pseudo='BOLEK';

UPDATE Mety M
SET M.osoba.imie='KLAUDIA'
WHERE pseudo='BOLEK';

ROLLBACK;

//object tables
CREATE TABLE OsobyR OF OSOBY
(CONSTRAINT osr_pk PRIMARY KEY (imie));

INSERT INTO OsobyR VALUES(OSOBY('JAN', ADRESY('POLNA', 2)))
INSERT INTO OsobyR VALUES('ZOFIA', ADRESY('KOZIA', 7))
INSERT INTO OsobyR VALUES('ADAM', ADRESY('MOKRA', 21))

SELECT REF(OsR), imie, VALUE(OsR).adres.ulica
FROM OsobyR OsR;

//obiekty i indeksy
CREATE INDEX Mety_imie_ind
ON Mety(osoba.imie)

CREATE INDEX OsobyR_ulica_ind
ON OsobyR(adres.ulica);

//dziedziczenie obiektow
CREATE OR REPLACE TYPE OSOBY_OBCE UNDER OSOBY
(miasto VARCHAR2(25),
MEMBER FUNCTION Dane_obce RETURN VARCHAR2,
PRAGMA RESTRICT_REFERENCES(Dane_obce,RNDS,WNDS,RNPS,WNPS))
FINAL;

CREATE OR REPLACE TYPE BODY OSOBY_OBCE AS
    MEMBER FUNCTION Dane_obce RETURN VARCHAR2 IS
        BEGIN
            RETURN miasto||', '||SELF.Dane();
        END Dane_obce;
END;

CREATE TABLE Mety_obce
(pseudo VARCHAR2(15)
    CONSTRAINT meo_pk PRIMARY KEY
    CONSTRAINT meo_ko_fk REFERENCES Kocury(pseudo),
osoba OSOBY_OBCE);

INSERT INTO Mety_obce
VALUES('TYGRYS',OSOBY_OBCE('MARIA',ADRESY('ZLOTA',22), 'WARSZAWA'));

INSERT INTO Mety_obce
VALUES('LOLA',OSOBY_OBCE('MARIA',ADRESY('ZLOTA',22),'WARSZAWA'));

INSERT INTO Mety_obce
VALUES('BOLEK',OSOBY_OBCE('ZENON',ADRESY('WEGLOWA',17),'KATOWICE'));

INSERT INTO Mety_obce
VALUES('MALY',OSOBY_OBCE('ROMAN',ADRESY('PYRY',11),'POZNAN'));

SELECT pseudo, M.osoba.Dane_obce()
FROM Mety_obce M;

//powiazania referencyjne obiektow
CREATE TABLE MetyO
(pseudo VARCHAR2(15) CONSTRAINT meob_pk PRIMARY KEY
    CONSTRAINT meob_ko_fk REFERENCES Kocury(pseudo),
osoba REF OSOBY SCOPE IS OsobyR);

INSERT INTO MetyO
SELECT 'TYGRYS', REF(O) FROM OsobyR O WHERE O.imie='JAN';

INSERT INTO MetyO
SELECT 'LOLA',REF(O) FROM OsobyR O WHERE O.imie='JAN';

INSERT INTO MetyO
SELECT 'BOLEK',REF(O) FROM OsobyR O WHERE O.imie='ZOFIA';

INSERT INTO MetyO
SELECT 'MALY',REF(O) FROM OsobyR O WHERE O.imie='ADAM';

SELECT * FROM MetyO

SELECT pseudo, O.osoba.imie, O.osoba.Dane()
FROM MetyO O

SELECT DEREF(osoba) "Gospodarz"
FROM MetyO
WHERE pseudo='MALY'

//object perspectives
CREATE TABLE Mety1
(pseudo VARCHAR2(15) CONSTRAINT me1_pk PRIMARY KEY
    CONSTRAINT me1_ko_fk REFERENCES Kocury(pseudo),
imie VARCHAR2(15),
ulica VARCHAR2(25),
nr_domu NUMBER(2));

INSERT INTO Mety1 VALUES('TYGRYS','JAN','POLNA',2);
INSERT INTO Mety1 VALUES('LOLA','JAN','POLNA',2);
INSERT INTO Mety1 VALUES('BOLEK','ZOFIA','KOZIA',7);
INSERT INTO Mety1 VALUES('MALY','ADAM','MOKRA',21);

CREATE OR REPLACE VIEW Mety_po (pseudo,osoba) AS
SELECT pseudo,OSOBY(imie,ADRESY(ulica,nr_domu))
FROM Mety1;

SELECT pseudo "Kot",M.osoba.Dane() "Meta"
FROM Mety_po M
ORDER BY osoba;

//modelling reference bindings
CREATE OR REPLACE TYPE KOCURY_TYP AS OBJECT
(imie VARCHAR2(15),
plec VARCHAR2(1),
pseudo VARCHAR2(15),
funkcja VARCHAR2(10),
szef VARCHAR2(15),
w_stadku_od DATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
nr_bandy NUMBER(2),
MEMBER FUNCTION O_plci RETURN VARCHAR2,
MEMBER FUNCTION Dochod_myszowy RETURN NUMBER);

CREATE OR REPLACE TYPE BODY KOCURY_TYP AS
    MEMBER FUNCTION O_plci RETURN VARCHAR2 IS
        BEGIN
            RETURN CASE NVL(plec,'N')
                WHEN 'M' THEN 'Kocur'
                WHEN 'D' THEN 'Kotka'
                WHEN 'N' THEN 'Nieznana'
                ELSE 'Bledna'
             END;
        END;
    MEMBER FUNCTION Dochod_myszowy RETURN NUMBER IS
        BEGIN
            RETURN NVL(przydzial_myszy,0)+
            NVL(myszy_extra,0);
        END;
END;

CREATE OR REPLACE VIEW Kocury_zoid OF KOCURY_TYP
WITH OBJECT IDENTIFIER (pseudo) AS
SELECT imie,plec,pseudo,funkcja,szef,
    w_stadku_od,przydzial_myszy,myszy_extra,
    nr_bandy
FROM Kocury;

CREATE OR REPLACE VIEW Mety_zoid AS
SELECT MAKE_REF(Kocury_zoid,pseudo) pseudo, imie,ulica,nr_domu
FROM Mety1;

SELECT MOID.pseudo.pseudo "Kot",
MOID.pseudo.O_plci() "Plec",
ulica||' '||nr_domu "Adres"
FROM Mety_zoid MOID
WHERE imie='JAN';

CREATE OR REPLACE TYPE METY1_TYP AS OBJECT
(id_pseudo VARCHAR2(15),
pseudo REF KOCURY_TYP,
imie VARCHAR2(15),
ulica VARCHAR2(25),
nr_domu NUMBER(2));

CREATE OR REPLACE VIEW Mety1_zoid OF METY1_TYP
WITH OBJECT IDENTIFIER (id_pseudo) AS
SELECT pseudo id_pseudo, MAKE_REF(Kocury_zoid,pseudo) pseudo, imie,ulica,nr_domu
FROM Mety1;

//objects in pl/sql
//cursor with reference objects
SET SERVEROUTPUT ON
DECLARE
    kot KOCURY_TYP;
    CURSOR myszy_dam IS
    SELECT VALUE(KO)
    FROM Kocury_zoid KO
    WHERE KO.O_plci()='Kotka';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Pseudo kotki    Placa');
    DBMS_OUTPUT.PUT_LINE('---------------------');
    OPEN myszy_dam;
    LOOP
        FETCH myszy_dam INTO kot;
        EXIT WHEN myszy_dam%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(kot.pseudo,15,' ')||' '||kot.Dochod_myszowy());
    END LOOP;
    CLOSE myszy_dam;
END;


DECLARE
   kot KOCURY_TYP:=KOCURY_TYP('RYCHO','M','GRUBY','KOT',
                       'TYGRYS','2012-02-09',50,NULL,1);
   k KOCURY_TYP;
   ma Funkcje.max_myszy%TYPE;
   mi Funkcje.min_myszy%TYPE;
   i NUMBER;
   istniejacy_pseudonim EXCEPTION;
   poza_widelkami EXCEPTION;
BEGIN
   SELECT COUNT(*) INTO i FROM Kocury_zoid
   WHERE pseudo=kot.pseudo;
   IF i>0 THEN RAISE istniejacy_pseudonim;
   END IF;
   SELECT max_myszy,min_myszy INTO ma,mi
   FROM Funkcje
   WHERE funkcja=kot.funkcja;
   IF kot.przydzial_myszy BETWEEN mi AND ma
      THEN INSERT INTO Kocury_zoid VALUES (kot);
      ELSE RAISE poza_widelkami;
   END IF;
   SELECT AVG(KZ.Dochod_myszowy()) INTO i
   FROM Kocury_zoid KZ;
   FOR kotek IN (SELECT VALUE(KK) ko
                 FROM Kocury_zoid KK)
   LOOP
    k:=kotek.ko;
    IF k.Dochod_myszowy()<i
    THEN UPDATE Kocury_zoid
         SET myszy_extra=NVL(myszy_extra,0)+5
         WHERE pseudo=k.pseudo;
    END IF;
   END LOOP;

EXCEPTION
   WHEN istniejacy_pseudonim
    THEN DBMS_OUTPUT.PUT_LINE('Pseudonim juz istnieje!!!');
   WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Bledna funkcja!!!');
   WHEN poza_widelkami THEN
    DBMS_OUTPUT.PUT_LINE('Myszy poza widelkami!!!');
   WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

SELECT pseudo "Pseudonim", K.O_plci() "Plec",
K.Dochod_myszowy() "Dochod myszowy"
FROM Kocury_zoid K
WHERE funkcja='KOT';

//nested tables
CREATE OR REPLACE TYPE PRZEWINA_KOTA AS OBJECT
(data_przewiny DATE,
opis_przewiny VARCHAR2(50));

CREATE OR REPLACE TYPE LISTA_PRZEWIN
AS TABLE OF PRZEWINA_KOTA;

CREATE TABLE Przewiny
(pseudo VARCHAR2(15) PRIMARY KEY REFERENCES Kocury(pseudo),
o_przewinach LISTA_PRZEWIN)
NESTED TABLE o_przewinach STORE AS Sklad_przewin;

//nested table insert

INSERT INTO Przewiny VALUES
('SZYBKA',
LISTA_PRZEWIN(
PRZEWINA_KOTA ('2011-01-03',
'ZBYT NATARCZYWIE DOMAGA SIE NAGRODY'),
PRZEWINA_KOTA ('2011-01-04',
'AWANTURA Z POWODU BRAKU NAGRODY')));

DECLARE
pierwsza_przewina LISTA_PRZEWIN:=
    LISTA_PRZEWIN(PRZEWINA_KOTA('2011-01-01', 'ZJEDZENIE UPOLOWANEJ MYSZY'));
BEGIN
    INSERT INTO Przewiny VALUES ('ZERO',pierwsza_przewina);
END;
/
COMMIT;

//nested table modification
INSERT INTO TABLE(SELECT o_przewinach
                FROM Przewiny
                WHERE pseudo='ZERO')
VALUES (PRZEWINA_KOTA('2011-01-10',
'ZJEDZENIE UPOLOWANEJ MYSZY'));
ROLLBACK;

DECLARE
    tabela_przewin Przewiny.o_przewinach%TYPE;
    nowa_przewina PRZEWINA_KOTA:=
        PRZEWINA_KOTA('2011-01-10','ZJEDZENIE UPOLOWANEJ MYSZY');
BEGIN
    SELECT o_przewinach INTO tabela_przewin
    FROM Przewiny WHERE pseudo='ZERO';
    tabela_przewin.EXTEND;
    tabela_przewin(tabela_przewin.COUNT):=nowa_przewina;
    UPDATE Przewiny
    SET o_przewinach=tabela_przewin
    WHERE pseudo='ZERO';
END;
/

//showing nested table data
SELECT pseudo "Winowajca",data_przewiny "Data", opis_przewiny "Wystepek"
FROM Przewiny P,
TABLE(SELECT o_przewinach
FROM Przewiny WHERE pseudo='ZERO')
WHERE P.pseudo='ZERO';

SET SERVEROUTPUT ON
//assigning a nested table to pl/sql variable gives it indexes from 1 to COUNT
DECLARE
    tabela_przewin Przewiny.o_przewinach%TYPE;
    p Przewiny.pseudo%TYPE:='&1';
BEGIN
    SELECT o_przewinach INTO tabela_przewin FROM Przewiny
    WHERE pseudo=p;
    DBMS_OUTPUT.PUT_LINE('Przewiny kota o pseudonimie '||p);
    FOR i IN 1..tabela_przewin.COUNT
    LOOP
        DBMS_OUTPUT.PUT(tabela_przewin(i).data_przewiny);
        DBMS_OUTPUT.PUT_LINE
        ('  '||tabela_przewin(i).opis_przewiny);
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE
    ('Zly pseudonim');
END;
/

//variable-length tables
CREATE OR REPLACE TYPE LISTA_PRZEWIN1
AS VARRAY(20) OF PRZEWINA_KOTA;

CREATE TABLE Przewiny1
(pseudo VARCHAR2(15)PRIMARY KEY REFERENCES Kocury(pseudo),
o_przewinach LISTA_PRZEWIN1);


//varray elements cant be modified with DML
DECLARE
   tabela_przewin LISTA_PRZEWIN1:=LISTA_PRZEWIN1();
   p Przewiny1.pseudo%TYPE:='&pseudonim_kota';
   nowa_przewina PRZEWINA_KOTA:=
        PRZEWINA_KOTA('&data_przewiny','&opis_przewiny');
   lp NUMBER;
BEGIN
   SELECT COUNT(*) INTO lp FROM Kocury WHERE pseudo=p;
   IF lp=0 THEN
      RAISE_APPLICATION_ERROR(-20101,'Zly pseudonim');
   END IF;
   SELECT COUNT(*) INTO lp FROM Przewiny1 WHERE pseudo=p;
   IF lp=0 THEN
      tabela_przewin.EXTEND;
      tabela_przewin(1):=nowa_przewina;
      INSERT INTO Przewiny1 VALUES (p,tabela_przewin);
   ELSE
      SELECT o_przewinach INTO tabela_przewin
      FROM Przewiny1 WHERE pseudo=p;
      IF tabela_przewin.COUNT=tabela_przewin.LIMIT THEN
         RAISE_APPLICATION_ERROR
                   (-20102,'Wyczerpany limit przewin');
      END IF;
      tabela_przewin.EXTEND;
      tabela_przewin(tabela_przewin.COUNT):=
                                            nowa_przewina;
      UPDATE Przewiny1 SET o_przewinach=tabela_przewin
      WHERE pseudo=p;
   END IF;
END;
/

SELECT pseudo "Winowajca",data_przewiny "Data", opis_przewiny "Wystepek"
FROM Przewiny1 P1,
TABLE(SELECT o_przewinach
    FROM Przewiny1 WHERE pseudo='LOLA')
WHERE P1.pseudo='LOLA';



