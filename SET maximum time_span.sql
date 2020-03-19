DROP TABLE IF EXISTS themaxes;

CREATE TABLE themaxes AS
(SELECT id_artefact, max(reliability_assignment) AS maxscore FROM tbl_artefacts_periods GROUP BY id_artefact);

DROP TABLE IF EXISTS max_reliability;

CREATE TABLE max_reliability AS 
(SELECT t.* FROM tbl_artefacts_periods t INNER JOIN themaxes m ON m.id_artefact = t.id_artefact AND m.maxscore = t.reliability_assignment);

DROP TABLE IF EXISTS span;

CREATE TABLE span (id_artefact, post_quem, ante_quem) AS (SELECT a.id_artefact, p.post_quem, p.ante_quem
FROM tbl_artefacts as a 
LEFT JOIN max_reliability AS mr ON (mr.id_artefact=a.id_artefact)
LEFT JOIN tbl_periods AS p ON (p.id_period=mr.id_period)
ORDER BY a.id_artefact, p.post_quem);

WITH max_span (id_artefact, post_quem, ante_quem) as 
(SELECT id_artefact, max(post_quem), min(ante_quem) FROM span
GROUP BY id_artefact
)

UPDATE tbl_artefacts AS a 
SET post_quem = max_span.post_quem
FROM max_span
WHERE a.id_artefact = max_span.id_artefact;

WITH max_span (id_artefact, post_quem, ante_quem) as 
(SELECT id_artefact, max(post_quem), min(ante_quem) FROM span
GROUP BY id_artefact
)

UPDATE tbl_artefacts AS a 
SET ante_quem = max_span.ante_quem
FROM max_span
WHERE a.id_artefact = max_span.id_artefact;

--DROP TABLE IF EXISTS span;