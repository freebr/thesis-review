﻿<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"--><%
If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
step=Request.QueryString("step")
teachtype_id=Request.Form("In_TEACHTYPE_ID2")
class_id=Request.Form("In_CLASS_ID2")
enter_year=Request.Form("In_ENTER_YEAR2")
query_task_progress=Request.Form("In_TASK_PROGRESS2")
query_review_status=Request.Form("In_REVIEW_STATUS2")
finalFilter=Request.Form("finalFilter2")
pageSize=Request.Form("pageSize2")
pageNo=Request.Form("pageNo2")

Dim conn,sql,ret,rs

Select Case step
Case vbNullString	' 选择页面
	thesis_ids=Request.QueryString("tid")
	If Len(thesis_ids)=0 Then
		thesis_ids=Request.Form("sel")
	End If
	Connect conn
	sql="SELECT * FROM ViewDissertations WHERE ID IN ("&thesis_ids&")"
	GetRecordSet conn,rs,sql,count
	If rs("TEACHTYPE_ID")=5 Then
		reviewfile_type=2
	Else
		reviewfile_type=1
	End If
	expert_id1=rs("REVIEWER1")
	expert_id2=rs("REVIEWER2")
	expert_name1=rs("EXPERT_NAME1")
	expert_name2=rs("EXPERT_NAME2")
	If rs("REVIEW_STATUS")<rsMatchedReviewer Then nFirstMatch=1 Else nFirstMatch=0
	If IsNull(expert_name1) Then expert_name1="单击选择..."
	If IsNull(expert_name2) Then expert_name2="单击选择..."
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>为送审论文匹配评阅专家</title>
<% useStylesheet "admin" %>
<% useScript "jquery", "common" %>
</head>
<body>
<center>
<font size=4><b>为送审论文匹配评阅专家</b></font>
<form id="fmChooseExp" method="post" action="?step=2">
<input type="hidden" name="paper_id" value="<%=thesis_ids%>" />
<input type="hidden" name="In_TEACHTYPE_ID" value="<%=teachtype_id%>" />
<input type="hidden" name="In_CLASS_ID" value="<%=class_id%>" />
<input type="hidden" name="In_ENTER_YEAR" value="<%=enter_year%>" />
<input type="hidden" name="In_TASK_PROGRESS" value="<%=query_task_progress%>" />
<input type="hidden" name="In_REVIEW_STATUS" value="<%=query_review_status%>" />
<input type="hidden" name="finalFilter" value="<%=toPlainString(finalFilter)%>" />
<input type="hidden" name="pageSize" value="<%=pageSize%>" />
<input type="hidden" name="pageNo" value="<%=pageNo%>" />
<input type="hidden" name="In_TEACHTYPE_ID2" value="<%=teachtype_id%>" />
<input type="hidden" name="In_CLASS_ID2" value="<%=class_id%>" />
<input type="hidden" name="In_ENTER_YEAR2" value="<%=enter_year%>" />
<input type="hidden" name="In_TASK_PROGRESS2" value="<%=query_task_progress%>" />
<input type="hidden" name="In_REVIEW_STATUS2" value="<%=query_review_status%>" />
<input type="hidden" name="finalFilter2" value="<%=toPlainString(finalFilter)%>" />
<input type="hidden" name="pageSize2" value="<%=pageSize%>" />
<input type="hidden" name="pageNo2" value="<%=pageNo%>" />
<input type="hidden" name="firstMatch" value="<%=nFirstMatch%>" />
<table class="form" width="800" cellspacing="1" cellpadding="3">
<tr><td>论文题目：&emsp;&emsp;&emsp;<input type="text" class="txt" name="subject" size="95%" value="<%=rs("THESIS_SUBJECT")%>" readonly /></td></tr>
<tr><td>作者姓名：&emsp;&emsp;&emsp;<input type="text" class="txt" name="author" size="40" value="<%=rs("STU_NAME")%>" readonly />&nbsp;
学号：<input type="text" class="txt" name="stuno" size="15" value="<%=rs("STU_NO")%>" readonly />&nbsp;
学位类别：<input type="text" class="txt" name="degreename" size="10" value="<%=rs("TEACHTYPE_NAME")%>" readonly /></td></tr>
<tr><td>指导教师：&emsp;&emsp;&emsp;<input type="text" class="txt" name="tutorname" size="95%" value="<%=rs("TUTOR_NAME")%>" readonly /></td></tr><%
	If reviewfile_type=2 Then %>
