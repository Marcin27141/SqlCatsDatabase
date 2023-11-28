SET SERVEROUTPUT ON
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

//zadanie 34
DECLARE
    CURSOR kocuryCur IS
    SELECT funkcja fun  FROM Kocury;
    funkcjaIn Kocury.funkcja%TYPE := '&funkcjaIn';
    znaleziono BOOLEAN := false;
BEGIN
    FOR kocur IN kocuryCur LOOP
        IF kocur.fun = funkcjaIn THEN
            znaleziono := true;
            EXIT;
        END IF;
    END LOOP;
    IF NOT znaleziono
        THEN DBMS_OUTPUT.PUT_LINE('Nie znaleziono kocurow dla funkcji '||funkcjaIn);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Znaleziono kocury pelniace funkcje '||funkcjaIn);
    END IF;
END;


//zadanie 35
DECLARE
    pseudoIn Kocury.pseudo%TYPE := '&pseudo';
    kocur Kocury%ROWTYPE;
    DUZO_MYSZY CONSTANT NUMBER(3) := 700;
    SZUKANY_MIESIAC CONSTANT NUMBER(2) := 5;
BEGIN
    SELECT * INTO kocur FROM Kocury WHERE pseudo = pseudoIn;
    CASE
        WHEN (NVL(kocur.przydzial_myszy, 0) + NVL(kocur.myszy_extra, 0) * 12) > DUZO_MYSZY
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

//zadanie 36
DECLARE
    CURSOR kocury IS
    SELECT max_myszy maxMyszy, NVL(przydzial_myszy,0) pm
    FROM Kocury NATURAL JOIN Funkcje
    ORDER BY 2
    FOR UPDATE OF przydzial_myszy;
    suma_przydzialow NUMBER(4);
    dodatkowy_przydzial NUMBER(2);
    liczba_modyfikacji NUMBER(2) := 0;
    LIMIT_PRZYDZIALOW CONSTANT NUMBER(4) := 1050;
BEGIN
    SELECT SUM(NVL(przydzial_myszy,0)) INTO suma_przydzialow FROM Kocury;
    <<przydzialy>>LOOP
        FOR kocur IN kocury LOOP
            EXIT przydzialy WHEN suma_przydzialow > LIMIT_PRZYDZIALOW;
            
            dodatkowy_przydzial := NVL(kocur.pm,0) * 0.1;
            IF (kocur.pm + dodatkowy_przydzial > kocur.maxMyszy)
                THEN dodatkowy_przydzial := (kocur.maxMyszy - kocur.pm);
            END IF;

            IF (dodatkowy_przydzial > 0) THEN               
                UPDATE Kocury
                SET przydzial_myszy = NVL(przydzial_myszy,0) + dodatkowy_przydzial
                WHERE CURRENT OF kocury;
                
                liczba_modyfikacji := liczba_modyfikacji + 1;
                suma_przydzialow := suma_przydzialow + dodatkowy_przydzial;
            END IF;
            
     
            DBMS_OUTPUT.PUT(suma_przydzialow);
        END LOOP;
    END LOOP;
    DBMS_OUTPUT.PUT('Calk. przydzial w stadku ');
    DBMS_OUTPUT.PUT(suma_przydzialow);
    DBMS_OUTPUT.PUT(' Zmian - ');
    DBMS_OUTPUT.PUT_LINE(liczba_modyfikacji);
END;

SELECT imie, przydzial_myszy "Myszki po podwyzce" FROM KOCURY
ROLLBACK;

//zadanie 37
DECLARE
    CURSOR ranking IS
    SELECT pseudo, NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) sumaMyszy
    FROM Kocury
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


//zadanie 38
DECLARE
    CURSOR kocury IS
    SELECT pseudo, imie, szef
    FROM Kocury
    WHERE funkcja IN ('KOT', 'MILUSIA');
    kocur kocury%ROWTYPE;
    szef_i kocury%ROWTYPE;
    liczba_przelozonych NUMBER(2) := &liczba_przelozonych;
