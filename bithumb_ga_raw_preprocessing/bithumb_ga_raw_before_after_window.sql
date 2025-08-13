CREATE OR REPLACE TABLE bitsum-ptk.datamart_ptk.mart_only_pv_2025_h1 AS
SELECT
  *,
  LAG(PAGE_TITLE) OVER (
    PARTITION BY
      SID
    ORDER BY
      EVENT_TS
  ) AS PREV_PAGE_TITLE,
  LEAD(PAGE_TITLE) OVER (
    PARTITION BY
      SID
    ORDER BY
      EVENT_TS
  ) AS NEXT_PAGE_TITLE
FROM
  `bitsum-ptk.datamart_ptk.mart_2025_h1`
WHERE
  EVENT_NAME IN ('page_view', 'screen_view');