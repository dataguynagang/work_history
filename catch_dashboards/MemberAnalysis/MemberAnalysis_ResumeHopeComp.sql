-- =================================================================
-- FileName: MemberAnalysis_ResumeHopeComp.sql
-- Description: 이력서에 등록된 희망 기업 정보를 조회합니다.
-- =================================================================

SELECT DISTINCT
    rhc.ResumeID,
    rhc.idx,
    rhc.CompID,
    bc.CompName,
    bsc.Name AS CompSize,
    bc.JinhakCode,
    bc.JinhakCodeName
FROM
    ResumeHopeComp AS rhc
    -- 활성화된 이력서 정보만 필터링
    JOIN (
        SELECT
            r.*
        FROM
            dbo.ResumeBase AS r
            JOIN dbo.Member AS m ON r.MemID = m.MemID
            JOIN dbo.ResumeMajor AS rm ON rm.MemID = r.MemID AND rm.ResumeID = r.ResumeID
        WHERE
            r.MemDelYN = 'N'
            AND r.Confirm > 0
    ) AS resume ON rhc.ResumeID = resume.ResumeID
    -- 기업 정보 조인
    JOIN BaseCompany AS bc ON rhc.CompID = bc.CompID
    -- 기업 규모 정보 조인
    LEFT JOIN BaseSizeCode AS bsc ON bc.기업규모 = bsc.Code;