BEGIN
    DBMS_OUTPUT.PUT(RPAD('Imie', 13, ' '));
    FOR i IN 1..liczba_przelozonych LOOP
        DBMS_OUTPUT.PUT('  |  '||'Szef '||RPAD(i, 7, ' '));
    END LOOP;
    DBMS_OUTPUT.NEW_LINE();
    DBMS_OUTPUT.PUT('-------------');
    FOR i IN 1..liczba_przelozonych LOOP
        DBMS_OUTPUT.PUT(' --- '||'------------');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE();
        
    FOR kocur IN kocury LOOP
        DBMS_OUTPUT.PUT(RPAD(kocur.imie, 13, ' '));
        FOR i IN 1..liczba_przelozonych LOOP
            IF kocur.szef IS NULL THEN
                DBMS_OUTPUT.PUT('  |  '||RPAD(' ', 12, ' '));
            ELSE
                SELECT pseudo, imie, szef INTO szef_i
                FROM Kocury
                WHERE pseudo = kocur.szef;
                DBMS_OUTPUT.PUT('  |  '||RPAD(szef_i.imie, 12, ' '));
                kocur := szef_i;
            END IF;
        END LOOP;
        DBMS_OUTPUT.NEW_LINE();
    END LOOP;
END;

//zadanie 39
DECLARE
    CURSOR bandy_cursor IS
    SELECT nr_bandy, nazwa, teren
    FROM Bandy;
    
    nr_bandy_in Bandy.nr_bandy%TYPE := &nr_bandy;
    nazwa_in Bandy.nazwa%TYPE := '&nazwa';
    teren_in Bandy.teren%TYPE := '&teren';

    nr_bandy_zajety BOOLEAN := false;
    nazwa_zajeta BOOLEAN := false;
    teren_zajety BOOLEAN := false;
    
    niepoprawny_nr_bandy EXCEPTION;
    zajete_parametry EXCEPTION;
BEGIN
    IF nr_bandy_in <= 0 THEN
        RAISE niepoprawny_nr_bandy;
    END IF;
    
    FOR banda IN bandy_cursor LOOP
        IF banda.nr_bandy = nr_bandy_in THEN
            nr_bandy_zajety := true;
            EXIT;
        END IF;
    END LOOP;
    
    FOR banda IN bandy_cursor LOOP
        IF banda.nazwa = nazwa_in THEN
            nazwa_zajeta := true;
            EXIT;
        END IF;
    END LOOP;
    
    FOR banda IN bandy_cursor LOOP
        IF banda.teren = teren_in THEN
            teren_zajety := true;
            EXIT;
        END IF;
    END LOOP;
    
    IF nr_bandy_zajety OR teren_zajety OR nazwa_zajeta
        THEN RAISE zajete_parametry;
    END IF;
    
    INSERT INTO Bandy(nr_bandy, nazwa, teren)
    VALUES(nr_bandy_in, nazwa_in, teren_in);
EXCEPTION
    WHEN niepoprawny_nr_bandy THEN
        DBMS_OUTPUT.PUT_LINE('Numer bandy nie moze byc <= 0');
    WHEN zajete_parametry THEN
        IF nr_bandy_zajety THEN
            DBMS_OUTPUT.PUT(nr_bandy_in);
        END IF;
        IF nazwa_zajeta THEN
            IF nr_bandy_zajety THEN DBMS_OUTPUT.PUT(', '); END IF;
            DBMS_OUTPUT.PUT(nazwa_in);
        END IF;
        IF teren_zajety THEN
            IF nazwa_zajeta OR nr_bandy_zajety 
                THEN DBMS_OUTPUT.PUT(', ');
            END IF;
            DBMS_OUTPUT.PUT(teren_in);
        END IF;
        DBMS_OUTPUT.PUT_LINE(': juz istnieje');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

SELECT * FROM Bandy
ROLLBACK;

//zadanie 40
CREATE OR REPLACE PROCEDURE stworz_bande(
    nr_bandy_in Bandy.nr_bandy%TYPE,
    nazwa_in Bandy.nazwa%TYPE,
    teren_in Bandy.teren%TYPE)
AS
    CURSOR bandy_cursor IS
    SELECT nr_bandy, nazwa, teren
    FROM Bandy;

    nr_bandy_zajety BOOLEAN := false;
    nazwa_zajeta BOOLEAN := false;
    teren_zajety BOOLEAN := false;
    
    niepoprawny_nr_bandy EXCEPTION;
    zajete_parametry EXCEPTION;
