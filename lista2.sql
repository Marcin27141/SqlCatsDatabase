//lista 2
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

//zadanie 17
SELECT K.pseudo "POLUJE W POLU", K.przydzial_myszy "PRZYDZIAL MYSZY", B.nazwa
FROM Kocury K JOIN Bandy B USING(nr_bandy)
WHERE B.teren IN ('CALOSC', 'POLE') AND NVL(K.przydzial_myszy, 0) > 50
ORDER BY K.przydzial_myszy DESC;

//zadanie 18
SELECT K1.imie, K1.w_stadku_od "POLUJE OD"
FROM Kocury K1, Kocury K2
WHERE K2.imie = 'JACEK' AND K1.w_stadku_od < K2.w_stadku_od
ORDER BY K1.w_stadku_od DESC;

/*SELECT K1.imie, K1.w_stadku_od "POLUJE OD"
FROM Kocury K1 JOIN Kocury K2 ON K2.imie = 'JACEK'
WHERE K1.w_stadku_od < K2.w_stadku_od
ORDER BY K1.w_stadku_od DESC;*/

//zadanie 19
//a) tylko zlaczenia
SELECT K1.imie "Imie", K1.funkcja "Funkcja", K2.imie "Szef 1", K3.imie "Szef 2", K4.imie "Szef 3"
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

//zadanie 20
SELECT K.imie "Imie kotki", B.nazwa "Nazwa bandy", W.imie_wroga "Imie wroga", stopien_wrogosci "Ocena wroga", data_incydentu "Data inc."
FROM Kocury K
    JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    JOIN Wrogowie_kocurow WK ON WK.pseudo = K.pseudo
    JOIN Wrogowie W ON W.imie_wroga = WK.imie_wroga
WHERE K.plec = 'D' AND WK.data_incydentu > '2007-01-01'
ORDER BY K.imie, W.imie_wroga;

//zadanie 21
SELECT B.nazwa "Nazwa bandy", COUNT(DISTINCT WK.pseudo) "Koty z wrogami"
FROM Kocury K
    JOIN Bandy B ON K.nr_bandy = B.nr_bandy
    JOIN Wrogowie_kocurow WK ON K.pseudo = WK.pseudo
GROUP BY B.nazwa;

//zadanie 22
SELECT K.funkcja "Funkcja", pseudo "Pseudonim kota", COUNT(*) "Liczba wrogow"
FROM Kocury K JOIN Wrogowie_kocurow WK USING(pseudo)
GROUP BY K.funkcja, pseudo
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
//a) bez podzapytań i operatorów zbiorowych
SELECT B.nr_bandy "NR BANDY", B.nazwa, B.teren
FROM Bandy B LEFT JOIN Kocury K ON B.nr_bandy = K.nr_bandy
WHERE K.nr_bandy IS NULL;

//b) z wykorzystaniem operatorów zbiorowych
SELECT nr_bandy "NR BANDY", nazwa, teren
FROM Bandy
MINUS
SELECT B.nr_bandy "NR BANDY", B.nazwa, B.teren
FROM Bandy B JOIN Kocury K ON B.nr_bandy = K.nr_bandy
GROUP BY B.nr_bandy, B.nazwa, B.teren;

//zadanie 25
SELECT imie, funkcja, przydzial_myszy "PRZYDZIAL MYSZY"
FROM Kocury
WHERE przydzial_myszy >= ALL(SELECT 3*przydzial_myszy
                            FROM Kocury JOIN Bandy USING (nr_bandy)
                            WHERE funkcja = 'MILUSIA' AND teren IN ('SAD', 'CALOSC')
                            )

//zadanie 26
SELECT funkcja, ROUND(AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) "Srednio najw. i najm. myszy"
FROM Kocury,
    (SELECT AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) srednie
    FROM Kocury
    WHERE funkcja != 'SZEFUNIO'
    GROUP BY funkcja)
WHERE funkcja != 'SZEFUNIO'
GROUP BY funkcja
HAVING AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) = MIN(srednie)
        OR AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) = MAX(srednie)

