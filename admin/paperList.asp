﻿<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"--><%
If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")

Dim PubTerm,PageNo,PageSize,bQuery,bSearch
activity_id=toUnsignedInt(Request.Form("In_ActivityId"))
teachtype_id=toUnsignedInt(Request.Form("In_TEACHTYPE_ID"))
enter_year=toUnsignedInt(Request.Form("In_ENTER_YEAR"))
class_id=toUnsignedInt(Request.Form("In_CLASS_ID"))
query_task_progress=toUnsignedInt(Request.Form("In_TASK_PROGRESS"))
query_review_status=toUnsignedInt(Request.Form("In_REVIEW_STATUS"))
finalFilter=Request.Form("finalFilter")
bSearch=Not IsEmpty(Request.Form("btnsearch"))
If Len(finalFilter) Then PubTerm="AND ("&finalFilter&")"
If activity_id=-1 Then
	Dim activity:Set activity=getLastActivityInfoOfStuType(Null)
	If Not IsNull(activity) Then activity_id=activity("Id")
End If
If activity_id>0 Then PubTerm=PubTerm&" AND ActivityId="&activity_id
If teachtype_id>0 Then PubTerm=PubTerm&" AND TEACHTYPE_ID="&teachtype_id
If enter_year>0 Then PubTerm=PubTerm&" AND ENTER_YEAR="&enter_year
If class_id>0 Then PubTerm=PubTerm&" AND CLASS_ID="&class_id
If query_task_progress>-1 Then PubTerm=PubTerm&" AND TASK_PROGRESS="&query_task_progress
If query_review_status>-1 Then PubTerm=PubTerm&" AND REVIEW_STATUS="&query_review_status

bQuery=bSearch Or Len(PubTerm)>0
'----------------------PAGE-------------------------
PageNo=""
PageSize=""
If Request.Form("In_PageNo").Count=0 Then
	PageNo=Request.Form("pageNo")
	PageSize=Request.Form("pageSize")
Else
	PageNo=Request.Form("In_PageNo")
	PageSize=Request.Form("In_PageSize")
End If
bShowAll=Request.QueryString="showAll"
If bShowAll Then PageSize=-1
'------------------------------------------------------
If bQuery Then
	Connect conn
	sql="SELECT * FROM ViewDissertations_admin WHERE 1=1 "&PubTerm
	GetRecordSetNoLock conn,rs,sql,count
	If IsEmpty(pageSize) Or Not IsNumeric(pageSize) Then
		pageSize=60
	Else
		pageSize=CInt(pageSize)
	End If
	If pageSize=-1 Then
		If rs.RecordCount>0 Then rs.PageSize=rs.RecordCount
	Else
		rs.PageSize=pageSize
	End If
	If IsEmpty(pageNo) Or Not IsNumeric(pageNo) Then
		If rs.PageCount<>0 Then pageNo=1
	Else
		pageNo=CInt(pageNo)
		If pageNo>rs.PageCount Then
			If rs.PageCount<>0 Then pageNo=1
		End If
	End If
	If rs.RecordCount>0 Then rs.AbsolutePage=pageNo
End If
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="theme-color" content="#2D79B2" />
<title>专业论文列表</title>
<% useStylesheet "admin", "jeasyui" %>
<% useScript "jquery", "jeasyui", "common", "paper" %>
</head>
<body bgcolor="ghostwhite" onload="return On_Load()">
<center>
<font size=4><b>专业硕士论文列表</b></font>
<form id="query_nocheck" method="post" onsubmit="if(Chk_Select())return chkField();else return false">
<table cellspacing="4" cellpadding="0">
<tr><td>评阅活动&nbsp;<%=activityList("In_ActivityId", Session("AdminType")("ManageStuTypes"), activity_id, True)%></td>
<td><table width="100%" cellspacing="4" cellpadding="0"><%
Dim ArrayList(2,5),k

