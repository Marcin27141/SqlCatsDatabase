//zadanie 47
//obiekty kocurow
CREATE OR REPLACE TYPE KOCUR_OBJ AS OBJECT
(pseudo VARCHAR2(15),
imie VARCHAR2(15),
plec VARCHAR2(1),
szef REF KOCUR_OBJ,
w_stadku_od DATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
funkcja VARCHAR2(10),
MEMBER FUNCTION Ile_lat_w_stadku RETURN NUMBER,
MEMBER FUNCTION Suma_myszy RETURN NUMBER);

CREATE OR REPLACE TYPE BODY KOCUR_OBJ AS
  MEMBER FUNCTION Ile_lat_w_stadku RETURN NUMBER IS
    BEGIN
      RETURN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM w_stadku_od);
    END;
  MEMBER FUNCTION Suma_myszy RETURN NUMBER IS
    BEGIN
      RETURN NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0);
    END;
END;

CREATE TABLE KOCURY_OBJ_T OF KOCUR_OBJ
(CONSTRAINT koob_ps_pk PRIMARY KEY (pseudo));

INSERT INTO KOCURY_OBJ_T VALUES ('TYGRYS', 'MRUCZEK', 'M', NULL, TO_DATE('2002-01-01', 'YYYY-MM-DD'), 103, 33, 'SZEFUNIO');
INSERT INTO KOCURY_OBJ_T VALUES ('BOLEK', 'CHYTRY', 'M', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'TYGRYS'), TO_DATE('2002-05-05', 'YYYY-MM-DD'), 50, NULL, 'DZIELCZY');
INSERT INTO KOCURY_OBJ_T VALUES ('LYSY', 'BOLEK', 'M', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'TYGRYS'), TO_DATE('2006-08-15', 'YYYY-MM-DD'), 72, 21, 'BANDZIOR');
INSERT INTO KOCURY_OBJ_T VALUES ('ZOMBI', 'KOREK', 'M', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'TYGRYS'), TO_DATE('2004-03-16', 'YYYY-MM-DD'), 75, 13, 'BANDZIOR');
INSERT INTO KOCURY_OBJ_T VALUES ('RAFA', 'PUCEK', 'M', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'TYGRYS'), TO_DATE('2006-10-15', 'YYYY-MM-DD'), 65, NULL, 'LOWCZY');
INSERT INTO KOCURY_OBJ_T VALUES ('MAN', 'KSAWERY', 'M', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'RAFA'), TO_DATE('2008-07-12', 'YYYY-MM-DD'), 51, NULL, 'LAPACZ');
INSERT INTO KOCURY_OBJ_T VALUES ('DAMA', 'MELA', 'D', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'RAFA'), TO_DATE('2008-11-01', 'YYYY-MM-DD'), 51, NULL, 'LAPACZ');
INSERT INTO KOCURY_OBJ_T VALUES ('PLACEK', 'JACEK', 'M', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'LYSY'), TO_DATE('2008-12-01', 'YYYY-MM-DD'), 67, NULL, 'LOWCZY');
INSERT INTO KOCURY_OBJ_T VALUES ('RURA', 'BARI', 'M', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'LYSY'), TO_DATE('2009-09-01', 'YYYY-MM-DD'), 56, NULL, 'LAPACZ');
INSERT INTO KOCURY_OBJ_T VALUES ('LOLA', 'MICKA', 'D', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'TYGRYS'), TO_DATE('2009-10-14', 'YYYY-MM-DD'), 25, 47, 'MILUSIA');
INSERT INTO KOCURY_OBJ_T VALUES ('KURKA', 'PUNIA', 'D', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'ZOMBI'), TO_DATE('2008-01-01', 'YYYY-MM-DD'), 61, NULL, 'LOWCZY');
INSERT INTO KOCURY_OBJ_T VALUES ('ZERO', 'LUCEK', 'M', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'KURKA'), TO_DATE('2010-03-01', 'YYYY-MM-DD'), 43, NULL, 'KOT');
INSERT INTO KOCURY_OBJ_T VALUES ('PUSZYSTA', 'SONIA', 'D', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'ZOMBI'), TO_DATE('2010-11-18', 'YYYY-MM-DD'), 20, 35, 'MILUSIA');
INSERT INTO KOCURY_OBJ_T VALUES ('UCHO', 'LATKA', 'D', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'RAFA'), TO_DATE('2011-01-01', 'YYYY-MM-DD'), 40, NULL, 'KOT');
INSERT INTO KOCURY_OBJ_T VALUES ('MALY', 'DUDEK', 'M', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'RAFA'), TO_DATE('2011-05-15', 'YYYY-MM-DD'), 40, NULL, 'KOT');
INSERT INTO KOCURY_OBJ_T VALUES ('SZYBKA', 'ZUZIA', 'D', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'LYSY'), TO_DATE('2006-07-21', 'YYYY-MM-DD'), 65, NULL, 'LOWCZY');
INSERT INTO KOCURY_OBJ_T VALUES ('MALA', 'RUDA', 'D', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'TYGRYS'), TO_DATE('2006-09-17', 'YYYY-MM-DD'), 22, 42, 'MILUSIA');
INSERT INTO KOCURY_OBJ_T VALUES ('LASKA', 'BELA', 'D', (SELECT REF(k) FROM KOCURY_OBJ_T k WHERE pseudo = 'LYSY'), TO_DATE('2008-02-01', 'YYYY-MM-DD'), 24, 28, 'MILUSIA');

