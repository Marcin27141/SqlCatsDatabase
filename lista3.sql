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
CREATE OR REPLACE PACKAGE Zad42 AS
    przydzial_tygrysa NUMBER;
    czy_ukarac_tygrysa BOOLEAN;
    czy_modyfikuje_tygrysa BOOLEAN;
    czy_w_trakcie_dzialania BOOLEAN;
END;

CREATE OR REPLACE PACKAGE BODY Zad42 AS
BEGIN
    czy_ukarac_tygrysa := false;
    czy_modyfikuje_tygrysa := false;
    czy_w_trakcie_dzialania := false;
END Zad42;
    
CREATE OR REPLACE TRIGGER pozyskaj_przydzial_tygrysa
BEFORE UPDATE ON Kocury
BEGIN
    SELECT przydzial_myszy INTO Zad42.przydzial_tygrysa
    FROM Kocury
    WHERE pseudo = 'TYGRYS';
END;


CREATE OR REPLACE TRIGGER ustaw_myszy_milus
BEFORE UPDATE ON Kocury
FOR EACH ROW
BEGIN
    IF :NEW.funkcja = 'MILUSIA' AND NOT Zad42.czy_modyfikuje_tygrysa THEN
        Zad42.czy_w_trakcie_dzialania := true;
    
        IF :NEW.przydzial_myszy < :OLD.przydzial_myszy THEN
            RAISE_APPLICATION_ERROR(-20001, 'Kto wazyl sie obnizyc przydzial Milusi?');
        END IF;
        
        IF :NEW.przydzial_myszy < 0.1 * Zad42.przydzial_tygrysa THEN
            :NEW.przydzial_myszy := 0.1 * Zad42.przydzial_tygrysa;
            :NEW.myszy_extra := :NEW.myszy_extra + 5;
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
        ELSE
            UPDATE Kocury SET
            myszy_extra = myszy_extra + 5
            WHERE pseudo = 'TYGRYS';
        END IF;
        
        Zad42.czy_modyfikuje_tygrysa := false;
    END IF;
END;



ALTER TRIGGER pozyskaj_przydzial_tygrysa ENABLE;
ALTER TRIGGER ustaw_myszy_milus ENABLE;
ALTER TRIGGER rozwiaz_sprawe_tygrysa ENABLE;

ALTER TRIGGER pozyskaj_przydzial_tygrysa DISABLE;
ALTER TRIGGER ustaw_myszy_milus DISABLE;
ALTER TRIGGER rozwiaz_sprawe_tygrysa DISABLE;

ALTER TRIGGER co_z_myszkami DISABLE;
SELECT * FROM kocury WHERE funkcja = 'MILUSIA' OR pseudo = 'TYGRYS';
UPDATE kocury
SET przydzial_myszy = 30
WHERE funkcja = 'MILUSIA';
ROLLBACK