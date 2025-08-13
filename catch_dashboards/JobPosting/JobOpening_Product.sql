-- 'Product.csv'로 저장

SELECT
    gong.RecruitID,
    gong.ProductID,
    pco.Gubun,
    gong.Type
FROM
    RecruitV2Gong AS gong
JOIN
    RecruitV2 AS rv2 ON gong.RecruitID = rv2.RecruitID
LEFT JOIN
    PayCompOrderList AS pcol ON gong.OrderListID = pcol.OrderListID
LEFT JOIN
    PayCompOrders AS pco ON pcol.OrderID = pco.OrderID
WHERE
    rv2.RecruitStatusCode = 'S'
    AND rv2.ApplyStartDatetime <= GETDATE()
    AND GETDATE() <= rv2.ApplyEndDatetime
    AND gong.IsActive = 1
    AND rv2.CompID NOT IN ('A6562', 'A881C', 'AFF1F', 'AF774', 'EO2193', 'AC8DD', 'AE453');