BEGIN
    IF nr_bandy_in <= 0 THEN
        RAISE niepoprawny_nr_bandy;
    END IF;
    
    FOR banda IN bandy_cursor LOOP
        IF banda.nr_bandy = nr_bandy_in THEN
            nr_bandy_zajety := true;
            EXIT;
        END IF;
    END LOOP;
    
    FOR banda IN bandy_cursor LOOP
        IF banda.nazwa = nazwa_in THEN
            nazwa_zajeta := true;
            EXIT;
        END IF;
    END LOOP;
    
    FOR banda IN bandy_cursor LOOP
        IF banda.teren = teren_in THEN
            teren_zajety := true;
            EXIT;
        END IF;
    END LOOP;
    
    IF nr_bandy_zajety OR teren_zajety OR nazwa_zajeta
        THEN RAISE zajete_parametry;
    END IF;
    
    INSERT INTO Bandy(nr_bandy, nazwa, teren)
    VALUES(nr_bandy_in, nazwa_in, teren_in);
EXCEPTION
    WHEN niepoprawny_nr_bandy THEN
        DBMS_OUTPUT.PUT_LINE('Numer bandy nie moze byc <= 0');
    WHEN zajete_parametry THEN
        IF nr_bandy_zajety THEN
            DBMS_OUTPUT.PUT(nr_bandy_in);
        END IF;
        IF nazwa_zajeta THEN
            IF nr_bandy_zajety THEN DBMS_OUTPUT.PUT(', '); END IF;
            DBMS_OUTPUT.PUT(nazwa_in);
        END IF;
        IF teren_zajety THEN
            IF nazwa_zajeta OR nr_bandy_zajety 
                THEN DBMS_OUTPUT.PUT(', ');
            END IF;
            DBMS_OUTPUT.PUT(teren_in);
        END IF;
        DBMS_OUTPUT.PUT_LINE(': juz istnieje');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

SELECT * FROM Bandy;
BEGIN 
    stworz_bande(10, 'NAZWA', 'POLE');
END;

ROLLBACK;
DROP PROCEDURE stworz_bande;

//zad 41
CREATE OR REPLACE TRIGGER nr_bandy_o_jeden_wiekszy
BEFORE INSERT ON Bandy
FOR EACH ROW
BEGIN
    SELECT MAX(nr_bandy) + 1 INTO :NEW.nr_bandy
    FROM Bandy;
END;

SELECT * FROM Bandy
BEGIN
 stworz_bande(18, 'ATRYDZI', 'DIUNA');
END;
ROLLBACK

//zad 42
//a
CREATE OR REPLACE PACKAGE Zad42 AS
    przydzial_tygrysa NUMBER;
    czy_ukarac_tygrysa BOOLEAN;
    czy_modyfikuje_tygrysa BOOLEAN;
    czy_w_trakcie_dzialania BOOLEAN;
END;

CREATE OR REPLACE PACKAGE BODY Zad42 AS
BEGIN
    SELECT przydzial_myszy INTO przydzial_tygrysa
    FROM Kocury
    WHERE pseudo = 'TYGRYS';
    czy_ukarac_tygrysa := false;
    czy_modyfikuje_tygrysa := false;
    czy_w_trakcie_dzialania := false;
END Zad42;

CREATE OR REPLACE TRIGGER ustaw_myszy_milus
BEFORE UPDATE ON Kocury
FOR EACH ROW
BEGIN
    IF :NEW.funkcja = 'MILUSIA' AND NOT Zad42.czy_modyfikuje_tygrysa THEN
        Zad42.czy_w_trakcie_dzialania := true;
    
        IF :NEW.przydzial_myszy < :OLD.przydzial_myszy THEN
            RAISE_APPLICATION_ERROR(-20001, 'Kto wazyl sie obnizyc przydzial Milusi?');
        END IF;
        
        IF (:NEW.przydzial_myszy - :OLD.przydzial_myszy) < 0.1 * Zad42.przydzial_tygrysa THEN
            :NEW.przydzial_myszy := :OLD.przydzial_myszy + 0.1 * Zad42.przydzial_tygrysa;
            :NEW.myszy_extra := :OLD.myszy_extra + 5;
            Zad42.czy_ukarac_tygrysa := true;
        END IF;
    END IF;
END;

CREATE OR REPLACE TRIGGER rozwiaz_sprawe_tygrysa
AFTER UPDATE ON Kocury
BEGIN
    IF Zad42.czy_w_trakcie_dzialania THEN
        Zad42.czy_w_trakcie_dzialania := false; --dlaczego musi byc tu a nie na koncu
        Zad42.czy_modyfikuje_tygrysa := true;
        
        IF Zad42.czy_ukarac_tygrysa THEN
            Zad42.czy_ukarac_tygrysa := false;
 
            UPDATE Kocury SET
            przydzial_myszy = 0.9 * przydzial_myszy
            WHERE pseudo = 'TYGRYS';

            SELECT przydzial_myszy INTO Zad42.przydzial_tygrysa
            FROM Kocury
            WHERE pseudo = 'TYGRYS';
        ELSE
            UPDATE Kocury SET
            myszy_extra = myszy_extra + 5
            WHERE pseudo = 'TYGRYS';
        END IF;
        
        Zad42.czy_modyfikuje_tygrysa := false;
    END IF;
