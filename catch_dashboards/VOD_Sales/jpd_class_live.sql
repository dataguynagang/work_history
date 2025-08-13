SELECT
    -- 라이브강의별 정보
    cll.ClassID,
    cl.Title,
    cl.IsActive,
    cll.IsOnline,
    cll.OnlineLectureTypeCode,
    cll.Location,
    cll.LectureStartTime,
    cll.IsOnlyCareer,
    cll.IsForeignCompany,
    cll.IsPublicCompany,
    cll.IsMigrationData,
    cll.IsFull,
    cll.MaxCount,

    -- 카테고리 코드
    cllcate.CategoryCode,
    CASE
        WHEN LEFT(cllcate.CategoryCode, 1) = 'A' THEN '취업트레이닝'
        WHEN LEFT(cllcate.CategoryCode, 1) = 'B' THEN '멘토링'
        WHEN LEFT(cllcate.CategoryCode, 1) = 'C' THEN '직무인사이드'
        WHEN LEFT(cllcate.CategoryCode, 1) = 'D' THEN '대학생활백서'
        WHEN LEFT(cllcate.CategoryCode, 1) = 'E' THEN '채용설명회'
        WHEN LEFT(cllcate.CategoryCode, 1) = 'F' THEN '직무상담회'
    END AS 'Category_Depth1',
    CASE
        WHEN cllcate.CategoryCode = 'A1' THEN '자소서'
        WHEN cllcate.CategoryCode = 'A2' THEN '인적성'
        WHEN cllcate.CategoryCode = 'A3' THEN '면접'
        WHEN cllcate.CategoryCode = 'A4' THEN '스킬'
        WHEN cllcate.CategoryCode = 'B1' THEN '경영기획/사무'
        WHEN cllcate.CategoryCode = 'B2' THEN '연구개발/설계'
        WHEN cllcate.CategoryCode = 'B3' THEN '반도체/디스플레이'
        WHEN cllcate.CategoryCode = 'B4' THEN '바이오/제약/식품'
        WHEN cllcate.CategoryCode = 'B5' THEN '영업/영업관리'
        WHEN cllcate.CategoryCode = 'B6' THEN '품질/공정관리'
        WHEN cllcate.CategoryCode = 'B7' THEN '마케팅/광고/홍보'
        WHEN cllcate.CategoryCode = 'B8' THEN '미디어'
        WHEN cllcate.CategoryCode = 'B9' THEN '디자인'
        WHEN cllcate.CategoryCode = 'B10' THEN '상품기획'
        WHEN cllcate.CategoryCode = 'B11' THEN '건설'
        WHEN cllcate.CategoryCode = 'B12' THEN '은행/금융'
        WHEN cllcate.CategoryCode = 'B13' THEN 'IT/프로그래밍'
        WHEN cllcate.CategoryCode = 'B14' THEN '웹기획'
        WHEN cllcate.CategoryCode = 'B15' THEN '빅데이터/AI'
        WHEN cllcate.CategoryCode = 'B16' THEN '전문/특수직'
        WHEN cllcate.CategoryCode = 'B17' THEN '물류'
        WHEN cllcate.CategoryCode = 'B18' THEN '게임'
        WHEN cllcate.CategoryCode = 'C1' THEN '경영기획/사무'
        WHEN cllcate.CategoryCode = 'C2' THEN '연구개발/설계'
        WHEN cllcate.CategoryCode = 'C3' THEN '반도체/디스플레이'
        WHEN cllcate.CategoryCode = 'C4' THEN '바이오/제약/식품'
        WHEN cllcate.CategoryCode = 'C5' THEN '영업/영업관리'
        WHEN cllcate.CategoryCode = 'C6' THEN '품질/공정관리'
        WHEN cllcate.CategoryCode = 'C7' THEN '마케팅/광고/홍보'
        WHEN cllcate.CategoryCode = 'C8' THEN '미디어'
        WHEN cllcate.CategoryCode = 'C9' THEN '디자인'
        WHEN cllcate.CategoryCode = 'C10' THEN '상품기획'
        WHEN cllcate.CategoryCode = 'C11' THEN '건설'
        WHEN cllcate.CategoryCode = 'C12' THEN '은행/금융'
        WHEN cllcate.CategoryCode = 'C13' THEN 'IT/프로그래밍'
        WHEN cllcate.CategoryCode = 'C14' THEN '웹기획/PM'
        WHEN cllcate.CategoryCode = 'C15' THEN '빅데이터/AI'
        WHEN cllcate.CategoryCode = 'C16' THEN '전문/특수직'
        WHEN cllcate.CategoryCode = 'C17' THEN '물류'
        WHEN cllcate.CategoryCode = 'C18' THEN '게임'
        ELSE NULL
    END AS 'Category_Depth2',

    -- 전공코드
    majorcode.MajorCode AS Lecture_MajorCode,
    majorcode.Major_Depth1 AS Lecture_Major_Depth1,
    majorcode.Major_Depth2 AS Lecture_Major_Depth2,

    -- 직무코드
    jobcode.JobCode AS Lecture_JobCode,
    jobcode.Job_Depth1 AS Lecture_Job_Depth1,
    jobcode.Job_Depth2 AS Lecture_Job_Depth2,

    -- 업종코드
    jinhakcode.JinhakCode AS Lecture_JinhakCode,
    jinhakcode.JinhakName AS Lecture_JinhakName,

    -- 신청자
    liveapplication.uid,
    liveapplication.MemRegDate,
    liveapplication.ResTime,
    liveapplication.EnterTime,
    liveapplication.NewOldCode,
    liveapplication.SchoolCode,
    liveapplication.SchoolName,
    liveapplication.MajorCode3Dpt,
    liveapplication.application_major_depth1,
    liveapplication.application_major_depth2,
    liveapplication.application_major_depth3,
    liveapplication.Birth,
    liveapplication.Gender,
    liveapplication.EduStartDate,
    liveapplication.EduEndDate,
    liveapplication.FromSite,
    liveapplication.Description,

    -- 신청자 희망직무, 희망산업
    rhw.Depth1 AS resume_hopework_depth1,
    rhw.Depth2 AS resume_hopework_depth2,
    rhj.Name AS resume_hopejob_name,

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

    -- 최초신청여부
    CASE
        WHEN ROW_NUMBER() OVER(PARTITION BY liveapplication.memid ORDER BY liveapplication.ResTime ASC) = 1 THEN 'Y'
        ELSE 'N'
    END AS FirstApplicationYN

