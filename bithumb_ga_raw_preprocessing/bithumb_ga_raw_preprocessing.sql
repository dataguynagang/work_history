-- =====================================================================
-- 변수 선언
-- =====================================================================
DECLARE start_date DATE DEFAULT DATE '2025-01-01';
DECLARE end_date DATE DEFAULT DATE '2025-06-30';

-- =====================================================================
-- 최종 테이블 생성
-- =====================================================================
CREATE OR REPLACE TABLE bitsum-ptk.datamart_ptk.mart_2025_h1 AS

WITH
  -- =====================================================================
  -- CTE 1: raw_logs_utm의 sid 중복값 처리
  -- - ts 기준으로 정렬 후 순위 컬럼(rn_order_by_ts) 생성
  -- - UTM 값이 없는 로우는 제외
  -- =====================================================================
  tbl_rn_for_unique AS (
    SELECT
      SID,
      CASE
        WHEN UTM_SOURCE IS NULL
        THEN 'null_value'
        ELSE UTM_SOURCE
      END AS UTM_SOURCE,
      CASE
        WHEN UTM_MEDIUM IS NULL
        THEN 'null_value'
        ELSE UTM_MEDIUM
      END AS UTM_MEDIUM,
      CASE
        WHEN UTM_CAMPAIGN IS NULL
        THEN 'null_value'
        ELSE UTM_CAMPAIGN
      END AS UTM_CAMPAIGN,
      CASE
        WHEN UTM_CONTENT IS NULL
        THEN 'null_value'
        ELSE UTM_CONTENT
      END AS UTM_CONTENT,
      CASE
        WHEN UTM_TERM IS NULL
        THEN 'null_value'
        ELSE UTM_TERM
      END AS UTM_TERM,
      COUNT(*) OVER (PARTITION BY SID) AS sid_cnt,
      ROW_NUMBER() OVER (
        PARTITION BY
          SID
        ORDER BY
          START_TS ASC
      ) AS rn_order_by_ts
    FROM
      `bithumb-ga-309905.analytics_preprocessed.raw_logs_utm`
    WHERE
      (
        EVENT_DT BETWEEN start_date AND end_date
      ) -- 날짜조건
      AND (
        UTM_SOURCE IS NOT NULL
        AND UTM_SOURCE <> '(not set)'
      )
      AND (
        UTM_MEDIUM IS NOT NULL
        AND UTM_MEDIUM <> '(not set)'
      )
      AND SID IS NOT NULL
  ),
  -- =====================================================================
  -- CTE 2: rn_order_by_ts가 1인 값만 선택 (고유 SID)
  -- =====================================================================
  utm_sid_unique AS (
    SELECT
      *
    FROM
      tbl_rn_for_unique
    WHERE
      rn_order_by_ts = 1
  ),
  -- =====================================================================
  -- CTE 3: UTM 메타 정보에서 DIV_CHANNEL 정보 추출
  -- =====================================================================
  utm_meta_null_value AS (
    SELECT
      DISTINCT CASE
        WHEN UTM_SOURCE IS NULL
        THEN 'null_value'
        ELSE UTM_SOURCE
      END AS UTM_SOURCE,
      CASE
        WHEN UTM_MEDIUM IS NULL
        THEN 'null_value'
        ELSE UTM_MEDIUM
      END AS UTM_MEDIUM,
      CASE
        WHEN UTM_CAMPAIGN IS NULL
        THEN 'null_value'
        ELSE UTM_CAMPAIGN
      END AS UTM_CAMPAIGN,
      CASE
        WHEN UTM_CONTENT IS NULL
        THEN 'null_value'
        ELSE UTM_CONTENT
      END AS UTM_CONTENT,
      CASE
        WHEN UTM_TERM IS NULL
        THEN 'null_value'
        ELSE UTM_TERM
      END AS UTM_TERM,
      DIV_CHANNEL
    FROM
      bithumb-ga-309905.da_mart.dm_ga_logs_utm_meta
  ),
  -- =====================================================================
  -- CTE 4: 고유 SID 테이블에 DIV_CHANNEL 정보 조인
  -- =====================================================================
  utm_sid_unique_joined AS (
    SELECT
      t.*,
      m.DIV_CHANNEL
    FROM
      utm_sid_unique t
      LEFT JOIN utm_meta_null_value m ON (
        t.UTM_SOURCE = m.UTM_SOURCE
        AND t.UTM_MEDIUM = m.UTM_MEDIUM
        AND t.UTM_CAMPAIGN = m.UTM_CAMPAIGN
        AND t.UTM_CONTENT = m.UTM_CONTENT
        AND t.UTM_TERM = m.UTM_TERM
      )
  ),
  -- =====================================================================
  -- CTE 5: UID별 가입일 정보 추출
  -- - 가입일로부터 1개월 안에 주문값을 불러오는 용도라 시작일로부터 1개월 전까지 가입일인 사람만 포함
  -- =====================================================================
  user_join AS (
    SELECT
      UID,
      MAX(EVENT_DT) AS join_dt,
      MAX(EVENT_TS) AS join_ts
    FROM
      `bithumb-ga-309905.analytics_preprocessed.raw_logs_event_v2`
    WHERE
      PAGE_TITLE LIKE '%가입완료%'
      AND EVENT_DT > DATE_SUB(start_date, INTERVAL 1 MONTH)
    GROUP BY
      UID
  ),
  -- =====================================================================
  -- CTE 6: 주문 완료 이벤트의 주문 금액과 가입일 정보 조인
  -- =====================================================================
  user_order_amount AS (
    SELECT
      logs.UID,
      user_join.join_dt,
      user_join.join_ts,
      logs.EVENT_NAME,
      logs.EVENT_DT,
      logs.EVENT_TS,
      logs.EP_AREA,
      (
        SELECT
          int_value
        FROM
          UNNEST(EVENT_PARAMS)
        WHERE
          key = 'cm_order_amount'
      ) AS cm_order_amount
    FROM
      `bithumb-ga-309905.analytics_preprocessed.raw_logs_event_v2` AS logs
      LEFT JOIN user_join ON logs.UID = user_join.UID
    WHERE
      (
        EVENT_DT BETWEEN start_date AND end_date
      ) -- 날짜조건
      AND (
        EVENT_NAME = 'click_order'
        AND EP_AREA LIKE '%_step_complete'
      ) -- 주문완료조건
  ),
  -- =====================================================================
  -- CTE 7: UID별 가입 이후 1개월 이내 주문금액 합산 (진성고객 분석용)
  -- =====================================================================
  order_within_1month AS (
    SELECT
      UID,
      MAX(join_dt) AS join_dt,
      MAX(join_ts) AS join_ts,
      -- 가입일 이후 1개월 이내 주문 합계값
      SUM(
        CASE
          WHEN DATE_SUB(EVENT_DT, INTERVAL 1 MONTH) < join_dt
          THEN cm_order_amount
        END
      ) AS order_amount_within_1month_after_join
    FROM
      user_order_amount
    GROUP BY
      UID
  ),
  -- =====================================================================
  -- CTE 8: SID별 주문 건수 계산
  -- =====================================================================
  session_order AS (
    SELECT
      SID,
      COUNT(*) AS session_order
    FROM
      `bithumb-ga-309905.analytics_preprocessed.raw_logs_event_v2`
    WHERE
      (
        EVENT_DT BETWEEN start_date AND end_date
      ) -- 날짜조건
      AND (
        EVENT_NAME = 'click_order'
        AND EP_AREA LIKE '%_step_complete'
      ) -- 주문완료조건
    GROUP BY
      SID
  )
