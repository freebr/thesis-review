﻿<%Response.Expires=-1%>
<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"--><%
If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")
paper_id=Request.Form("tid")
new_thesis_form=Request.Form("thesis_form")
If IsEmpty(paper_id) Then
	bError=True
	errMsg="参数无效。"
ElseIf new_thesis_form=0 Then
	bError=True
	errMsg="请选择论文形式！"
End If
If bError Then
%><body><center><font color=red size="4"><%=errMsg%></font><br/><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Dim conn,sql
Connect conn
sql="UPDATE Dissertations SET REVIEW_TYPE="&new_thesis_form&" WHERE ID="&paper_id
conn.Execute sql
CloseConn conn
%><script type="text/javascript">
	alert("操作完成。");
	location.href='home.asp';
</script>