END;


ALTER TRIGGER ustaw_myszy_milus ENABLE;
ALTER TRIGGER rozwiaz_sprawe_tygrysa ENABLE;

ALTER TRIGGER ustaw_myszy_milus DISABLE;
ALTER TRIGGER rozwiaz_sprawe_tygrysa DISABLE;

ALTER TRIGGER co_z_myszkami DISABLE;
SELECT * FROM kocury WHERE funkcja = 'MILUSIA' OR pseudo = 'TYGRYS';
UPDATE kocury
SET przydzial_myszy = 30
WHERE funkcja = 'MILUSIA';
UPDATE kocury
SET przydzial_myszy = 50
WHERE pseudo = 'LOLA';
ROLLBACK

//b
CREATE OR REPLACE TRIGGER Zad42Compound
  FOR UPDATE OF przydzial_myszy ON Kocury
  COMPOUND TRIGGER
    przydzial_tygrysa NUMBER;
    myszy_extra_tygrysa NUMBER;
    czy_ukarac_tygrysa BOOLEAN := false;
    czy_modyfikuje_tygrysa BOOLEAN := false;
    czy_w_trakcie_dzialania BOOLEAN := false;
  BEFORE STATEMENT IS
  BEGIN
    SELECT przydzial_myszy, myszy_extra
    INTO przydzial_tygrysa, myszy_extra_tygrysa
    FROM Kocury
    WHERE pseudo = 'TYGRYS';
  END BEFORE STATEMENT;

  BEFORE EACH ROW IS
  BEGIN
    IF :NEW.funkcja = 'MILUSIA' AND NOT czy_modyfikuje_tygrysa THEN
        czy_w_trakcie_dzialania := true;
        
        IF :NEW.przydzial_myszy < :OLD.przydzial_myszy THEN
             RAISE_APPLICATION_ERROR(-20001, 'Kto wazyl sie obnizyc przydzial Milusi?');
        END IF;
        
        IF (:NEW.przydzial_myszy - :OLD.przydzial_myszy) < 0.1 * przydzial_tygrysa THEN
            :NEW.przydzial_myszy := :OLD.przydzial_myszy + 0.1 * przydzial_tygrysa;
            :NEW.myszy_extra := :OLD.myszy_extra + 5;
            przydzial_tygrysa := 0.9 * przydzial_tygrysa;
        ELSE
            myszy_extra_tygrysa := myszy_extra_tygrysa + 5;
        END IF;
    END IF;
  END BEFORE EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    IF czy_w_trakcie_dzialania THEN
        czy_w_trakcie_dzialania := false;
        czy_modyfikuje_tygrysa := true;
        UPDATE Kocury SET
        przydzial_myszy = przydzial_tygrysa,
        myszy_extra = myszy_extra_tygrysa
        WHERE pseudo = 'TYGRYS';
        czy_modyfikuje_tygrysa := false;
    END IF;
  END AFTER STATEMENT;
END Zad42Compound;

SELECT * FROM kocury WHERE funkcja = 'MILUSIA' OR pseudo = 'TYGRYS';
UPDATE kocury
SET przydzial_myszy = 30
WHERE funkcja = 'MILUSIA';
UPDATE kocury
SET przydzial_myszy = 26
WHERE pseudo = 'LOLA';
ROLLBACK
SET SERVEROUTPUT ON

