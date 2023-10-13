ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

//zadanie 1
SELECT imie_wroga WROG, opis_incydentu PRZEWINA
FROM Wrogowie_kocurow
WHERE EXTRACT(YEAR FROM data_incydentu) = 2009;

//zadanie 2
SELECT imie, funkcja, w_stadku_od "Z NAMI OD"
FROM Kocury
WHERE plec = 'D' AND w_stadku_od BETWEEN '2005-09-01' AND '2007-07-31';

//zadanie 3
SELECT imie_wroga, gatunek, stopien_wrogosci "STOPIEN WROGOSCI"
FROM Wrogowie
WHERE lapowka IS NULL
ORDER BY stopien_wrogosci;

//zadanie 4
SELECT imie||' zwany '||pseudo||' (fun. '||funkcja||') lowi myszki w bandzie '||nr_bandy||' od '||w_stadku_od "WSZYSTKO O KOCURACH"
FROM Kocury
WHERE plec = 'M'
ORDER BY w_stadku_od DESC, pseudo;

//zadanie 5
SELECT pseudo, REGEXP_REPLACE(REGEXP_REPLACE(pseudo, 'A', '#', 1, 1), 'L', '%', 1, 1) "Po wymianie A na # oraz L na %"
FROM Kocury
WHERE INSTR(pseudo, 'A') > 0 AND INSTR(pseudo, 'L') > 0;

//zadanie 6
SELECT imie, w_stadku_od "W stadku", (przydzial_myszy - FLOOR(przydzial_myszy / 10)) Zjadal, ADD_MONTHS(w_stadku_od, 6) Podwyzka, przydzial_myszy Zjada
FROM Kocury
WHERE ((date '2023-06-29' - w_stadku_od) / 365) >= 14
    AND EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9
ORDER BY przydzial_myszy DESC;

//zadanie 7
SELECT imie, (NVL(przydzial_myszy, 0) * 3) "MYSZY KWARTALNE", (NVL(myszy_extra, 0) * 3) "KWARTALNE DODATKI"
FROM Kocury
WHERE NVL(przydzial_myszy, 0) > (2 * NVL(myszy_extra, 0)) AND NVL(przydzial_myszy, 0) >= 55
ORDER BY przydzial_myszy DESC, imie;

//zadanie 8
SELECT
    imie,
    CASE
        WHEN (przydzial_myszy*12 + NVL(myszy_extra, 0)*12) > 660 THEN TO_CHAR((przydzial_myszy*12 + NVL(myszy_extra, 0)*12))
        WHEN (przydzial_myszy*12 + NVL(myszy_extra, 0)*12) = 660 THEN 'Limit'
        ELSE 'Poniżej 660'
    END "Zjada rocznie"
FROM Kocury
ORDER BY imie;

//zadanie 9
//24.10.2023
SELECT
    pseudo,
    w_stadku_od,
    CASE
        WHEN (EXTRACT(DAY FROM w_stadku_od) BETWEEN 1 AND 15)
        AND NEXT_DAY(LAST_DAY('2023-10-24') - 7, 3) >= '2023-10-24'
        THEN NEXT_DAY(LAST_DAY('2023-10-24') - 7, 3)
        ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2023-10-24', 1)) - 7, 3)
    END WYPLATA
FROM Kocury
ORDER BY w_stadku_od;

//26.10.2023
SELECT
    pseudo,
    w_stadku_od,
    CASE
        WHEN (EXTRACT(DAY FROM w_stadku_od) BETWEEN 1 AND 15)
        AND NEXT_DAY(LAST_DAY('2023-10-26') - 7, 3) >= '2023-10-26'
        THEN NEXT_DAY(LAST_DAY('2023-10-26') - 7, 3)
        ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2023-10-26', 1)) - 7, 3)
    END WYPLATA
FROM Kocury
ORDER BY w_stadku_od;

//zadanie 10
//unikalnosc atr. PSEUDO
SELECT pseudo||' - '||(CASE WHEN Count(*) > 1 THEN 'nieunikalny' ELSE 'Unikalny' END) "Unikalnosc atr. PSEUDO"
FROM Kocury
GROUP BY pseudo
ORDER BY pseudo;

//unikalnosc atr. SZEF
SELECT szef||' - '||(CASE WHEN Count(*) > 1 THEN 'nieunikalny' ELSE 'Unikalny' END) "Unikalnosc atr. SZEF"
FROM Kocury
WHERE szef IS NOT NULL
GROUP BY szef
ORDER BY szef;