SELECT * FROM KOCURY_OBJ_T

//obiekty plebsu
CREATE OR REPLACE TYPE PLEBS_OBJ AS OBJECT
(nr NUMBER(3),
kot REF KOCUR_OBJ,
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
WHERE KT.Suma_myszy() <= 60;

SELECT * FROM PLEBS_OBJ_T

//obiekty elity
CREATE OR REPLACE TYPE ELITA_OBJ AS OBJECT
(nr NUMBER(3),
kot REF KOCUR_OBJ,
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
WHERE KT.Suma_myszy() > 60;

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
SELECT PANOWIE_SLUDZY_OBJ(1, REF(E), REF(P), SYSDATE)
FROM ELITA_OBJ_T E, PLEBS_OBJ_T P 
WHERE VALUE(E).kot.pseudo = 'TYGRYS' AND VALUE(P).kot.pseudo = 'UCHO'

INSERT INTO PANOWIE_SLUDZY_OBJ_T
SELECT PANOWIE_SLUDZY_OBJ(2, REF(E), REF(P), SYSDATE)
FROM ELITA_OBJ_T E, PLEBS_OBJ_T P 
WHERE VALUE(E).kot.pseudo = 'ZOMBI' AND VALUE(P).kot.pseudo = 'MALY'

SELECT * FROM PANOWIE_SLUDZY_OBJ_T

--Navigation through REF variables is not supported in PL/SQL
CREATE OR REPLACE TRIGGER jeden_z_elita_plebs
BEFORE INSERT ON PLEBS_OBJ_T
FOR EACH ROW
DECLARE
    ile_w_drugiej_klasie NUMBER := 0;
BEGIN   
    SELECT COUNT(nr) INTO ile_w_drugiej_klasie
    FROM ELITA_OBJ_T E
    WHERE Pseudo_kota() = :NEW.kot.pseudo;

    IF ile_w_drugiej_klasie > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Kot jest juz przypisany do drugiej klasy');
    END IF;
END;

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

//zadanie 19a
SELECT K1.imie "Imie", K1.funkcja "Funkcja", K2.imie "Szef 1", K3.imie "Szef 2", K4.imie "Szef 3"
FROM KOCURY_OBJ_T K1
    LEFT JOIN KOCURY_OBJ_T K2 ON DEREF(K1.szef).pseudo = K2.pseudo
    LEFT JOIN KOCURY_OBJ_T K3 ON DEREF(K2.szef).pseudo = K3.pseudo
    LEFT JOIN KOCURY_OBJ_T K4 ON DEREF(K3.szef).pseudo = K4.pseudo
WHERE K1.funkcja IN ('KOT', 'MILUSIA')

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
(nr NUMBER(3) CONSTRAINT el_nr_pk PRIMARY KEY,
pseudo VARCHAR2(15) CONSTRAINT el_ps_fk REFERENCES Kocury(pseudo),
w_elicie_od DATE
);

CREATE TABLE Plebs
(nr NUMBER(3) CONSTRAINT pl_nr_pk PRIMARY KEY,
pseudo VARCHAR2(15) CONSTRAINT pl_ps_fk REFERENCES Kocury(pseudo),
w_plebsie_od DATE
);

CREATE TABLE Panowie_sludzy
(nr NUMBER(3) CONSTRAINT ps_nr_pk PRIMARY KEY,
pan NUMBER(3) CONSTRAINT ps_pan_fk REFERENCES Elita(nr),
sluga NUMBER(3) CONSTRAINT ps_sl_fk REFERENCES Plebs(nr),
od_kiedy DATE CONSTRAINT ps_od_nn NOT NULL
);

CREATE TABLE Elitarne_konto
(nr_myszy NUMBER(4) CONSTRAINT el_nrm_pk PRIMARY KEY,
kot NUMBER(3) CONSTRAINT el_ko_fk REFERENCES Elita(nr),
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
kot REF KOCURY_PERS_OBJ,
w_plebsie_od DATE,
MEMBER FUNCTION Przedstaw_kota RETURN VARCHAR2
)

CREATE OR REPLACE TYPE BODY PLEBS_PERS_OBJ AS
  MEMBER FUNCTION Przedstaw_kota RETURN VARCHAR2 IS
        przedstawienie VARCHAR2(100);
      BEGIN
        SELECT 'Plebejusz ' || DEREF(kot).imie INTO przedstawienie FROM DUAL;
        RETURN przedstawienie;
      END;    
END;

CREATE OR REPLACE VIEW PLEBS_OBJ_PERS OF PLEBS_PERS_OBJ
WITH OBJECT IDENTIFIER (nr) AS
SELECT nr, MAKE_REF(KOCURY_OBJ_PERS, pseudo) kot, w_plebsie_od
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
SELECT nr, MAKE_REF(KOCURY_OBJ_PERS, pseudo) kot, w_elicie_od
FROM Elita;

CREATE OR REPLACE TYPE PANOWIE_SLUDZY_PERS_OBJ AS OBJECT
(nr NUMBER(3),
pan REF ELITA_PERS_OBJ,
sluga REF PLEBS_PERS_OBJ,
od_kiedy DATE
)

CREATE OR REPLACE VIEW PANOWIE_SLUDZY_OBJ_PERS OF PANOWIE_SLUDZY_PERS_OBJ
WITH OBJECT IDENTIFIER (nr) AS
SELECT nr, MAKE_REF(ELITA_OBJ_PERS, pan) pan, MAKE_REF(PLEBS_OBJ_PERS, sluga), od_kiedy
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
SELECT nr_myszy, MAKE_REF(ELITA_OBJ_PERS, kot) pan, data_wprowadzenia, data_usuniecia
FROM Elitarne_konto;

INSERT INTO Plebs
SELECT ROWNUM, pseudo, SYSDATE
FROM KOCURY_OBJ_PERS K
WHERE K.Suma_myszy() < 55;

SELECT * FROM Plebs
SELECT * FROM PLEBS_OBJ_PERS

INSERT INTO Elita
SELECT ROWNUM, pseudo, SYSDATE
FROM KOCURY_OBJ_PERS K
WHERE K.Suma_myszy() > 70;

SELECT * FROM Elita
SELECT * FROM ELITA_OBJ_PERS

INSERT INTO Panowie_sludzy
SELECT 1, E.nr, P.nr, SYSDATE
FROM ELITA_OBJ_PERS E, PLEBS_OBJ_PERS P
WHERE VALUE(E).kot.pseudo = 'TYGRYS' AND VALUE(P).kot.pseudo = 'UCHO';

INSERT INTO Panowie_sludzy
SELECT 2, E.nr, P.nr, SYSDATE
FROM ELITA_OBJ_PERS E, PLEBS_OBJ_PERS P
WHERE VALUE(E).kot.pseudo = 'ZOMBI' AND VALUE(P).kot.pseudo = 'ZERO';

SELECT * FROM Panowie_sludzy
SELECT * FROM PANOWIE_SLUDZY_OBJ_PERS

INSERT INTO Elitarne_konto
SELECT 1, E.nr, SYSDATE, NULL
FROM ELITA_OBJ_PERS E
WHERE VALUE(E).kot.pseudo = 'TYGRYS';

INSERT INTO Elitarne_konto
SELECT 2, E.nr, SYSDATE, NULL
FROM ELITA_OBJ_PERS E
WHERE VALUE(E).kot.pseudo = 'TYGRYS';

INSERT INTO Elitarne_konto
SELECT 3, E.nr, SYSDATE, SYSDATE
FROM ELITA_OBJ_PERS E
WHERE VALUE(E).kot.pseudo = 'TYGRYS';

INSERT INTO Elitarne_konto
SELECT 4, E.nr, SYSDATE, SYSDATE
FROM ELITA_OBJ_PERS E
WHERE VALUE(E).kot.pseudo = 'ZOMBI';

SELECT * FROM Elitarne_konto
SELECT * FROM ELITARNE_KONTO_OBJ_PERS

//przyklady
//referencja
SELECT VALUE(PS).pan.Przedstaw_kota() || ' ma sluge: ' || VALUE(PS).sluga.Przedstaw_kota() || ' od ' || od_kiedy "Panowie i sludzy"
FROM PANOWIE_SLUDZY_OBJ_PERS PS

//podzapytanie
SELECT *
FROM KOCURY_OBJ_PERS
WHERE pseudo IN(
    (SELECT PS.pan.kot.pseudo
    FROM PANOWIE_SLUDZY_OBJ_PERS PS
    WHERE PS.pan.kot.pseudo = 'TYGRYS'),
    (SELECT PS.sluga.kot.pseudo
    FROM PANOWIE_SLUDZY_OBJ_PERS PS
    WHERE PS.pan.kot.pseudo = 'TYGRYS')
)

//grupowanie
SELECT VALUE(K).kot.kot.pseudo "Kot", COUNT(*) "Myszy w historii", COUNT(*) - COUNT(data_usuniecia) "Dostepne myszy"
FROM ELITARNE_KONTO_OBJ_PERS K
GROUP BY VALUE(K).kot.kot.pseudo


//lista 2
//zadanie 18
SELECT K1.imie, K1.w_stadku_od "POLUJE OD"
FROM KOCURY_OBJ_PERS K1, KOCURY_OBJ_PERS K2
WHERE K2.imie = 'JACEK' AND K1.w_stadku_od < K2.w_stadku_od
ORDER BY K1.w_stadku_od DESC;

//zadanie 23
SELECT imie,
    K.Suma_myszy() * 12 "DAWKA ROCZNA",
    'powyzej 864' "DAWKA"
FROM KOCURY_OBJ_PERS K
WHERE NVL(myszy_extra, 0) > 0 AND K.Suma_myszy() * 12 > 864
UNION ALL
SELECT imie,
    K.Suma_myszy() * 12 "DAWKA ROCZNA",
    '864' "DAWKA"
FROM KOCURY_OBJ_PERS K
WHERE NVL(myszy_extra, 0) > 0 AND K.Suma_myszy() * 12 = 864
UNION ALL
SELECT imie,
    K.Suma_myszy() * 12 "DAWKA ROCZNA",
    'ponizej 864' "DAWKA"
FROM KOCURY_OBJ_PERS K
WHERE NVL(myszy_extra, 0) > 0 AND K.Suma_myszy() * 12 < 864
ORDER BY 2 DESC

//lista 3
//zadanie 35
DECLARE
    pseudoIn VARCHAR(15) := '&pseudo';
    kocur KOCURY_PERS_OBJ;
    DUZO_MYSZY CONSTANT NUMBER(3) := 700;
    SZUKANY_MIESIAC CONSTANT NUMBER(2) := 5;
BEGIN
    SELECT KOCURY_PERS_OBJ(pseudo, imie, plec, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
    INTO kocur
    FROM KOCURY_OBJ_PERS
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
    FROM KOCURY_OBJ_PERS K
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

//zad 49
DECLARE
    dyn_sql VARCHAR2(1000);
    istniejace NUMBER(1);
    
  od_kiedy DATE := TO_DATE('2004-01-01');
  do_kiedy DATE := TO_DATE('2024-01-22');
  
    CURSOR HierarchiaCur (max_date DATE) IS
    SELECT *
    FROM Kocury
    WHERE w_stadku_od <= max_date
    ORDER BY NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) DESC, w_stadku_od;
    
  TYPE Myszy_table IS TABLE OF Myszy%ROWTYPE INDEX BY SIMPLE_INTEGER;
  myszy_t Myszy_table;
  
  TYPE Liczby_table IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
  zjedzone_myszy Liczby_table;

  nr_upolowanej_myszy NUMBER(10) := 0;
  nr_zjedzonej_myszy NUMBER(10) := 0;
  wypelniono_przydzialy BOOLEAN := true;
  
  koniec_miesiaca DATE;
  sroda DATE;
  srednia_w_miesiacu INTEGER;
BEGIN
    SELECT COUNT(*) INTO istniejace FROM USER_TABLES WHERE table_name='MYSZY';
    IF istniejace=1 THEN
        EXECUTE IMMEDIATE 'DROP TABLE MYSZY';
    END IF;

    dyn_sql := 'CREATE TABLE Myszy('||
        'nr_myszy NUMBER(10) CONSTRAINT my_nr_pk PRIMARY KEY,' ||
        'lowca VARCHAR(15) REFERENCES Kocury(pseudo),' ||
        'zjadacz VARCHAR(15) REFERENCES Kocury(pseudo),' ||
        'waga_myszy NUMBER(2) CONSTRAINT norma_wagi CHECK(waga_myszy BETWEEN 5 AND 30),' ||
        'data_zlowienia DATE,' ||
        'data_wydania DATE CONSTRAINT ostatnia_sroda CHECK(NEXT_DAY(LAST_DAY(data_wydania) - 7, TO_CHAR(data_wydania, ''DY'')) = data_wydania))';
        
    EXECUTE IMMEDIATE dyn_sql;
        
    FOR miesiac IN 0..FLOOR(MONTHS_BETWEEN(do_kiedy, od_kiedy)) LOOP
        koniec_miesiaca := LAST_DAY(ADD_MONTHS(od_kiedy, miesiac));
        sroda := NEXT_DAY(koniec_miesiaca - 7, 'środa');
        IF koniec_miesiaca > do_kiedy THEN koniec_miesiaca := do_kiedy; END IF;
        SELECT CEIL(AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) INTO srednia_w_miesiacu
        FROM Kocury
        WHERE w_stadku_od <= koniec_miesiaca;
                    
        FOR kocur IN HierarchiaCur(koniec_miesiaca) LOOP
            FOR i IN 1..srednia_w_miesiacu LOOP
                nr_upolowanej_myszy := nr_upolowanej_myszy + 1;
                myszy_t(nr_upolowanej_myszy).nr_myszy := nr_upolowanej_myszy;
                myszy_t(nr_upolowanej_myszy).lowca := kocur.pseudo;
                myszy_t(nr_upolowanej_myszy).zjadacz := NULL;
                myszy_t(nr_upolowanej_myszy).waga_myszy := DBMS_RANDOM.VALUE(5, 30);
                myszy_t(nr_upolowanej_myszy).data_zlowienia := CASE WHEN koniec_miesiaca > do_kiedy
                                                                THEN sroda - DBMS_RANDOM.VALUE(0, EXTRACT(DAY FROM sroda)-1)
                                                                ELSE koniec_miesiaca - DBMS_RANDOM.VALUE(0, EXTRACT(DAY FROM koniec_miesiaca)-1)
                                                                END;
                myszy_t(nr_upolowanej_myszy).data_wydania := NULL;
                --DBMS_OUTPUT.PUT_LINE(kocur.pseudo || ' upolowal mysz nr ' || nr_upolowanej_myszy);
            END LOOP; 
        END LOOP;
        
        FOR kocur IN HierarchiaCur(koniec_miesiaca) LOOP
            zjedzone_myszy(kocur.pseudo) := 0;
        END LOOP;
        
        IF sroda <= do_kiedy THEN
            LOOP
                EXIT WHEN nr_zjedzonej_myszy = nr_upolowanej_myszy;
                wypelniono_przydzialy := true;
                FOR kocur IN HierarchiaCur(koniec_miesiaca) LOOP
                    IF zjedzone_myszy(kocur.pseudo) < NVL(kocur.przydzial_myszy, 0) + NVL(kocur.myszy_extra, 0) AND nr_zjedzonej_myszy < nr_upolowanej_myszy THEN
                        wypelniono_przydzialy := false;
                        zjedzone_myszy(kocur.pseudo) := zjedzone_myszy(kocur.pseudo) + 1;
                        nr_zjedzonej_myszy := nr_zjedzonej_myszy + 1;
                        myszy_t(nr_zjedzonej_myszy).zjadacz := kocur.pseudo;
                        myszy_t(nr_zjedzonej_myszy).data_wydania := sroda;
                        --DBMS_OUTPUT.PUT_LINE(kocur.pseudo || ' zjadl mysz nr ' || nr_zjedzonej_myszy);
                    END IF;
                END LOOP;
                IF wypelniono_przydzialy THEN
                    nr_zjedzonej_myszy := nr_upolowanej_myszy;
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    END LOOP;
    
    FORALL nr IN 1..myszy_t.COUNT()
    INSERT INTO Myszy VALUES myszy_t(nr);
    Rejestr_myszy.liczba_myszy := nr_upolowanej_myszy;
END;

SELECT *
FROM Kocury
WHERE w_stadku_od <= LAST_DAY(ADD_MONTHS(TO_DATE('2004-01-01'), 0));

SELECT pseudo, NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)
FROM Kocury
ORDER BY NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)