//zadanie 43
DECLARE
    CURSOR funkcjeCur IS
    SELECT funkcja FROM Funkcje
    ORDER BY funkcja;
    
    CURSOR grupyCur IS
    SELECT nazwa, plec, COUNT(pseudo) ile, SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) suma_myszy
    FROM Kocury NATURAL JOIN Bandy
    GROUP BY nazwa, plec
    ORDER BY nazwa;
    
    suma_myszy_dla_funkcji NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT(RPAD('NAZWA BANDY', 20, ' '));
    DBMS_OUTPUT.PUT(RPAD('PLEC', 7, ' '));
    DBMS_OUTPUT.PUT(RPAD('ILE', 4, ' '));
    FOR funkcjaI IN funkcjeCur LOOP
        DBMS_OUTPUT.PUT(LPAD(funkcjaI.funkcja, 10, ' '));
    END LOOP;
    DBMS_OUTPUT.PUT(LPAD('SUMA', 7, ' '));
    DBMS_OUTPUT.NEW_LINE();
    
    DBMS_OUTPUT.PUT('------------------- ');
    DBMS_OUTPUT.PUT('------ ');
    DBMS_OUTPUT.PUT('----');
    FOR funkcjaI IN funkcjeCur LOOP
        DBMS_OUTPUT.PUT(' ---------');
    END LOOP;
    DBMS_OUTPUT.PUT(' ------');
    DBMS_OUTPUT.NEW_LINE();
        
    FOR grupa IN grupyCur LOOP
        DBMS_OUTPUT.PUT(RPAD(CASE WHEN grupa.plec = 'D' THEN grupa.nazwa ELSE ' ' END, 20, ' '));
        DBMS_OUTPUT.PUT(RPAD(CASE WHEN grupa.plec = 'D' THEN 'Kotka' ELSE 'Kocur' END, 7, ' '));
        DBMS_OUTPUT.PUT(LPAD(grupa.ile, 4, ' '));
        FOR funkcjaI IN funkcjeCur LOOP
            SELECT SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) INTO suma_myszy_dla_funkcji
            FROM Kocury NATURAL JOIN BANDY
            WHERE nazwa = grupa.nazwa AND plec = grupa.plec AND funkcja = funkcjaI.funkcja;
            DBMS_OUTPUT.PUT(LPAD(NVL(suma_myszy_dla_funkcji, 0), 10, ' '));
        END LOOP;
        DBMS_OUTPUT.PUT(LPAD(grupa.suma_myszy, 7, ' '));
        DBMS_OUTPUT.NEW_LINE();
    END LOOP;
    
    DBMS_OUTPUT.PUT('Z------------------ ');
    DBMS_OUTPUT.PUT('------ ');
    DBMS_OUTPUT.PUT('----');
    FOR funkcjaI IN funkcjeCur LOOP
        DBMS_OUTPUT.PUT(' ---------');
    END LOOP;
    DBMS_OUTPUT.PUT(' ------');
    DBMS_OUTPUT.NEW_LINE();
    
    DBMS_OUTPUT.PUT(RPAD('ZJADA RAZEM', 20, ' '));
    DBMS_OUTPUT.PUT('       ');
    DBMS_OUTPUT.PUT('    ');
    
    FOR funkcjaI IN funkcjeCur LOOP
        SELECT SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) INTO suma_myszy_dla_funkcji
        FROM Kocury NATURAL JOIN BANDY
        WHERE funkcja = funkcjaI.funkcja;
        DBMS_OUTPUT.PUT(LPAD(NVL(suma_myszy_dla_funkcji, 0), 10, ' '));
    END LOOP;
    
    SELECT SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) INTO suma_myszy_dla_funkcji
    FROM Kocury;
    DBMS_OUTPUT.PUT_LINE(LPAD(NVL(suma_myszy_dla_funkcji, 0), 7, ' '));
END;

//zad 44
CREATE OR REPLACE FUNCTION znajdz_wysokosc_podatku(pseudoIn VARCHAR)
RETURN NUMBER
AS
    kocur Kocury%ROWTYPE;
    podatek_od_sumy_myszy NUMBER;
    kara_za_brak_podwladnych NUMBER;
    kara_za_brak_wrogow NUMBER;
    podatek_dla_najnowszych NUMBER;
BEGIN
    SELECT * INTO kocur FROM Kocury WHERE pseudo = pseudoIn;

    SELECT CEIL(0.05 * SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) INTO podatek_od_sumy_myszy
    FROM Kocury WHERE pseudo = pseudoIn;
    
    SELECT DECODE(COUNT(K2.pseudo), 0, 2, 0) INTO kara_za_brak_podwladnych
    FROM Kocury K1 LEFT JOIN Kocury K2 ON K1.pseudo = pseudoIn AND K1.pseudo = K2.szef;
    
    SELECT DECODE(COUNT(WK.pseudo), 0, 1, 0) INTO kara_za_brak_wrogow
    FROM Kocury K1 LEFT JOIN Wrogowie_kocurow WK ON K1.pseudo = pseudoIn AND K1.pseudo = WK.pseudo;
    
    SELECT DECODE(MAX(w_stadku_od), kocur.w_stadku_od, 1, 0) INTO podatek_dla_najnowszych
    FROM Kocury
    WHERE nr_bandy = kocur.nr_bandy;
    
    RETURN podatek_od_sumy_myszy + kara_za_brak_podwladnych + kara_za_brak_wrogow + podatek_dla_najnowszych;
