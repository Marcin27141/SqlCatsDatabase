//zadanie 47
//obiekty kocurow
CREATE OR REPLACE TYPE KOCURY_OBJ AS OBJECT
(pseudo VARCHAR2(15),
imie VARCHAR2(15),
plec VARCHAR2(1),
szef VARCHAR2(15),
w_stadku_od DATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
MEMBER FUNCTION Ile_lat_w_stadku RETURN NUMBER,
MEMBER FUNCTION Suma_myszy RETURN NUMBER);

CREATE OR REPLACE TYPE BODY KOCURY_OBJ AS
  MEMBER FUNCTION Ile_lat_w_stadku RETURN NUMBER IS
    BEGIN
      RETURN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM w_stadku_od);
    END;
  MEMBER FUNCTION Suma_myszy RETURN NUMBER IS
    BEGIN
      RETURN NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0);
    END;
END;

CREATE TABLE KOCURY_OBJ_T OF KOCURY_OBJ
(CONSTRAINT kobj_pk PRIMARY KEY (pseudo),
CONSTRAINT kobj_szef FOREIGN KEY (szef) REFERENCES KOCURY_OBJ_T(pseudo));

ALTER TABLE KOCURY_OBJ_T
DISABLE CONSTRAINT kobj_szef;
DESC KOCURY_OBJ_T

INSERT ALL
    INTO KOCURY_OBJ_T VALUES ('PLACEK', 'JACEK', 'M', 'LYSY', TO_DATE('2008-12-01', 'YYYY-MM-DD'), 67, NULL)
    INTO KOCURY_OBJ_T VALUES ('RURA', 'BARI', 'M', 'LYSY', TO_DATE('2009-09-01', 'YYYY-MM-DD'), 56, NULL)
    INTO KOCURY_OBJ_T VALUES ('LOLA', 'MICKA', 'D', 'TYGRYS', TO_DATE('2009-10-14', 'YYYY-MM-DD'), 25, 47)
    INTO KOCURY_OBJ_T VALUES ('ZERO', 'LUCEK', 'M', 'KURKA', TO_DATE('2010-03-01', 'YYYY-MM-DD'), 43, NULL)
    INTO KOCURY_OBJ_T VALUES ('PUSZYSTA', 'SONIA', 'D', 'ZOMBI', TO_DATE('2010-11-18', 'YYYY-MM-DD'), 20, 35)
    INTO KOCURY_OBJ_T VALUES ('UCHO', 'LATKA', 'D', 'RAFA', TO_DATE('2011-01-01', 'YYYY-MM-DD'), 40, NULL)
    INTO KOCURY_OBJ_T VALUES ('MALY', 'DUDEK', 'M', 'RAFA', TO_DATE('2011-05-15', 'YYYY-MM-DD'), 40, NULL)
    INTO KOCURY_OBJ_T VALUES ('TYGRYS', 'MRUCZEK', 'M', 'SZEFUNIO', TO_DATE('2002-01-01', 'YYYY-MM-DD'), 103, 33)
    INTO KOCURY_OBJ_T VALUES ('BOLEK', 'CHYTRY', 'M', 'TYGRYS', TO_DATE('2002-05-05', 'YYYY-MM-DD'), 50, NULL)
    INTO KOCURY_OBJ_T VALUES ('ZOMBI', 'KOREK', 'M', 'BANDZIOR', TO_DATE('2004-03-16', 'YYYY-MM-DD'), 75, 13)
    INTO KOCURY_OBJ_T VALUES ('LYSY', 'BOLEK', 'M', 'BANDZIOR', TO_DATE('2006-08-15', 'YYYY-MM-DD'), 72, 21)
    INTO KOCURY_OBJ_T VALUES ('SZYBKA', 'ZUZIA', 'D', 'LYSY', TO_DATE('2006-07-21', 'YYYY-MM-DD'), 65, NULL)
    INTO KOCURY_OBJ_T VALUES ('MALA', 'RUDA', 'D', 'TYGRYS', TO_DATE('2006-09-17', 'YYYY-MM-DD'), 22, 42)
    INTO KOCURY_OBJ_T VALUES ('RAFA', 'PUCEK', 'M', 'TYGRYS', TO_DATE('2006-10-15', 'YYYY-MM-DD'), 65, NULL)
    INTO KOCURY_OBJ_T VALUES ('KURKA', 'PUNIA', 'D', 'ZOMBI', TO_DATE('2008-01-01', 'YYYY-MM-DD'), 61, NULL)
    INTO KOCURY_OBJ_T VALUES ('LASKA', 'BELA', 'D', 'LYSY', TO_DATE('2008-02-01', 'YYYY-MM-DD'), 24, 28)
    INTO KOCURY_OBJ_T VALUES ('MAN', 'KSAWERY', 'M', 'RAFA', TO_DATE('2008-07-12', 'YYYY-MM-DD'), 51, NULL)
    INTO KOCURY_OBJ_T VALUES ('DAMA', 'MELA', 'D', 'RAFA', TO_DATE('2008-11-01', 'YYYY-MM-DD'), 51, NULL)
