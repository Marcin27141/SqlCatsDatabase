SET SERVEROUTPUT ON
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

//zadanie 34
DECLARE
    funkcjaIn Kocury.funkcja%TYPE := '&funkcja';
    liczba_kotow NUMBER(2);
BEGIN
    SELECT COUNT(*) INTO liczba_kotow FROM Kocury WHERE funkcja = funkcjaIn;
    IF liczba_kotow = 0
        THEN DBMS_OUTPUT.PUT_LINE('Nie znaleziono kocurow dla funkcji '||funkcjaIn);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Znaleziono kocury pelniace funkcje '||funkcjaIn);
    END IF;
END;

//zadanie 35
DECLARE
    pseudoIn Kocury.pseudo%TYPE := '&pseudo';
    kocur Kocury%ROWTYPE;
BEGIN
    SELECT * INTO kocur FROM Kocury WHERE pseudo = pseudoIn;
    CASE
        WHEN (NVL(kocur.przydzial_myszy, 0) + NVL(kocur.myszy_extra, 0) * 12) > 700
            THEN DBMS_OUTPUT.PUT_LINE('calkowity roczny przydzial myszy > 700');
        WHEN kocur.imie LIKE '%A%'
            THEN DBMS_OUTPUT.PUT_LINE('imie zawiera litere A');
        WHEN EXTRACT(MONTH FROM kocur.w_stadku_od) = 5
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
    kocur kocury%ROWTYPE;
    suma_przydzialow NUMBER(4);
    dodatkowy_przydzial NUMBER(2);
    liczba_modyfikacji NUMBER(2) := 0;
BEGIN
    SELECT SUM(NVL(przydzial_myszy,0)) INTO suma_przydzialow FROM Kocury;
    DBMS_OUTPUT.PUT(suma_przydzialow);
    <<przydzialy>>LOOP
        FOR kocur IN kocury LOOP
            EXIT przydzialy WHEN suma_przydzialow > 1050;
            
            dodatkowy_przydzial := NVL(kocur.pm,0) * 0.1;
            IF (kocur.pm + dodatkowy_przydzial > kocur.maxMyszy)
                THEN dodatkowy_przydzial := (kocur.maxMyszy - kocur.pm);
            END IF;
            
            UPDATE Kocury
            SET przydzial_myszy = NVL(przydzial_myszy,0) + dodatkowy_przydzial
            WHERE CURRENT OF kocury;
            
            suma_przydzialow := suma_przydzialow + dodatkowy_przydzial;
            liczba_modyfikacji := liczba_modyfikacji + 1;
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
