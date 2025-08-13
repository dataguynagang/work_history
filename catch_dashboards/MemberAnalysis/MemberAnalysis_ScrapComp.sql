-- =================================================================
-- FileName: MemberAnalysis_ScrapComp.sql
-- Description: 회원이 스크랩한 기업의 정보를 조회합니다.
-- =================================================================

SELECT DISTINCT
    madd.uid,
    -- 회원별 스크랩 순번
    ROW_NUMBER() OVER (PARTITION BY cs.MemID ORDER BY cs.ScrapID) AS idx,
    bc.CompID,
    bc.CompName,
    bsc.Name AS CompSize,
    bc.JinhakCode,
    bc.JinhakCodeName
FROM
    CommonScrap AS cs
    -- 회원 정보 조인
    JOIN Member AS mem ON cs.MemID = mem.MemID
    JOIN MemberAdd AS madd ON mem.MemID = madd.MemID
    -- 스크랩된 기업 정보 조인
    JOIN BaseCompany AS bc ON cs.Contents = bc.CompID
    -- 기업 규모 정보 조인
    LEFT JOIN BaseSizeCode AS bsc ON bc.기업규모 = bsc.Code
WHERE
    -- 기업 스크랩 정보만 필터링 (Gubun = '1')
    cs.Gubun = '1'
ORDER BY
    uid,
    idx;