SELECT * FROM dual;

ALTER TABLE KOCURY_OBJ_T
ENABLE CONSTRAINT kobj_szef;

SELECT * FROM KOCURY_OBJ_T

//obiekty plebsu
CREATE OR REPLACE TYPE PLEBS_OBJ AS OBJECT
(nr NUMBER(3),
kot REF KOCURY_OBJ,
w_plebsie_od DATE,
MEMBER FUNCTION Przedstaw_kota RETURN VARCHAR2);

CREATE OR REPLACE TYPE BODY PLEBS_OBJ AS
  MEMBER FUNCTION Przedstaw_kota RETURN VARCHAR2 IS
        przedstawienie VARCHAR2(100);
      BEGIN
        SELECT 'Plebejusz ' || DEREF(kot).imie INTO przedstawienie FROM DUAL;
        RETURN przedstawienie;
      END;    
END;

CREATE TABLE PLEBS_OBJ_T OF PLEBS_OBJ
(CONSTRAINT pobj_pk PRIMARY KEY (nr));

INSERT INTO PLEBS_OBJ_T
SELECT PLEBS_OBJ(ROWNUM, REF(KT), SYSDATE)
FROM KOCURY_OBJ_T KT
WHERE KT.Suma_myszy() < 55;

SELECT * FROM PLEBS_OBJ_T

//obiekty elity
CREATE OR REPLACE TYPE ELITA_OBJ AS OBJECT
(nr NUMBER(3),
kot REF KOCURY_OBJ,
w_elicie_od DATE,
MEMBER FUNCTION Przedstaw_kota RETURN VARCHAR2);

CREATE OR REPLACE TYPE BODY ELITA_OBJ AS
  MEMBER FUNCTION Przedstaw_kota RETURN VARCHAR2 IS
        przedstawienie VARCHAR2(100);
      BEGIN
        SELECT 'Jego ekscelencja ' || DEREF(kot).imie INTO przedstawienie FROM DUAL;
        RETURN przedstawienie;
      END;    
END;

CREATE TABLE ELITA_OBJ_T OF ELITA_OBJ
(CONSTRAINT eobj_pk PRIMARY KEY (nr));

INSERT INTO ELITA_OBJ_T
SELECT ELITA_OBJ(ROWNUM, REF(KT), SYSDATE)
FROM KOCURY_OBJ_T KT
WHERE KT.Suma_myszy() > 75;

SELECT * FROM PLEBS_OBJ_T

//obiekty wpisow
CREATE OR REPLACE TYPE WPIS_KONTA_OBJ AS OBJECT
(
  nr NUMBER(3),
  kot REF ELITA_OBJ,
  data_wprowadzenia DATE,
  data_usuniecia DATE,
  MEMBER PROCEDURE usun_mysz
);

CREATE OR REPLACE TYPE BODY WPIS_KONTA_OBJ AS
  MEMBER PROCEDURE usun_mysz IS
    BEGIN
      data_usuniecia := SYSDATE;
    END;
END;

CREATE TABLE WPIS_KONTA_OBJ_T OF WPIS_KONTA_OBJ
(CONSTRAINT wobj_pk PRIMARY KEY (nr));

INSERT INTO WPIS_KONTA_OBJ_T
SELECT WPIS_KONTA_OBJ(1, REF(E), SYSDATE, NULL)
FROM ELITA_OBJ_T E
WHERE VALUE(E).kot.pseudo = 'TYGRYS'

INSERT INTO WPIS_KONTA_OBJ_T
SELECT WPIS_KONTA_OBJ(2, REF(E), SYSDATE, SYSDATE)
FROM ELITA_OBJ_T E
WHERE VALUE(E).kot.pseudo = 'TYGRYS'

INSERT INTO WPIS_KONTA_OBJ_T
SELECT WPIS_KONTA_OBJ(3, REF(E), SYSDATE, NULL)
FROM ELITA_OBJ_T E
WHERE VALUE(E).kot.pseudo = 'ZOMBI'

SELECT * FROM WPIS_KONTA_OBJ_T

