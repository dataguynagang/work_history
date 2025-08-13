-- 'RecruitGubun.csv'로 저장

SELECT
    rv2gc.*,
    CASE rv2gc.RecruitGubunCode
        WHEN 1 THEN '정규직'
        WHEN 2 THEN '계약직'
        WHEN 4 THEN '인턴'
        WHEN 5 THEN '위촉직'
    END AS RecruitGubunName
FROM
    RecruitV2GubunCode AS rv2gc
JOIN
    RecruitV2 AS rv2 ON rv2.RecruitID = rv2gc.RecruitID
WHERE
    rv2.RecruitStatusCode = 'S'
    AND rv2.ApplyStartDatetime <= GETDATE()
    AND GETDATE() <= rv2.ApplyEndDatetime
    AND rv2.CompID NOT IN ('A6562', 'A881C', 'AFF1F', 'AF774', 'EO2193', 'AC8DD', 'AE453');
