--creating a simple function
CREATE OR REPLACE FUNCTION min_przydzial(nrb NUMBER)
RETURN NUMBER
AS min_przydzial Kocury.przydzial_myszy%TYPE;
BEGIN
    SELECT MIN(przydzial_myszy) INTO min_przydzial
    FROM Kocury WHERE nr_bandy=nrb;
    RETURN min_przydzial;
EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

SELECT * FROM Kocury WHERE nr_bandy = 2;
SELECT * FROM Kocury WHERE przydzial_myszy = min_przydzial(2);

--showing functions
SELECT * FROM USER_OBJECTS;
SELECT * FROM USER_SOURCE;

--delete a function
DROP FUNCTION min_przydzial;

--recursive function
CREATE OR REPLACE FUNCTION szefowie_rek(pseudoIn Kocury.pseudo%TYPE)
RETURN VARCHAR2
AS pseudo_szefa Kocury.szef%TYPE; imie_szefa Kocury.imie%TYPE;
BEGIN
    SELECT K2.pseudo, K2.imie INTO pseudo_szefa, imie_szefa
    FROM Kocury K1,Kocury K2
    WHERE K1.szef=K2.pseudo AND K1.pseudo=pseudoIN;
    DBMS_OUTPUT.PUT('Pseudonim szefa: ');
    DBMS_OUTPUT.PUT(RPAD(pseudo_szefa,10));
    DBMS_OUTPUT.PUT_LINE(' Imie: '||RPAD(imie_szefa,10));
    RETURN szefowie_rek(pseudo_szefa); 
END szefowie_rek;

DECLARE
    ps Kocury.pseudo%TYPE:='&pseudonim';
    ps_kota Kocury.pseudo%TYPE; im_kota Kocury.imie%TYPE;
BEGIN
    SELECT imie INTO im_kota
    FROM Kocury
    WHERE pseudo=ps;
    DBMS_OUTPUT.PUT('Pseudonim kota:  ');
    DBMS_OUTPUT.PUT(RPAD(ps,10));
    DBMS_OUTPUT.PUT_LINE(' Imie: '||RPAD(im_kota,10));
    ps_kota:=szefowie_rek(ps);
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Koniec');
END;

--packages
CREATE OR REPLACE PACKAGE my_package AS
    FUNCTION min_przydzial(nrb NUMBER) RETURN NUMBER;
    FUNCTION sred_przydzial(nrb NUMBER) RETURN NUMBER;
END my_package;

CREATE OR REPLACE PACKAGE BODY my_package AS
    FUNCTION min_przydzial(nrb NUMBER) RETURN NUMBER
    IS
        min_przydzial_out Kocury.przydzial_myszy%TYPE;
    BEGIN
        SELECT MIN(NVL(przydzial_myszy,0)) INTO min_przydzial_out
        FROM Kocury
        WHERE nr_bandy=nrb;
        RETURN min_przydzial_out;
    END min_przydzial;
    FUNCTION sred_przydzial(nrb NUMBER) RETURN NUMBER
    IS
        sredni_przydzial_out NUMBER(10,3);
    BEGIN
        SELECT AVG(NVL(przydzial_myszy,0)) INTO sredni_przydzial_out
        FROM Kocury
        WHERE nr_bandy=nrb;
        RETURN sredni_przydzial_out;
    END sred_przydzial;
END my_package;

SELECT imie, nr_bandy, NVL(przydzial_myszy, 0)-my_package.min_przydzial(nr_bandy) "Nadmiar"
FROM Kocury
WHERE przydzial_myszy > my_package.sred_przydzial(nr_bandy)
ORDER BY nr_bandy;

--triggers
--prevent deletion trigger
CREATE OR REPLACE TRIGGER czy_usunac_bande
BEFORE DELETE ON Bandy
FOR EACH ROW WHEN (OLD.nr_bandy IN (1,2))
DECLARE
    ile_czlonkow NUMBER(3):=0;
BEGIN
    SELECT COUNT(*) INTO ile_czlonkow
    FROM Kocury WHERE nr_bandy=:OLD.nr_bandy;
    IF ile_czlonkow>0 THEN
    RAISE_APPLICATION_ERROR(-20105,
    'Banda '||:OLD.nazwa||' z obsada jest nieusuwalna!');
    END IF;
END;

DELETE FROM Bandy WHERE nr_bandy = 1;
SELECT * FROM Bandy;
DELETE FROM Bandy WHERE nr_bandy = 5;
SELECT * FROM Bandy;
ROLLBACK;

--inserting a row with instead of trigger
CREATE OR REPLACE VIEW Kotki AS
SELECT pseudo,imie,w_stadku_od,nazwa,szef
FROM Kocury K,Bandy B
WHERE K.nr_bandy=B.nr_bandy;

SELECT * FROM Kotki;

CREATE OR REPLACE TRIGGER dopisz_kota
  INSTEAD OF INSERT ON Kotki
DECLARE
  nb NUMBER;
  l NUMBER;