FormName="query_nocheck"
k=0
ArrayList(k,0)="学位类别"
ArrayList(k,1)="ViewStudentTypeInfo"
ArrayList(k,2)="TEACHTYPE_ID"
ArrayList(k,3)="TEACHTYPE_NAME"
ArrayList(k,4)=teachtype_id
ArrayList(k,5)=Format("AND (StuTypeBitwise&{0})<>0", Session("AdminType")("ManageStuTypes"))

k=1

ArrayList(k,0)="年级"
ArrayList(k,1)="ViewSpecialityInfo"
ArrayList(k,2)="ENTER_YEAR"
ArrayList(k,3)="STR(ENTER_YEAR,4)+'级'"
ArrayList(k,4)=enter_year
ArrayList(k,5)="AND VALID=0 AND ENTER_YEAR>=2008"

k=2
ArrayList(k,0)="班级"
ArrayList(k,1)="ViewSpecialityInfo"
ArrayList(k,2)="CLASS_ID"
ArrayList(k,3)="CLASS_NAME"
ArrayList(k,4)=class_id
ArrayList(k,5)=""
Get_ListJavaMenu ArrayList,k,FormName,""
%></tr></table></td></tr>
<tr><td colspan=2><table cellspacing="4" cellpadding="0"><tr><td>表格审核状态</td><td><select name="In_TASK_PROGRESS"><option value="-1">所有</option><%
GetMenuListPubTerm "ReviewStatuses","STATUS_ID1","STATUS_NAME",query_task_progress,"AND STATUS_ID1 IS NOT NULL"
%></select></td><td>论文审核状态</td><td><select name="In_REVIEW_STATUS"><option value="-1">所有</option><%
GetMenuListPubTerm "ReviewStatuses","STATUS_ID2","STATUS_NAME",query_review_status,"AND STATUS_ID2 IS NOT NULL"
%></select></td></tr></table></td></tr><tr><td colspan=2>
<!--查找-->
<select name="field" onchange="ReloadOperator()">
<option value="s_STU_NAME">学生姓名</option>
<option value="s_STU_NO">学号</option>
<option value="s_THESIS_SUBJECT">论文题目</option>
<option value="s_TUTOR_NAME">导师姓名</option>
<option value="ms_EXPERT_NAME1|EXPERT_NAME2">专家姓名</option>
<option value="n_DETECT_COUNT">论文送检次数</option>
<option value="ms_REVIEW_RESULT_TEXT1|REVIEW_RESULT_TEXT2">送审结果</option>
<option value="s_FINAL_RESULT_TEXT">处理意见</option>
</select>
<select name="operator">
<script>ReloadOperator()</script>
</select>
<input type="text" name="filter" size="10" onkeypress="checkKey()">
<input type="hidden" name="finalFilter" value="<%=toPlainString(finalFilter)%>">
<input type="submit" name="btnsearch" value="查找" onclick="genFilter()">
<input type="submit" value="在结果中查找" onclick="genFinalFilter()"><%
If bQuery Then %>
&nbsp;每页
<select name="pageSize" onchange="if(Chk_Select())submitForm(this.form)">
<option value="-1" <%If pageSize=-1 Then%>selected<%End If%>>全部</option>
<option value="20" <%If rs.PageSize=20 Then%>selected<%End If%>>20</option>
<option value="40" <%If rs.PageSize=40 Then%>selected<%End If%>>40</option>
<option value="60" <%If rs.PageSize=60 Then%>selected<%End If%>>60</option>
</select>
条
&nbsp;
转到
<select name="pageNo" onchange="if(Chk_Select())submitForm(this.form)">
<%
For i=1 to rs.PageCount
		Response.write "<option value="&i
		If rs.AbsolutePage=i Then Response.write " selected"
		Response.write ">"&i&"</option>"
