-- =================================================================
-- FileName: MemberAnalysis_MemberZip.sql
-- Description: 회원의 우편번호를 기반으로 주소 정보(시/도, 시/군/구, 동)를 조회합니다.
-- =================================================================

SELECT
    mem.MemID,
    juso.Zip,
    MAX(juso.SidoName) AS SiDo,
    MAX(juso.SiGunGuName) AS SiGunGu,
    MAX(juso.DongName) AS Dong
FROM
    Member AS mem
    JOIN Juso_SiGuDong_1709 AS juso ON mem.Zip = juso.Zip
GROUP BY
    mem.MemID,
    juso.Zip;