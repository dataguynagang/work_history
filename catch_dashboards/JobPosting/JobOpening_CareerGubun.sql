-- 'CareerGubun.csv'로 저장

SELECT
    rv2cgc.RecruitID,
    rv2cgc.CareerGubunCode,
    CASE rv2cgc.CareerGubunCode
        WHEN 0 THEN '무관'
        WHEN 1 THEN '신입'
        WHEN 2 THEN '경력'
        WHEN 3 THEN '신입/경력'
    END AS CareerGubunName
FROM
    RecruitV2CareerGubunCode AS rv2cgc
JOIN
    RecruitV2 AS rv2 ON rv2.RecruitID = rv2cgc.RecruitID
WHERE
    rv2.RecruitStatusCode = 'S'
    AND rv2.ApplyStartDatetime <= GETDATE()
    AND GETDATE() <= rv2.ApplyEndDatetime
    AND rv2.CompID NOT IN ('A6562', 'A881C', 'AFF1F', 'AF774', 'EO2193', 'AC8DD', 'AE453');