BEGIN
  SELECT COUNT(*) INTO l FROM Bandy
  WHERE nazwa = :NEW.nazwa;

  IF l = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Zla nazwa bandy!');
  END IF;

  SELECT nr_bandy INTO nb FROM Bandy
  WHERE nazwa = :NEW.nazwa;

  IF :NEW.w_stadku_od > SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20002, 'Data powyzej biezacej!');
  END IF;

  SELECT COUNT(*) INTO l FROM Kocury
  WHERE pseudo = :NEW.pseudo;

  IF l = 1 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Istniejacy pseudonim!');
  END IF;

  SELECT COUNT(*) INTO l FROM Kocury
  WHERE szef = :NEW.szef;

  IF l = 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Nieistniejacy szef!');
  END IF;

  INSERT INTO Kocury (pseudo, imie, w_stadku_od, nr_bandy, szef)
  VALUES (:NEW.pseudo, :NEW.imie, :NEW.w_stadku_od, nb, :NEW.szef);
END;

INSERT INTO Kotki VALUES ('GRUBY','RYCHO','2019-11-16', 'CZARNI RYCERZE','LYSY');
ROLLBACK;
INSERT INTO Kotki VALUES ('TYGRYS','RYCHO','2019-11-16', 'CZARNI RYCERZE','LYSY');

--triggers for system events
CREATE TABLE Zdarzenia
(polecenie VARCHAR2(10),
uzytkownik VARCHAR2(15),
data DATE,
obiekt VARCHAR2(10),
nazwa VARCHAR2(14));

CREATE OR REPLACE TRIGGER opis_zdarzenia
BEFORE CREATE OR ALTER OR DROP ON DATABASE
DECLARE
    pol Zdarzenia.polecenie%TYPE;
    uzy Zdarzenia.uzytkownik%TYPE;
    dat Zdarzenia.data%TYPE;
    obi Zdarzenia.obiekt%TYPE;
    naz Zdarzenia.nazwa%TYPE;
BEGIN
    pol:=SYSEVENT; 
    uzy:=LOGIN_USER;
    dat:=SYSDATE; 
    obi:=DICTIONARY_OBJ_TYPE;
    naz:=DICTIONARY_OBJ_NAME;
    INSERT INTO Zdarzenia VALUES (pol,uzy,dat,obi,naz);
END;

--tracing przydzial_myszy changes with triggers
--and autonomous transaction
CREATE TABLE Historia_zmian(
nr_zmiany NUMBER(5),
komu VARCHAR2(15),
data DATE,
przydzial NUMBER(5),
extra NUMBER);

CREATE SEQUENCE nr_w_historii;

CREATE OR REPLACE TRIGGER co_z_myszkami
BEFORE INSERT OR UPDATE OF przydzial_myszy, myszy_extra
ON Kocury FOR EACH ROW
DECLARE
    ps Kocury.pseudo%TYPE;
    pm Kocury.przydzial_myszy%TYPE;
    me Kocury.myszy_extra%TYPE;
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF INSERTING THEN
        ps:=:NEW.pseudo;
        pm:=:NEW.przydzial_myszy;
        me:=:NEW.myszy_extra;
    ELSE ps:=:OLD.pseudo;
    END IF;
    IF UPDATING('przydzial_myszy')
        THEN pm:=:NEW.przydzial_myszy;
        ELSIF NOT INSERTING THEN pm:=:OLD.przydzial_myszy;
    END IF;
    IF UPDATING('myszy_extra')
        THEN me:=:NEW.myszy_extra;
        ELSIF NOT INSERTING THEN me:=:OLD.myszy_extra;
    END IF;
    INSERT INTO Historia_zmian 
    VALUES (nr_w_historii.NEXTVAL,ps,SYSDATE,pm,me);
    COMMIT;
END;

SELECT * FROM historia_zmian;
UPDATE Kocury SET myszy_extra=50 WHERE pseudo='LOLA';
ROLLBACK;
SELECT * FROM historia_zmian;
SELECT myszy_extra FROM Kocury WHERE pseudo='LOLA';

--dynamic SQL
DECLARE
  CURSOR kotki IS SELECT level, pseudo FROM Kocury
    START WITH szef IS NULL CONNECT BY PRIOR pseudo = szef;
  dyn_lanc VARCHAR2(1000);
  maxl NUMBER(2) := 0;
  ile NUMBER(4);
BEGIN
  FOR ko IN kotki LOOP
    IF ko.level > maxl THEN
      maxl := ko.level;
    END IF;

    SELECT COUNT(*) INTO ile
    FROM USER_TABLES WHERE table_name = ko.pseudo;

    IF ile = 1 THEN
      EXECUTE IMMEDIATE 'DROP TABLE ' || ko.pseudo;
    END IF;

    dyn_lanc := 'CREATE TABLE ' || ko.pseudo || '
               (data_wpisu DATE, data_wypisu DATE)';
    EXECUTE IMMEDIATE dyn_lanc;
  END LOOP;

  FOR ko IN kotki LOOP
    dyn_lanc := 'INSERT INTO ' || ko.pseudo ||
      ' (data_wpisu) VALUES (:da_wp)';

    FOR i IN 1..maxl - ko.level + 1 LOOP
      EXECUTE IMMEDIATE dyn_lanc USING SYSDATE;
    END LOOP;
  END LOOP;

  FOR ko IN kotki LOOP
    dyn_lanc := 'SELECT COUNT(*) - COUNT(data_wypisu) FROM ' ||
      ko.pseudo;
    EXECUTE IMMEDIATE dyn_lanc INTO ile;
    DBMS_OUTPUT.PUT_LINE(RPAD(ko.pseudo, 10) ||
      ' - Liczba myszy na stanie: ' || ile);
  END LOOP;
END;
