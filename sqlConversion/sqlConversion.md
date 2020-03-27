# Converting the paper to larger datasets:

With `regex` searches it's useful to use a trigram index, supported by the [postgres extension pg_trgm](https://www.postgresql.org/docs/current/pgtrgm.html):

```sql
CREATE EXTENSION pg_trgm;
```

Once the extension is added to the server we can then use trigrams, which break up strings into sequences of three letters, providing faster matching and supporting `LIKE` and regex matching much faster:

```sql
CREATE INDEX idx_trgm ON sentences
USING GiST(words GiST_trgm_ops);
```
*`runtime: 4min 7sec`*

The current IRD corpus has 2,530,000 sentences from 3,900 papers.  We can identify 9,800 sentences that match either `IRD` or `(rafted).*(debris)` (*runtime: 22sec*).

```sql
SELECT COUNT(*) as cwds
  	FROM
  		sentences AS sent
  	WHERE  LOWER(sent.words) ~ '.*".ird",.*' OR
         LOWER(sent.words) ~ '(rafted).*(debris)'
```

Where is the paper abstract?  First figure out why we don't match in some papers:

```sql
WITH abstracthit AS (
  SELECT DISTINCT gddid as cwds
  FROM
    sentences AS sent
  WHERE
    LOWER(sent.words) ~ '.*abstract.*')
SELECT *
FROM
  publications AS pub
WHERE gddid NOT IN (SELECT * FROM abstracthit)
```

This returns 658 articles where the Abstract could not be found with a simple text search.

Since we'll likely be doing a similar task with the Introduction, References and other sections we can make this into a function:

```sql
CREATE OR REPLACE FUNCTION findpaperloc(_location CHARACTER VARYING)
RETURNS TABLE (
  journal TEXT,
  total BIGINT,
  missing BIGINT
)
LANGUAGE sql
AS $function$
  WITH abstracthit AS (
    SELECT DISTINCT gddid as cwds
    FROM
      sentences AS sent
    WHERE
      sent.words ~ _location),
  misscount AS (
  	SELECT pub."journal.name.name", COUNT(*)
  	FROM
  	  publications AS pub
  	WHERE gddid NOT IN (SELECT * FROM abstracthit)
  	GROUP BY pub."journal.name.name"),
  alljrnl AS (
  	SELECT pub."journal.name.name", COUNT(*)
  	FROM
    		publications AS pub
  	GROUP BY pub."journal.name.name")
  SELECT
  	alljrnl."journal.name.name",
  	alljrnl.count AS total,
  	misscount.count AS missing
  FROM
  alljrnl
  FULL JOIN misscount ON alljrnl."journal.name.name" = misscount."journal.name.name"
$function$
```

This lets us do things like $chi$^2 tests on the presence or absence of paper sections, or certain terms within journals, so that we can decide whether we need general solutions for matching, or more specific solutions.

For example:
```sql
SELECT * FROM findpaperloc(_location := 'Introduction')
```

Returns a total of 190 rows (our initial search for Ice Rafted Debris returned hits from 190 total journals).

Journal                                                     | Total | Missing |
------------------------------------------------------------|-------|---------|--
Proceedings of the IODP                                     | 28    | 14      |
Journal of Phycology                                        | 1     |         |
GSA Bulletin                                                | 2     | 2       |
International Ocean Discovery Program Scientific Prospectus | 2     | 1       |
Anthropocene                                                | 1     |         |
Interdisciplinary Science Reviews                           | 1     | 1       |
SEPM Journal of Sedimentary Research                        | 24    | 22      |
International Journal of Coal Geology                       | 1     | 1       |
Water-Resources Investigations Report                       | 21    |         |

Number of sentences in a paper, number of papers:
```sql
  WITH cts AS (
  	SELECT gddid, COUNT(words) as cwds
  	FROM
  		sentences AS sent
  	WHERE  sent.words ~ '.*IRD",.*' OR
         toLower(sent.words) ~ '(rafted).*(debris)'
  	GROUP BY gddid)
  SELECT cwds, COUNT(*) AS refs
  FROM cts
  GROUP BY cwds
  ORDER BY cwds
```
