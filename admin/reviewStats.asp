﻿<%Response.Charset="utf-8"%>
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")

period_id=Request.Form("sel_periodid")
sem_info=getCurrentSemester()
If Len(period_id)=0 Then period_id=sem_info(3)
Connect conn
Set comm=Server.CreateObject("ADODB.Command")
comm.ActiveConnection=conn
comm.CommandText="getTestThesisReviewStatsList"
comm.CommandType=adCmdStoredProc
Set pmPeriodId=comm.CreateParameter("PERIOD_ID",adInteger,adParamInput,5,period_id)
comm.Parameters.Append pmPeriodId
Set rs=comm.Execute()
Set pmPeriodId=Nothing
Set comm=Nothing
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="../css/admin.css" rel="stylesheet" type="text/css" />
<script src="../scripts/jquery-1.6.3.min.js" type="text/javascript"></script>
<script src="../scripts/query.js" type="text/javascript"></script>
</head>
<body bgcolor="ghostwhite">
<center>
<font size=4><b>送审结果统计表</b></font>
<table cellspacing=4 cellpadding=0>
<form id="query" method="post" onsubmit="return chkField()">
<tr><td>查询学期：&nbsp;<%=semesterList("sel_periodid",Int(period_id))%></td>
<td width="150" align="center"><input type="button" id="btnexport" value="导出到Excel文件" /></td></tr></form></table>
<form id="fmStatsList" method="post" action="exportReviewStats.asp">
<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
<table width="1000" cellpadding="2" cellspacing="1" bgcolor="dimgray">
  <tr bgcolor="gainsboro" height="25">
  <td rowspan="2" width="90" align=center>学位类别</td>
  <td rowspan="2" align=center>专业名称</td>
  <td rowspan="2" width="70" align=center>送审总数</td>
  <td colspan="6" align=center>送审结果</td>
  <td colspan="4" align=center>总体评价</td>
  <td colspan="2" align=center>导师审核</td></tr>
  <tr bgcolor="gainsboro" height="25">
    <td width="60" align=center>可以答辩</td>
		<td width="60" align=center>适当修改</td>
		<td width="60" align=center>重大修改</td>
		<td width="60" align=center>加送两份</td>
		<td width="60" align=center>延期送审</td>
		<td width="60" align=center>未齐</td>
    <td width="40" align=center>优</td>
		<td width="40" align=center>良</td>
		<td width="40" align=center>中</td>
		<td width="40" align=center>差</td>
    <td width="40" align=center>同意</td>
		<td width="40" align=center>不同意</td>
  </tr>
  <%
  Dim review_result
  Do While Not rs.EOF
  %><tr bgcolor="ghostwhite" height="25">
    <td align=center><%=rs("TEACHTYPE_NAME")%></td>
    <td align=center><%=rs("SPECIALITY_NAME")%></td>
    <td align=center><%outputNumber(rs("TOTAL"))%></td>
    <td align=center><%outputNumber(rs("AGREED"))%></td>
    <td align=center><%outputNumber(rs("MODIFY"))%></td>
    <td align=center><%outputNumber(rs("GREATMODIFY"))%></td>
    <td align=center><%outputNumber(rs("EXTRAONE"))%></td>
    <td align=center><%outputNumber(rs("DELAYED"))%></td>
    <td align=center><%outputNumber(rs("UNFINISHED"))%></td>
    <td align=center><%outputNumber(rs("LEVEL1"))%></td>
    <td align=center><%outputNumber(rs("LEVEL2"))%></td>
    <td align=center><%outputNumber(rs("LEVEL3"))%></td>
    <td align=center><%outputNumber(rs("LEVEL4"))%></td>
    <td align=center><%outputNumber(rs("PASSED"))%></td>
    <td align=center><%outputNumber(rs("UNPASSED"))%></td></tr><%
  	rs.MoveNext()
  Loop
%></table></center></body>
<script type="text/javascript">
	$('select[name="sel_periodid"]').change(function() {
		this.form.submit();
	});
	$(':button#btnexport').click(function() {
		$(this).val("正在导出，请稍候……").attr('disabled',true);
		$('#fmStatsList').submit();
	}).attr('disabled',false);
</script></html><%
  CloseRs rs
  CloseConn conn
%>