//panowie i sludzy
CREATE OR REPLACE TYPE PANOWIE_SLUDZY_OBJ AS OBJECT
(
  nr NUMBER(3),
  pan REF ELITA_OBJ,
  sluga REF PLEBS_OBJ,
  od_kiedy DATE
);

CREATE TABLE PANOWIE_SLUDZY_OBJ_T OF PANOWIE_SLUDZY_OBJ
(CONSTRAINT psobj_pk PRIMARY KEY (nr));

INSERT INTO PANOWIE_SLUDZY_OBJ_T
SELECT PANOWIE_SLUDZY_OBJ(ROWNUM, REF(E), REF(P), SYSDATE)
FROM ELITA_OBJ_T E, PLEBS_OBJ_T P 
WHERE VALUE(E).kot.pseudo = 'TYGRYS' AND VALUE(P).kot.pseudo = 'UCHO'

SELECT * FROM PANOWIE_SLUDZY_OBJ_T

//przyklady
//referencja
SELECT VALUE(PS).pan.Przedstaw_kota() || ' ma sluge: ' || VALUE(PS).sluga.Przedstaw_kota() || ' od ' || od_kiedy "Panowie i sludzy"
FROM PANOWIE_SLUDZY_OBJ_T PS

//podzapytanie
SELECT *
FROM KOCURY_OBJ_T
WHERE pseudo IN(
    (SELECT PS.pan.kot.pseudo
    FROM PANOWIE_SLUDZY_OBJ_T PS
    WHERE PS.pan.kot.pseudo = 'TYGRYS'),
    (SELECT PS.sluga.kot.pseudo
    FROM PANOWIE_SLUDZY_OBJ_T PS
    WHERE PS.pan.kot.pseudo = 'TYGRYS')
)

//grupowanie
SELECT VALUE(W).kot.kot.pseudo, COUNT(*) "Myszy w historii", COUNT(*) - COUNT(data_usuniecia) "Dostepne myszy"
FROM WPIS_KONTA_OBJ_T W
GROUP BY VALUE(W).kot.kot.pseudo


//lista 2
//zadanie 18
SELECT K1.imie, K1.w_stadku_od "POLUJE OD"
FROM KOCURY_OBJ_T K1, KOCURY_OBJ_T K2
WHERE K2.imie = 'JACEK' AND K1.w_stadku_od < K2.w_stadku_od
ORDER BY K1.w_stadku_od DESC;

//zadanie 23
SELECT imie,
    K.Suma_myszy() * 12 "DAWKA ROCZNA",
    'powyzej 864' "DAWKA"
FROM KOCURY_OBJ_T K
WHERE NVL(myszy_extra, 0) > 0 AND K.Suma_myszy() * 12 > 864
UNION ALL
SELECT imie,
    K.Suma_myszy() * 12 "DAWKA ROCZNA",
    '864' "DAWKA"
FROM KOCURY_OBJ_T K
WHERE NVL(myszy_extra, 0) > 0 AND K.Suma_myszy() * 12 = 864
UNION ALL
SELECT imie,
    K.Suma_myszy() * 12 "DAWKA ROCZNA",
    'ponizej 864' "DAWKA"
FROM KOCURY_OBJ_T K
WHERE NVL(myszy_extra, 0) > 0 AND K.Suma_myszy() * 12 < 864
ORDER BY 2 DESC

//lista 3
//zadanie 35
DECLARE
    pseudoIn VARCHAR(15) := '&pseudo';
    kocur KOCURY_OBJ;
    DUZO_MYSZY CONSTANT NUMBER(3) := 700;
    SZUKANY_MIESIAC CONSTANT NUMBER(2) := 5;
BEGIN
    SELECT KOCURY_OBJ(pseudo, imie, plec, szef, w_stadku_od, przydzial_myszy, myszy_extra)
    INTO kocur
    FROM KOCURY_OBJ_T
    WHERE pseudo = pseudoIn;
    CASE
        WHEN kocur.Suma_myszy() * 12 > DUZO_MYSZY
            THEN DBMS_OUTPUT.PUT_LINE('calkowity roczny przydzial myszy > 700');
        WHEN kocur.imie LIKE '%A%'
            THEN DBMS_OUTPUT.PUT_LINE('imie zawiera litere A');
        WHEN EXTRACT(MONTH FROM kocur.w_stadku_od) = SZUKANY_MIESIAC
            THEN DBMS_OUTPUT.PUT_LINE('maj jest miesiacem przystapienia do stada');
        ELSE
            DBMS_OUTPUT.PUT_LINE('nie odpowiada kryteriom');
    END CASE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota o podanym pseudonimie');
