-- 'JobCode.csv'로 저장

SELECT
    rv2jc.RecruitID,
    rv2jc.RecruitJobCode,
    brjc.Depth1,
    brjc.Depth2
FROM
    RecruitV2JobCode AS rv2jc
JOIN
    RecruitV2 AS rv2 ON rv2jc.RecruitID = rv2.RecruitID
LEFT JOIN
    BaseRecruitJobCode AS brjc ON rv2jc.RecruitJobCode = brjc.Code
WHERE
    rv2.RecruitStatusCode = 'S'
    AND rv2.ApplyStartDatetime <= GETDATE()
    AND GETDATE() <= rv2.ApplyEndDatetime
    AND rv2.CompID NOT IN ('A6562', 'A881C', 'AFF1F', 'AF774', 'EO2193', 'AC8DD', 'AE453');