SELECT *
FROM Myszy

SELECT M.lowca, COUNT(*)
FROM Myszy M
    JOIN Kocury K1 ON M.lowca = K1.pseudo
GROUP BY M.lowca

SELECT *
FROM Myszy M
WHERE M.lowca IS NULL OR M.zjadacz IS NULL

SELECT zjadacz, MIN(NVL(K.przydzial_myszy, 0) + NVL(K.myszy_extra, 0)), COUNT(*)
FROM Myszy M JOIN Kocury K ON M.zjadacz = K.pseudo
WHERE EXTRACT(MONTH FROM data_zlowienia) = 4
GROUP BY zjadacz

SELECT M.lowca, COUNT(*)
FROM Myszy M
GROUP BY M.lowca

DELETE FROM Myszy

CREATE OR REPLACE PACKAGE Rejestr_myszy AS
    liczba_myszy NUMBER;
END;

CREATE OR REPLACE PROCEDURE zarejestruj_myszy(pseudo Kocury.pseudo%TYPE, query_date DATE)
AS
    dyn_sql VARCHAR2(500);
    
    TYPE Wagi_table IS TABLE OF Myszy.waga_myszy%TYPE INDEX BY SIMPLE_INTEGER;
    wagi_t Wagi_table;
    
    TYPE Myszy_table IS TABLE OF Myszy%ROWTYPE INDEX BY SIMPLE_INTEGER;
    myszy_t Myszy_table;
    
    ostatni_nr_myszy NUMBER(10) := Rejestr_myszy.liczba_myszy;
    istniejace NUMBER(1);
    nie_znaleziono_tabeli EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO istniejace FROM USER_TABLES WHERE table_name=pseudo;
    IF istniejace = 0 THEN
        RAISE nie_znaleziono_tabeli;
    END IF;
        
    dyn_sql := 'SELECT waga_myszy' ||
    ' FROM ' || pseudo ||
    ' WHERE data_zlowienia = :1';
    EXECUTE IMMEDIATE dyn_sql BULK COLLECT INTO wagi_t USING query_date;
    
    FOR i IN 1..wagi_t.COUNT LOOP
        myszy_t(i).nr_myszy := ostatni_nr_myszy + i;
        myszy_t(i).lowca := pseudo;
        myszy_t(i).zjadacz := NULL;
        myszy_t(i).waga_myszy := wagi_t(i);
        myszy_t(i).data_zlowienia := query_date;
        myszy_t(i).data_wydania := NULL;
     END LOOP;
    
    FORALL i IN 1..myszy_t.COUNT
    INSERT INTO Myszy VALUES myszy_t(i);
    
    Rejestr_myszy.liczba_myszy := Rejestr_myszy.liczba_myszy + wagi_t.COUNT;