END;

//zadanie 37
DECLARE
    CURSOR ranking IS
    SELECT pseudo, K.Suma_myszy() sumaMyszy
    FROM KOCURY_OBJ_T K
    ORDER BY 2 DESC;
    i NUMBER(1) := 1;
    ILE_MIEJSC CONSTANT NUMBER(1) := 5;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Nr  Pseudonim    Zjada');
    DBMS_OUTPUT.PUT_LINE('----------------------');
    FOR kocur IN ranking LOOP
        EXIT WHEN i > ILE_MIEJSC;
        DBMS_OUTPUT.PUT_LINE(i||'   '||RPAD(kocur.pseudo, 8, ' ')||'     '||kocur.sumaMyszy);
        i := i + 1;
    END LOOP;
END;

//zad 48
CREATE TABLE Elita
(pseudo VARCHAR2(15) CONSTRAINT el_ps_pk PRIMARY KEY
    CONSTRAINT el_ps_fk REFERENCES Kocury(pseudo),
w_elicie_od DATE
);

CREATE TABLE Plebs
(pseudo VARCHAR2(15) CONSTRAINT pl_ps_pk PRIMARY KEY
    CONSTRAINT pl_ps_fk REFERENCES Kocury(pseudo),
w_plebsie_od DATE
);

CREATE TABLE Panowie_sludzy
(pan VARCHAR2(15) CONSTRAINT ps_pan_fk REFERENCES Elita(pseudo),
sluga VARCHAR2(15) CONSTRAINT ps_sl_fk REFERENCES Plebs(pseudo),
od_kiedy DATE CONSTRAINT ps_od_nn NOT NULL,
CONSTRAINT ps_pasl_pk PRIMARY KEY(pan, sluga)
);

CREATE TABLE Elitarne_konto
(nr_myszy NUMBER(4) CONSTRAINT el_nr_pk PRIMARY KEY,
kot VARCHAR2(15) CONSTRAINT el_ko_fk REFERENCES Elita(pseudo),
data_wprowadzenia DATE CONSTRAINT el_dw_nn NOT NULL,
data_usuniecia DATE
);

CREATE OR REPLACE TYPE KOCURY_PERS_OBJ AS OBJECT
(pseudo VARCHAR2(15),
imie VARCHAR2(15),
plec VARCHAR2(1),
funkcja VARCHAR2(10),
szef REF KOCURY_PERS_OBJ,
w_stadku_od DATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
nr_bandy NUMBER(2),
MEMBER FUNCTION Ile_lat_w_stadku RETURN NUMBER,
MEMBER FUNCTION Suma_myszy RETURN NUMBER
)

CREATE OR REPLACE TYPE BODY KOCURY_PERS_OBJ AS
  MEMBER FUNCTION Ile_lat_w_stadku RETURN NUMBER IS
    BEGIN
      RETURN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM w_stadku_od);
    END;
  MEMBER FUNCTION Suma_myszy RETURN NUMBER IS
    BEGIN
      RETURN NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0);
    END;
END;