//zadanie 27
//a
SELECT pseudo, NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) "ZJADA"
FROM Kocury K
WHERE 6 > (SELECT COUNT(DISTINCT (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)))
            FROM Kocury
            WHERE (NVL(K.przydzial_myszy, 0) + NVL(K.myszy_extra, 0)) < (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))
            )
ORDER BY 2 DESC;

//b
SELECT pseudo, NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)
FROM Kocury K
WHERE NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) >= (SELECT MIN(ranking)
                                                        FROM
                                                            (SELECT DISTINCT NVL(przydzial_myszy,0) + NVL(myszy_extra,0) ranking
                                                            FROM Kocury
                                                            ORDER BY 1 DESC)
                                                        WHERE ROWNUM <= 6)
ORDER BY 2 DESC;

//c
SELECT K1.pseudo, NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0) "ZJADA"
FROM Kocury K1 LEFT JOIN Kocury K2 ON (NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)) < (NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0))
GROUP BY K1.pseudo, NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)
HAVING COUNT(DISTINCT NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)) < 6
ORDER BY 2 DESC

//d
SELECT pseudo, suma_myszy "ZJADA"
FROM (
    SELECT
        pseudo,
        NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) suma_myszy,
        DENSE_RANK()
            OVER (ORDER BY (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) DESC) pozycja
    FROM Kocury)
WHERE pozycja <= 6;

//zadanie 28
SELECT TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "ROK", COUNT(*) "LICZBA WSTAPIEN"
FROM Kocury,
    (SELECT AVG(COUNT(*)) srednia
    FROM Kocury
    GROUP BY EXTRACT(YEAR FROM w_stadku_od))
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
HAVING (COUNT(*) - MIN(srednia)) IN ((SELECT MAX((COUNT(*) - MIN(srednia))) dolna_granica
                                    FROM Kocury
                                    GROUP BY EXTRACT(YEAR FROM w_stadku_od)
                                    HAVING (COUNT(*) - MIN(srednia)) < 0),
                                    (SELECT MIN((COUNT(*) - MIN(srednia))) gorna_granica
                                    FROM Kocury
                                    GROUP BY EXTRACT(YEAR FROM w_stadku_od)
                                    HAVING (COUNT(*) - MIN(srednia)) > 0))
UNION
SELECT 'srednia', ROUND(AVG(COUNT(*)), 7)
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
ORDER BY 2

//zadanie 29
//a
SELECT K1.imie, MIN(K1.przydzial_myszy) "ZJADA", K1.nr_bandy "NR BANDY",
    AVG(NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)) "SREDNIA BANDY"
FROM Kocury K1 JOIN Kocury K2 ON K1.nr_bandy = K2.nr_bandy
WHERE K1.plec = 'M'
GROUP BY K1.imie, K1.nr_bandy
HAVING MIN((NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0))) <=
    AVG(NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0))
ORDER BY K1.nr_bandy DESC;

//b
SELECT K.imie, K.przydzial_myszy "ZJADA", K.nr_bandy "NR BANDY", SR.srednia "SREDNIA BANDY"
FROM Kocury K
    JOIN (SELECT nr_bandy, AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) srednia
          FROM Kocury
          GROUP BY nr_bandy) SR
    ON K.nr_bandy = SR.nr_bandy
        AND (NVL(K.przydzial_myszy, 0) + NVL(K.myszy_extra, 0)) <= SR.srednia
WHERE K.plec = 'M'
ORDER BY K.nr_bandy DESC;

//c
SELECT K.imie, K.przydzial_myszy "ZJADA", K.nr_bandy "NR BANDY",
    (SELECT AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))
     FROM Kocury
     WHERE nr_bandy = K.nr_bandy) "SREDNIA BANDY"
FROM Kocury K
WHERE K.plec = 'M'
    AND NVL(K.przydzial_myszy, 0) + NVL(K.myszy_extra, 0) <=
        (SELECT AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))
        FROM Kocury
        WHERE nr_bandy = K.nr_bandy)
ORDER BY K.nr_bandy DESC;

//zadanie 30
SELECT K.imie, '  '||TO_CHAR(K.w_stadku_od)||' <---' "WSTAPIL DO STADKA", 'NAJMLODSZY STAZEM W BANDZIE '||B.nazwa " "
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE K.w_stadku_od = (SELECT MAX(w_stadku_od)
                       FROM Kocury
                       WHERE nr_bandy = K.nr_bandy)