<tr><td>领域名称：&emsp;&emsp;&emsp;<input type="text" class="txt" name="speciality" size="95%" value="<%=rs("SPECIALITY_NAME")%>" readonly /></td></tr><%
	End If %>
<tr><td>研究方向：&emsp;&emsp;&emsp;<input type="text" class="txt" name="researchway_name" size="95%" value="<%=rs("RESEARCHWAY_NAME")%>" readonly /></td></tr>
<tr><td>院系名称：&emsp;&emsp;&emsp;<input type="text" class="txt" name="faculty" size="95%" value="工商管理学院" readonly /></td></tr><%
	If Not IsNull(rs("THESIS_FORM")) And Len(rs("THESIS_FORM")) Then %>
<tr><td>论文形式：&emsp;&emsp;&emsp;<input type="text" class="txt" name="thesisform" size="95%" value="<%=rs("THESIS_FORM")%>" readonly /></td></tr><%
	End If %></table>
<p><font size=4><b>请选择要匹配的评阅专家（单击方框选择）</b></font></p>
<table class="form" width="800" cellpadding="2" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="gainsboro" align="center" height="25">
<td width="100" align="center">专家一：</td>
<td width="200" align="center"><input type="text" class="txt selectbox" name="expertname" size=20 value="<%=expert_name1%>" onclick="window.open('selectExpert.asp?match_type=1&ctrl1=expertname&ctrl2=expertid&item=0','','width=1000,height=500,location=no,scrollbars=yes')"/><input type="hidden" name="expertid" value="<%=expert_id1%>" /></td></tr>
<tr bgcolor="gainsboro" align="center" height="25">
<td width="100" align="center">专家二：</td>
<td width="200" align="center"><input type="text" class="txt selectbox" name="expertname" size=20 value="<%=expert_name2%>" onclick="window.open('selectExpert.asp?match_type=1&ctrl1=expertname&ctrl2=expertid&item=1','','width=1000,height=500,location=no,scrollbars=yes')"/><input type="hidden" name="expertid" value="<%=expert_id2%>" /></td></tr>
</table><p><input type="submit" id="btnsubmit" value="确 定" />&emsp;
<input type="button" id="btnreturn" value="返 回" onclick="history.go(-1)" /></p></form></center></body>
<script type="text/javascript">
	$('#btnsubmit').click(function(){
		$(this).val('正在提交，请稍候……').attr('disabled',true);
		this.form.submit();
	}).attr('disabled',false);
</script></html><%
  CloseRs rs
  CloseConn conn
