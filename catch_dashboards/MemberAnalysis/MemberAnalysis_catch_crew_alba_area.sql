-- =================================================================
-- FileName: MemberAnalysis_catch_crew_alba_area.sql
-- Description: 크루의 희망 근무 지역 정보를 조회합니다.
-- =================================================================

WITH
    -- CTE: location_code
    -- 설명: 지역 코드와 지역명(시/도, 시/군/구)을 정의합니다.
    location_code
    AS (
        SELECT '1' AS loc_code, '서울' AS loc_depth1, '강남구' AS loc_depth2
        UNION ALL
        SELECT '2', '서울', '강동구'
        UNION ALL
        SELECT '3', '서울', '강북구'
        UNION ALL
        SELECT '4', '서울', '강서구'
        UNION ALL
        SELECT '5', '서울', '관악구'
        UNION ALL
        SELECT '6', '서울', '광진구'
        UNION ALL
        SELECT '7', '서울', '구로구'
        UNION ALL
        SELECT '8', '서울', '금천구'
        UNION ALL
        SELECT '9', '서울', '노원구'
        UNION ALL
        SELECT '10', '서울', '도봉구'
        UNION ALL
        SELECT '11', '서울', '동대문구'
        UNION ALL
        SELECT '12', '서울', '동작구'
        UNION ALL
        SELECT '13', '서울', '마포구'
        UNION ALL
        SELECT '14', '서울', '서대문구'
        UNION ALL
        SELECT '15', '서울', '서초구'
        UNION ALL
        SELECT '16', '서울', '성동구'
        UNION ALL
        SELECT '17', '서울', '성북구'
        UNION ALL
        SELECT '18', '서울', '송파구'
        UNION ALL
        SELECT '19', '서울', '양천구'
        UNION ALL
        SELECT '20', '서울', '영등포구'
        UNION ALL
        SELECT '21', '서울', '용산구'
        UNION ALL
        SELECT '22', '서울', '은평구'
        UNION ALL
        SELECT '23', '서울', '종로구'
        UNION ALL
        SELECT '24', '서울', '중구'
        UNION ALL
        SELECT '25', '서울', '중랑구'
        UNION ALL
        SELECT '26', '경기', '가평군'
        UNION ALL
        SELECT '27', '경기', '고양시'
        UNION ALL
        SELECT '28', '경기', '과천시'
        UNION ALL
        SELECT '29', '경기', '광명시'
        UNION ALL
        SELECT '30', '경기', '광주시'
        UNION ALL
        SELECT '31', '경기', '구리시'
        UNION ALL
        SELECT '32', '경기', '군포시'
        UNION ALL
        SELECT '33', '경기', '김포시'
        UNION ALL
        SELECT '34', '경기', '남양주시'
        UNION ALL
        SELECT '35', '경기', '동두천시'
        UNION ALL
        SELECT '36', '경기', '부천시'
        UNION ALL
        SELECT '37', '경기', '성남시'
        UNION ALL
        SELECT '38', '경기', '수원시'
        UNION ALL
        SELECT '39', '경기', '시흥시'
        UNION ALL
        SELECT '40', '경기', '안산시'
        UNION ALL
        SELECT '41', '경기', '안성시'
        UNION ALL
        SELECT '42', '경기', '안양시'
        UNION ALL
        SELECT '43', '경기', '양주시'
        UNION ALL
        SELECT '44', '경기', '양평군'
        UNION ALL
        SELECT '45', '경기', '여주시'
        UNION ALL
        SELECT '46', '경기', '연천군'
        UNION ALL
        SELECT '47', '경기', '오산시'
        UNION ALL
        SELECT '48', '경기', '용인시'
        UNION ALL
        SELECT '49', '경기', '의왕시'
        UNION ALL
        SELECT '50', '경기', '의정부시'
        UNION ALL
        SELECT '51', '경기', '이천시'
        UNION ALL
        SELECT '52', '경기', '파주시'
        UNION ALL
        SELECT '53', '경기', '평택시'
        UNION ALL
        SELECT '54', '경기', '포천시'
        UNION ALL
        SELECT '55', '경기', '하남시'
        UNION ALL
        SELECT '56', '경기', '화성시'
    ),
    -- CTE: alba_area_codes
    -- 설명: catch_crew_resume 테이블에서 JSONB 형식의 희망 근무 지역 코드를 개별 행으로 추출합니다.
    alba_area_codes
    AS (
        SELECT
            mem_id,
            each_area ->> 0 AS alba_area_codes
        FROM
            catch_crew_resume AS ccr
            CROSS JOIN jsonb_array_elements(alba_area_codes) AS each_area
    )
-- 최종 쿼리: 회원 ID별 희망 근무 지역의 코드와 상세 지역명을 조인하여 조회합니다.
SELECT
    aac.mem_id,
    lc.*
FROM
    alba_area_codes AS aac
    LEFT JOIN location_code AS lc ON aac.alba_area_codes = lc.loc_code;