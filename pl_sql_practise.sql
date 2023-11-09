SET SERVEROUTPUT ON

CREATE VIEW Banda4
AS
SELECT pseudo,imie,funkcja,przydzial_myszy,nr_bandy
FROM Kocury WHERE nr_bandy=4
WITH CHECK OPTION;

--inserting rows and handling exceptions
CREATE UNIQUE INDEX unikalne_imie ON Kocury(imie);
BEGIN
    INSERT INTO Banda4 VALUES ('&pseudo','&imie','&funkcja',&przydzial_myszy,&nr_bandy);
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX
    THEN DBMS_OUTPUT.PUT_LINE('Powtarzajace sie pseudo lub imie!!! - BRAK WPISU!');
    WHEN OTHERS
    THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

--showing number of modified rows
DECLARE
    liczba_pop NUMBER;
BEGIN
    UPDATE Kocury SET myszy_extra=myszy_extra+1
    WHERE myszy_extra>20;
    liczba_pop:=SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Poprawiono krotek: '||liczba_pop);
END;
ROLLBACK;

--loading values into declared variables
DECLARE
  l_kotow NUMBER;
  l_z_dodatkami NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_kotow
  FROM Kocury;
  SELECT COUNT(myszy_extra) INTO l_z_dodatkami
  FROM Kocury; 
  DBMS_OUTPUT.PUT_LINE('*'||LPAD('*',54,'*')||'*');
  DBMS_OUTPUT.PUT_LINE('*'||LPAD(' ',54,' ')||'*');
  DBMS_OUTPUT.PUT_LINE('*  W stadku '||
                   ROUND(l_z_dodatkami/l_kotow*100,2)||
                   '% kotow ma dodatkowy przydzial myszy  *');
  DBMS_OUTPUT.PUT_LINE('*'||LPAD(' ',54,' ')||'*'); 
  DBMS_OUTPUT.PUT_LINE('*'||LPAD('*',54,'*')||'*');
 
EXCEPTION
  WHEN ZERO_DIVIDE 
  THEN DBMS_OUTPUT.PUT_LINE('Brak kotow w stadzie!!!');
  WHEN OTHERS
  THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;


--loading variables, defining exception types, handling exceptions
DECLARE
    maxm Funkcje.max_myszy%TYPE;
    minm Funkcje.min_myszy%TYPE;
    p1   Funkcje.funkcja%TYPE:='&funkcja';
    p2   Kocury.przydzial_myszy%TYPE:=&nowy_przydzial;
    za_malo_lub_za_duzo EXCEPTION;
BEGIN
    SELECT max_myszy,min_myszy INTO maxm,minm FROM Funkcje
    WHERE funkcja=p1;
    IF p2 BETWEEN minm AND maxm 
       THEN UPDATE Kocury SET przydzial_myszy=p2
            WHERE funkcja=p1;
        --ELSE RAISE za_malo_lub_za_duzo;
        ELSE RAISE_APPLICATION_ERROR(-20001, 'Poza widelkami!!!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        --DBMS_OUTPUT.PUT_LINE('Bledna funkcja!!!');
        RAISE_APPLICATION_ERROR(-20002, 'Bledna funkcja!!!');
--    WHEN za_malo_lub_za_duzo
--        THEN DBMS_OUTPUT.PUT_LINE('Poza widelkami!!!');
    WHEN OTHERS 
        THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
ROLLBACK;

--handling exceptions with pragma
DECLARE
    wyj EXCEPTION;
    PRAGMA EXCEPTION_INIT(wyj,-1);
BEGIN
    INSERT INTO Bandy VALUES (5,'NOWORYSZE','LASEK');
EXCEPTION
    WHEN wyj THEN
       DBMS_OUTPUT.PUT_LINE('Nr bandy wpisany przez Ciebie juz istnieje!!!');
       DBMS_OUTPUT.PUT_LINE('Zastosuj sekwencję Numery_band!!!');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

--loop statement with then exit
DECLARE
    licznik NUMBER(2) := 0;
BEGIN
    LOOP
        licznik:=licznik+1;
        DBMS_OUTPUT.PUT_LINE(licznik);
        IF licznik=10 THEN EXIT;
        END IF;
    END LOOP;
END;

--loop statement with exit when
DECLARE
    licznik NUMBER(2) := 0;
BEGIN
    LOOP
        licznik:=licznik+1;
        DBMS_OUTPUT.PUT_LINE(licznik);
        EXIT WHEN licznik >= 10;
    END LOOP;
END;

--records based on a table
DECLARE
  kocury_r Kocury%ROWTYPE;
BEGIN
  SELECT * INTO kocury_r
  FROM Kocury
  WHERE pseudo='TYGRYS';
END;

--declaring records
DECLARE
  TYPE o_kocurach IS RECORD(pseudonim VARCHAR2(15),
                            sex CHAR(1) NOT NULL:='M',
                            poluje_od DATE);
  o_kocurach_r o_kocurach;
END;

--putting most experiences cats data into index table
DECLARE
    TYPE rec_da IS RECORD (ps Kocury.pseudo%TYPE,da DATE);
    TYPE tab_da IS TABLE OF rec_da INDEX BY BINARY_INTEGER;
    tab_re tab_da;
    i BINARY_INTEGER; lb NUMBER; l NUMBER;
BEGIN
    SELECT MIN(nr_bandy),MAX(nr_bandy) INTO l,lb
    FROM Kocury;
    FOR i IN l..lb
    LOOP
     BEGIN
      SELECT pseudo,w_stadku_od INTO tab_re(i) FROM Kocury
      WHERE nr_bandy=i
            AND
            w_stadku_od=(SELECT MIN(w_stadku_od)
                         FROM Kocury
                         WHERE nr_bandy=i)
            AND ROWNUM=1;
      DBMS_OUTPUT.PUT('Banda '||i||' - najdluzej ');
      DBMS_OUTPUT.PUT(tab_re(i).ps||' od ');
      DBMS_OUTPUT.PUT_LINE(TO_CHAR(tab_re(i).da,'YYYY-MM-DD'));
     EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
     END;
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND
        THEN DBMS_OUTPUT.PUT_LINE('Brak kotow');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

--explicit cursor
DECLARE
    CURSOR ponadsr IS
    SELECT NVL(przydzial_myszy,0) pm, NVL(myszy_extra,0) me
    FROM Kocury
    WHERE NVL(przydzial_myszy,0)+NVL(myszy_extra,0)>=
          (SELECT AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))
           FROM Kocury);
    sp NUMBER(4):=0; se NUMBER(4):=0; pr ponadsr%ROWTYPE;
    sa_wiersze BOOLEAN:=FALSE;