Case 2	' 后台处理
	thesis_ids=Request.Form("paper_id")
	If Len(thesis_ids)=0 Then
		thesis_ids=Request.Form("ids")
	End If
	expertid1=Request.Form("expertid")(1)
	expertid2=Request.Form("expertid")(2)
	bFirstMatch=Request.Form("firstMatch")<>"0"
	If Len(thesis_ids)=0 Then
		bError=True
		errdesc="您未选择论文！"
	ElseIf Request.Form("expertid").Count<>2 Then
		bError=True
		errdesc="必须选择两名专家！"
	ElseIf Not IsNumeric(expertid1) Or Not IsNumeric(expertid2) Then
		bError=True
		errdesc="必须选择两名专家！"
	ElseIf expertid1=expertid2 Then
		bError=True
		errdesc="所选两名专家不能相同！"
	End If
	If bError Then
		showErrorPage errdesc, "提示"
	End If

	expertid1=Int(expertid1)
	expertid2=Int(expertid2)
	Connect conn
	For i=1 To 2
		teacherID=Request.Form("expertid")(i)
		sql="SELECT ID FROM Experts WHERE TEACHER_ID="&teacherID
		GetRecordSetNoLock conn,rs2,sql,count
		CloseRs rs2
		If count=0 Then	' 临时添加专家，用于校内导师作为评阅专家录入
			sql="SELECT * FROM ViewTeacherInfo WHERE TEACHERID="&teacherID
			GetRecordSetNoLock conn,rs2,sql,count
			teacherName=rs2("TEACHERNAME")
			proDutyName=getProDutyNameOf(teacherID)
			workplace="华南理工大学工商管理学院"&rs2("DEPT_NAME")
			address=rs2("Office_Address")
			telephone=rs2("OFFICE_PHONE")
			mobile=rs2("MOBILE")
			email=rs2("EMAIL")
			CloseRs rs2
			sql="INSERT INTO Experts VALUES("&toSqlString(teacherName)&","&teacherID&","&toSqlString(proDutyName)&",NULL,"&_
			toSqlString(workplace)&","&toSqlString(address)&",NULL,"&toSqlString(telephone)&","&toSqlString(mobile)&","&toSqlString(email)&",NULL,NULL,NULL,1,1)"
			conn.Execute sql
		End If
	Next
	sql="EXEC dbo.spSetDissertationReviewer "&thesis_ids&","&expertid1&","&expertid2
	conn.Execute sql

	If bFirstMatch Then
		' 发送送审通知邮件
		Dim arrDissertations:arrDissertations=Split(thesis_ids,",")
		Dim activity_id,stu_type,is_sent
		Dim dict:Set dict=CreateDictionary()
		sql="SELECT ActivityId,TEACHTYPE_ID,STU_NAME,STU_NO,CLASS_NAME,SPECIALITY_NAME,EMAIL,THESIS_SUBJECT,TUTOR_NAME,TUTOR_EMAIL FROM ViewDissertations WHERE ID=?"
		For i=0 To UBound(arrDissertations)
			Set ret=ExecQuery(conn,sql,CmdParam("ID",adInteger,4,arrDissertations(i)))
			Set rs=ret("rs")
			If Not rs.EOF Then
				activity_id=rs("ActivityId")
				stu_type=rs("TEACHTYPE_ID")
				dict("stuname")=rs("STU_NAME")
				dict("stuno")=rs("STU_NO")
				dict("stuclass")=rs("CLASS_NAME")
				dict("stuspec")=rs("SPECIALITY_NAME")
				dict("stumail")=rs("EMAIL")
				dict("subject")=rs("THESIS_SUBJECT")
				dict("tutorname")=rs("TUTOR_NAME")
				dict("tutormail")=rs("TUTOR_EMAIL")
				CloseRs rs

				is_sent=sendNotifyMail(activity_id,stu_type,"lwsstzyj(xs)",dict("stumail"),dict)
				writeNotificationEventLog usertypeAdmin,Session("name"),"匹配专家",usertypeStudent,_
					dict("stuname"),dict("stumail"),notifytypeMail,is_sent

				is_sent=sendNotifyMail(activity_id,stu_type,"lwsstzyj(ds)",dict("tutormail"),dict)
				writeNotificationEventLog usertypeAdmin,Session("name"),"匹配专家",usertypeTutor,_
					dict("tutorname"),dict("tutormail"),notifytypeMail,is_sent
			End If
		Next
	End If
	CloseConn conn

	msg="操作完成，是否立即向专家发送评阅通知短信及邮件？"
	If InStr(thesis_ids,",") Then
		returl="paperList.asp"
	Else
		returl="paperDetail.asp?tid="&thesis_ids
	End If
%><form id="ret" action="<%=returl%>" method="post">
<input type="hidden" name="finalFilter" value="<%=toPlainString(finalFilter)%>" />
<input type="hidden" name="pageSize" value="<%=pageSize%>" />
<input type="hidden" name="pageNo" value="<%=pageNo%>" />
<input type="hidden" name="paper_id" value="<%=thesis_ids%>" />
<input type="hidden" name="In_TEACHTYPE_ID2" value="<%=teachtype_id%>" />
<input type="hidden" name="In_CLASS_ID2" value="<%=class_id%>" />
<input type="hidden" name="In_ENTER_YEAR2" value="<%=enter_year%>" />
<input type="hidden" name="In_TASK_PROGRESS2" value="<%=query_task_progress%>" />
<input type="hidden" name="In_REVIEW_STATUS2" value="<%=query_review_status%>" />
<input type="hidden" name="finalFilter2" value="<%=toPlainString(finalFilter)%>" />
<input type="hidden" name="pageSize2" value="<%=pageSize%>" />
<input type="hidden" name="pageNo2" value="<%=pageNo%>" /></form>
<script type="text/javascript">
	if(confirm("<%=msg%>"))	document.all.ret.action="notifyReviewer.asp";
	document.all.ret.submit();
</script><%
End Select
%>