FROM
    ClassLectureLive AS cll
    -- 렉쳐
    JOIN ClassLecture AS cl ON cll.ClassID = cl.ClassID

    -- 카테고리
    LEFT JOIN (
        SELECT *
        FROM (
            SELECT *,
                ROW_NUMBER() OVER(PARTITION BY ClassID ORDER BY CategoryCode) AS num
            FROM ClassLectureLiveCategory
        ) a
        WHERE a.num = 1
    ) AS cllcate ON cll.ClassID = cllcate.ClassID

    -- 전공코드
    LEFT JOIN (
        SELECT
            cllmc.ClassID,
            cllmc.MajorCode,
            bmcv2.Depth1 AS Major_Depth1,
            bmcv2.Depth2 AS Major_Depth2
        FROM (
            SELECT *,
                ROW_NUMBER() OVER(PARTITION BY ClassID ORDER BY MajorCode) AS count
            FROM ClassLectureLiveMajorCode
        ) a
        WHERE a.count = 1
    ) AS cllmc
    LEFT JOIN BaseMajorCodeV2 AS bmcv2 ON cllmc.majorcode = bmcv2.Code
    ) AS majorcode ON cll.ClassID = majorcode.ClassID

    -- 직무코드
    LEFT JOIN (
        SELECT
            clljc.ClassID,
            clljc.JobCode,
            brjc.Depth1 AS Job_Depth1,
            brjc.Depth2 AS Job_Depth2
        FROM (
            SELECT *,
                ROW_NUMBER() OVER(PARTITION BY ClassID ORDER BY JobCode) AS count
            FROM ClassLectureLiveJobCode
        ) a
        WHERE a.count = 1
    ) AS clljc
    LEFT JOIN BaseRecruitJobCodeV99 AS brjc ON clljc.JobCode = brjc.Code
    ) AS jobcode ON cll.ClassID = jobcode.ClassID

    -- 업종코드
    LEFT JOIN (
        SELECT
            clljinhakc.ClassID,
            clljinhakc.JinhakCode,
            bjcv2.Name AS JinhakName
        FROM (
            SELECT *,
                ROW_NUMBER() OVER(PARTITION BY ClassID ORDER BY JinhakCode) AS count
            FROM ClassLectureLiveJinhakCode
        ) a
        WHERE a.count = 1
    ) AS clljinhakc
    LEFT JOIN BaseJinhakCodeV2All AS bjcv2 ON clljinhakc.JinhakCode = bjcv2.Code
    ) AS jinhakcode ON cll.ClassID = jinhakcode.ClassID

    -- 신청자
    LEFT JOIN (
        SELECT
            application.ClassID,
            application.MemID,
            memadd.uid,
            ISNULL(mem.RegDate, mdel.regdate) AS MemRegDate,
            application.ResTime,
            application.EnterTime,
            application.NewOldCode,
            medu.SchoolCode,
            medu.SchoolName,
            medu.MajorCode3Dpt,
            bmcv2.Depth1 AS application_major_depth1,
            bmcv2.Depth2 AS application_major_depth2,
            bmcv2.Depth3 AS application_major_depth3,
            mem.Birth,
            mem.Gender,
            medu.EduStartDate,
            medu.EduEndDate,
            application.FromSite,
            fs.Description
        FROM
            ClassLectureLiveApplication AS application
            LEFT JOIN (SELECT MemID, Birth, Gender, RegDate FROM Member UNION SELECT MemID, Birth, Gender, RegDate FROM MemberDormant) AS mem ON application.MemID = mem.MemID
            LEFT JOIN MemberDel AS mdel ON application.MemID = mdel.MemID
            LEFT JOIN MemberAdd AS memadd ON application.MemID = memadd.MemID
            LEFT JOIN MemberEdu AS medu ON application.MemID = medu.MemID
            LEFT JOIN BaseMajorCodeV2 AS bmcv2 ON medu.MajorCode3Dpt = bmcv2.Code
            LEFT JOIN FromSite AS fs ON application.FromSite = fs.FromSite
    ) AS liveapplication ON cll.ClassID = liveapplication.ClassID

    -- 이력서 경력만
    LEFT JOIN ResumeMajor AS rm ON liveapplication.MemID = rm.MemID
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

    LEFT JOIN (
        SELECT *
        FROM (
            SELECT *,
                ROW_NUMBER() OVER(PARTITION BY resumeid ORDER BY idx) AS rn
            FROM ResumeHopeWork
        ) rhw
        LEFT JOIN BaseRecruitJobCode AS brjc ON rhw.HopeWork = brjc.Code
        WHERE rhw.rn = 1
    ) AS rhw ON rm.ResumeID = rhw.ResumeID

    LEFT JOIN (
        SELECT *
        FROM (
            SELECT *,
                ROW_NUMBER() OVER(PARTITION BY resumeid ORDER BY idx) AS rn
            FROM ResumeHopeJob
        ) rhj
        LEFT JOIN BaseJinhakCode AS bjc ON rhj.HopeJob = bjc.Code
        WHERE rhj.rn = 1
    ) AS rhj ON rm.ResumeID = rhj.ResumeID

WHERE
    cl.IsActive = 1
ORDER BY
    cll.ClassID ASC;