UNION
SELECT K.imie, '  '||TO_CHAR(K.w_stadku_od)||' <---' "WSTAPIL DO STADKA", 'NAJSTARSZY STAZEM W BANDZIE '||B.nazwa " "
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE K.w_stadku_od = (SELECT MIN(w_stadku_od)
                       FROM Kocury NATURAL JOIN Bandy
                       WHERE nr_bandy = K.nr_bandy)
UNION
SELECT K.imie, '  '||TO_CHAR(K.w_stadku_od)||' <---' "WSTAPIL DO STADKA", ' ' " "
FROM Kocury K
WHERE K.w_stadku_od NOT IN (
    (SELECT MIN(w_stadku_od)
     FROM Kocury
     WHERE nr_bandy = K.nr_bandy),
    (SELECT MAX(w_stadku_od)
     FROM Kocury
     WHERE nr_bandy = K.nr_bandy))
ORDER BY 1

//zadanie 31
DROP VIEW Zadanie31

CREATE VIEW Zadanie31 (nazwa_bandy, sre_spoz, max_spoz, min_spoz, koty, koty_z_dod)
AS
SELECT B.nazwa,
    AVG(K.przydzial_myszy),
    MAX(K.przydzial_myszy),
    MIN(K.przydzial_myszy),
    COUNT(K.pseudo),
    COUNT(K.myszy_extra)
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
GROUP BY B.nazwa

SELECT * FROM Zadanie31

ACCEPT lookup_pseudo PROMPT 'Enter pseudo: '
SELECT K.pseudo "PSEUDONIM", K.imie, K.funkcja, K.przydzial_myszy "ZJADA",
       'OD '|| Z.min_spoz ||' DO '|| Z.max_spoz "GRANICE SPOZYCIA", K.w_stadku_od "LOWI OD"
FROM Zadanie31 Z
JOIN Bandy B ON Z.nazwa_bandy = B.nazwa
JOIN KOCURY K ON K.nr_bandy = B.nr_bandy
WHERE pseudo = '&lookup_pseudo';

//zadanie 32
/*DROP VIEW Zadanie32

CREATE VIEW Zadanie32
AS
SELECT K.pseudo, K.plec, NVL(K.przydzial_myszy, 0) przydzial_myszy, NVL(K.myszy_extra, 0) myszy_extra
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE B.nazwa IN ('CZARNI RYCERZE', 'LACIACI MYSLIWI')
    AND 3 > (SELECT COUNT(DISTINCT w_stadku_od)
             FROM Kocury
             WHERE nr_bandy = K.nr_bandy AND w_stadku_od < K.w_stadku_od)
*/

SELECT K.pseudo "Pseudonim", K.plec "Plec", NVL(K.przydzial_myszy, 0) "Myszy przed podw.", NVL(K.myszy_extra, 0) "Extra przed podw."
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE B.nazwa IN ('CZARNI RYCERZE', 'LACIACI MYSLIWI')
    AND 3 > (SELECT COUNT(DISTINCT w_stadku_od)
             FROM Kocury
             WHERE nr_bandy = K.nr_bandy AND w_stadku_od < K.w_stadku_od)
             
SELECT K.pseudo "Pseudonim", K.plec "Plec", NVL(K.przydzial_myszy, 0) "Myszy przed podw.", NVL(K.myszy_extra, 0) "Extra przed podw."
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy

UPDATE Kocury K_UP
SET przydzial_myszy = (CASE
                       WHEN plec = 'M' THEN 10
                       ELSE 0.1 * (SELECT MIN(K.przydzial_myszy) FROM Kocury K)
                       END) + przydzial_myszy,
    myszy_extra = ROUND(0.15 * (SELECT AVG(NVL(K.myszy_extra, 0))
                                FROM Kocury K
                                WHERE K.nr_bandy = K_UP.nr_bandy)
                        + NVL(myszy_extra, 0))
