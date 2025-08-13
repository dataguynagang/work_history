-- =================================================================
-- FileName: MemberAnalysis_Member.sql
-- Description: 회원 관련 종합 정보를 조회하는 쿼리입니다.
-- =================================================================

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- CTE: FirstJPD
-- 설명: 회원의 첫번째 JPD(진학콘서트, 라이브, 스터디 등) 참여 기록을 조회합니다.
WITH FirstJPD AS (
    SELECT
        B.MemID,
        B.ResTime,
        B.Via
    FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY A.MemID ORDER BY A.ResTime DESC) AS jpdcount
            FROM
                (
                    (SELECT MemID, RegDate AS ResTime, 'Cafe' AS 'Via' FROM CatchDotMEM WHERE ConfirmDate IS NOT NULL)
                    UNION
                    (SELECT cdpr.MemID, cdpr.ResTime, 'Live' AS 'Via' FROM CatchDotProgRes cdpr LEFT JOIN CatchDotProgram cdp ON cdpr.ID = cdp.ID WHERE cdp.PGubun = 1)
                    UNION
                    (SELECT clla.MemID, clla.ResTime, 'Live' AS 'Via' FROM ClassLectureLive cll JOIN ClassLecture cl ON cll.ClassID = cl.ClassID JOIN ClassLectureLiveApplication clla ON cl.ClassID = clla.ClassID)
                    UNION
                    (SELECT cdpr.MemID, cdpr.ResTime, 'CareerCon' AS 'Via' FROM CatchDotProgRes cdpr LEFT JOIN CatchDotProgram cdp ON cdpr.ID = cdp.ID WHERE cdp.PGubun = 3)
                    UNION
                    (
                        SELECT
                            clla.MemID,
                            clla.ResTime,
                            'CareerCon' AS 'Via'
                        FROM
                            ClassLecture cl
                            JOIN ClassCareerConSection cccs ON cl.ClassCareerConSectionID = cccs.ClassCareerConSectionID
                            JOIN ClassCareerCon ccc ON cccs.ClassCareerConID = ccc.ClassCareerConID
                            JOIN ClassLectureCareerCon clcs ON cl.ClassID = clcs.ClassID
                            JOIN ClassLectureLiveApplication clla ON cl.ClassID = clla.ClassID
                    )
                    UNION
                    (SELECT MemID, ResTime, 'Study' AS 'Via' FROM CatchDotStudyRes)
                ) AS A
        ) AS B
    WHERE
        B.jpdcount = 1
),
-- CTE: JPD_YN
-- 설명: 회원별 JPD 참여 여부 및 횟수를 집계합니다.
JPD_YN AS (
    SELECT
        A.MemID,
        CASE WHEN SUM(CASE WHEN A.Via = 'Cafe' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS CafeYN,
        SUM(CASE WHEN A.Via = 'Cafe' THEN 1 ELSE 0 END) AS CafeCount,
        CASE WHEN SUM(CASE WHEN A.Via = 'Live' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS LiveYN,
        SUM(CASE WHEN A.Via = 'Live' THEN 1 ELSE 0 END) AS LiveCount,
        CASE WHEN SUM(CASE WHEN A.Via = 'CareerCon' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS CareerConYN,
        SUM(CASE WHEN A.Via = 'CareerCon' THEN 1 ELSE 0 END) AS CareerConCount,
        CASE WHEN SUM(CASE WHEN A.Via = 'Study' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS StudyYN,
        SUM(CASE WHEN A.Via = 'Study' THEN 1 ELSE 0 END) AS StudyCount,
        CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS WholeJPDYN,
        COUNT(*) AS WholeJPDCount
    FROM
        (
            (SELECT MemID, RegDate AS ResTime, 'Cafe' AS 'Via' FROM CatchDotMEM WHERE ConfirmDate IS NOT NULL)
            UNION
            (SELECT cdpr.MemID, cdpr.ResTime, 'Live' AS 'Via' FROM CatchDotProgRes cdpr LEFT JOIN CatchDotProgram cdp ON cdpr.ID = cdp.ID WHERE cdp.PGubun = 1)
            UNION
            (SELECT clla.MemID, clla.ResTime, 'Live' AS 'Via' FROM ClassLectureLive cll JOIN ClassLecture cl ON cll.ClassID = cl.ClassID JOIN ClassLectureLiveApplication clla ON cl.ClassID = clla.ClassID)
            UNION
            (SELECT cdpr.MemID, cdpr.ResTime, 'CareerCon' AS 'Via' FROM CatchDotProgRes cdpr LEFT JOIN CatchDotProgram cdp ON cdpr.ID = cdp.ID WHERE cdp.PGubun = 3)
            UNION
            (
                SELECT
                    clla.MemID,
                    clla.ResTime,
                    'CareerCon' AS 'Via'
                FROM
                    ClassLecture cl
                    JOIN ClassCareerConSection cccs ON cl.ClassCareerConSectionID = cccs.ClassCareerConSectionID
                    JOIN ClassCareerCon ccc ON cccs.ClassCareerConID = ccc.ClassCareerConID
                    JOIN ClassLectureCareerCon clcs ON cl.ClassID = clcs.ClassID
                    JOIN ClassLectureLiveApplication clla ON cl.ClassID = clla.ClassID
            )
            UNION
            (SELECT MemID, ResTime, 'Study' AS 'Via' FROM CatchDotStudyRes)
        ) AS A
    GROUP BY
        A.MemID
),
-- CTE: JPDMem
-- 설명: 첫번째 JPD 정보와 JPD 참여 통계를 결합합니다.
JPDMem AS (
    SELECT
        fj.MemID,
        fj.ResTime AS JPDFirstResTime,
        fj.Via,
        yn.CafeCount,
        yn.CafeYN,
        yn.CareerConCount,
        yn.CareerConYN,
        yn.LiveCount,
        yn.LiveYN,
        yn.StudyCount,
        yn.StudyYN
    FROM
        FirstJPD AS fj
        JOIN JPD_YN AS yn ON fj.MemID = yn.MemID
),
-- CTE: PremiumCriteria
-- 설명: 특정 조건(프리미엄 서비스)에 해당하는 기업 및 발송일 정보를 정의합니다.
PremiumCriteria AS (
    SELECT '310670' AS CompID, CONVERT(DATE, '2022-4-27') AS SendDate UNION
    SELECT '310670', CONVERT(DATE, '2022-4-28') UNION
    SELECT 'AEBF8', CONVERT(DATE, '2022-4-28') UNION
    SELECT '310670', CONVERT(DATE, '2022-4-29') UNION
    SELECT 'AEBF8', CONVERT(DATE, '2022-5-4') UNION
    SELECT 'L24796', CONVERT(DATE, '2022-5-24') UNION
    SELECT '128372', CONVERT(DATE, '2022-6-2') UNION
    SELECT '128372', CONVERT(DATE, '2022-6-7') UNION
    SELECT '128372', CONVERT(DATE, '2022-6-8') UNION
    SELECT '620351', CONVERT(DATE, '2022-6-13') UNION
    SELECT '821500', CONVERT(DATE, '2022-6-15') UNION
    SELECT '821500', CONVERT(DATE, '2022-6-24') UNION
    SELECT '310069', CONVERT(DATE, '2022-6-29') UNION
    SELECT '310069', CONVERT(DATE, '2022-6-30') UNION
    SELECT '310670', CONVERT(DATE, '2022-7-6') UNION
    SELECT '350621', CONVERT(DATE, '2022-7-7') UNION
    SELECT 'HS6813', CONVERT(DATE, '2022-7-8') UNION
    SELECT '310069', CONVERT(DATE, '2022-7-12') UNION
    SELECT '389552', CONVERT(DATE, '2022-7-14') UNION
    SELECT '310670', CONVERT(DATE, '2022-7-18') UNION
    SELECT '049653', CONVERT(DATE, '2022-7-19') UNION
    SELECT '049653', CONVERT(DATE, '2022-7-20') UNION
    SELECT 'GR06G', CONVERT(DATE, '2022-8-1') UNION
    SELECT '350621', CONVERT(DATE, '2022-8-2') UNION
    SELECT 'L24796', CONVERT(DATE, '2022-8-12') UNION
    SELECT '049653', CONVERT(DATE, '2022-8-12') UNION
    SELECT '049653', CONVERT(DATE, '2022-8-17') UNION
    SELECT '481812', CONVERT(DATE, '2022-8-18') UNION
    SELECT '481812', CONVERT(DATE, '2022-8-19') UNION
    SELECT '481812', CONVERT(DATE, '2022-8-22') UNION
    SELECT '481812', CONVERT(DATE, '2022-8-23')
),
-- CTE: JobOfferMem
-- 설명: 입사 제안 관련 통계를 집계합니다.
JobOfferMem AS (
    SELECT
        jo.MemID,
        1 AS OfferYN,
        COUNT(*) AS OfferCount,
        MIN(jod.OfferDate) AS OfferDateFirst,
        MAX(jod.OfferDate) AS OfferDateLast,
        CASE WHEN SUM(CASE WHEN rpr.RegDate IS NOT NULL THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS ResumeReadYN,
        SUM(CASE WHEN rpr.RegDate IS NOT NULL THEN 1 ELSE 0 END) AS ResumeReadCount,
        MIN(rpr.RegDate) AS ResumeReadDateFirst,
        MAX(rpr.RegDate) AS ResumeReadDateLast,
        CASE WHEN SUM(CASE WHEN jod.ViewDate IS NOT NULL THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS ViewYN,
        SUM(CASE WHEN jod.ViewDate IS NOT NULL THEN 1 ELSE 0 END) AS ViewCount,
        MIN(jod.ViewDate) AS ViewDateFirst,
        MAX(jod.ViewDate) AS ViewDateLast,
        CASE WHEN SUM(CASE WHEN jod.AcceptDate IS NOT NULL THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS AcceptYN,
        SUM(CASE WHEN jod.AcceptDate IS NOT NULL THEN 1 ELSE 0 END) AS AcceptCount,
        MIN(jod.AcceptDate) AS AcceptDateFirst,
        MAX(jod.AcceptDate) AS AcceptDateLast,
        CASE WHEN SUM(CASE WHEN jod.InterviewDate IS NOT NULL THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS InterviewYN,
        SUM(CASE WHEN jod.InterviewDate IS NOT NULL THEN 1 ELSE 0 END) AS InterviewCount,
        MIN(jod.InterviewDate) AS InterviewDateFirst,
        MAX(jod.InterviewDate) AS InterviewDateLast,
        CASE WHEN SUM(CASE WHEN jod.PassYN IS NOT NULL THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS PassYN,
        SUM(CASE WHEN jod.PassYN IS NOT NULL THEN 1 ELSE 0 END) AS PassCount
    FROM
        JobOffer AS jo
        JOIN JobOfferDetail AS jod ON jo.OfferID = jod.OfferID
        LEFT JOIN ResumePoolRead AS rpr ON jo.CompID = rpr.CompID AND jo.MemID = rpr.MemID
        LEFT JOIN PremiumCriteria AS pc ON jo.CompID = pc.CompID AND CONVERT(DATE, jod.OfferDate) = pc.SendDate
    WHERE
        jo.OfferID > 288
        AND (jo.CompID NOT IN ('AF774', 'AC8DD', 'A6562', 'AFF1F', 'A6562', 'EO2193'))
        AND jod.RecruitId IS NULL
        AND pc.CompID IS NULL
    GROUP BY
        jo.MemID
)
-- 최종 쿼리: 회원 관련 모든 정보를 종합하여 조회합니다.
SELECT
    -- 컬럼 from 회원
    memadd.uid,
    mem.MemID,
    CASE WHEN mem.JoinMember = 'jinhak' THEN '통합회원' ELSE '일반회원' END AS JinhakMem,
    CASE WHEN mem.RegSite >= 5 THEN 'SNS가입' ELSE '일반가입' END AS SnsMem,
    CASE WHEN mem.CatchAlbaMember = 1 THEN 1 ELSE 0 END AS IsAlbaMem,
    mem.RegDate AS MemberRegDate,
    CONVERT(INT, GETDATE() - mem.RegDate) AS MemberRegDateDays,
    CONVERT(DATE, mem.Birth) AS Birth,
    YEAR(GETDATE()) - YEAR(mem.birth) + 1 AS KoreanAge,
    CASE WHEN mem.Gender = 'F' THEN '여' WHEN mem.Gender = 'M' THEN '남' END AS MemberGender,
    CASE WHEN MemSMS > 0 THEN 1 ELSE 0 END AS SmsYN,
    CASE WHEN MemEmail > 0 THEN 1 ELSE 0 END AS EmailYN,
    CASE WHEN MemPush > 0 THEN 1 ELSE 0 END AS PushYN,
    -- 컬럼 from 로그인로그
    CASE WHEN loginlog.MemID IS NULL THEN 0 ELSE 1 END AS LoginYN,
    loginlog.login_count AS LoginLogCount,
    loginlog.first_login AS LoginLogFirstLogin,
    loginlog.last_login AS LoginLogLastLogin,
    CONVERT(INT, loginlog.last_login - loginlog.first_login) AS UsingDays,
    -- 컬럼 from 학력정보
    CASE WHEN memedu.MemID IS NULL THEN 0 ELSE 1 END AS EduMemberEduYN,
    CASE WHEN memedu.SchoolTypeCode = 0 THEN '고등학교' WHEN memedu.SchoolTypeCode = 1 THEN '전문학사' WHEN memedu.SchoolTypeCode = 2 THEN '학사' WHEN memedu.SchoolTypeCode = 3 THEN '석사' WHEN memedu.SchoolTypeCode = 4 THEN '박사' ELSE NULL END AS EduSchoolType,
    memedu.SchoolCode AS EduSchoolCode,
    memedu.SchoolName AS EduSchoolName,
    memedu.MajorCode3Dpt AS EduMajorCode3Dpt,
    memedu.Depth1 AS EduMajorDepth1,
    memedu.Depth2 AS EduMajorDepth2,
    memedu.Depth3 AS EduMajorDepth3,
    memedu.MajorName AS EduMajorName,
    memedu.EduStartDate,
    memedu.EduEndDate,
    CASE WHEN TRY_CONVERT(INT, LEFT(memedu.EduStartDate, 4)) >= 1950 AND TRY_CONVERT(INT, LEFT(memedu.EduStartDate, 4)) <= 2050 THEN TRY_CONVERT(INT, LEFT(memedu.EduStartDate, 4)) ELSE NULL END AS EduStartYear,
    CASE WHEN TRY_CONVERT(INT, LEFT(memedu.EduEndDate, 4)) >= 1950 AND TRY_CONVERT(INT, LEFT(memedu.EduEndDate, 4)) <= 2050 THEN TRY_CONVERT(INT, LEFT(memedu.EduEndDate, 4)) ELSE NULL END AS EduEndYear,
    -- 컬럼 FROM 이력서정보
    CASE WHEN resume.MemID IS NULL THEN 0 ELSE 1 END AS ResumeYN,
    resume.ResumeID,
    resume.FirstRegDate AS ResumeFirstRegDate,
    resume.RegDate AS ResumeRegDate,
    -- 인재검색 관련
    CASE WHEN mem.ResumeOpen = 'Y' THEN 1 ELSE 0 END AS ResumeOpenYN,
    rp.RegDate AS ResumeOpenDate,
    CONVERT(INT, rp.RegDate - resume.FirstRegDate) AS ResumeOpenDaySinceFirstReg,
    -- 컬럼 FROM 이력서 경력정보
    CASE WHEN resume.ResumeID IS NULL THEN NULL ELSE CASE WHEN resume.CareerGubun = 2 THEN '경력' ELSE '신입' END END AS ResumeCareerGubun,
    CASE WHEN resumecareer.ResumeID IS NULL THEN 0 ELSE 1 END AS ResumeCareerYN,
    resumecareer.total_work_month AS ResumeTotalWorkMonth,
    resumecareer.Code AS ResumeCareerJobCode,
    resumecareer.Depth1 AS ResumeCareerJobDepth1,
    resumecareer.Depth2 AS ResumeCareerJobDepth2,
    resumecareer.JinhakCode AS ResumeCareerJinhakCode,
    resumecareer.JinhakDepth1 AS ResumeCareerJinhakDepth1,
    resumecareer.JinhakDepth2 AS ResumeCareerJinhakDepth2,
    -- 컬럼 FROM 이력서 어학시험
    CASE WHEN langtest.ResumeID IS NULL THEN 0 ELSE 1 END AS ResumeLangTestYN,
    langtest.langtestcount AS ResumeLangTestCount,
    -- 컬럼 FROM 이력서 자격증
    CASE WHEN license.ResumeID IS NULL THEN 0 ELSE 1 END AS ResumeLicenseYN,
    license.license_count AS ResumeLicenseCount,
    -- 컬럼 FROM 이력서 보유기술
    CASE WHEN skill.ResumeID IS NULL THEN 0 ELSE 1 END AS ResumeSkillYN,
    skill.skillcount AS ResumeSkillCount,
    -- 컬럼 FROM 이력서 수상내역
    CASE WHEN award.ResumeID IS NULL THEN 0 ELSE 1 END AS ResumeAwardYN,
    award.awardcount AS ResumeAwardCount,
    -- 컬럼 FROM 이력서 인턴,대외활동
    CASE WHEN experience.ResumeID IS NULL THEN 0 ELSE 1 END AS ResumeExperienceYN,
    experience.expcount AS ResumeExperienceCount,
    -- 공고 조회 관련
    CASE WHEN JobPostingViewLog.MemID IS NULL THEN 0 ELSE 1 END AS JobPostingViewYN,
    JobPostingViewLog.JobPostingViewCount,
    JobPostingViewLog.JobPostingViewFirstDate,
    JobPostingViewLog.JobPostingViewLastDate,
    -- 즉시지원 공고 조회 관련
    CASE WHEN InstantApplyJobPostingViewLog.MemID IS NULL THEN 0 ELSE 1 END AS InstantApplyJobPostingViewYN,
    InstantApplyJobPostingViewLog.InstantApplyJobPostingViewCount,
    InstantApplyJobPostingViewLog.InstantApplyJobPostingViewFirstDate,
    InstantApplyJobPostingViewLog.InstantApplyJobPostingViewLastDate,
    -- 즉시지원 관련
    CASE WHEN applycount.MemID IS NULL THEN 0 ELSE 1 END AS ApplyYN,
    applycount.ApplyCount,
    applycount.ApplyFirstDateTime,
    applycount.ApplyLastDateTime,
    -- JPD 관련
    jpd.JpdFirstResTime,
    jpd.Via AS JpdVia,
    CASE WHEN jpd.JPDFirstResTime < DATEADD(HOUR, 1, mem.RegDate) THEN 1 ELSE 0 END AS JpdMemberResByJPD,
    CASE WHEN jpd.JPDFirstResTime < DATEADD(HOUR, 1, resume.FirstRegDate) THEN 1 ELSE 0 END AS JpdFirstResumeResByJPD,
    CASE WHEN jpd.JPDFirstResTime < DATEADD(HOUR, 1, rp.RegDate) THEN 1 ELSE 0 END AS JpdResumeOpenByJPD,
    jpd.CafeYN AS JpdCafeYN,
    jpd.LiveYN AS JpdLiveYN,
    jpd.CareerConYN AS JpdCareerConYN,
    jpd.StudyYN AS JpdStudyYN,
    -- 인재픽 관련
    JobOfferMem.OfferYN AS JobOfferOfferYN,
    JobOfferMem.OfferCount AS JobOfferOfferCount,
    JobOfferMem.OfferDateFirst AS JobOfferDateFirst,
    JobOfferMem.OfferDateLast AS JobOfferDateLast,
    CASE WHEN (CONVERT(INT, JobOfferMem.OfferDateFirst - resume.FirstRegDate)) < 0 THEN NULL ELSE (CONVERT(INT, JobOfferMem.OfferDateFirst - resume.FirstRegDate)) END AS JobOfferFirstDaySinceFirstReg,
    JobOfferMem.ResumeReadYN AS JobOfferResumeReadYN,
    JobOfferMem.ResumeReadCount AS JobOfferResumeReadCount,
    JobOfferMem.ResumeReadDateFirst AS JobOfferResumeReadDateFirst,
    JobOfferMem.ResumeReadDateLast AS JobOfferResumeReadDateLast,
    CASE WHEN (CONVERT(INT, JobOfferMem.ResumeReadDateFirst - resume.FirstRegDate)) < 0 THEN NULL ELSE (CONVERT(INT, JobOfferMem.ResumeReadDateFirst - resume.FirstRegDate)) END AS ResumeReadFirstDaySinceFirstReg,
    JobOfferMem.ViewYN AS JobOfferViewYN,
    JobOfferMem.ViewCount AS JobOfferViewCount,
    JobOfferMem.ViewDateFirst AS JobOfferViewDateFirst,
    JobOfferMem.ViewDateLast AS JobOfferViewDateLast,
    CASE WHEN (CONVERT(INT, JobOfferMem.ViewDateFirst - resume.FirstRegDate)) < 0 THEN NULL ELSE (CONVERT(INT, JobOfferMem.ViewDateFirst - resume.FirstRegDate)) END AS ViewFirstDaySinceFirstReg,
    JobOfferMem.AcceptYN AS JobOfferAcceptYN,
    JobOfferMem.AcceptCount AS JobOfferAcceptCount,
    JobOfferMem.AcceptDateFirst AS JobOfferAcceptDateFirst,
    JobOfferMem.AcceptDateLast AS JobOfferAcceptDateLast,
    CASE WHEN (CONVERT(INT, JobOfferMem.AcceptDateFirst - resume.FirstRegDate)) < 0 THEN NULL ELSE (CONVERT(INT, JobOfferMem.AcceptDateFirst - resume.FirstRegDate)) END AS AcceptFirstDaySinceFirstReg,
    JobOfferMem.InterviewYN AS JobOfferInterviewYN,
    JobOfferMem.InterviewCount AS JobOfferInterviewCount,
    JobOfferMem.InterviewDateFirst AS JobOfferInterviewDateFirst,
    JobOfferMem.InterviewDateLast AS JobOfferInterviewDateLast,
    CASE WHEN (CONVERT(INT, JobOfferMem.InterviewDateFirst - resume.FirstRegDate)) < 0 THEN NULL ELSE (CONVERT(INT, JobOfferMem.InterviewDateFirst - resume.FirstRegDate)) END AS InterviewFirstDaySinceFirstReg,
    JobOfferMem.PassYN AS JobOfferPassYN,
    JobOfferMem.PassCount AS JobOfferPassCoun,
    -- 휴면 관련
    mem.DormantPeriod,
    CONVERT(CHAR(10), DATEADD(YEAR, mem.DormantPeriod, CASE WHEN loginlog.last_login IS NULL THEN mem.RegDate ELSE loginlog.last_login END), 23) AS DormantExpectDate,
    CASE WHEN (CONVERT(INT, (DATEADD(YEAR, mem.DormantPeriod, CASE WHEN loginlog.last_login IS NULL THEN mem.RegDate ELSE loginlog.last_login END)) - GETDATE())) < 0 THEN NULL ELSE (CONVERT(INT, (DATEADD(YEAR, mem.DormantPeriod, CASE WHEN loginlog.last_login IS NULL THEN mem.RegDate ELSE loginlog.last_login END)) - GETDATE())) END AS DormantDaysToDormant
FROM
    Member AS mem
    LEFT JOIN MemberAdd AS memadd ON mem.MemID = memadd.MemID -- UID 사용 위한 조인
    LEFT JOIN (SELECT MemID, COUNT(*) AS login_count, MIN(LoginTime) AS first_login, MAX(LoginTime) AS last_login FROM JobLog.dbo.MemberLoginLog GROUP BY MemID) AS loginlog ON mem.MemID = loginlog.MemID -- 로그인로그
    LEFT JOIN (
        SELECT
            MemID,
            COUNT(*) AS JobPostingViewCount,
            MIN(RegDate) AS JobPostingViewFirstDate,
            MAX(RegDate) AS JobPostingViewLastDate
        FROM
            JobLog.dbo.RecruitViewLogLog
        WHERE
            MemID IS NOT NULL
        GROUP BY
            MemID
    ) AS JobPostingViewLog ON mem.MemID = JobPostingViewLog.MemID -- 공고 조회로그
    LEFT JOIN (
        SELECT
            MemID,
            COUNT(*) AS InstantApplyJobPostingViewCount,
            MIN(RegDate) AS InstantApplyJobPostingViewFirstDate,
            MAX(RegDate) AS InstantApplyJobPostingViewLastDate
        FROM
            JobLog.dbo.RecruitViewLogLog
        WHERE
            MemID IS NOT NULL
            AND RecruitIDX IN (SELECT DISTINCT RecruitID FROM Application)
        GROUP BY
            MemID
    ) AS InstantApplyJobPostingViewLog ON mem.MemID = InstantApplyJobPostingViewLog.MemID -- 즉시지원 공고 조회로그
    LEFT JOIN (SELECT * FROM MemberEdu memedu LEFT JOIN BaseMajorCodeV2 mcode ON memedu.MajorCode3Dpt = mcode.Code) AS memedu ON mem.MemID = memedu.MemID -- 학력정보
    LEFT JOIN (
        SELECT
            r.*
        FROM
            dbo.ResumeBase AS r
            JOIN dbo.Member AS m ON r.MemID = m.MemID
            JOIN dbo.ResumeMajor AS rm ON rm.MemID = r.MemID AND rm.ResumeID = r.ResumeID
        WHERE
            r.MemDelYN = 'N' AND r.Confirm > 0
    ) AS resume ON mem.memid = resume.memid -- 이력서
    LEFT JOIN (SELECT * FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY MEMID ORDER BY RESUMEID DESC) AS rn FROM ResumePool) AS a WHERE a.rn = 1) AS rp ON resume.ResumeID = rp.ResumeID
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
        FROM
            (
                SELECT
                    ResumeID,
                    CareerID,
                    WorkYear,
                    WorkMonth,
                    SUM(WorkYear) OVER (PARTITION BY resumeid) * 12 + SUM(workmonth) OVER (PARTITION BY resumeid) AS total_work_month,
                    CompID,
                    LEFT(MAX(WorkJob) OVER (PARTITION BY resumeid), 6) AS workcode,
                    ROW_NUMBER() OVER (PARTITION BY ResumeID ORDER BY CareerID DESC) AS count
                FROM
                    ResumeCareer
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
        WHERE
            career.count = 1
    ) AS resumecareer ON resume.ResumeID = resumecareer.ResumeID -- 경력정보
    LEFT JOIN (SELECT ResumeID, COUNT(*) AS langtestcount FROM ResumeLangTest GROUP BY ResumeID) AS langtest ON resume.ResumeID = langtest.ResumeID -- 어학시험
    LEFT JOIN (SELECT ResumeID, COUNT(*) AS license_count FROM ResumeLicense GROUP BY ResumeID) AS license ON resume.ResumeID = license.ResumeID -- 자격증
    LEFT JOIN (SELECT ResumeID, COUNT(*) AS skillcount FROM ResumeSkill GROUP BY ResumeID) AS skill ON resume.ResumeID = skill.ResumeID -- 보유기술
    LEFT JOIN (SELECT ResumeID, COUNT(*) AS awardcount FROM ResumeAward GROUP BY ResumeID) AS award ON resume.ResumeID = award.ResumeID -- 수상내역
    LEFT JOIN (SELECT ResumeID, COUNT(*) AS expcount FROM ResumeSocialExperience GROUP BY ResumeID) AS experience ON resume.ResumeID = experience.ResumeID -- 인턴,대외활동
    LEFT JOIN (
        SELECT
            MemID,
            COUNT(*) AS ApplyCount,
            MIN(ApplyDateTime) AS ApplyFirstDateTime,
            MAX(ApplyDateTime) AS ApplyLastDateTime
        FROM
            Application
        WHERE
            CompID NOT IN ('AF774', 'AC8DD', 'A6562', 'AFF1F', 'A6562', 'EO2193')
        GROUP BY
            MemID
    ) AS applycount ON mem.MemID = applycount.MemID -- 즉시지원 기록
    LEFT JOIN JPDMem AS jpd ON mem.MemID = jpd.MemID -- 카페 관련
    LEFT JOIN JobOfferMem ON mem.MemID = JobOfferMem.MemID;
