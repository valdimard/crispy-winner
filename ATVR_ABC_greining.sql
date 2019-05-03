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
         AND h2.yfirflokkur in ('01')
     GROUP BY h2.vorunumer
    HAVING max(h2.solumagn) > 0
ORDER BY sum(h2.solumagn) DESC) t,
    hreyfingar h, vorur v
    WHERE h.vorunumer = v.vorunumer
    AND h.vorunumer = t."Vorunumer"
    AND h.yfirflokkur in ('01')
    GROUP BY t."Vorunumer", h.vorunumer, v.nafn, v.verd, v.upprunaland, t."Solumagn", v.millilitrar, v.eining, v.abc
ORDER BY t."Solumagn" DESC;


--Sýna hvaða vörur eru vitlaust flokkaðar
--CREATE VIEW raudvin_vitlaust AS
SELECT *
FROM raudvin_allt r
WHERE (r.class = 'C' AND r.abc NOT IN ('3'))
      OR (r.class = 'B' AND r.abc NOT IN ('2'))
      OR (r.class = 'A' AND r.abc NOT IN ('1'));


--Raða vörum upp eftir veltuhraða
--CREATE VIEW raudvin_veltuhradi AS
SELECT r.vorunumer, r.nafn, r."Sala" AS "Heildarsala", round(avg(h.birgdir), 0) AS "Meðalbirgðir", round((r."Sala"/avg(h.birgdir)), 6) AS "Veltuhraði", r.class, r.abc
FROM raudvin_vitlaust r, hreyfingar h
WHERE r.vorunumer = h.vorunumer
GROUP BY r.vorunumer, r.nafn, r."Sala", r.class, r.abc
ORDER BY "Veltuhraði" ASC;

--Vörur sem eru að velta of hægt
--CREATE VIEW raudvin_haegur_veltuhradi AS
SELECT r.vorunumer, r.nafn, r."Heildarsala", r."Meðalbirgðir", r."Veltuhraði", r.class, r.abc
FROM raudvin_veltuhradi r, hreyfingar h
WHERE r.vorunumer = h.vorunumer
    AND r."Veltuhraði" < 2
    AND r.class = 'C'
GROUP BY r.vorunumer, r.nafn, r."Heildarsala", r."Meðalbirgðir", r."Veltuhraði", r.class, r.abc
ORDER BY "Veltuhraði" ASC;


--Hámarks sala vitlausra vara með lágan veltuhraða
--Meðalbirgðir/Hamarks solumagn
--CREATE VIEW hamarkssolumagn_medalbirgdir AS
SELECT v.vorunumer, v.nafn, max(h.solumagn) AS "Hámarks Sölumagn", round(avg(h.birgdir), 6) AS "Meðalbirgðir", round(avg(h.birgdir)/max(h.solumagn), 6) AS "Birgdir/Hámarks Sölumagn", r.class, v.abc
FROM vorur v, hreyfingar h, raudvin_allt r
WHERE v.vorunumer = r.vorunumer
    AND v.vorunumer = h.vorunumer
    AND h.solumagn IS NOT NULL
GROUP BY v.vorunumer, v.nafn, r.class, v.abc
ORDER BY v.abc DESC;

SELECT avg(h."Birgdir/Max Solumagn")
FROM hamarkssolumagn_medalbirgdir h
WHERE h.abc = '3';

SELECT *
FROM hamarkssolumagn_medalbirgdir
WHERE "Birgdir/Max Solumagn" > 8
AND abc = '3'
ORDER BY "Birgdir/Max Solumagn" DESC;


SELECT h.vorunumer, h.nafn, h."Hámarks Sölumagn", h."Meðalbirgðir", CEIL(r."Heildarsala"/2.0) AS "Ideal Birgðir", h."Birgdir/Hámarks Sölumagn", r."Veltuhraði", round(r."Heildarsala"/(CEIL(r."Heildarsala"/2.0)), 6) AS "Ideal Veltuhraði", h."Meðalbirgðir"-CEIL(r."Heildarsala"/2.0) AS "Mismunur ideal og raun"
FROM hamarkssolumagn_medalbirgdir h, raudvin_haegur_veltuhradi r
WHERE h.vorunumer = r.vorunumer
ORDER BY h."Birgdir/Hámarks Sölumagn" DESC

SELECT * FROM raudvin_haegur_veltuhradi


--Heildarsala og heildarbirgðir fyrir alla daga
--CREATE VIEW dagsetning_solumagn_birgdir AS
SELECT h.dagsetning, sum(h.solumagn) AS "Sölumagn", sum(h.birgdir) AS "Birgðir"
FROM hreyfingar h, raudvin_vitlaust r
    WHERE h.vorunumer = r.vorunumer
GROUP BY h.dagsetning

--Veltuhraði vara sem eru vitlaust flokkaðar
SELECT sum(dsb."Sölumagn") AS "Heildarsala", avg(dsb."Birgðir") AS "Meðalbirgðir", sum(dsb."Sölumagn")/avg(dsb."Birgðir") AS "Veltuhraði"
FROM dagsetning_solumagn_birgdir dsb

SELECT * FROM raudvin_vitlaust









SELECT h.dagsetning, sum(h.birgdir) as "Birgdir", sum(h.solumagn) as "Solumagn", sum(h.aukning) as "Aukning"
FROM hreyfingar h, raudvin_allt r
WHERE r.class = 'C'
    AND r.abc NOT IN ('3')
    AND h.vorunumer = r.vorunumer
GROUP BY h.dagsetning;

SELECT h.vorunumer, v.nafn, sum(h.aukning) - sum(h.solumagn) AS "aukning-solumagn", max(h.birgdir) as "Max Birgdir", max(h.aukning) as "Max aukning", max(h.solumagn) as "Max solumagn"
FROM hreyfingar h, raudvin_allt r, vorur v
WHERE r.class = 'C'
    AND r.abc NOT IN ('3')
    AND h.vorunumer = r.vorunumer
    AND h.vorunumer = v.vorunumer
GROUP BY h.vorunumer, v.nafn
ORDER BY sum(h.aukning) - sum(h.solumagn) DESC;

SELECT avg(h.birgdir) as "Avg birgdir", r.class, v.abc
FROM hreyfingar h, raudvin_allt r, vorur v
WHERE r.class = 'C'
    AND r.vorunumer = h.vorunumer
    AND h.vorunumer = v.vorunumer
GROUP BY r.class, v.abc
ORDER BY avg(h.birgdir) DESC;