Next
%>
</select>
页
&nbsp;
共<%=rs.RecordCount%>条<%
End If %>
<input type="button" value="显示全部" onclick="showAllRecords(this.form)">
&nbsp;全选<input type="checkbox" onclick="checkAll()" id="chk" /></td></tr>
<tr><td>
评阅结果&nbsp;<select name="selreviewfilestat"><%
For i=0 To UBound(arrReviewFileStat)
%><option value="<%=i%>"><%=arrReviewFileStat(i)%></option><%
Next %></select><input type="button" value="设置" onclick="batchUpdatePaper($('#paperList'))" />
</td>
<td>
<a href="javascript:void(0)" id="menuImport">导入数据</a>
<div id="popupImport">
<div data-options="name: 'importNewPaper'">导入新增论文信息</div>
<div data-options="name: 'importDetectResult'">导入送检论文查重信息</div>
<div data-options="name: 'importInstructReviewDetectResult'">导入教指委盲评论文查重信息</div>
<div data-options="name: 'importDefencePlan'">导入答辩安排信息</div>
<div data-options="name: 'importDefenceEval'">导入答辩委员会修改意见</div>
<div data-options="name: 'importDegreeEval'">导入学院学位评定分会修改意见</div>
<div class="menu-sep"></div>
<div data-options="name: 'importReviewerMatchResult'">导入评阅专家匹配结果</div>
<div data-options="name: 'importInstructMemberMatchResult'">导入教指委委员匹配结果</div>
</div>
<a href="javascript:void(0)" id="btnBatchNotifyExpert">批量通知专家评阅</a>
<a href="javascript:void(0)" id="btnBatchFetchDocument">批量下载表格/论文</a>
<a href="javascript:void(0)" id="btnExport">导出到Excel文件</a>
<a href="javascript:void(0)" id="btnDelete">删 除</a>
</td></tr></table></form>
<form id="paperList" method="post">
<input type="hidden" name="In_ActivityId2" value="<%=activity_id%>">
<input type="hidden" name="In_TEACHTYPE_ID2" value="<%=teachtype_id%>">
<input type="hidden" name="In_CLASS_ID2" value="<%=class_id%>">
<input type="hidden" name="In_ENTER_YEAR2" value="<%=enter_year%>">
<input type="hidden" name="In_TASK_PROGRESS2" value="<%=query_task_progress%>">
<input type="hidden" name="In_REVIEW_STATUS2" value="<%=query_review_status%>">
<input type="hidden" name="finalFilter2" value="<%=toPlainString(finalFilter)%>">
<input type="hidden" name="pageSize2" value=<%=pageSize%>>
<input type="hidden" name="pageNo2" value=<%=pageNo%>>
<input type="hidden" name="review_display_status" value="0">
<table width="1000" cellpadding="2" cellspacing="1" bgcolor="dimgray">
	<tr bgcolor="gainsboro" height="25">
		<td align="center">论文题目</td>
		<td width="80" align="center">姓名</td>
		<td width="90" align="center">学号</td>
		<td width="120" align="center">专业</td>
		<td width="100" align="center">学位类别</td>
		<td width="60" align="center">导师</td>
		<td width="80" align="center">送审结果1</td>
		<td width="80" align="center">送审结果2</td>
		<td width="80" align="center">处理意见</td>
		<td width="110" align="center">状态</td>
		<td width="30" align="center">选择</td>
		<td width="50" align="center">操作</td>
	</tr><%
