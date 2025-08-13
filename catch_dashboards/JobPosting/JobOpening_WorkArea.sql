-- 'WorkArea.csv'로 저장

SELECT
    wa.*
FROM
    RecruitV2WorkArea AS wa
JOIN
    RecruitV2 AS rv2 ON wa.RecruitID = rv2.RecruitID
WHERE
    rv2.RecruitStatusCode = 'S'
    AND rv2.ApplyStartDatetime <= GETDATE()
    AND GETDATE() <= rv2.ApplyEndDatetime
    AND rv2.CompID NOT IN ('A6562', 'A881C', 'AFF1F', 'AF774', 'EO2193', 'AC8DD', 'AE453');