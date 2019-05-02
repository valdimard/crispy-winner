SELECT * FROM yfirflokkur;


--ABC Greining
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
         AND h2.yfirflokkur in ('61', '62')
     GROUP BY h2.vorunumer
    HAVING max(h2.solumagn) > 0
ORDER BY sum(h2.solumagn) DESC) t,
    hreyfingar h, vorur v
    WHERE h.vorunumer = v.vorunumer
    AND h.vorunumer = t."Vorunumer"
    AND h.yfirflokkur in ('61', '62')
    GROUP BY t."Vorunumer", h.vorunumer, v.nafn, v.verd, v.upprunaland, t."Solumagn", v.millilitrar, v.eining, v.abc
ORDER BY t."Solumagn" DESC;

SELECT h.vorunumer, v.nafn, max(h.birgdir) as "Max birgdir", r.class, v.abc
FROM hreyfingar h, raudvin_allt r, vorur v
WHERE r.class = 'C'
      AND r.abc NOT IN ('3')
      AND r.vorunumer = h.vorunumer
      AND h.vorunumer = v.vorunumer
GROUP BY h.vorunumer, v.nafn, r.class, v.abc
ORDER BY max(h.birgdir) DESC

SELECT sum(h.birgdir) as "Birgdir", sum(h.solumagn) as "Solumagn", sum(h.aukning) as "Aukning", h.dagsetning
FROM hreyfingar h, raudvin_allt r
WHERE r.class = 'C'
    AND r.abc NOT IN ('3')
    AND h.vorunumer = r.vorunumer
GROUP BY h.dagsetning

SELECT h.vorunumer, v.nafn, sum(h.aukning) - sum(h.solumagn) AS "aukning-solumagn", max(h.birgdir) as "Max Birgdir", max(h.aukning) as "Max aukning", max(h.solumagn) as "Max solumagn"
FROM hreyfingar h, raudvin_allt r, vorur v
WHERE r.class = 'C'
    AND r.abc NOT IN ('3')
    AND h.vorunumer = r.vorunumer
    AND h.vorunumer = v.vorunumer
GROUP BY h.vorunumer, v.nafn
ORDER BY sum(h.aukning) - sum(h.solumagn) DESC

SELECT avg(h.birgdir) as "Avg birgdir", r.class, v.abc
FROM hreyfingar h, raudvin_allt r, vorur v
WHERE r.class = 'C'
    AND r.vorunumer = h.vorunumer
    AND h.vorunumer = v.vorunumer
GROUP BY r.class, v.abc
ORDER BY avg(h.birgdir) DESC

SELECT avg(h.birgdir) as "Avg birgdir", r.class, v.abc
FROM hreyfingar h, raudvin_allt r, vorur v
WHERE v.abc = '3'
    AND r.vorunumer = h.vorunumer
    AND h.vorunumer = v.vorunumer
GROUP BY r.class, v.abc
ORDER BY avg(h.birgdir) DESC