If bQuery Then
	Dim is_review_visible,review_result,review_result_text(1)
	For i=1 to rs.PageSize
		If rs.EOF Then Exit For
		If Not IsNull(rs("REVIEW_RESULT")) Then
			review_result=Split(rs("REVIEW_RESULT"),",")
			review_result_text(0)=HtmlEncode(rs("EXPERT_NAME1"))&"<br/>"&rs("REVIEW_RESULT_TEXT1")
			review_result_text(1)=HtmlEncode(rs("EXPERT_NAME2"))&"<br/>"&rs("REVIEW_RESULT_TEXT2")
		End If
		is_review_visible=Array(rs("ReviewFileDisplayStatus1")>0,rs("ReviewFileDisplayStatus2")>0)
		substat=vbNullString
		If rs("TASK_PROGRESS")>=tpTbl4Uploaded Then
			stat=rs("STAT_TEXT1")&"，"&rs("STAT_TEXT2")
		ElseIf rs("REVIEW_STATUS")=0 Then
			stat=rs("STAT_TEXT1")
		Else
			stat=rs("STAT_TEXT2")
			If rs("REVIEW_STATUS")>=rsReviewed And Not is_review_visible(0) And Not is_review_visible(1) Then
				substat="评阅结果["&arrReviewFileStat(rs("REVIEW_FILE_STATUS"))&"]"
			End If
		End If
		If rs("UNHANDLED") Then
			cssclass="paper-status-unhandled"
		Else
			cssclass="paper-status"
		End If
	%><tr bgcolor="ghostwhite">
		<td align="center"><a href="#" onclick="return showPaperDetail(<%=rs("ID")%>,0)"><%=HtmlEncode(rs("THESIS_SUBJECT"))%></a></td>
		<td align="center"><a href="#" onclick="return showStudentProfile(<%=rs("STU_ID")%>,0)"><%=HtmlEncode(rs("STU_NAME"))%></a></td>
		<td align="center"><%=rs("STU_NO")%></td>
		<td align="center"><%=HtmlEncode(rs("SPECIALITY_NAME"))%></td>
		<td align="center"><%=rs("TEACHTYPE_NAME")%></td>
		<td align="center"><%=HtmlEncode(rs("TUTOR_NAME"))%></td>
	<td align="center"><%=review_result_text(0)%></td>
		<td align="center"><%=review_result_text(1)%></td>
		<td align="center"><%=rs("FINAL_RESULT_TEXT")%></td>
		<td align="center"><a href="#" onclick="return showPaperDetail(<%=rs("ID")%>,0)"><span class="<%=cssclass%>"><%=stat%></span></a><%
		If Len(substat) Then
		%><br/><span class="thesissubstat"><%=substat%></span><%
		End If %></td>
		<td align="center"><input type="checkbox" name="sel" value="<%=rs("ID")%>" /></td>
		<td align="center"><%
		If rs("REVIEW_STATUS")=rsAgreedReview Then
			If IsNull(rs("REVIEWER1")) And IsNull(rs("REVIEWER2")) Then
%><input type="button" value="匹配专家" onclick="matchReviewer(this.form,<%=rs("ID")%>)" /><%
			Else
%><input type="button" value="通知专家评阅" onclick="notifyReviewer(this.form,<%=rs("ID")%>)" /><%
			End If
		End If
		%></td></tr><%
		rs.MoveNext()
	Next
End If
%></table></form></center>
<script type="text/javascript">
	$("#menuImport").menubutton({
		iconCls: "icon-upload",
		menu: "#popupImport",
		plain: false
	});
	$("#popupImport").menu({
		onClick: function(item) {
			submitForm($("#paperList"),	item.name + ".asp");
		}
	});
	$("#btnExport").linkbutton({ iconCls: "icon-file-export" }).click(function() {
		this.value="正在导出，请稍候……";
		$(this).linkbutton("disable");
		submitForm($("#paperList"),"exportReviewStats.asp");
	}).linkbutton("enable");
	$("#btnBatchNotifyExpert").linkbutton({ iconCls: "icon-mails" }).click(function() {
		submitForm($("#paperList"),"notifyReviewer.asp");
	});
	$("#btnBatchFetchDocument").linkbutton({ iconCls: "icon-batch-download" }).click(function() {
		batchFetchDocument($("#paperList"));
	});
	$("#btnDelete").linkbutton({ iconCls: "icon-cancel" }).click(function() {
		if(confirm("是否删除这 "+countClk()+" 条记录？")) {
			submitForm($("#paperList"),"deletePaper.asp");
		}
	});
</script></body></html><%
	CloseRs rs
	CloseConn conn
%>