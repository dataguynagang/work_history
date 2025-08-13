-- =================================================================
-- FileName: MemberAnalysis_catch_crew_alba_hope_position.sql
-- Description: 크루의 희망 직무 정보를 조회합니다.
-- =================================================================

-- CTE: hope_position_codes
-- 설명: 희망 직무 코드와 직무명(대분류, 중분류)을 정의합니다.
WITH hope_position_codes AS (
    SELECT 'U1' AS hope_position_code, '독서실·스터디카페' AS hope_position_depth1, '전체' AS hope_position_depth2 UNION ALL
    SELECT 'U2', '카페', '전체' UNION ALL
    SELECT 'U3', '학원', '전체' UNION ALL
    SELECT 'U4', '편의점', '전체' UNION ALL
    SELECT 'U5', '베이커리', '전체' UNION ALL
    SELECT 'U6', '영화관·전시·공연장', '전체' UNION ALL
    SELECT 'U7', '매장관리·판매', '전체' UNION ALL
    SELECT 'U8', '사무직', '전체' UNION ALL
    SELECT 'U99', '그 외', '전체' UNION ALL
    SELECT '1', '독서실·스터디카페', '독서실' UNION ALL
    SELECT '2', '독서실·스터디카페', '스터디카페' UNION ALL
    SELECT '3', '카페', '커피·음료 전문점' UNION ALL
    SELECT '4', '카페', '아이스크림 전문점' UNION ALL
    SELECT '5', '카페', '디저트 카페' UNION ALL
    SELECT '6', '학원', '입시·보습학원' UNION ALL
    SELECT '7', '학원', '외국어학원' UNION ALL
    SELECT '8', '학원', '컴퓨터학원' UNION ALL
    SELECT '9', '학원', '기타 학원' UNION ALL
    SELECT '10', '편의점', '편의점' UNION ALL
    SELECT '11', '베이커리', '빵집' UNION ALL
    SELECT '12', '베이커리', '도넛' UNION ALL
    SELECT '13', '베이커리', '떡집' UNION ALL
    SELECT '14', '베이커리', '기타 디저트' UNION ALL
    SELECT '15', '영화관·전시·공연장', '영화관' UNION ALL
    SELECT '16', '영화관·전시·공연장', '전시장' UNION ALL
    SELECT '17', '영화관·전시·공연장', '공연장' UNION ALL
    SELECT '18', '매장관리·판매', '마트' UNION ALL
    SELECT '19', '매장관리·판매', '백화점·면세점·쇼핑몰' UNION ALL
    SELECT '20', '매장관리·판매', '서점·문구' UNION ALL
    SELECT '21', '매장관리·판매', '의류·잡화' UNION ALL
    SELECT '22', '매장관리·판매', '뷰티·헬스' UNION ALL
    SELECT '23', '매장관리·판매', '휴대폰·전자기기' UNION ALL
    SELECT '24', '매장관리·판매', '약국' UNION ALL
    SELECT '25', '매장관리·판매', '유통·판매 기타' UNION ALL
    SELECT '26', '사무직', '경영·사무' UNION ALL
    SELECT '27', '사무직', '마케팅·광고' UNION ALL
    SELECT '28', '사무직', '기술·개발' UNION ALL
    SELECT '29', '사무직', '디자인' UNION ALL
    SELECT '30', '사무직', '미디어' UNION ALL
    SELECT '31', '사무직', '사무직 기타' UNION ALL
    SELECT '32', '그 외', '외식업' UNION ALL
    SELECT '33', '그 외', '놀이공원·테마파크·스키장' UNION ALL
    SELECT '34', '그 외', '호텔·리조트·예식장' UNION ALL
    SELECT '35', '그 외', '주차요원' UNION ALL
    SELECT '36', '그 외', '배달대행' UNION ALL
    SELECT '37', '그 외', '물류센터' UNION ALL
    SELECT '38', '그 외', '병원' UNION ALL
    SELECT '39', '그 외', '생산·공장·노무' UNION ALL
    SELECT '40', '그 외', '고객상담·리서치·영업' UNION ALL
    SELECT '41', '그 외', '그외 기타'
)
-- 최종 쿼리: 회원별 희망 직무 코드와 상세 직무명을 조인하여 조회합니다.
-- 참고: 'hope_position'은 사전에 정의된 테이블 또는 CTE로 가정합니다.
SELECT
    hp.mem_id,
    hpc.*
FROM
    hope_position AS hp
    LEFT JOIN hope_position_codes AS hpc ON hp.position_code = hpc.hope_position_code;