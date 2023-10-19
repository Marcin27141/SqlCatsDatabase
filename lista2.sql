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
SELECT K1.imie, K1.funkcja, K2.imie, K3.imie, K4.imie
FROM Kocury K1
    LEFT JOIN Kocury K2 ON K1.szef = K2.pseudo
    LEFT JOIN Kocury K3 ON K2.szef = K3.pseudo
    LEFT JOIN Kocury K4 ON K3.szef = K4.pseudo
WHERE K1.funkcja IN ('KOT', 'MILUSIA')

//b) z wykorzystaniem drzewa
SELECT *
FROM (SELECT CONNECT_BY_ROOT imie "Imie", CONNECT_BY_ROOT funkcja "Funkcja", imie "Szef kota", Level "Level szefa"
    FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    CONNECT BY PRIOR szef = pseudo
    START WITH funkcja IN ('KOT', 'MILUSIA'))
PIVOT
(
    MIN("Szef kota")
    FOR "Level szefa"
    IN (2 "Szef 1",
        3 "Szef 2",
        4 "Szef 3")
)

//c) z wykorzystaniem drzewa, SYS_CONNECT_BY_PATH i CONNECT_BY_ROOT
SELECT
    CONNECT_BY_ROOT imie "Imie",
    CONNECT_BY_ROOT funkcja "Funkcja",
    SUBSTR(SYS_CONNECT_BY_PATH(RPAD(imie, 15, ' '), '| '), 17) "Imiona kolejnych szefów"
FROM Kocury
WHERE szef IS NULL
CONNECT BY PRIOR szef = pseudo
START WITH funkcja IN ('KOT', 'MILUSIA')

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
SELECT imie, funkcja, przydzial_myszy "PRZYDZIAL MYSZY"
FROM Kocury
WHERE przydzial_myszy >= ALL(SELECT 3*przydzial_myszy
                            FROM Kocury JOIN Bandy USING (nr_bandy)
                            WHERE funkcja = 'MILUSIA' AND teren IN ('SAD', 'CALOSC')
                            )