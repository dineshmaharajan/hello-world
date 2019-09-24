/* Interest Post Q */

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET NOCOUNT ON 
SET DATEFORMAT DMY

DECLARE @BranchCode CHAR(3),
		@MainCode VARCHAR(20),
		@Today    DATETIME

SELECT	@BranchCode = '011',
		@MainCode = '01100400000671000002' /*Post*/

SELECT @Today = Today FROM ControlTable (NOLOCK);

WITH CTE_IntCalculation
	(BranchCode,AcType,CyCode,MainCode,CalcDate,CalcAmount,CalcOnBaln,TranId)
AS 
	(
	(
	SELECT 
		BranchCode,AcType,CyCode,MainCode,CalcDate,CalcAmount, CalcOnBaln ,TranId
	FROM IntTranDetail I (NOLOCK)
	where BranchCode = '011'
	and  CalcAmount < 0
	AND  MainCode = @MainCode
	UNION ALL
	SELECT 
		BranchCode,AcType,CyCode,MainCode,CalcDate,CalcAmount, CalcOnBaln ,TranId
	FROM IntTranDetail I (NOLOCK)
	where BranchCode = '011'
	and  CalcAmount < 0
	AND  MainCode = @MainCode
	)
)

SELECT I.BranchCode,I.AcType,I.CyCode,I.MainCode,Name, I.CalcDate,I.CalcAmount,I.CalcOnBaln ,TranId
FROM CTE_IntCalculation I, 
Master M (NOLOCK)
WHERE I.BranchCode = M.BranchCode
AND   I.MainCode   = M.MainCode   
AND  M.MainCode = @MainCode

UNION ALL
SELECT 
	BranchCode,AcType,CyCode,'~ProductTotal~', NULL,NULL,  SUM(ISNULL(CalcAmount,0))  CalcAmount, NULL, NULL
FROM IntTranDetail 
where BranchCode = '011'
and  CalcAmount < 0
AND  MainCode = @MainCode
GROUP BY BranchCode,AcType,CyCode

UNION ALL
SELECT 
	'~~','~~',	'~~', '~GrandTotal~', NULL,NULL,  SUM(ISNULL(CalcAmount,0))  CalcAmount, nULL , NULL
FROM IntTranDetail 
where BranchCode = '011'
and  CalcAmount < 0
AND  MainCode = @MainCode
ORDER BY 1,2,3,4

