USE [FIGURA]
GO
/****** Object:  StoredProcedure [dbo].[calc_1_Num_Defined_CRs]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_1_Num_Defined_CRs]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many new CR-s were defined " 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of created CR-s per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(35)  
DECLARE @l_vchParmname       varchar(35)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_1_Num_Defined_CRs ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 001)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT 1 as MetricID, Count(*) as Value, Convert(date, creationDate) as ValueDate, 1 as ValueType, @pSiteID as SiteID 
INTO #TMP
FROM WEBINT..CNF_Accounts ac
WHERE DATEDIFF(day,  creationDate, getdate() ) <= @p_DaysBack
GROUP by Convert(date, creationDate), DATEDIFF(day,  creationDate, getdate() )
Order by ValueDate desc
-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

DROP TABLE #TMP
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_16_Num_Errors_ETL]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_16_Num_Errors_ETL]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many logins" 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of unique logins from today to @p_DaysBack and also will populate list of such login-names
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [calc_20_Num_UniqueLogins] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(35)  
DECLARE @l_vchParmname       varchar(35)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_16_Num_Errors_ETL ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 016)

-----------------------------------------------------------------------------------
-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD ----------
-----------------------------------------------------------------------------------
SELECT 
   16 as MetricID,
   Count(ID) as Value, 
   Convert(date, [timeEnd]) as ValueDate,
   1 as ValueType, 
   @pSiteID as SiteID 
INTO #TMP
FROM 
	[Level1_logs].[dbo].[ETL_Logs]
WHERE 
	(DATEDIFF(day,  timeEnd, getdate() ) <= @p_DaysBack) and
	isError = 1 -- there is an error in that ETL
Group By Convert(date, [timeEnd]) 
Order by ValueDate desc


-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] -----------------------------------------
-----------------------------------------------------------------------------------
	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,  DT);

-----------------------------------------------------------------------------------
-- INSERT RESULTS INTO [dbo].[MetricMultiValues] ----------------------------------
-----------------------------------------------------------------------------------	

	INSERT INTO [dbo].[MetricMultivalues]
	(SiteID,
		MetricID,
		ValueDate,
		ID,
		Value
		) 
	SELECT 
		  @pSiteID,
		  16 ,
		  t.ValueDate,
		 ROW_NUMBER() OVER(PARTITION BY ValueDate ORDER BY Value DESC),	
		 convert(varchar,etl.ErrorCode) + ' - ' + etl.errorMsg as V
		 
	FROM 
		#TMP t INNER JOIN [Level1_logs].[dbo].[ETL_Logs] etl ON convert(date,t.ValueDate) = convert(date, etl.timeEnd)
	WHERE 
		etl.isError = 1
		 
		and convert(varchar,etl.ErrorCode) + ' - ' + etl.errorMsg not in  (SELECT Value FROM MetricMultivalues m WHERE (m.SiteID = @pSiteID) and (m.MetricID = 16) and (t.ValueDate = m.ValueDate))
		


----------------------------------
DROP TABLE #TMP
--DROP TABLE #TMPDISTINCT
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_19_Num_Logins]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_19_Num_Logins]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many logins" 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of Logins (not unique) to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [calc_19_Num_Logins] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(35)  
DECLARE @l_vchParmname       varchar(35)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_19_Num_Logins ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 019)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT 
   19 as MetricID,
   Count([UserID]) as Value, 
   Convert(date, [DateTime]) as ValueDate,
   2 as ValueType, 
   @pSiteID as SiteID 
INTO #TMP
FROM 
	[Xtract].[dbo].[SA_Audit]
WHERE 
	EVENTID in (7) -- Successful login
	and (DATEDIFF(day,  [DateTime], getdate() ) <= @p_DaysBack) 
Group By Convert(date, [DateTime]) 
Order by ValueDate desc

-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ------------------------------------------

		MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

DROP TABLE #TMP
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_2_Num_Scheduled_CRs]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_2_Num_Scheduled_CRs]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: June 9,2015 
* Author: Petar Kenarov
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "Number of CRs scheduled 1" 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of run scheduled CRs per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(36)  
DECLARE @l_vchParmname       varchar(36)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_2_Num_Scheduled_CRs ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 0036)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT
		2 as MetricID,
		Count(distinct a.name) as Value,
		cast(xp.lastUpdateDate as date) as ValueDate,
		2 as ValueType, 
		@pSiteID as SiteID

INTO #TMP

from 
		[WEBINT].[dbo].[XPM_Processes] xp inner join
		[WEBINT].[dbo].[CNF_Accounts] a 
            on xp.targetId=a.id

where   
		executionId=rootExecId 
		and scheduleType='FocalCollect' 
		and origin = (select a.name where xp.targetId=a.id)
		and (DATEDIFF(day,  xp.lastUpdateDate, getdate() ) <= @p_DaysBack)

group by 
		cast(xp.lastUpdateDate as date)

Order By 
        ValueDate desc

-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

-----------------------------------------------------------------------------------
-- INSERT RESULTS INTO [dbo].[MetricMultiValues] ----------------------------------
-----------------------------------------------------------------------------------	

SELECT 
		s.name + ' ' + '-' + ' ' + cast(count(1) as varchar) + ' ' + 'Time(s)' as Value,
		cast(xp.lastUpdateDate as date) as ValueDate

INTO #TMPWF

from 
		[WEBINT].[dbo].[XPM_Processes] xp inner join
		[WEBINT].[dbo].[CNF_Accounts] a 
            on xp.targetId=a.id inner join 
				[WEBINT].[dbo].[cnf_sites] s 
                     on a.siteId=s.id

where   
		executionId=rootExecId 
		and scheduleType='FocalCollect' 
		and origin = (select a.name where xp.targetId=a.id)
		and (DATEDIFF(day,  xp.lastUpdateDate, getdate() ) <= @p_DaysBack)

group by
		s.name, 
		cast(xp.lastUpdateDate as date)

Order By 
        ValueDate desc

	INSERT INTO [dbo].[MetricMultivalues]
	(SiteID,
		MetricID,
		ValueDate,
		ID,
		Value
		) 
	SELECT 
		  @pSiteID,
		  2,
		  twf.ValueDate,
		 ROW_NUMBER() OVER(PARTITION BY ValueDate ORDER BY Value DESC),	
		 twf.Value
		 
	FROM 
		#TMPWF twf 
	WHERE 
		twf.Value not in  (SELECT Value FROM MetricMultivalues m WHERE (m.SiteID = @pSiteID) and (m.MetricID = 2) and (twf.ValueDate = m.ValueDate))
		



DROP TABLE #TMP
DROP TABLE #TMPWF

----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_20_Num_UniqueLogins]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_20_Num_UniqueLogins]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many logins" 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of unique logins from today to @p_DaysBack and also will populate list of such login-names
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [calc_20_Num_UniqueLogins] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(35)  
DECLARE @l_vchParmname       varchar(35)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_20_Num_UniqueLogins ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 020)

-----------------------------------------------------------------------------------
-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD ----------
-----------------------------------------------------------------------------------
	SELECT DISTINCT
	   [UserID] as V, 
	   Convert(date, [DateTime]) as ValueDate
	INTO 
		#TMPDISTINCT
	FROM 
		[Xtract].[dbo].[SA_Audit]
	WHERE 
		EVENTID in (7) -- Successful login 
		and DATEDIFF(day,  [DateTime], getdate() ) <= @p_DaysBack

	Order by ValueDate desc
-----------------------------------------------------------------------------------
	SELECT
	  20 as MetricID,
	  2 as ValueType,
	  @pSiteID as SiteID,
	   ValueDate,	
	   Count(V) as Value
	INTO #TMP
	FROM 
		#TMPDISTINCT
	Group By ValueDate

-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] -----------------------------------------
-----------------------------------------------------------------------------------
	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,  DT);

-----------------------------------------------------------------------------------
-- INSERT RESULTS INTO [dbo].[MetricMultiValues] ----------------------------------
-----------------------------------------------------------------------------------	
	INSERT INTO [dbo].[MetricMultivalues]
		(SiteID,
		 MetricID,
		 ValueDate,
		 ID,
		 Value
		 ) 
	
	SELECT
		  @pSiteID,
		  20 ,
		  ValueDate,
		 ROW_NUMBER() OVER(PARTITION BY ValueDate ORDER BY V DESC),	
		 V
FROM 
	#TMPDISTINCT
WHERE 
	V not in  (SELECT Value FROM MetricMultivalues WHERE (SiteID = @pSiteID) and (MetricID = 20) and (ValueDate = #TMPDISTINCT.ValueDate))

----------------------------------
DROP TABLE #TMP
DROP TABLE #TMPDISTINCT
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_3_Num_Executed_CRs]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_3_Num_Executed_CRs]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: June 9,2015 
* Author: Petar Kenarov
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "Number of CRs scheduled 1" 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of manually run CRs per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(36)  
DECLARE @l_vchParmname       varchar(36)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_3_Num_Executed_CRs ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 0036)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT
		3 as MetricID,
		Count(distinct a.name) as Value,
		cast(xp.lastUpdateDate as date) as ValueDate,
		2 as ValueType, 
		@pSiteID as SiteID

INTO #TMP

from 
		[WEBINT].[dbo].[XPM_Processes] xp inner join
		[WEBINT].[dbo].[CNF_Accounts] a 
            on xp.targetId=a.id

where   
		executionId=rootExecId 
		and scheduleType='FocalCollect' 
		and origin <> (select a.name where xp.targetId=a.id)
		and (DATEDIFF(day,  xp.lastUpdateDate, getdate() ) <= @p_DaysBack)

group by 
		cast(xp.lastUpdateDate as date)

Order By 
        ValueDate desc

-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	
-----------------------------------------------------------------------------------
-- INSERT RESULTS INTO [dbo].[MetricMultiValues] ----------------------------------
-----------------------------------------------------------------------------------	

SELECT 
		s.name + ' ' + '-' + ' ' + cast(count(1) as varchar) + ' ' + 'Time(s)' as Value,
		cast(xp.lastUpdateDate as date) as ValueDate

INTO #TMPWF

from 
		[WEBINT].[dbo].[XPM_Processes] xp inner join
		[WEBINT].[dbo].[CNF_Accounts] a 
            on xp.targetId=a.id inner join 
				[WEBINT].[dbo].[cnf_sites] s 
                     on a.siteId=s.id

where   
		executionId=rootExecId 
		and scheduleType='FocalCollect' 
		and origin <> (select a.name where xp.targetId=a.id)
		and (DATEDIFF(day,  xp.lastUpdateDate, getdate() ) <= @p_DaysBack)

group by
		s.name, 
		cast(xp.lastUpdateDate as date)

Order By 
        ValueDate desc

	INSERT INTO [dbo].[MetricMultivalues]
	(SiteID,
		MetricID,
		ValueDate,
		ID,
		Value
		) 
	SELECT 
		  @pSiteID,
		  3 ,
		  twf.ValueDate,
		 ROW_NUMBER() OVER(PARTITION BY ValueDate ORDER BY Value DESC),	
		 twf.Value
		 
	FROM 
		#TMPWF twf 
	WHERE 
		twf.Value not in  (SELECT Value FROM MetricMultivalues m WHERE (m.SiteID = @pSiteID) and (m.MetricID = 3) and (twf.ValueDate = m.ValueDate))
		



DROP TABLE #TMP
DROP TABLE #TMPWF

----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_33_Most_Problematic_Site]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_33_Most_Problematic_Site]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "Most Problematic Site" 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of fails in Target/Site and the most "failing" will be displayed in FIGURA in format "Today X sites were problematic"
* Drilling down will show list of such sites with mentioning of how many times every one was failing the same day.
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [calc_33_Most_Problematic_Site] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(35)  
DECLARE @l_vchParmname       varchar(35)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_33_Most_Problematic_Site ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 033)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------

-- Get the number of failed sites per day
select
		33 as MetricID,	
		Count(distinct s.name) as Value,
		cast(xp.lastUpdateDate as date) as ValueDate,
		2 as ValueType, 
		@pSiteID as SiteID    
INTO #TMP    
from 
       [WEBINT].[dbo].[XPM_Processes] xp inner join 
              [WEBINT].[dbo].[CNF_Accounts] a 
                     on xp.targetId=a.id 
                                inner join  [WEBINT].[dbo].[cnf_sites] s 
                     on a.siteId=s.id
where   
       executionId=rootExecId 
       and scheduleType='FocalCollect' 
       and xp.hasError=1 
	   and (DATEDIFF(day,  xp.lastUpdateDate, getdate() ) <= @p_DaysBack) 
group by 
       cast(xp.lastUpdateDate as date)
Order By 
          ValueDate desc

-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ------------------------------------------

		MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

-----------------------------------------------------------------------------------
-- INSERT RESULTS INTO [dbo].[MetricMultiValues] ----------------------------------
-----------------------------------------------------------------------------------	

-- Get how many times each site failed per day

select 
       cast(xp.lastUpdateDate as date) as ValueDate,
       s.name + ' ' + '-' + ' ' + cast(count(1) as varchar) + ' ' + 'Time(s)' as Value
INTO #TMPDD
from 
       [WEBINT].[dbo].[XPM_Processes] xp inner join 
              [WEBINT].[dbo].[CNF_Accounts] a 
                     on xp.targetId=a.id 
                                inner join [WEBINT].[dbo].[cnf_sites] s 
                     on a.siteId=s.id
where   
       executionId=rootExecId 
       and scheduleType='FocalCollect' 
       and xp.hasError=1
	   and (DATEDIFF(day,  xp.lastUpdateDate, getdate() ) <= @p_DaysBack) 
group by 
       s.name,
       cast(xp.lastUpdateDate as date)
order by 
       ValueDate desc


--SELECT * FROM #TMPDD



	INSERT INTO [dbo].[MetricMultivalues]
	(SiteID,
		MetricID,
		ValueDate,
		ID,
		Value
		) 
	SELECT 
		  @pSiteID,
		  33 ,
		  tdd.ValueDate,
		 ROW_NUMBER() OVER(PARTITION BY ValueDate ORDER BY Value DESC),	
		 tdd.Value
		 
	FROM 
		#TMPDD tdd 
	WHERE 
		tdd.Value not in  (SELECT Value FROM MetricMultivalues m WHERE (m.SiteID = @pSiteID) and (m.MetricID = 33) and (tdd.ValueDate = m.ValueDate))
		



DROP TABLE #TMP
DROP TABLE #TMPDD

----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_34_Num_New_Entities]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_34_Num_New_Entities]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many new CR-s were defined " 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of created CR-s per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(35)  
DECLARE @l_vchParmname       varchar(35)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_1_Num_Defined_CRs ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 0034)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT 
	34 as MetricID, 
	Count(externalID) as Value, 
	Convert(date, FirstExtracted) as ValueDate, 
	1 as ValueType, 
	@pSiteID as SiteID 
INTO #TMP
FROM WEBINT..WebEntity we
WHERE DATEDIFF(day,  FirstExtracted, getdate() ) <= @p_DaysBack
GROUP by Convert(date, FirstExtracted), DATEDIFF(day,  FirstExtracted, getdate() )
Order by ValueDate desc



-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

DROP TABLE #TMP
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_35_Num_Errors_PL]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_35_Num_Errors_PL]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many logins" 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of unique logins from today to @p_DaysBack and also will populate list of such login-names
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [calc_20_Num_UniqueLogins] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(35)  
DECLARE @l_vchParmname       varchar(35)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_35_Num_Errors_PL ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 016)

-----------------------------------------------------------------------------------
-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD ----------
-----------------------------------------------------------------------------------
SELECT 
   35 as MetricID,
   Count(Sequence) as Value, 
   Convert(date, TimeUtc) as ValueDate,
   1 as ValueType, 
   @pSiteID as SiteID 
INTO #TMP
FROM 
	[FocalAnalytics].[dbo].[ELMAH_Error]
WHERE 
	(DATEDIFF(day,  TimeUtc, getdate() ) <= @p_DaysBack) 
	
Group By Convert(date, TimeUtc) 
Order by ValueDate desc


-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] -----------------------------------------
-----------------------------------------------------------------------------------
	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,  DT);

-----------------------------------------------------------------------------------
-- INSERT RESULTS INTO [dbo].[MetricMultiValues] ----------------------------------
-----------------------------------------------------------------------------------	

	INSERT INTO [dbo].[MetricMultivalues]
	(SiteID,
		MetricID,
		ValueDate,
		ID,
		Value
		) 
	SELECT 
		  @pSiteID,
		  35 ,
		  t.ValueDate,
		 ROW_NUMBER() OVER(PARTITION BY ValueDate ORDER BY Value DESC),	
		 pl.Sequence   
		 
	FROM 
		
		#TMP t INNER JOIN (SELECT Sequence, [TimeUtc], convert(date, [TimeUtc]) as converteddate from [FocalAnalytics].[dbo].[ELMAH_Error]) pl 
		ON t.ValueDate =  pl.converteddate
	WHERE 
		pl.Sequence   not in  (SELECT Value FROM MetricMultivalues m WHERE (m.SiteID = 11) and (m.MetricID = 16) and (t.ValueDate = m.ValueDate))
		

----------------------------------
DROP TABLE #TMP
--DROP TABLE #TMPDISTINCT
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_36_Num_New_Images]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_36_Num_New_Images]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many new CR-s were defined " 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of created CR-s per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(36)  
DECLARE @l_vchParmname       varchar(36)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_36_Num_New_Images ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 0036)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT 
	36 as MetricID, 
	Count(externalID) as Value, 
	Convert(date, FirstExtracted) as ValueDate, 
	1 as ValueType, 
	@pSiteID as SiteID 
INTO #TMP
FROM WEBINT..Images we
WHERE DATEDIFF(day,  FirstExtracted, getdate() ) <= @p_DaysBack
GROUP by Convert(date, FirstExtracted), DATEDIFF(day,  FirstExtracted, getdate() )
Order by ValueDate desc



-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

DROP TABLE #TMP
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_37_Num_New_Comments]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create   PROCEDURE [dbo].[calc_37_Num_New_Comments]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many new CR-s were defined " 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of created CR-s per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(37)  
DECLARE @l_vchParmname       varchar(37)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_37_Num_New_Comments ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 0037)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT 
	37 as MetricID, 
	Count(externalID) as Value, 
	Convert(date, FirstExtracted) as ValueDate, 
	1 as ValueType, 
	@pSiteID as SiteID 
INTO #TMP
FROM WEBINT..Comments we
WHERE DATEDIFF(day,  FirstExtracted, getdate() ) <= @p_DaysBack
GROUP by Convert(date, FirstExtracted), DATEDIFF(day,  FirstExtracted, getdate() )
Order by ValueDate desc



-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

DROP TABLE #TMP
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_38_Num_New_Topics]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create   PROCEDURE [dbo].[calc_38_Num_New_Topics]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many new CR-s were defined " 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of created CR-s per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(38)  
DECLARE @l_vchParmname       varchar(38)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_38_Num_New_Topics ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 0038)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT 
	38 as MetricID, 
	Count(externalID) as Value, 
	Convert(date, FirstExtracted) as ValueDate, 
	1 as ValueType, 
	@pSiteID as SiteID 
INTO #TMP
FROM WEBINT..Topics we
WHERE DATEDIFF(day,  FirstExtracted, getdate() ) <= @p_DaysBack
GROUP by Convert(date, FirstExtracted), DATEDIFF(day,  FirstExtracted, getdate() )
Order by ValueDate desc



-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

DROP TABLE #TMP
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_39_Num_New_Albums]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create   PROCEDURE [dbo].[calc_39_Num_New_Albums]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many new CR-s were defined " 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of created CR-s per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(39)  
DECLARE @l_vchParmname       varchar(39)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_39_Num_New_Albums ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 0039)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT 
	39 as MetricID, 
	Count(externalID) as Value, 
	Convert(date, FirstExtracted) as ValueDate, 
	1 as ValueType, 
	@pSiteID as SiteID 
INTO #TMP
FROM WEBINT..Albums we
WHERE DATEDIFF(day,  FirstExtracted, getdate() ) <= @p_DaysBack
GROUP by Convert(date, FirstExtracted), DATEDIFF(day,  FirstExtracted, getdate() )
Order by ValueDate desc



-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

DROP TABLE #TMP
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_40_Num_New_Relations]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_40_Num_New_Relations]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many new CR-s were defined " 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of created CR-s per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(40)  
DECLARE @l_vchParmname       varchar(40)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_40_Num_New_Relations ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 0040)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT 
	40 as MetricID, 
	Count(externalID) as Value, 
	Convert(date, FirstExtracted) as ValueDate, 
	1 as ValueType, 
	@pSiteID as SiteID 
INTO #TMP
FROM WEBINT..Videos we
WHERE DATEDIFF(day,  FirstExtracted, getdate() ) <= @p_DaysBack
GROUP by Convert(date, FirstExtracted), DATEDIFF(day,  FirstExtracted, getdate() )
Order by ValueDate desc



-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

DROP TABLE #TMP
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_41_Num_New_Videos]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_41_Num_New_Videos]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many new CR-s were defined " 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of created CR-s per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(41)  
DECLARE @l_vchParmname       varchar(41)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_41_Num_New_Videos ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 0041)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT 
	41 as MetricID, 
	Count(ExecutionID) as Value, 
	Convert(date, FirstExtracted) as ValueDate, 
	1 as ValueType, 
	@pSiteID as SiteID 
INTO #TMP
FROM WEBINT..Relations we
WHERE DATEDIFF(day,  FirstExtracted, getdate() ) <= @p_DaysBack
GROUP by Convert(date, FirstExtracted), DATEDIFF(day,  FirstExtracted, getdate() )
Order by ValueDate desc



-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

DROP TABLE #TMP
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_42_Num_New_Addresses]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create   PROCEDURE [dbo].[calc_42_Num_New_Addresses]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many new CR-s were defined " 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of created CR-s per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(42)  
DECLARE @l_vchParmname       varchar(42)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_42_Num_New_Addresses ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 0042)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT 
	42 as MetricID, 
	Count(ExecutionID) as Value, 
	Convert(date, FirstExtracted) as ValueDate, 
	1 as ValueType, 
	@pSiteID as SiteID 
INTO #TMP
FROM WEBINT..Address we
WHERE DATEDIFF(day,  FirstExtracted, getdate() ) <= @p_DaysBack
GROUP by Convert(date, FirstExtracted), DATEDIFF(day,  FirstExtracted, getdate() )
Order by ValueDate desc



-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

DROP TABLE #TMP
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_43_VA_Locked]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_43_VA_Locked]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: Sept 25,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How manyLocked VA-s " 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of created CR-s per day from today to @p_DaysBack 
* The last value for that metric will be overritten in any case (maybe some new CR-s were created after it was executed last time)
* If overlap is more than one day - the rest will be recalculated only if @p_Overwrite is 1
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(42)  
DECLARE @l_vchParmname       varchar(42)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_43_VA_Locked ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 0042)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------
SELECT 
	43 as MetricID, 
	Count(ID) as Value, 
	Convert(date, lastUpdated) as ValueDate, 
	1 as ValueType, 
	@pSiteID as SiteID 
INTO #TMP
FROM 
	WEBINT..CNF_Logins lg
WHERE 
	DATEDIFF(day,  lastUpdated, getdate() ) <= @p_DaysBack
	and Status is not null
GROUP by Convert(date, lastUpdated), DATEDIFF(day,  lastUpdated, getdate() )
Order by ValueDate desc



-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ----------------------------------------------------------------------------

	MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	
-----------------------------------------------------------------------------------
-- INSERT RESULTS INTO [dbo].[MetricMultiValues] ----------------------------------
-----------------------------------------------------------------------------------	

	INSERT INTO [dbo].[MetricMultivalues]
	(SiteID,
		MetricID,
		ValueDate,
		ID,
		Value
		) 
	SELECT 
		@pSiteID,
		43, 
		CONVERT(DATE, lg.lastUpdated) as LUD,
		ROW_NUMBER() OVER(PARTITION BY CONVERT(DATE, lg.lastUpdated) ORDER BY lg.userName + ' --> ' + lg.status DESC),	
		lg.userName + ' --> ' + lg.status as ST
		 
	FROM 
		WEBINT..CNF_Logins lg
	WHERE
		DATEDIFF(day,  lastUpdated, getdate() ) <= @p_DaysBack
		and  (lg.userName + ' --> ' + lg.status) != (lg.userName + ' --> ')

DROP TABLE #TMP
----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[calc_6_Different_WebFlows_Used]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[calc_6_Different_WebFlows_Used]   
						@p_DaysBack int, 
						@pSiteID int
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: March 5,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate metric "How many different WF-s were used" 
*
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

* It will calculate number of Web Flows run today and its name(s) will be shown as a list in format "Web Flow name - Number of runs".
* Drilling down will show list of Web Flows run the same day.
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [calc_6_Different_WebFlows_Used] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(35)  
DECLARE @l_vchParmname       varchar(35)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('calc_6_Different_WebFlows_Used ('  + 	CAST(@p_DaysBack as varchar) + ', ' +  ', ' + CAST(@pSiteID as varchar) + ') started', 06)

-- POPULATE TEMPORARY TABLE WITH ALL POSSIBLE RESULTS FOR A GIVEN PERIOD --------------------------------------------

-- Get number of used WFs per day
select
		6 as MetricID,
		Count(distinct r.name) as Value,
        cast(xp.lastUpdateDate as date) as ValueDate,
		2 as ValueType, 
		@pSiteID as SiteID    
INTO #TMP
         
from 
       [WEBINT].[dbo].[XPM_Processes] xp inner join 
              [WEBINT].[dbo].[CNF_Accounts] a 
                     on xp.targetId=a.id 
                                inner join [WEBINT].[dbo].[cnf_sites] s 
                     on a.siteId=s.id inner join [WEBINT].[dbo].[CNF_SitesRobots] sr
							on s.id = sr.siteId inner join [WEBINT].[dbo].[CNF_Robots] r
							on sr.robotId = r.Id
where   
       executionId=rootExecId 
       and scheduleType='FocalCollect'
	   and (DATEDIFF(day,  xp.lastUpdateDate, getdate() ) <= @p_DaysBack) 

group by 
       cast(xp.lastUpdateDate as date)

Order By 
          ValueDate desc



-----------------------------------------------------------------------------------
-- MERGE RESULTS INTO [dbo].[MainResults] ------------------------------------------

		MERGE [dbo].[MainResults]  as dst
	USING
	(
		SELECT  MetricID,   ValueDate, Value,  ValueType,  SiteID, getdate() as DT 
		FROM #TMP t
		
	) AS src ( MetricID,   ValueDate, Value,  ValueType,  SiteID, DT )
	--ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate))
	ON ((dst.MetricID = src.MetricID) and (src.ValueDate = dst.ValueDate) and (src.SiteID = dst.SiteID))
	WHEN MATCHED
		THEN UPDATE SET dst.Value = src.Value
	WHEN  NOT MATCHED
		THEN INSERT VALUES ( SiteID, MetricID, ValueDate, Value,    ValueType,   DT);
	

-----------------------------------------------------------------------------------
-- INSERT RESULTS INTO [dbo].[MetricMultiValues] ----------------------------------
-----------------------------------------------------------------------------------	

-- List of WF that were running today
select 
		r.name + ' ' + '-' + ' ' + cast(count(1) as varchar) + ' ' + 'Time(s)' as Value,
		cast(xp.lastUpdateDate as date) as ValueDate
INTO #TMPWF
from 
       [WEBINT].[dbo].[XPM_Processes] xp inner join 
              [WEBINT].[dbo].[CNF_Accounts] a 
                     on xp.targetId=a.id 
                                inner join [WEBINT].[dbo].[cnf_sites] s 
                     on a.siteId=s.id inner join [WEBINT].[dbo].[CNF_SitesRobots] sr
							on s.id = sr.siteId inner join [WEBINT].[dbo].[CNF_Robots] r
							on sr.robotId = r.Id
where   
       executionId=rootExecId 
       and scheduleType='FocalCollect'
	   and (DATEDIFF(day,  xp.lastUpdateDate, getdate() ) <= @p_DaysBack)  

group by 
       r.name,
	   cast(xp.lastUpdateDate as date)
order by 
       ValueDate desc


	INSERT INTO [dbo].[MetricMultivalues]
	(SiteID,
		MetricID,
		ValueDate,
		ID,
		Value
		) 
	SELECT 
		  @pSiteID,
		  6 ,
		  twf.ValueDate,
		 ROW_NUMBER() OVER(PARTITION BY ValueDate ORDER BY Value DESC),	
		 twf.Value
		 
	FROM 
		#TMPWF twf 
	WHERE 
		twf.Value not in  (SELECT Value FROM MetricMultivalues m WHERE (m.SiteID = @pSiteID) and (m.MetricID = 6) and (twf.ValueDate = m.ValueDate))
		



DROP TABLE #TMP
DROP TABLE #TMPWF

----------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[CalculateMetrics]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[CalculateMetrics]  
						@p_DaysBack int, 
						@p_SiteID int
						
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: February 26,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Calculate all active metrics according to given parameters
* Parameters:  
* IN:  
*	@p_DaysBack - How many months back should be considered
	

	Procedure will calculate for every 24 hours days metrics in between of given time period (@p_MonthBack)
	
*  
* Return:  
* 0 - success  
* -1 - failure   

 TEST: exec  [CalculateMetrics] 2, 0
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(35)  
DECLARE @l_vchParmname       varchar(35)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)

  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
DECLARE @pSiteID int
--------------------------------------------------------
-- CLEAR DATA --
truncate table [dbo].[MainResults]
truncate table [dbo].[MetricMultivalues]

-- MAIN PART -------------------------------------------
SET @pSiteID = @p_SiteID --(Select TOP 1 SiteID from luCustomerSites WHERE IsCurrent = 1)
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('CalculateMetrics started', 90001)

DECLARE @RelevantMetrics CURSOR
SET @RelevantMetrics = CURSOR FAST_FORWARD
FOR
		Select 
			MetricID,
			HandlerName  
		From 
			Metrics 
		Where 
			IsEnabled = 1

OPEN @RelevantMetrics
FETCH NEXT FROM @RelevantMetrics
INTO @fMetricID,@fHandlerName

WHILE @@FETCH_STATUS = 0
	BEGIN
			
		set @SPName = @fHandlerName + ' ' + 	CAST(@p_DaysBack as varchar) + ', '  + CAST(@pSiteID as varchar) 
		
		BEGIN TRY				
			EXEC (@SPName)
			--SELECT @SPName
			--INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES(@SPName, 103)
		END TRY
		BEGIN CATCH
			INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('SP ' + @fHandlerName + ' - ' + ERROR_MESSAGE(), 666)
		END CATCH
 
		FETCH NEXT FROM @RelevantMetrics
		INTO @fMetricID,@fHandlerName
	END
CLOSE @RelevantMetrics
DEALLOCATE @RelevantMetrics
-------------------------------------------------
COMMIT TRAN 
INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES('CalculateMetrics ended', 90009)
END TRY

BEGIN CATCH
	

    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage
		INSERT INTO ExecutionLog (Message, ExceptionCode) VALUES(@l_vchMessage	, 9999999)
	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode





GO
/****** Object:  StoredProcedure [dbo].[GetMultivalues]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Valentin
-- Create date: March 17, 2015

-- =============================================
CREATE PROCEDURE [dbo].[GetMultivalues]
	@pYear int,
	@pMetricID int,
	@pMonth int,
	@pDay int,
	@pSiteID int
	
AS
BEGIN
	SELECT DISTINCT
		Value
	FROM
		[dbo].[MetricMultivalues] mv
	WHERE
			mv.SiteID = @pSiteID
		and mv.MetricID = @pMetricID
		and MONTH(mv.ValueDate) = @pMonth
		and YEAR(mv.ValueDate) = @pYear 
		and DAY(mv.ValueDate) = @pDay
END









GO
/****** Object:  StoredProcedure [dbo].[PivotedResults]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Valentin
-- Create date: March 17, 2015

-- =============================================
CREATE PROCEDURE [dbo].[PivotedResults]
	@pYear int,
	@pMonth int,
	@pSiteID int
AS
BEGIN
	-- SET NOCOUNT ON acDed to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

------ SUCH EXPRESSION SHOULDS BE CREATED ------------------

------------------------------------------------------------



DECLARE @columns VARCHAR(MAX)
DECLARE @headers VARCHAR(MAX)
DECLARE @lowdate Date 
DECLARE @highdate Date

SELECT 
	@columns = COALESCE(@columns + ',[' + cast(cD as varchar) + ']', '[' + cast(cD as varchar)+ ']')
FROM 
	ShortReport
WHERE 
	cY = @pYear and
	cM = @pMonth 
GROUP BY 
	cD


DECLARE @query VARCHAR(8000)



SET @query = '
SELECT * FROM  (SELECT Name as [Metric Name], MetricID as [Metric ID], DisplayType as [Detailes], Minthreshold as [Min], Maxthreshold as [Max], cD, Value FROM ShortReport WHERE cY = ' + cast(@pYear as varchar) + ' and cM = ' + cast(@pMonth as varchar) + ' and SiteID = ' + cast(@pSiteID as varchar) + ' )  as s
	PIVOT
	(
		SUM(Value)
		FOR [cD]
		IN (' + @columns + ')
	)AS p '


EXECUTE(@query)



	--select @query

END








GO
/****** Object:  StoredProcedure [dbo].[PivotedResultsOrdered]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Valentin
-- Create date: March 17, 2015

-- =============================================
CREATE PROCEDURE [dbo].[PivotedResultsOrdered]
	@pYear int,
	@pMonth int,
	@pSiteID int
AS
BEGIN
	-- SET NOCOUNT ON acDed to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

------ SUCH EXPRESSION SHOULDS BE CREATED ------------------

------------------------------------------------------------



DECLARE @columns VARCHAR(MAX)
DECLARE @headers VARCHAR(MAX)
DECLARE @lowdate Date 
DECLARE @highdate Date

SELECT 
	@columns = COALESCE(@columns + ',[' + cast(cD as varchar) + ']', '[' + cast(cD as varchar)+ ']')
FROM 
	ShortReport
WHERE 
	cY = @pYear and
	cM = @pMonth 
GROUP BY 
	cD


DECLARE @query VARCHAR(8000)



SET @query = '
SELECT * FROM  (SELECT TOP 10000  OrderID, MetricID as [Metric ID], DisplayType as [Detailes],  Name as [Metric Name], Minthreshold as [Min], Maxthreshold as [Max], cD, Value FROM ShortReport WHERE cY = ' + cast(@pYear as varchar) + ' and cM = ' + cast(@pMonth as varchar) + ' and SiteID = ' + cast(@pSiteID as varchar) + ' ORDER BY OrderID)  as s
	PIVOT
	(
		SUM(Value)
		FOR [cD]
		IN (' + @columns + ')
	)AS p '

	--select @query
EXECUTE(@query)





END








GO
/****** Object:  StoredProcedure [dbo].[PS_RegisterAgents]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[PS_RegisterAgents]   
	 @pSiteName varchar(50)
						
						    
/************************************************************************  
* CMS  
*  
* Database Environment: SQL Server 2012 
* Name: CalculateMetrics  
* Created: Aug 11,2015 
* Author: Valentin Rubenchik
* History-  
*  
* Modified:   
* By:   
*  
* Description:  
*  Register bulk of V.Agents and assign them to "Site"" 
*
* Parameters:  
* IN:  @pSiteName - Name Of the site 
*	
	

* SP gets as input table tmpAgents with the following fields:
1) Login name
2) Password
3) Proxy IP

	
*  
* Return:  
* 0 - success  
* -1 - failure   



 TEST: exec  PS_RegisterAgents NewSite
 
*************************************************************************/  
AS  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON  
  