CREATE OR REPLACE VIEW KOCUR_OBJ_PERS OF KOCURY_PERS_OBJ
WITH OBJECT IDENTIFIER (pseudo) AS
SELECT KOCURY_PERS_OBJ(pseudo, imie, plec, funkcja, NULL, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
FROM Kocury;

CREATE OR REPLACE VIEW KOCURY_OBJ_PERS OF KOCURY_PERS_OBJ
WITH OBJECT IDENTIFIER (pseudo) AS
SELECT KOCURY_PERS_OBJ(pseudo, imie, plec, funkcja, MAKE_REF(KOCUR_OBJ_PERS, szef), w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
FROM Kocury;

CREATE OR REPLACE TYPE PLEBS_PERS_OBJ AS OBJECT
(nr NUMBER(3),
pseudo REF KOCURY_PERS_OBJ,
w_plebsie_od DATE,
MEMBER FUNCTION Przedstaw_kota RETURN VARCHAR2
)


CREATE OR REPLACE TYPE BODY PLEBS_PERS_OBJ AS
  MEMBER FUNCTION Przedstaw_kota RETURN VARCHAR2 IS
        przedstawienie VARCHAR2(100);
      BEGIN
        SELECT 'Plebejusz ' || DEREF(pseudo).imie INTO przedstawienie FROM DUAL;
        RETURN przedstawienie;
      END;    
END;

CREATE OR REPLACE VIEW PLEBS_OBJ_PERS OF PLEBS_PERS_OBJ
WITH OBJECT IDENTIFIER (nr) AS
SELECT 0, MAKE_REF(KOCURY_OBJ_PERS, pseudo) kot, w_plebsie_od
FROM Plebs;


CREATE OR REPLACE TYPE ELITA_PERS_OBJ AS OBJECT
(nr NUMBER(3),
kot REF KOCURY_PERS_OBJ,
w_elicie_od DATE,
MEMBER FUNCTION Przedstaw_kota RETURN VARCHAR2
)

CREATE OR REPLACE TYPE BODY ELITA_PERS_OBJ AS
  MEMBER FUNCTION Przedstaw_kota RETURN VARCHAR2 IS
        przedstawienie VARCHAR2(100);
      BEGIN
        SELECT 'Jego ekscelencja ' || DEREF(kot).imie INTO przedstawienie FROM DUAL;
        RETURN przedstawienie;
      END;    
END;

CREATE OR REPLACE VIEW ELITA_OBJ_PERS OF ELITA_PERS_OBJ
WITH OBJECT IDENTIFIER (nr) AS
SELECT 0, MAKE_REF(KOCURY_OBJ_PERS, pseudo) kot, w_elicie_od
FROM Elita;

CREATE OR REPLACE TYPE PANOWIE_SLUDZY_PERS_OBJ AS OBJECT
(nr NUMBER(3),
pan REF ELITA_PERS_OBJ,
sluga REF PLEBS_PERS_OBJ,
od_kiedy DATE
)

CREATE OR REPLACE VIEW PANOWIE_SLUDZY_OBJ_PERS OF PANOWIE_SLUDZY_PERS_OBJ
WITH OBJECT IDENTIFIER (nr) AS
SELECT 0, MAKE_REF(ELITA_OBJ_PERS, pan) pan, MAKE_REF(PLEBS_OBJ_PERS, sluga), od_kiedy
FROM Panowie_sludzy;

CREATE OR REPLACE TYPE WPIS_KONTA_PERS_OBJ AS OBJECT
(nr NUMBER(3),
kot REF ELITA_PERS_OBJ,
data_wprowadzenie DATE,
data_usuniecia DATE,
MEMBER PROCEDURE usun_mysz
)

CREATE OR REPLACE TYPE BODY WPIS_KONTA_PERS_OBJ AS
  MEMBER PROCEDURE usun_mysz IS
    BEGIN
      data_usuniecia := SYSDATE;
    END;   
END;

CREATE OR REPLACE VIEW ELITARNE_KONTO_OBJ_PERS OF WPIS_KONTA_PERS_OBJ
WITH OBJECT IDENTIFIER (nr) AS
SELECT 0, MAKE_REF(ELITA_OBJ_PERS, kot) pan, data_wprowadzenia, data_usuniecia
FROM Elitarne_konto;

INSERT INTO Plebs
SELECT pseudo, SYSDATE
FROM KOCURY_OBJ_PERS K
WHERE K.Suma_myszy() < 55;

SELECT * FROM Plebs
SELECT * FROM PLEBS_OBJ_PERS

INSERT INTO Elita
SELECT pseudo, SYSDATE
FROM KOCURY_OBJ_PERS K
WHERE K.Suma_myszy() > 70;

SELECT * FROM Elita
SELECT * FROM ELITA_OBJ_PERS

INSERT ALL
    INTO Panowie_sludzy VALUES ('TYGRYS', 'UCHO',SYSDATE)
    INTO Panowie_sludzy VALUES ('ZOMBI', 'ZERO', SYSDATE)
SELECT * FROM dual;

SELECT * FROM Panowie_sludzy
SELECT * FROM PANOWIE_SLUDZY_OBJ_PERS //TODO

INSERT ALL
    INTO Elitarne_konto VALUES (1, 'TYGRYS', SYSDATE, NULL)
    INTO Elitarne_konto VALUES (2, 'TYGRYS', SYSDATE, NULL)
    INTO Elitarne_konto VALUES (3, 'TYGRYS', SYSDATE, SYSDATE)
    INTO Elitarne_konto VALUES (4, 'ZOMBI', SYSDATE, SYSDATE)
    INTO Elitarne_konto VALUES (5, 'ZOMBI', SYSDATE, SYSDATE)
    INTO Elitarne_konto VALUES (6, 'LOLA', SYSDATE, NULL)
    INTO Elitarne_konto VALUES (7, 'LYSY', SYSDATE, NULL)
SELECT * FROM dual;

SELECT * FROM Elitarne_konto
SELECT * FROM ELITARNE_KONTO_OBJ_PERS //TODO