-- =====================================================================
-- 최종 SELECT
-- =====================================================================
SELECT
  logs.EVENT_DT,
  logs.EVENT_TS,
  logs.UID,
  logs.CID,
  logs.SID,
  logs.EVENT_NAME,
  logs.PAGE_TITLE,
  (
    SELECT
      string_value
    FROM
      UNNEST(EVENT_PARAMS)
    WHERE
      key = 'ep_page_1depth'
  ) AS ep_page_1depth,
  (
    SELECT
      string_value
    FROM
      UNNEST(EVENT_PARAMS)
    WHERE
      key = 'ep_page_2depth'
  ) AS ep_page_2depth,
  (
    SELECT
      string_value
    FROM
      UNNEST(EVENT_PARAMS)
    WHERE
      key = 'ep_page_3depth'
  ) AS ep_page_3depth,
  (
    SELECT
      string_value
    FROM
      UNNEST(EVENT_PARAMS)
    WHERE
      key = 'ep_page_4depth'
  ) AS ep_page_4depth,
  (
    SELECT
      string_value
    FROM
      UNNEST(EVENT_PARAMS)
    WHERE
      key = 'ep_tab'
  ) AS ep_tab,
  (
    SELECT
      string_value
    FROM
      UNNEST(EVENT_PARAMS)
    WHERE
      key = 'ep_cat'
  ) AS ep_cat,
  (
    SELECT
      string_value
    FROM
      UNNEST(EVENT_PARAMS)
    WHERE
      key = 'ep_symbol'
  ) AS ep_symbol,
  (
    SELECT
      string_value
    FROM
      UNNEST(EVENT_PARAMS)
    WHERE
      key = 'ep_button_detail'
  ) AS ep_button_detail,
  EP_CHANNEL,
  EP_PAGE,
  EP_AREA,
  EP_LABEL,
  (
    SELECT
      string_value
    FROM
      UNNEST(EVENT_PARAMS)
    WHERE
      key = 'order_coin_symbol'
  ) AS order_coin_symbol,
  (
    SELECT
      string_value
    FROM
      UNNEST(EVENT_PARAMS)
    WHERE
      key = 'order_buy_sell_type'
  ) AS order_buy_sell_type,
  utm.UTM_SOURCE,
  utm.UTM_MEDIUM,
  utm.UTM_CAMPAIGN,
  utm.UTM_CONTENT,
  utm.UTM_TERM,
  utm.DIV_CHANNEL,
  ow1.join_dt,
  ow1.order_amount_within_1month_after_join,
  -- 진성고객 조건: 가입 후 1개월 이내 주문금액 1000만원 이상이면 TRUE
  CASE
    WHEN ow1.order_amount_within_1month_after_join >= 10000000
    THEN TRUE
    ELSE FALSE
  END AS royal_after_join,
  so.session_order,
  -- 세션 내 주문여부
  CASE
    WHEN so.session_order >= 1
    THEN TRUE
    ELSE FALSE
  END AS order_yn_in_session
FROM
  `bithumb-ga-309905.analytics_preprocessed.raw_logs_event_v2` AS logs
  LEFT JOIN utm_sid_unique_joined AS utm ON logs.SID = utm.SID
  LEFT JOIN order_within_1month AS ow1 ON logs.UID = ow1.UID
  LEFT JOIN session_order AS so ON logs.SID = so.SID
WHERE
  (
    logs.EVENT_DT BETWEEN start_date AND end_date
  ) -- 날짜조건
  AND (
    EVENT_NAME IN (
      'click_order',
      'appsflyer_open',
      'page_view',
      'popup_view',
      'click_event',
      'screen_view'
    )
  ) -- 해당 이벤트만