-- ============ Declarations section ============  
-- Standard variables  
DECLARE @l_vchProcname       varchar(35)  
DECLARE @l_vchParmname       varchar(35)  
DECLARE @l_vchTablename      varchar(255)  
DECLARE @l_vchMessage        varchar(255)  
DECLARE @l_intError          int
DECLARE @l_intRowcount       int
DECLARE @l_intRtrncode       int
DECLARE @l_intErrnum         int
DECLARE @l_intSqlstatus      int
DECLARE @l_intSuccess        int
DECLARE @l_intFail           int
DECLARE @l_intNTFND          int
DECLARE @l_dtmCurrentDate datetime
DECLARE @l_vchServerName varchar(255)
  
------------------------------------------------- 
-- Local variables

------------------------------------------------- 
-- Initialize standard variables  
SELECT @l_vchProcname = OBJECT_NAME(@@procid)
SELECT @l_intError = 0, @l_intRtrncode = 0, @l_intRowcount = 0, @l_intSqlstatus = 0
SELECT @l_intSuccess = 0, @l_intFail = -1, @l_intNTFND = 100
SELECT @l_dtmCurrentDate = GETDATE()
SELECT @l_vchServerName = @@SERVERNAME

-------------------------------------------------
BEGIN TRY

	--SET ROWCOUNT @p_intChunkSize
	