BEGIN
    OPEN ponadsr;
    LOOP
     FETCH ponadsr INTO pr;
     EXIT WHEN ponadsr%NOTFOUND;
     IF NOT sa_wiersze THEN sa_wiersze:=TRUE; END IF;
     sp:=sp+pr.pm; se:=se+pr.me;
    END LOOP;
    CLOSE ponadsr;
    IF sa_wiersze
    THEN
     DBMS_OUTPUT.PUT('Miesiecznie spozycie: ');
     DBMS_OUTPUT.PUT(TO_CHAR(sp+se,999));
     DBMS_OUTPUT.PUT(' (w tym dodatki: ');
     DBMS_OUTPUT.PUT_LINE(TO_CHAR(se,999)||')');
    ELSE
     DBMS_OUTPUT.PUT_LINE('Brak kotow!!!');
    END IF;
END;

--updating table with explicit cursor
DECLARE
    CURSOR do_zm IS
    SELECT pseudo FROM Kocury
    WHERE (((przydzial_myszy,nr_bandy) IN
           (SELECT MIN(NVL(przydzial_myszy,0)),nr_bandy
            FROM Kocury
            GROUP BY nr_bandy)) AND funkcja<>'MILUSIA')
           OR pseudo='LOLA'
    FOR UPDATE OF nr_bandy;
    re do_zm%ROWTYPE; sa_wiersze BOOLEAN:=FALSE;
    brak_kota EXCEPTION;
BEGIN
    OPEN do_zm;
    LOOP
      FETCH do_zm INTO re;
      EXIT WHEN do_zm%NOTFOUND;
      IF NOT sa_wiersze THEN sa_wiersze:=TRUE;
      END IF;
      UPDATE Kocury
      SET nr_bandy=5
      WHERE CURRENT OF do_zm;
    END LOOP;
    CLOSE do_zm;
    IF NOT sa_wiersze
       THEN RAISE brak_kota;
    END IF;
    UPDATE Bandy
    SET nazwa='LOLERSI',
        szef_bandy='LOLA'
    WHERE nr_bandy=5;
    --COMMIT;
EXCEPTION
    WHEN brak_kota THEN DBMS_OUTPUT.PUT_LINE('Brak kota');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
SELECT * FROM Kocury NATURAL JOIN Bandy WHERE nr_bandy = 5;
ROLLBACK;

--unnamed explicit cursor in for statement
DECLARE
    sa_wiersze BOOLEAN:=FALSE;
    brak_kotow EXCEPTION;
BEGIN
    FOR re IN (SELECT pseudo,w_stadku_od,nr_bandy
               FROM Kocury
               WHERE (w_stadku_od,nr_bandy) IN
                           (SELECT MIN(w_stadku_od),nr_bandy
                            FROM Kocury
                            GROUP BY nr_bandy))
    LOOP
     sa_wiersze:=TRUE;
     DBMS_OUTPUT.PUT('Banda '||re.nr_bandy||' - najdluzej ');
     DBMS_OUTPUT.PUT(re.pseudo||' od ');
     DBMS_OUTPUT.PUT_LINE(TO_CHAR(re.w_stadku_od,'YYYY-MM-DD'));
    END LOOP;
    IF NOT sa_wiersze
       THEN RAISE brak_kotow;
    END IF;
EXCEPTION
    WHEN brak_kotow THEN DBMS_OUTPUT.PUT_LINE('Brak kotow');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

--ref cursor 
DECLARE
  TYPE typ_kursora IS REF CURSOR;
  kursor typ_kursora;
  ps Kocury.pseudo%TYPE;
  pm Kocury.przydzial_myszy%TYPE;
  me Kocury.myszy_extra%TYPE;
  iw Wrogowie.imie_wroga%TYPE;
  sw Wrogowie.stopien_wrogosci%TYPE;
  kod_relacji VARCHAR2(2):='&kod_relacji';
BEGIN
  IF kod_relacji='KO'
     THEN OPEN kursor FOR
          SELECT pseudo,przydzial_myszy,myszy_extra
          FROM Kocury 
          WHERE przydzial_myszy>50;
  ELSIF kod_relacji='WR'
        THEN OPEN kursor FOR
             SELECT imie_wroga,stopien_wrogosci
             FROM Wrogowie
             WHERE stopien_wrogosci>5;
  ELSE
   RAISE_APPLICATION_ERROR(-20103,'Brak obslugi tej relacji'); 
  END IF;
  LOOP
    IF kod_relacji='KO' THEN
       FETCH kursor INTO ps,pm,me;
       EXIT WHEN kursor%NOTFOUND;
    ELSE
       FETCH kursor INTO iw,sw;
       EXIT WHEN kursor%NOTFOUND;
    END IF;
  END LOOP;
  CLOSE kursor;
END;   