EXCEPTION
    WHEN nie_znaleziono_tabeli THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono tabeli o nazwie ' || pseudo);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

CREATE OR REPLACE PROCEDURE wyplac_myszy_z_miesiaca(dzien DATE)
AS
    od_kiedy DATE;
    do_kiedy DATE;
    
    CURSOR HierarchiaCur (max_date DATE) IS
    SELECT *
    FROM Kocury
    WHERE w_stadku_od <= max_date
    ORDER BY NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) DESC, w_stadku_od;
    
    CURSOR MyszyCur (od_kiedy DATE, do_kiedy DATE) IS
    SELECT *
    FROM Myszy
    WHERE (data_zlowienia BETWEEN od_kiedy AND do_kiedy) AND zjadacz IS NULL;
    mysz MyszyCur%ROWTYPE;
    
    TYPE Liczby_table IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
    zjedzone_myszy Liczby_table;
    
    TYPE Myszy_table IS TABLE OF Myszy%ROWTYPE INDEX BY SIMPLE_INTEGER;
    myszy_t Myszy_table;
    
    nr_zjedzonej_myszy NUMBER(10) := 0;
    wypelniono_przydzialy BOOLEAN := true; 
BEGIN
    od_kiedy := NEXT_DAY(LAST_DAY(ADD_MONTHS(dzien, -1)) - 7, 'środa');
    do_kiedy := NEXT_DAY(LAST_DAY(dzien) - 7, 'środa');
        
    FOR kocur IN HierarchiaCur(do_kiedy) LOOP
        zjedzone_myszy(kocur.pseudo) := 0;
    END LOOP;
    
    OPEN MyszyCur(od_kiedy, do_kiedy);
    LOOP
        wypelniono_przydzialy := true;
        FOR kocur IN HierarchiaCur(do_kiedy) LOOP
            IF zjedzone_myszy(kocur.pseudo) < NVL(kocur.przydzial_myszy, 0) + NVL(kocur.myszy_extra, 0) THEN
                FETCH MyszyCur INTO mysz;
                EXIT WHEN MyszyCur%NOTFOUND;
                wypelniono_przydzialy := false;
                nr_zjedzonej_myszy := nr_zjedzonej_myszy + 1;
                zjedzone_myszy(kocur.pseudo) := zjedzone_myszy(kocur.pseudo) + 1;
                myszy_t(nr_zjedzonej_myszy).nr_myszy := mysz.nr_myszy;
                myszy_t(nr_zjedzonej_myszy).zjadacz := kocur.pseudo;
                myszy_t(nr_zjedzonej_myszy).data_wydania := do_kiedy;
            END IF;
        END LOOP;
        EXIT WHEN wypelniono_przydzialy;
    END LOOP;
    CLOSE MyszyCur;
    
    FORALL i IN 1..myszy_t.COUNT
    UPDATE Myszy SET
        data_wydania = myszy_t(i).data_wydania,
        zjadacz = myszy_t(i).zjadacz
    WHERE nr_myszy = myszy_t(i).nr_myszy;
END;