-------------------------------------------------
-- Find next available
	BEGIN TRAN 
------------------------------

DECLARE @fMetricID int
DECLARE @fHandlerName varchar(100)
DECLARE @SPName VARCHAR(100)  
--------------------------------------------------------
-- MAIN PART -------------------------------------------

if
(SELECT COUNT(1) from [Webint].[dbo].[CNF_Sites] s WHERE s.name = @pSiteName) > 0

BEGIN

	
-- (1) ------------------ Register Proxies -------------
	INSERT INTO 
		[Webint].[dbo].[CNF_Proxies] 
		(
			ip, 
			country
			
		)
	SELECT
		[Proxy],
		'NA'
		
	FROM
		[dbo].[tmpAgents] a

	WHERE NOT EXISTS
	(
		SELECT * FROM [Webint].[dbo].[CNF_Proxies] 
		WHERE ip = a.Proxy
	)

	-- (2) ------------------ Register Agents  -------------

	INSERT INTO 
		[Webint].[dbo].[CNF_Logins] 
		(
			Name,
			password,
			proxy,
			siteId,
			userName,
			description
		)
	SELECT
		LoginName,
		Password,
		(SELECT MIN(id) from [Webint].[dbo].[CNF_Proxies] WHERE ip = a.Proxy),
		(SELECT id from [Webint].[dbo].[CNF_Sites] s WHERE s.name = @pSiteName),
		LoginName,
		Password
	FROM
		[dbo].[tmpAgents] a	

