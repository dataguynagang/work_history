-- 'RecruitV2.csv'로 저장

SELECT
    rv2.RecruitID,
    rv2.CompID,
    bc.CompName,
    bsc.Name AS CompSize,
    bc.JinhakCode,
    bc.JinhakCodeName,
    rv2.RecruitTitle,
    CASE
        WHEN rv2.RecruitID IN (SELECT RecruitID FROM RecruitV2Reward) THEN '합격축하금'
        ELSE '일반공고'
    END AS Reward,
    CASE rv2.EduLevelCode
        WHEN 0 THEN '학력무관'
        WHEN 3 THEN '고졸'
        WHEN 4 THEN '초대졸'
        WHEN 5 THEN '대졸'
        WHEN 6 THEN '석사'
        WHEN 7 THEN '박사'
        ELSE NULL
    END AS EduLevelGubun,
    rv2.RegDateTime,
    rv2.ApplyStartDatetime,
    rv2.ApplyEndDatetime,
    GETDATE() AS ExtractTime,
    rv2.ViewCnt,
    rv2.ApplyCnt + ISNULL(Application.ApplyCnt, 0) AS ApplyCnt,
    rv2.ShareCnt,
    rv2.ScrapCnt
FROM
    RecruitV2 AS rv2
LEFT JOIN
    BaseCompany AS bc ON rv2.CompID = bc.CompID
LEFT JOIN
    BaseSizeCode AS bsc ON bc.기업규모 = bsc.Code
LEFT JOIN
    (
        SELECT
            RecruitID,
            COUNT(*) AS ApplyCnt
        FROM
            Application
        GROUP BY
            RecruitID
    ) AS Application ON rv2.RecruitID = Application.RecruitID
WHERE
    rv2.RecruitStatusCode = 'S'
    AND rv2.ApplyStartDatetime <= GETDATE()
    AND GETDATE() <= rv2.ApplyEndDatetime
    AND rv2.CompID NOT IN ('A6562', 'A881C', 'AFF1F', 'AF774', 'EO2193', 'AC8DD', 'AE453');