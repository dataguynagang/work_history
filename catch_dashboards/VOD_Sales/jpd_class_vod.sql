-- VOD Sales Data
SELECT
    cpr.OrderID,
    memadd.uid,
    cprd.ClassID,
    cl.Title,

    -- 카테고리 코드
    vodcate.CategoryCode,
    CASE
        WHEN LEFT(vodcate.CategoryCode, 1) = 'A' THEN '취업트레이닝'
        WHEN LEFT(vodcate.CategoryCode, 1) = 'B' THEN '멘토링'
        WHEN LEFT(vodcate.CategoryCode, 1) = 'C' THEN '직무인사이드'
        WHEN LEFT(vodcate.CategoryCode, 1) = 'D' THEN '대학생활백서'
        WHEN LEFT(vodcate.CategoryCode, 1) = 'E' THEN '채용설명회'
        WHEN LEFT(vodcate.CategoryCode, 1) = 'F' THEN '직무상담회'
    END AS 'Category_Depth1',
    CASE
        WHEN vodcate.CategoryCode = 'A1' THEN '자소서'
        WHEN vodcate.CategoryCode = 'A2' THEN '인적성'
        WHEN vodcate.CategoryCode = 'A3' THEN '면접'
        WHEN vodcate.CategoryCode = 'A4' THEN '스킬'
        WHEN vodcate.CategoryCode = 'B1' THEN '경영기획/사무'
        WHEN vodcate.CategoryCode = 'B2' THEN '연구개발/설계'
        WHEN vodcate.CategoryCode = 'B3' THEN '반도체/디스플레이'
        WHEN vodcate.CategoryCode = 'B4' THEN '바이오/제약/식품'
        WHEN vodcate.CategoryCode = 'B5' THEN '영업/영업관리'
        WHEN vodcate.CategoryCode = 'B6' THEN '품질/공정관리'
        WHEN vodcate.CategoryCode = 'B7' THEN '마케팅/광고/홍보'
        WHEN vodcate.CategoryCode = 'B8' THEN '미디어'
        WHEN vodcate.CategoryCode = 'B9' THEN '디자인'
        WHEN vodcate.CategoryCode = 'B10' THEN '상품기획'
        WHEN vodcate.CategoryCode = 'B11' THEN '건설'
        WHEN vodcate.CategoryCode = 'B12' THEN '은행/금융'
        WHEN vodcate.CategoryCode = 'B13' THEN 'IT/프로그래밍'
        WHEN vodcate.CategoryCode = 'B14' THEN '웹기획'
        WHEN vodcate.CategoryCode = 'B15' THEN '빅데이터/AI'
        WHEN vodcate.CategoryCode = 'B16' THEN '전문/특수직'
        WHEN vodcate.CategoryCode = 'B17' THEN '물류'
        WHEN vodcate.CategoryCode = 'B18' THEN '게임'
        WHEN vodcate.CategoryCode = 'C1' THEN '경영기획/사무'
        WHEN vodcate.CategoryCode = 'C2' THEN '연구개발/설계'
        WHEN vodcate.CategoryCode = 'C3' THEN '반도체/디스플레이'
        WHEN vodcate.CategoryCode = 'C4' THEN '바이오/제약/식품'
        WHEN vodcate.CategoryCode = 'C5' THEN '영업/영업관리'
        WHEN vodcate.CategoryCode = 'C6' THEN '품질/공정관리'
        WHEN vodcate.CategoryCode = 'C7' THEN '마케팅/광고/홍보'
        WHEN vodcate.CategoryCode = 'C8' THEN '미디어'
        WHEN vodcate.CategoryCode = 'C9' THEN '디자인'
        WHEN vodcate.CategoryCode = 'C10' THEN '상품기획'
        WHEN vodcate.CategoryCode = 'C11' THEN '건설'
        WHEN vodcate.CategoryCode = 'C12' THEN '은행/금융'
        WHEN vodcate.CategoryCode = 'C13' THEN 'IT/프로그래밍'
        WHEN vodcate.CategoryCode = 'C14' THEN '웹기획/PM'
        WHEN vodcate.CategoryCode = 'C15' THEN '빅데이터/AI'
        WHEN vodcate.CategoryCode = 'C16' THEN '전문/특수직'
        WHEN vodcate.CategoryCode = 'C17' THEN '물류'
        WHEN vodcate.CategoryCode = 'C18' THEN '게임'
        ELSE NULL
    END AS 'Category_Depth2',

    -- 신청자 개인정보
    medu.SchoolCode AS Customer_SchoolCode,
    medu.SchoolName AS Customer_SchoolName,
    medu.MajorCode3Dpt,
    bmcv2.Depth1 AS Customer_major_depth1,
    bmcv2.Depth2 AS Customer_major_depth2,
    bmcv2.Depth3 AS Customer_major_depth3,
    YEAR(cpr.UpdateDate) - YEAR(mem.Birth) + 1 AS Customer_Age,
    CASE
        WHEN mem.Gender = 'F' THEN '여'
        WHEN mem.Gender = 'M' THEN '남'
    END AS Customer_Gender,
    medu.EduStartDate AS Customer_EduStartDate,
    medu.EduEndDate AS Customer_EduEndDate,
    CASE
        WHEN TRY_CONVERT(INT, LEFT(medu.EduStartDate, 4)) >= 1950 AND TRY_CONVERT(INT, LEFT(medu.EduStartDate, 4)) <= 2050
        THEN TRY_CONVERT(INT, LEFT(medu.EduStartDate, 4))
        ELSE NULL
    END AS Customer_EduStartYear,
    CASE
        WHEN TRY_CONVERT(INT, LEFT(medu.EduEndDate, 4)) >= 1950 AND TRY_CONVERT(INT, LEFT(medu.EduEndDate, 4)) <= 2050
        THEN TRY_CONVERT(INT, LEFT(medu.EduEndDate, 4))
        ELSE NULL
    END AS Customer_EduEndYear,

    -- 이력서 경력
    -- 컬럼 FROM 이력서 경력정보
    CASE
        WHEN resumecareer.ResumeID IS NULL THEN 'N'
        ELSE 'Y'
    END AS resumecareer_YN,
    resumecareer.total_work_month,
    resumecareer.Code AS career_jobcode,
    resumecareer.Depth1 AS career_job_depth1,
    resumecareer.Depth2 AS career_job_depth2,
    resumecareer.JinhakCode AS career_JinhakCode,
    resumecareer.JinhakDepth1 AS career_JinhakDepth1,
    resumecareer.JinhakDepth2 AS career_JinhakDepth2,

    -- JPD 콘텐츠 이용경험유무
    CASE WHEN jpdmem.MemID IS NULL THEN 'N' ELSE 'Y' END AS JPD_Mem_YN,
    CASE WHEN jpd_cafe.MemID IS NULL THEN 'N' ELSE 'Y' END AS jpd_cafe_YN,
    CASE WHEN jpd_live.MemID IS NULL THEN 'N' ELSE 'Y' END AS jpd_live_YN,
    CASE WHEN jpd_cacon.MemID IS NULL THEN 'N' ELSE 'Y' END AS jpd_cacon_YN,
    CASE WHEN jpd_study.MemID IS NULL THEN 'N' ELSE 'Y' END AS jpd_study_YN,

    -- 최초구매여부
    CASE
        WHEN (RANK() OVER (PARTITION BY cpr.MemID ORDER BY cpr.OrderID ASC)) = 1 THEN 'Y'
        ELSE 'N'
    END AS FirstBuyCustomer,

    -- 결제 관련
    CASE
        WHEN cpr.UpdateDate < '2022-07-01' THEN NULL
        ELSE cpr.ClassDiscountCodes
    END AS OrderDiscountCodes,
    CASE
        WHEN cpr.UpdateDate < '2022-07-01' THEN NULL
        ELSE OrderDiscountCodes.Title
    END AS OrderDiscountTitle,
    cpr.OrderStatusCode,
    cpr.PayMethodCode,
    cpr.TotalFullPrice,
    cpr.OrderDiscountPrice,
    cpr.TotalCancelPrice,
    cpr.TotalSalesPrice,
    cpr.IsConfirm,
    cpr.CompleteDate,
    cpr.UpdateDate,

    -- From ClassPaymentResultDetail
    cprd.PaymentResultDetailID,
    cprd.IsCancel AS ClassIsCancel,
    -- , cpr.TotalFullPrice / (CASE WHEN (SUM(CASE WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO' THEN 0 ELSE 1 END) OVER(PARTITION BY cpr.OrderID)) < 1 THEN 1 ELSE (SUM(CASE WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO' THEN 0 ELSE 1 END) OVER(PARTITION BY cpr.OrderID)) END) FullPricePerClass
    cprd.FullPrice AS ClassFullPrice,
    CASE
        WHEN cpr.UpdateDate < '2022-07-01'
        THEN NULL
        ELSE
            (CASE
                WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO'
                THEN 0
                ELSE cpr.OrderDiscountPrice / (
                    CASE
                        WHEN (SUM(CASE WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO' THEN 0 ELSE 1 END) OVER(PARTITION BY cpr.OrderID)) < 1
                        THEN 1
                        ELSE (SUM(CASE WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO' THEN 0 ELSE 1 END) OVER(PARTITION BY cpr.OrderID))
                    END
                )
            END)
    END AS OrderDiscountPricePerClass,
    CASE
        WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO'
        THEN 0
        ELSE cpr.TotalCancelPrice / (
            CASE
                WHEN (SUM(CASE WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO' THEN 0 ELSE 1 END) OVER(PARTITION BY cpr.OrderID)) < 1
                THEN 1
                ELSE (SUM(CASE WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO' THEN 0 ELSE 1 END) OVER(PARTITION BY cpr.OrderID))
            END
        )
    END AS TotalCancelPricePerClass,
    CASE
        WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO'
        THEN 0
        ELSE cpr.TotalSalesPrice / (
            CASE
                WHEN (SUM(CASE WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO' THEN 0 ELSE 1 END) OVER(PARTITION BY cpr.OrderID)) < 1
                THEN 1
                ELSE (SUM(CASE WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO' THEN 0 ELSE 1 END) OVER(PARTITION BY cpr.OrderID))
            END
        )
    END AS TotalSalesPricePerClass,

    -- , cpr.TotalFullPrice / COUNT(*) OVER(PARTITION BY cpr.OrderID) FullPricePerClass
    -- , cpr.OrderDiscountPrice / COUNT(*) OVER(PARTITION BY cpr.OrderID) OrderDiscountPricePerClass
    -- , cpr.TotalCancelPrice / COUNT(*) OVER(PARTITION BY cpr.OrderID) TotalCancelPricePerClass
    -- , cpr.TotalSalesPrice / COUNT(*) OVER(PARTITION BY cpr.OrderID) TotalSalesPricePerClass
    CASE
        WHEN cpr.UpdateDate < '2022-07-01'
        THEN cpr.ClassDiscountCodes
        ELSE cprd.ClassDiscountCodes
    END AS ClassDiscountCodes,
    CASE
        WHEN cpr.UpdateDate < '2022-07-01'
        THEN OrderDiscountCodes.Title
        ELSE ClassDiscountCodes.Title
    END AS ClassDiscountTitle,
    CASE
        WHEN cpr.UpdateDate < '2022-07-01'
        THEN
            (CASE
                WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO'
                THEN 0
                ELSE cpr.OrderDiscountPrice / (
                    CASE
                        WHEN (SUM(CASE WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO' THEN 0 ELSE 1 END) OVER(PARTITION BY cpr.OrderID)) < 1
                        THEN 1
                        ELSE (SUM(CASE WHEN cprd.ClassDiscountCodes = 'FIRST_ZERO' THEN 0 ELSE 1 END) OVER(PARTITION BY cpr.OrderID))
                    END
                )
            END)
        ELSE cprd.DiscountPrices
    END AS ClassDiscountPrice,
    cprd.BundleClassID,
    clBundle.Title AS BundleTitle

-- 결제정보
FROM
    ClassPaymentResult AS cpr
    LEFT JOIN ClassPaymentResultDetail AS cprd ON cpr.OrderID = cprd.OrderID
    LEFT JOIN ClassDiscount AS OrderDiscountCodes ON cpr.ClassDiscountCodes = OrderDiscountCodes.ClassDiscountCode
    LEFT JOIN ClassDiscount AS ClassDiscountCodes ON cprd.ClassDiscountCodes = ClassDiscountCodes.ClassDiscountCode
    -- LEFT JOIN ClassDiscount cdc on cpr.ClassDiscountCodes = cdc.ClassDiscountCode

-- 강의정보
    LEFT JOIN ClassLecture AS cl ON cprd.ClassID = cl.ClassID
    LEFT JOIN (
        SELECT *
        FROM (
            SELECT
                *,
                ROW_NUMBER() OVER(PARTITION BY ClassID ORDER BY IsTitleCategory DESC) AS count
            FROM ClassLectureVODCategory
        ) a
        WHERE a.count = 1
    ) AS vodcate ON cprd.ClassID = vodcate.ClassID

-- 회원정보
    LEFT JOIN Member AS mem ON cpr.MemID = mem.MemID
    LEFT JOIN MemberAdd AS memadd ON cpr.MemID = memadd.MemID
    LEFT JOIN MemberEdu AS medu ON cpr.MemID = medu.MemID
    LEFT JOIN BaseMajorCodeV2 AS bmcv2 ON medu.MajorCode3Dpt = bmcv2.Code

-- 이력서 경력만
    LEFT JOIN ResumeMajor AS rm ON cpr.MemID = rm.MemID
    LEFT JOIN (
        SELECT
            career.ResumeID,
            career.total_work_month,
            brjc.Code,
            brjc.Depth1,
            brjc.Depth2,
            bc.JinhakCode,
            bc.JinhakCodeName,
            basejc.depth1 AS JinhakDepth1,
            basejc.depth2 AS JinhakDepth2
        FROM (
            SELECT
                ResumeID,
                CareerID,
                WorkYear,
                WorkMonth,
                SUM(WorkYear) OVER(PARTITION BY resumeid) * 12 + SUM(workmonth) OVER(PARTITION BY resumeid) AS total_work_month,
                CompID,
                LEFT(MAX(WorkJob) OVER(PARTITION BY resumeid), 6) AS workcode,
                ROW_NUMBER() OVER(PARTITION BY ResumeID ORDER BY CareerID DESC) AS count
            FROM ResumeCareer
        ) AS career
        LEFT JOIN BaseRecruitJobCodeV99 AS brjc ON career.workcode = brjc.Code
        LEFT JOIN BaseCompany AS bc ON career.CompID = bc.CompID
        LEFT JOIN (
            SELECT
                code1.Code AS code,
                code2.Name AS depth1,
                code1.name AS depth2
            FROM
                BaseJinhakCodeV2All AS code1
                LEFT JOIN BaseJinhakCodeV2All AS code2 ON LEFT(code1.Code, 1) = code2.Code
        ) AS basejc ON bc.JinhakCode = basejc.code
        WHERE career.count = 1
    ) AS resumecareer ON rm.ResumeID = resumecareer.ResumeID -- 경력정보

-- JPD 콘텐츠 사용경험 회원
    LEFT JOIN (
        SELECT MemID FROM CatchDotVisit
        UNION
        SELECT MemID FROM CatchDotProgRes
        UNION
        SELECT MemID FROM CatchDotStudyRes
        UNION
        SELECT MemID FROM ClassLectureLiveApplication
    ) AS jpdmem ON cpr.MemID = jpdmem.MemID
    LEFT JOIN (
        SELECT DISTINCT MemID FROM CatchDotVisit
    ) AS jpd_cafe ON cpr.MemID = jpd_cafe.MemID
    LEFT JOIN (
        SELECT MemID
        FROM
            CatchDotProgRes AS cdpr
            LEFT JOIN CatchDotProgram AS cdp ON cdpr.ID = cdp.ID
        WHERE cdp.PGubun <> 3
        UNION
        SELECT MemID FROM ClassLectureLiveApplication
    ) AS jpd_live ON cpr.MemID = jpd_live.MemID
    LEFT JOIN (
        SELECT DISTINCT MemID
        FROM
            CatchDotProgRes AS cdpr
            LEFT JOIN CatchDotProgram AS cdp ON cdpr.ID = cdp.ID
        WHERE cdp.PGubun = 3
    ) AS jpd_cacon ON cpr.MemID = jpd_cacon.MemID
    LEFT JOIN (
        SELECT DISTINCT MemID FROM CatchDotStudyRes
    ) AS jpd_study ON cpr.MemID = jpd_study.MemID

-- 묶음 강의
    LEFT JOIN ClassLecture AS clBundle ON cprd.BundleClassID = clBundle.ClassID

WHERE
    cpr.MemID NOT IN ('event6605', 'ebkim8888', 'user01', 'godongha1')
    AND cpr.OrderStatusCode <> 'PAC'

;

-- select * from ClassDiscount

