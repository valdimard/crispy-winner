SELECT h.vorunumer, h.yfirflokkur, v.nafn, v.millilitrar, v.eining, sum(h.solumagn)
FROM hreyfingar h, vorur v
    WHERE h.vorunumer = v.vorunumer
    AND h.yfirflokkur in ('60', '61', '62')
GROUP BY h.vorunumer, h.yfirflokkur, v.nafn, v.millilitrar, v.eining
    HAVING max(h.solumagn) > 0
ORDER BY sum(h.solumagn) DESC;


SELECT h.vorunumer, v.nafn, v.millilitrar, v.eining, t."Solumagn" AS "Sala",
    sum(t."Solumagn") OVER (ORDER BY t."Solumagn" DESC) AS "Uppsöfnuð Sala",
    ROUND(sum(t."Solumagn") OVER (ORDER BY t."Solumagn" DESC) / sum(t."Solumagn") OVER () , 5)*100 AS "Uppsafnað hlutfall",
    /*sum(t."Solumagn") OVER () AS "Heildarsala",*/
    CASE
        WHEN (sum(t."Solumagn") OVER (ORDER BY t."Solumagn" DESC) / sum(t."Solumagn") OVER ())*100 <= 80
            THEN 'A'
        WHEN (sum(t."Solumagn") OVER (ORDER BY t."Solumagn" DESC) / sum(t."Solumagn") OVER ())*100 <= 95
            THEN 'B'
        ELSE 'C'
    END AS Class
FROM (SELECT h2.vorunumer as "Vorunumer", sum(h2.solumagn) as "Solumagn"
     FROM hreyfingar h2, vorur v2
     WHERE h2.vorunumer = v2.vorunumer
         AND h2.yfirflokkur in ('60', '61', '62')
     GROUP BY h2.vorunumer
    HAVING max(h2.solumagn) > 0
ORDER BY sum(h2.solumagn) DESC) t,
    hreyfingar h, vorur v
    WHERE h.vorunumer = v.vorunumer
    AND h.vorunumer = t."Vorunumer"
    AND h.yfirflokkur in ('60', '61', '62')
    GROUP BY t."Vorunumer", h.vorunumer, v.nafn, t."Solumagn", v.millilitrar, v.eining
ORDER BY t."Solumagn" DESC;

SELECT h2.vorunumer as "Vorunumer", sum(h2.solumagn) as "Solumagn"
     FROM hreyfingar h2, vorur v2
     WHERE h2.vorunumer = v2.vorunumer
         AND h2.yfirflokkur in ('60', '61', '62')
     GROUP BY h2.vorunumer
    HAVING max(h2.solumagn) > 0
ORDER BY sum(h2.solumagn) DESC

SELECT * FROM yfirflokkur;
