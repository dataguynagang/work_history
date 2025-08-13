-- 'ApplyGubun.csv'로 저장

SELECT
    rv2.RecruitID,
    rv2.ApplyGubunCodes,
    value AS ApplyGubunCode,
    CASE value
        WHEN '0' THEN '즉시지원'
        WHEN '1' THEN '홈페이지'
        WHEN '2' THEN '이메일'
        WHEN '3' THEN '방문/우편'
    END AS ApplyGubunName
FROM
    RecruitV2 AS rv2
CROSS APPLY
    string_split(rv2.ApplyGubunCodes, ',')
WHERE
    rv2.RecruitStatusCode = 'S'
    AND rv2.ApplyStartDatetime <= GETDATE()
    AND GETDATE() <= rv2.ApplyEndDatetime
    AND rv2.CompID NOT IN ('A6562', 'A881C', 'AFF1F', 'AF774', 'EO2193', 'AC8DD', 'AE453');