﻿<%Response.Expires=-1%>
<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"--><%
If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
thesisID=Request.Form("tid")
hash=Request.Form("hash")
delete_type=Request.Form("delete_type")
teachtype_id=Request.Form("In_TEACHTYPE_ID2")
class_id=Request.Form("In_CLASS_ID2")
enter_year=Request.Form("In_ENTER_YEAR2")
query_task_progress=Request.Form("In_TASK_PROGRESS2")
query_review_status=Request.Form("In_REVIEW_STATUS2")
finalFilter=Request.Form("finalFilter2")
pageSize=Request.Form("pageSize2")
pageNo=Request.Form("pageNo2")
If Len(thesisID)=0 Or Not IsNumeric(thesisID) Or Len(hash)=0 Or Len(delete_type)=0 Or Not IsNumeric(delete_type) Or Not (delete_type=0 Or delete_type=1) Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数无效。</font><br/><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Dim conn,rs,sql,count
Connect conn
sql="SELECT THESIS_FILE,REPRODUCTION_RATIO,DETECT_REPORT FROM Dissertations WHERE ID="&thesisID
GetRecordSet conn,rs,sql,count
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">数据库没有该论文记录！</font><br/><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
  CloseRs rs
  CloseConn conn
	Response.End()
End If

Dim bLatest
sql="SELECT THESIS_FILE,RESULT,DETECT_TIME,DETECT_REPORT FROM ViewDetectResult WHERE THESIS_ID="&thesisID&" AND HASH="&toSqlString(hash)
GetRecordSet conn,rsDetect,sql,count

bLatest=rs("THESIS_FILE").Value=rsDetect("THESIS_FILE").Value
If delete_type=0 Then	' 删除送检报告
	rsDetect("RESULT")=Null
	rsDetect("DETECT_TIME")=Null
	rsDetect("DETECT_REPORT")=Null
	rsDetect.Update()
ElseIf delete_type=1 Then	' 删除送检记录
	rsDetect.Delete()
End If
CloseRs rsDetect

If bLatest Then	' 更新论文评阅信息表中的检测数据
	sql="SELECT THESIS_FILE,RESULT,DETECT_TIME,DETECT_REPORT FROM DetectResults WHERE THESIS_ID="&thesisID&" ORDER BY DETECT_TIME DESC"
	GetRecordSetNoLock conn,rsDetect,sql,count
	If count>0 Then	' 取上次的送检结果
		If delete_type=1 Then rs("THESIS_FILE").Value=rsDetect("THESIS_FILE").Value
		rs("REPRODUCTION_RATIO").Value=rsDetect("RESULT").Value
		rs("DETECT_REPORT").Value=rsDetect("DETECT_REPORT").Value
	Else
		If delete_type=1 Then rs("THESIS_FILE").Value=Null
		rs("REPRODUCTION_RATIO").Value=Null
		rs("DETECT_REPORT").Value=Null
	End If
	rs.Update()
End If
CloseRs rs
CloseConn conn
%><form id="ret" action="thesisDetail.asp?tid=<%=thesisID%>" method="post">
<input type="hidden" name="In_TEACHTYPE_ID2" value="<%=teachtype_id%>" />
<input type="hidden" name="In_CLASS_ID2" value="<%=class_id%>" />
<input type="hidden" name="In_ENTER_YEAR2" value="<%=enter_year%>" />
<input type="hidden" name="In_TASK_PROGRESS2" value="<%=query_task_progress%>" />
<input type="hidden" name="In_REVIEW_STATUS2" value="<%=query_review_status%>" />
<input type="hidden" name="finalFilter2" value="<%=toPlainString(finalFilter)%>" />
<input type="hidden" name="pageSize2" value="<%=pageSize%>" />
<input type="hidden" name="pageNo2" value="<%=pageNo%>" /></form>
<script type="text/javascript">
	alert("操作完成。");
	document.all.ret.submit();
</script>