WHERE nr_bandy IN (SELECT nr_bandy FROM Bandy WHERE nazwa IN ('CZARNI RYCERZE', 'LACIACI MYSLIWI'))
    AND 3 > (SELECT COUNT(DISTINCT K.w_stadku_od)
             FROM Kocury K
             WHERE K_UP.nr_bandy = K.nr_bandy AND K_UP.w_stadku_od > K.w_stadku_od)
             
                        
SELECT K.pseudo "Pseudonim", K.plec "Plec", NVL(K.przydzial_myszy, 0) "Myszy po podw.", NVL(K.myszy_extra, 0) "Extra po podw."
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE B.nazwa IN ('CZARNI RYCERZE', 'LACIACI MYSLIWI')
    AND 3 > (SELECT COUNT(DISTINCT w_stadku_od)
             FROM Kocury
             WHERE nr_bandy = K.nr_bandy AND w_stadku_od < K.w_stadku_od)
             
ROLLBACK

//zadanie 33
//b
SELECT *
FROM
    (SELECT
        TO_CHAR(DECODE(plec, 'D', nazwa, '')) "NAZWA BANDY",
        TO_CHAR(DECODE(plec, 'D', 'Kotka', 'Kocur')) "PLEC",
        TO_CHAR(liczba_grp) "ILE",
        TO_CHAR(NVL("SZEFUNIO", 0)) "SZEFUNIO",
        TO_CHAR(NVL("BANDZIOR", 0)) "BANDZIOR",
        TO_CHAR(NVL("LOWCZY", 0)) "LOWCZY",
        TO_CHAR(NVL("LAPACZ", 0)) "LAPACZ",
        TO_CHAR(NVL("KOT", 0)) "KOT",
        TO_CHAR(NVL("MILUSIA", 0)) "MILUSIA",
        TO_CHAR(NVL("DZIELNICZY", 0)) "DZIELNICZY",
        TO_CHAR(suma_grp) "SUMA"
    FROM (SELECT nazwa, plec, funkcja, NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) myszy_kota
          FROM Kocury JOIN Bandy USING (nr_bandy))
    PIVOT (
        SUM(myszy_kota)
        FOR funkcja
        IN ('SZEFUNIO' "SZEFUNIO", 'BANDZIOR' "BANDZIOR", 'LOWCZY' "LOWCZY",
                'LAPACZ' "LAPACZ", 'KOT' "KOT", 'MILUSIA' "MILUSIA", 'DZIELCZY' "DZIELNICZY")
    ) JOIN (SELECT nazwa nazwa_grp, plec plec_grp, COUNT(pseudo) liczba_grp, SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) suma_grp
          FROM Kocury JOIN Bandy USING (nr_bandy)
          GROUP BY nazwa, plec) PL
    ON plec_grp = plec AND nazwa_grp = nazwa
)
UNION ALL
SELECT 'Z--------------', '------', '--------', '---------', '---------', '--------', '--------', '--------',
       '--------','----------', '--------'
FROM DUAL
UNION
(SELECT
        'ZJADA RAZEM',
        ' ',
        ' ',
        TO_CHAR(NVL("SZEFUNIO", 0)) "SZEFUNIO",
        TO_CHAR(NVL("BANDZIOR", 0)) "BANDZIOR",
        TO_CHAR(NVL("LOWCZY", 0)) "LOWCZY",
        TO_CHAR(NVL("LAPACZ", 0)) "LAPACZ",
        TO_CHAR(NVL("KOT", 0)) "KOT",
        TO_CHAR(NVL("MILUSIA", 0)) "MILUSIA",
        TO_CHAR(NVL("DZIELNICZY", 0)) "DZIELNICZY",
        TO_CHAR((SELECT SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) FROM Kocury))
    FROM (SELECT funkcja, SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) suma
          FROM Kocury
          GROUP BY funkcja)
    PIVOT (
        MIN(suma)
        FOR funkcja
        IN ('SZEFUNIO' "SZEFUNIO", 'BANDZIOR' "BANDZIOR", 'LOWCZY' "LOWCZY",
                'LAPACZ' "LAPACZ", 'KOT' "KOT", 'MILUSIA' "MILUSIA", 'DZIELCZY' "DZIELNICZY")
    )
)