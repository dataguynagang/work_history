-- =================================================================
-- FileName: MemberAnalysis_catch_crew_catch_crew_resume.sql
-- Description: 캐치크루 이력서 정보를 조회합니다.
-- =================================================================

SELECT
    ccr.mem_id,
    -- 근무 가능 상태 코드 변환
    CASE
        WHEN workable_status_code = '1' THEN '가능'
        WHEN workable_status_code = '2' THEN '향후가능'
        WHEN workable_status_code = '3' THEN '불가능'
        ELSE NULL
    END AS workable_status,
    -- 서류 검증 상태 코드 변환
    CASE
        WHEN document_status_code = 'U' THEN '검증필요'
        WHEN document_status_code = 'N' THEN '검증 불필요'
        WHEN document_status_code = 'C' THEN '검증완료'
        ELSE NULL
    END AS document_status,
    ccr.is_certification,
    ccr.certification_time,
    ccr.is_training_complete,
    ccr.training_time,
    ccr.is_telecommuting,
    ccr.register_time,
    ccr.update_time,
    -- 알바 경력 유무
    CASE
        WHEN alba_career_count.mem_id IS NULL THEN FALSE
        ELSE TRUE
    END AS is_alba_career,
    -- 알바 경력 수
    alba_career_count.career_count AS alba_career_count
FROM
    catch_crew_resume AS ccr
    LEFT JOIN (
        -- 회원의 알바 경력 수를 계산
        SELECT
            mem_id,
            COUNT(*) AS career_count
        FROM
            alba_career ac
        GROUP BY
            mem_id
    ) AS alba_career_count
    ON ccr.mem_id = alba_career_count.mem_id;