END
	ELSE 
		SELECT 'WRONG SITE NAME'
--------------------------------------------------------

COMMIT TRAN 

END TRY

BEGIN CATCH
    SELECT 
        @l_intRtrncode = @l_intFail,
		@l_intErrnum = ERROR_NUMBER(),
		@l_vchMessage = ERROR_MESSAGE()		
		
	SELECT
		@l_vchMessage = @l_vchProcname + ' error ' + CONVERT( varchar(9), @l_intErrnum ) + ': ' + @l_vchMessage

	IF @@TRANCOUNT > 0 -- Uncompleted transaction in the database
		ROLLBACK TRAN

	RAISERROR (@l_vchMessage,16,1)  

END CATCH

RETURN @l_intRtrncode






GO
/****** Object:  Table [dbo].[ExecutionLog]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExecutionLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TS] [datetime] NOT NULL,
	[Message] [varchar](500) NOT NULL,
	[ExceptionCode] [int] NULL,
 CONSTRAINT [PK_ExecutionLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[luCustomerSites]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[luCustomerSites](
	[SiteID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[IsCurrent] [int] NOT NULL,
	[IsLocal] [int] NOT NULL,
	[ConStr] [varchar](255) NULL,
 CONSTRAINT [PK_luCustomerSites] PRIMARY KEY CLUSTERED 
(
	[SiteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MainResults]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MainResults](
	[SiteID] [int] NOT NULL,
	[MetricID] [int] NOT NULL,
	[ValueDate] [date] NOT NULL,
	[Value] [int] NULL,
	[ValueType] [int] NULL,
	[DT] [datetime] NOT NULL,
 CONSTRAINT [PK_MainLog] PRIMARY KEY CLUSTERED 
(
	[SiteID] ASC,
	[MetricID] ASC,
	[ValueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MetricMultivalues]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MetricMultivalues](
	[SiteID] [int] NOT NULL,
	[MetricID] [int] NOT NULL,
	[ValueDate] [date] NOT NULL,
	[ID] [int] NOT NULL,
	[Value] [varchar](500) NOT NULL,
	[Note] [varbinary](255) NULL,
 CONSTRAINT [PK_MetricMultivalues] PRIMARY KEY CLUSTERED 
(
	[SiteID] ASC,
	[MetricID] ASC,
	[ValueDate] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Metrics]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Metrics](
	[MetricID] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[Description] [varchar](255) NULL,
	[MetricTypeID] [int] NOT NULL,
	[MinThreshold] [int] NULL,
	[MaxThreshold] [int] NULL,
	[HandlerName] [varchar](100) NULL,
	[IsEnabled] [int] NULL,
	[DisplayType] [int] NULL,
	[OrderID] [int] NOT NULL,
 CONSTRAINT [PK_Metrics] PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MetricTypes]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MetricTypes](
	[MetricTypeID] [int] NOT NULL,
	[MetricType] [varchar](50) NULL,
 CONSTRAINT [PK_MetricTypes] PRIMARY KEY CLUSTERED 
(
	[MetricTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[ShortReport]    Script Date: 10/7/2015 4:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ShortReport]
AS
SELECT        TOP (100) PERCENT m.Name, m.DisplayType, m.MinThreshold, m.MaxThreshold, CONVERT(VARCHAR(10), mr.ValueDate, 103) AS cDate, MAX(mr.Value) AS Value, 
                         MAX(YEAR(mr.ValueDate)) AS cY, MAX(MONTH(mr.ValueDate)) AS cM, MAX(DAY(mr.ValueDate)) AS cD, CAST(mr.ValueDate AS varchar) AS FullDate, mr.SiteID, 
                         mr.MetricID, m.OrderID
FROM            dbo.MainResults AS mr INNER JOIN
                         dbo.Metrics AS m ON mr.MetricID = m.MetricID
GROUP BY m.Name, CONVERT(VARCHAR(10), mr.ValueDate, 103), CAST(mr.ValueDate AS varchar), m.MinThreshold, m.MaxThreshold, m.DisplayType, mr.SiteID, mr.MetricID, 
                         m.OrderID
ORDER BY m.OrderID, m.Name, cY, cM, cD



GO
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (1, N'MANU', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (2, N'SACI', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (3, N'WHITE MONTANA', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (4, N'LILAC', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (5, N'BERKUT', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (6, N'ATZTEC', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (7, N'NAHUA', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (8, N'PICHINCHA', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (9, N'SIBELIUS', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (10, N'SNOWCAP', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (11, N'OSPRAY', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (12, N'GEFEN', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (13, N'ALVORADA', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (14, N'LABERINTO', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (15, N'NORMANDIE', 0, 0, NULL)
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (17, N'DEV2', 0, 1, N'Data Source=10.161.52.247;Initial Catalog=FIGURA;User ID=sa;Password=Rel7.xPass!')
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (21, N'PS2', 0, 1, N'Data Source=10.161.149.104;Initial Catalog=FIGURA;User ID=sa;Password=Rel1.xPass!')
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (25, N'QA', 0, 1, N'Data Source=10.161.144.94;Initial Catalog=FIGURA;User ID=sa;Password=Rel5.xPass!')
INSERT [dbo].[luCustomerSites] ([SiteID], [Name], [IsCurrent], [IsLocal], [ConStr]) VALUES (26, N'PS3', 1, 1, N'Data Source=10.161.58.86;Initial Catalog=FIGURA;User ID=sa;Password=xtract1!')
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (1, N'How many new CR-s were defined ', N'', 1, 3, 2, N'calc_1_Num_Defined_CRs', 1, 1, 3)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (2, N'Number of CRs scheduled', N'`', 1, 20, 100, N'calc_2_Num_Scheduled_CRs', 1, 2, 2)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (3, N'How many CR-s (“run now”))', N'', 1, 20, 100, N'calc_3_Num_Executed_CRs', 1, 2, 1)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (4, N'Number of collected  Records ', N'', 1, 3, 5, N'', 0, 1, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (5, N'Total number of Results in FocalAnalytics', N'(accumulated)', 1, 3, 5, N'', 0, 1, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (6, N'How many different WF-s were used ', N'', 1, 3, 18, N'calc_6_Different_WebFlows_Used', 1, 2, 4)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (7, N'Which sites have been used today? (counter per site)', N'', 1, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (8, N'How many Persons created', N'', 1, 3, 100, N'', 0, 1, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (9, N'How many Cases created ', N'', 1, 3, 100, N'', 0, 1, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (10, N'How many ontologies created ', N'', 1, 3, 100, N'', 0, 1, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (11, N'How many attachments to Person created ', N'', 1, 3, 500, N'', 0, 1, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (12, N'How many Person attachments to Case created ', N'', 1, 3, 500, N'', 0, 1, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (13, N'Number of blocked agents', N'', 2, 3, 5, N'', 0, 1, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (14, N'Number of Errors in the Execution Report', N'', 2, 3, 5, N'', 0, 1, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (15, N'How many blocked users ', N'', 2, 3, 5, N'', 0, 1, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (16, N'Number of errors in ETL DB logs', N'', 2, 3, 5, N'calc_16_Num_Errors_ETL', 1, 2, 5)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (17, N'Top 10 ETL errors from today (+ counter)', N'', 2, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (18, N'Number of defected rows per site', N'', 2, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (19, N'How many logins ', N'', 3, 3, 19, N'calc_19_Num_Logins', 1, 1, 6)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (20, N'How many unique logins ', N'', 3, 3, 20, N'calc_20_Num_UniqueLogins', 1, 2, 7)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (21, N'How many users are defined', N'', 3, 3, 5, N'calc_21_Num_Defined_Users', 0, 1, 8)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (22, N'How many open tabs exist per user?', N'', 3, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (23, N'How many User Agents are used in more than one site', N'', 4, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (24, N'How many CR-s use concrete User Agent', N'', 4, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (25, N'Average CR execution time ', N'', 4, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (26, N'Min CR execution time', N'', 4, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (27, N'Max CR execution time', N'', 4, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (28, N'Average number of collected records', N'', 4, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (29, N'Min number of collected records', N'', 4, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (30, N'Max number of collected records', N'', 4, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (31, N'Number of runs per site', N'', 4, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (32, N'Number of usage per VAgent', N'', 4, 3, 5, N'', 0, 2, 0)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (33, N'Most problematic site(s)', N'', 4, 3, 3, N'calc_33_Most_Problematic_Site', 1, 2, 9)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (34, N'How many new Entities ', NULL, 1, 3, 500000, N'calc_34_Num_New_Entities', 1, 1, 10)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (35, N'How many errors in in PL', NULL, 1, 3, 20, N'calc_35_Num_Errors_PL', 0, 2, 11)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (36, N'How many new Images', NULL, 1, 0, 500000, N'calc_36_Num_New_Images', 1, 1, 12)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (37, N'How many new Comments', NULL, 1, 0, 500000, N'calc_37_Num_New_Comments', 1, 1, 13)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (38, N'How many new Topics', NULL, 1, 0, 500000, N'calc_38_Num_New_Topics', 1, 1, 14)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (39, N'How many new Albums', NULL, 1, 0, 500000, N'calc_39_Num_New_Albums', 1, 1, 15)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (40, N'How many new Videos', NULL, 1, 0, 500000, N'calc_40_Num_New_Relations', 1, 1, 16)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (41, N'How many new Relations', NULL, 1, 0, 500000, N'calc_41_Num_New_Videos', 1, 1, 17)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (42, N'How many new Addresses', NULL, 1, 0, 500000, N'calc_42_Num_New_Addresses', 1, 1, 18)
INSERT [dbo].[Metrics] ([MetricID], [Name], [Description], [MetricTypeID], [MinThreshold], [MaxThreshold], [HandlerName], [IsEnabled], [DisplayType], [OrderID]) VALUES (43, N'Problematic VA-s', NULL, 1, 0, 2, N'calc_43_VA_Locked', 1, 2, 19)
INSERT [dbo].[MetricTypes] ([MetricTypeID], [MetricType]) VALUES (1, N'Usage Statistics')
INSERT [dbo].[MetricTypes] ([MetricTypeID], [MetricType]) VALUES (2, N'Statistics of Errors')
INSERT [dbo].[MetricTypes] ([MetricTypeID], [MetricType]) VALUES (3, N'Users Statistics')
INSERT [dbo].[MetricTypes] ([MetricTypeID], [MetricType]) VALUES (4, N'Wrong Usage/Configuration')
ALTER TABLE [dbo].[ExecutionLog] ADD  CONSTRAINT [DF_ExecutionLog_TS]  DEFAULT (getdate()) FOR [TS]
GO
ALTER TABLE [dbo].[luCustomerSites] ADD  CONSTRAINT [DF_luCustomerSites_IsCurrent]  DEFAULT ((0)) FOR [IsCurrent]
GO
ALTER TABLE [dbo].[luCustomerSites] ADD  CONSTRAINT [DF_luCustomerSites_IsLocal]  DEFAULT ((0)) FOR [IsLocal]
GO
ALTER TABLE [dbo].[MainResults] ADD  CONSTRAINT [DF_MainResults_DT]  DEFAULT (getdate()) FOR [DT]
GO
ALTER TABLE [dbo].[Metrics] ADD  CONSTRAINT [DF_Metrics_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[MainResults]  WITH CHECK ADD  CONSTRAINT [FK_MainLog_Metrics] FOREIGN KEY([MetricID])
REFERENCES [dbo].[Metrics] ([MetricID])
GO
ALTER TABLE [dbo].[MainResults] CHECK CONSTRAINT [FK_MainLog_Metrics]
GO
ALTER TABLE [dbo].[Metrics]  WITH CHECK ADD  CONSTRAINT [FK_Metrics_MetricTypes] FOREIGN KEY([MetricTypeID])
REFERENCES [dbo].[MetricTypes] ([MetricTypeID])
GO
ALTER TABLE [dbo].[Metrics] CHECK CONSTRAINT [FK_Metrics_MetricTypes]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[26] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "mr"
            Begin Extent = 
               Top = 29
               Left = 50
               Bottom = 223
               Right = 318
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "m"
            Begin Extent = 
               Top = 75
               Left = 708
               Bottom = 325
               Right = 894
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 13
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ShortReport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ShortReport'
GO
