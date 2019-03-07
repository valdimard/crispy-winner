SELECT h.vorunumer, h.yfirflokkur, v.nafn, v.millilitrar, v.eining, sum(h.solumagn)
FROM hreyfingar h, vorur v
    WHERE h.vorunumer = v.vorunumer
    AND h.yfirflokkur in ('60', '61', '62')
GROUP BY h.vorunumer, h.yfirflokkur, v.nafn, v.millilitrar, v.eining
    HAVING max(h.solumagn) > 0
ORDER BY sum(h.solumagn) DESC;

SELECT sum(solumagn)
FROM hreyfingar
WHERE yfirflokkur in ('60', '61', '62');

SELECT * FROM yfirflokkur
WHERE tegund = 'Rauðvín';
SELECT * FROM yfirflokkur
WHERE tegund = 'Hvítvín';

SELECT * FROM alagning
where afengisgjald = '1'





