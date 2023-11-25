//zad 1
SELECT AVG(NVL(K.przydzial_myszy, 0))
FROM Kocury K LEFT JOIN Wrogowie_kocurow WK ON K.pseudo = WK.pseudo
WHERE K.plec = 'M' AND WK.pseudo IS NULL AND 55 <= (SELECT AVG(NVL(przydzial_myszy, 0))
                                                    FROM Kocury
                                                    WHERE nr_bandy = K.nr_bandy)
                                                    
//zad 2
SELECT MAX(NVL(przydzial_myszy, 0)), COUNT(pseudo) - COUNT(myszy_extra)
FROM Kocury K
WHERE (plec IN (SELECT DISTINCT plec
                FROM Kocury
                WHERE pseudo IN ('PLACEK', 'RURA'))
        AND nr_bandy IN (SELECT DISTINCT nr_bandy
                FROM Kocury
                WHERE pseudo IN ('PLACEK', 'RURA')))
        OR (nr_bandy IN (SELECT nr_bandy
                        FROM Kocury
                        GROUP BY nr_bandy
                        HAVING AVG(NVL(przydzial_myszy, 0)) > 50)
        AND NVL(przydzial_myszy, 0) >= 1.1 * (SELECT MIN(NVL(przydzial_myszy, 0))
                                            FROM Kocury
                                            WHERE nr_bandy = K.nr_bandy))

//zad 3
SELECT K.pseudo, K.nr_bandy
FROM Kocury K LEFT JOIN Wrogowie_kocurow WK ON K.pseudo = WK.pseudo
WHERE K.plec = 'M' AND WK.pseudo IS NULL AND nr_bandy IN (SELECT nr_bandy
                                                        FROM Kocury
                                                        WHERE plec = 'M'
                                                        GROUP BY nr_bandy
                                                        HAVING AVG(NVL(przydzial_myszy, 0)) > 55)
                                                        
//zad 4
SELECT AVG(NVL(K.przydzial_myszy, 0))
FROM Kocury K LEFT JOIN Wrogowie_kocurow WK ON K.pseudo = WK.pseudo
WHERE K.plec = 'M' AND WK.pseudo IS NULL AND 55 <= (SELECT AVG(NVL(przydzial_myszy, 0))
                                                    FROM Kocury
                                                    WHERE nr_bandy = K.nr_bandy)
                                                    
//zad 2
SELECT MAX(NVL(przydzial_myszy, 0)), COUNT(pseudo) - COUNT(myszy_extra)
FROM Kocury K
WHERE (plec IN (SELECT DISTINCT plec
                FROM Kocury
                WHERE pseudo IN ('PLACEK', 'RURA'))
        AND nr_bandy IN (SELECT DISTINCT nr_bandy
                FROM Kocury
                WHERE pseudo IN ('PLACEK', 'RURA')))
        OR (nr_bandy IN (SELECT nr_bandy
                        FROM Kocury
                        GROUP BY nr_bandy
                        HAVING AVG(NVL(przydzial_myszy, 0)) > 50)
        AND NVL(przydzial_myszy, 0) >= 1.1 * (SELECT MIN(NVL(przydzial_myszy, 0))
                                            FROM Kocury
                                            WHERE nr_bandy = K.nr_bandy))

//zad3
SELECT K.pseudo, K.nr_bandy
FROM Kocury K LEFT JOIN Wrogowie_kocurow WK ON K.pseudo = WK.pseudo
WHERE K.plec = 'M' AND WK.pseudo IS NULL AND nr_bandy IN (SELECT nr_bandy
                                                        FROM Kocury
                                                        WHERE plec = 'M'
                                                        GROUP BY nr_bandy
                                                        HAVING AVG(NVL(przydzial_myszy, 0)) > 55)
                                                        
//zad 4
SELECT B.nr_bandy, MIN(B.nazwa)
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
GROUP BY B.nr_bandy
HAVING COUNT(K.pseudo) > 4) AND
    (SELECT COUNT(pseudo)
    FROM Kocury K2 JOIN Myszy ON K2.pseudo = M.pseudo_zjadacza
    WHERE nr_bandy = B.nr_bandy) >
    (SELECT COUNT(pseudo)
    FROM Kocury K2 JOIN Myszy M ON K2.pseudo = M.psedo_lapacza
    WHERE nr_bandy = B.nr_bandy)