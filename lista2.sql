//lista 2

//zadanie 17
SELECT K.pseudo "POLUJE W POLU", K.przydzial_myszy "PRZYDZIAL MYSZY", B.nazwa
FROM Kocury K JOIN Bandy B USING(nr_bandy)
WHERE B.teren IN ('CALOSC', 'POLE') AND K.przydzial_myszy > 50
ORDER BY K.przydzial_myszy DESC;

//zadanie 18
SELECT K1.imie, K1.w_stadku_od "POLUJE OD"
FROM Kocury K1, Kocury K2
WHERE K2.imie = 'JACEK' AND K1.w_stadku_od < K2.w_stadku_od
ORDER BY K1.w_stadku_od DESC;

//zadanie 19
//a) tylko zlaczenia
/*SELECT K1.imie, K1.funkcja, K2.imie, K3.imie, K4.imie
FROM Kocury K1
    LEFT JOIN Kocury K2 ON K1.szef = K2.pseudo
    LEFT JOIN Kocury K3 ON K2.szef = K3.pseudo
    LEFT JOIN Kocury K4 ON K3.szef = K4.pseudo
WHERE K1.funkcja IN ('KOT', 'MILUSIA')

//b) z wykorzystaniem drzewa
SELECT Level, imie, funkcja
FROM Kocury
CONNECT BY PRIOR szef = pseudo
START WITH funkcja IN ('KOT', 'MILUSIA')

//c) z wykorzystaniem drzewa, SYS_CONNECT_BY_PATH i CONNECT_BY_ROOT
SELECT imie, funkcja, SYS_CONNECT_BY_PATH(szef, '/')
FROM Kocury
CONNECT BY PRIOR szef = pseudo
START WITH funkcja IN ('KOT', 'MILUSIA')

SELECT CONNECT_BY_ROOT imie "Imie",
       CONNECT_BY_ROOT funkcja "Funkcja",
       REPLACE(SYS_CONNECT_BY_PATH(imie, ' | '), ' | ' || CONNECT_BY_ROOT IMIE || ' ' , '') "Imiona kolejnych szefow"
FROM Kocury
WHERE szef IS NULL
CONNECT BY PRIOR szef = pseudo
START WITH funkcja IN ('KOT','MILUSIA');

SELECT * FROM Kocury WHERE szef IS NULL*/

ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

//zadanie 20
SELECT K.imie "Imie kotki", B.nazwa "Nazwa bandy", W.imie_wroga "Imie wroga", stopien_wrogosci "Ocena wroga", data_incydentu "Data inc."
FROM Kocury K
    JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    JOIN Wrogowie_kocurow WK ON WK.pseudo = K.pseudo
    JOIN Wrogowie W ON W.imie_wroga = WK.imie_wroga
WHERE K.plec = 'D' AND WK.data_incydentu > '2007-01-01'
ORDER BY K.imie, W.imie_wroga;

//zadanie 21
SELECT B.nazwa "Nazwa bandy", COUNT(DISTINCT K.pseudo) "Koty z wrogami"
FROM Kocury K
    JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    JOIN Wrogowie_kocurow WK ON K.pseudo = WK.pseudo
GROUP BY B.nazwa;

//zadanie 22
SELECT K.funkcja "Funkcja", K.pseudo "Pseudonim kota", COUNT(*) "Liczba wrogow"
FROM Kocury K JOIN Wrogowie_kocurow WK ON K.pseudo = WK.pseudo
GROUP BY K.funkcja, K.pseudo
HAVING COUNT(WK.imie_wroga) > 1;

//zadanie 23
SELECT imie,
    (NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12) "DAWKA ROCZNA",
    'powyzej 864' "DAWKA"
FROM Kocury
WHERE NVL(myszy_extra, 0) > 0 AND (NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12) > 864
UNION
SELECT imie,
    (NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12) "DAWKA ROCZNA",
    '864' "DAWKA"
FROM Kocury
WHERE NVL(myszy_extra, 0) > 0 AND (NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12) = 864
UNION
SELECT imie,
    (NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12) "DAWKA ROCZNA",
    'ponizej 864' "DAWKA"
FROM Kocury
WHERE NVL(myszy_extra, 0) > 0 AND (NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12) < 864
ORDER BY 2 DESC

//zadanie 24
SELECT B.nr_bandy "NR BANDY", B.nazwa, B.teren
FROM Bandy B LEFT JOIN Kocury K ON B.nr_bandy = K.nr_bandy
WHERE K.nr_bandy IS NULL;

//zadanie 25
/*
SELECT imie, funkcja, przydzial_myszy "PRZYDZIAL MYSZY"
FROM Kocury
WHERE przydzial_myszy >= (SELECT DISTINCT K1.przydzial_myszy
                            FROM Kocury K1
                                LEFT JOIN Kocury K2 ON
                                    K1.przydzial_myszy < K2.przydzial_myszy
                                    AND K2.przydzial_myszy IS NOT NULL
                                JOIN Bandy B ON K1.nr_bandy = B.nr_bandy
                            WHERE K1.funkcja = 'MILUSIA'
                                AND B.teren IN ('SAD', 'CALOSC')
                                AND 
                            

SELECT *
FROM Kocury K LEFT JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE K.funkcja = 'MILUSIA' AND B.teren IN ('SAD', 'CALOSC')*/