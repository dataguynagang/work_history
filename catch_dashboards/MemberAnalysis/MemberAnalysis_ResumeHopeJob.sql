-- =================================================================
-- FileName: MemberAnalysis_ResumeHopeJob.sql
-- Description: 이력서에 등록된 희망 직무 정보를 조회합니다.
-- =================================================================

SELECT
    rhj.*,
    bjc.*
FROM
    ResumeHopeJob AS rhj
    -- 활성화된 이력서 정보만 필터링
    LEFT JOIN (
        SELECT
            r.*
        FROM
            dbo.ResumeBase AS r
            JOIN dbo.Member AS m ON r.MemID = m.MemID
            JOIN dbo.ResumeMajor AS rm ON rm.MemID = r.MemID AND rm.ResumeID = r.ResumeID
        WHERE
            r.MemDelYN = 'N'
            AND r.Confirm > 0
    ) AS resume ON rhj.ResumeID = resume.ResumeID
    -- 직무 코드 정보 조인
    LEFT JOIN (
        SELECT
            Code,
            Name,
            ROW_NUMBER() OVER (ORDER BY Code ASC) AS OrderNumber
        FROM
            BaseJinhakCodeV2
    ) AS bjc ON rhj.HopeJob = bjc.Code
WHERE
    resume.ResumeID IS NOT NULL;