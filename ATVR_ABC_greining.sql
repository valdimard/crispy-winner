--ABC Greining
--CREATE VIEW raudvin_allt AS
SELECT h.vorunumer, v.nafn, v.verd, v.upprunaland, v.millilitrar, v.eining, t."Solumagn" AS "Sala",
    sum(t."Solumagn") OVER (ORDER BY t."Solumagn" DESC) AS "Uppsöfnuð Sala",
    ROUND(sum(h.solumagn)/sum(t."Solumagn") OVER (), 5) AS "Hlutfall",
    ROUND(sum(t."Solumagn") OVER (ORDER BY t."Solumagn" DESC) / sum(t."Solumagn") OVER () , 5) AS "Uppsafnað hlutfall",
    /*sum(t."Solumagn") OVER () AS "Heildarsala",*/
    CASE
        WHEN (sum(t."Solumagn") OVER (ORDER BY t."Solumagn" DESC) / sum(t."Solumagn") OVER ())*100 <= 80
            THEN 'A'
        WHEN (sum(t."Solumagn") OVER (ORDER BY t."Solumagn" DESC) / sum(t."Solumagn") OVER ())*100 <= 95
            THEN 'B'
        ELSE 'C'
    END AS Class, v.abc
FROM (SELECT h2.vorunumer as "Vorunumer", sum(h2.solumagn) as "Solumagn"
     FROM hreyfingar h2, vorur v2
     WHERE h2.vorunumer = v2.vorunumer
         AND h2.yfirflokkur in ('23')
     GROUP BY h2.vorunumer
    HAVING max(h2.solumagn) > 0
ORDER BY sum(h2.solumagn) DESC) t,
    hreyfingar h, vorur v
    WHERE h.vorunumer = v.vorunumer
    AND h.vorunumer = t."Vorunumer"
    AND h.yfirflokkur in ('23')
    GROUP BY t."Vorunumer", h.vorunumer, v.nafn, v.verd, v.upprunaland, t."Solumagn", v.millilitrar, v.eining, v.abc
ORDER BY t."Solumagn" DESC;


--Sýna hvaða vörur eru vitlaust flokkaðar
--CREATE VIEW raudvin_vitlaust AS
SELECT *
FROM raudvin_allt r
WHERE (r.class = 'C' AND r.abc NOT IN ('3'))
      OR (r.class = 'B' AND r.abc NOT IN ('2'))
      OR (r.class = 'A' AND r.abc NOT IN ('1'));




--SKOÐA VÖRUR
SELECT * FROM raudvin_vitlaust

SELECT h.vorunumer, ROUND(avg(h.birgdir), 3) as "Birgdir", sum(h.solumagn) as "Solumagn", sum(h.aukning) as "Aukning", r.class, r.abc
FROM hreyfingar h, raudvin_allt r
WHERE r.class = 'C'
    AND r.abc NOT IN ('3')
    AND h.vorunumer = r.vorunumer
GROUP BY h.vorunumer, r.class, r.abc;


--SÆKJA HREYFINGAR
SELECT h.dagsetning, h.vorunumer, h.birgdir, h.solumagn, h.aukning, r.class, r.abc, v.afengisgjald, v.verd
FROM hreyfingar h, vorur v, raudvin_vitlaust r
  WHERE h.vorunumer = r.vorunumer
        AND h.vorunumer = v.vorunumer
        AND h.vorunumer in (/*'09851', '14429'*/'24242')

--Fyrir Excel
SELECT h.dagsetning, v.yfirflokkur, h.vorunumer, v.nafn, h.birgdir, h.solumagn, h.aukning
FROM hreyfingar h, vorur v
WHERE h.vorunumer = v.vorunumer
AND h.vorunumer = '14429'
