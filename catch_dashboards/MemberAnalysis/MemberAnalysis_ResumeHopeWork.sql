-- =================================================================
-- FileName: MemberAnalysis_ResumeHopeWork.sql
-- Description: 이력서에 등록된 희망 근무 형태 정보를 조회합니다.
-- =================================================================

SELECT
    rhw.MemID,
    rhw.ResumeID,
    rhw.idx,
    rhw.HopeWork,
    rhw.RegDate,
    brjc.Depth1,
    brjc.Depth2,
    brjc.Depth3,
    brjc.Depth1Order,
    brjc.Depth2Order,
    brjc.Depth3Order
FROM
    ResumeHopeWork AS rhw
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
    ) AS resume ON rhw.ResumeID = resume.ResumeID
    -- 직무 코드 정보 조인 (Depth 별 정렬 순서 포함)
    LEFT JOIN (
        SELECT
            *,
            LEFT(Code, 2) AS Depth1Order,
            CASE
                WHEN DepthChk = 1 THEN NULL
                ELSE LEFT(Code, 4)
            END AS Depth2Order,
            CASE
                WHEN DepthChk <= 2 THEN NULL
                ELSE Code
            END AS Depth3Order
        FROM
            BaseRecruitJobCode
    ) AS brjc ON rhw.HopeWork = brjc.Code
WHERE
    resume.ResumeID IS NOT NULL;