EXCEPTION
    WHEN NO_DATA_FOUND THEN 
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota o podanym pseudonimie');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

SELECT K1.pseudo,
    MIN(NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)) SUMA,
    COUNT(DISTINCT K2.pseudo) "liczba podwladnych",
    COUNT(DISTINCT WK.imie_wroga) "liczba wrogow",
    MIN(K1.w_stadku_od) "w stadku od",
    MIN(min_w_bandzie) "min w bandzie",
    MIN(znajdz_wysokosc_podatku(K1.pseudo)) "podatek"
FROM Kocury K1
    LEFT JOIN Kocury K2 ON K1.pseudo = K2.szef
    LEFT JOIN Wrogowie_kocurow WK ON K1.pseudo = WK.pseudo
    LEFT JOIN (SELECT Ki.nr_bandy, MAX(Ki.w_stadku_od) min_w_bandzie FROM Kocury Ki GROUP BY nr_bandy) Ki
        ON K1.nr_bandy = Ki.nr_bandy
GROUP BY K1.pseudo;

//zad 45
CREATE OR REPLACE TRIGGER odnotuj_wzrost_myszy_u_milusi
BEFORE UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW
DECLARE
    pragma AUTONOMOUS_TRANSACTION;
    dynamic_result VARCHAR2(1000); 
    allowed_user VARCHAR2(50) := 'd##266547';
BEGIN
    IF (:NEW.funkcja = 'MILUSIA')
        AND NVL(:NEW.przydzial_myszy, 0) > NVL(:OLD.przydzial_myszy, 0)
        AND LOGIN_USER != allowed_user
        THEN
            dynamic_result := '
                DECLARE
                    CURSOR milusieCur IS
                    SELECT pseudo
                    FROM Kocury
                    WHERE funkcja = ''MILUSIA'';
                BEGIN
                    FOR MILUSIA IN MilusieCur LOOP
                        INSERT INTO Dodatki_extra VALUES(milusia.pseudo, -10);
                    END LOOP;
                END;';
            EXECUTE IMMEDIATE dynamic_result;
            COMMIT;
    END IF;
END;

INSERT INTO Dodatki_extra
VALUES('TYGRYS', -10)
SELECT * FROM Dodatki_extra
UPDATE Kocury SET
przydzial_myszy = 50
WHERE funkcja = 'MILUSIA'
SELECT * FROM Kocury WHERE funkcja= 'MILUSIA'
DELETE FROM Dodatki_extra
ROLLBACK
SET SERVEROUTPUT ON

//zad 46
CREATE TABLE Niedozwolone_przydzialy
(uzytkownik VARCHAR2(20),
data_wpisu DATE,
pseudo VARCHAR2(20),
wydarzenie VARCHAR2(20))
DROP TABLE Niedozwolone_przydzialy

CREATE OR REPLACE TRIGGER przydzial_poza_granicami
BEFORE UPDATE OR INSERT ON Kocury
FOR EACH ROW
DECLARE
    minMyszy NUMBER;
    maxMyszy NUMBER;
    operacja VARCHAR2(20) := 'INSERT';
    pragma AUTONOMOUS_TRANSACTION;
BEGIN
    SELECT min_myszy, max_myszy
        INTO minMyszy, maxMyszy 
    FROM Funkcje
    WHERE funkcja = :NEW.funkcja;
    
    IF UPDATING THEN
        operacja := 'UPDATE';
    END IF;

    IF :NEW.przydzial_myszy < minMyszy OR :NEW.przydzial_myszy > maxMyszy THEN
        INSERT INTO Niedozwolone_przydzialy VALUES (SYS.LOGIN_USER, CURRENT_DATE , :NEW.pseudo, operacja);
        COMMIT;
        :NEW.przydzial_myszy := :OLD.przydzial_myszy;
        DBMS_OUTPUT.PUT_LINE('Przydzial myszy spoza przedzialu funkcji');
    END IF;
END;

SELECT * FROM Niedozwolone_przydzialy
DELETE FROM Niedozwolone_przydzialy;
UPDATE Kocury SET
przydzial_myszy = 500
WHERE pseudo = 'LOLA'
ROLLBACK
SET SERVEROUTPUT ON