﻿<%Response.Charset="utf-8"
Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("Tuser")) Then Response.Redirect("../error.asp?timeout")
TeacherId=Session("Tid")
If Len(TeacherId)=0 Or Not IsNumeric(TeacherId) Then
	bError=True
	errdesc="参数无效。"
End If
If bError Then
%><body bgcolor="ghostwhite"><center><font color=red size="4"><%=errdesc%></font><br/><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	CloseRs rs
	CloseConn conn
	Response.End
End If

Connect conn
sql="SELECT * FROM VIEW_TEST_THESIS_REVIEW_EXPERT_INFO WHERE TEACHER_ID="&TeacherId
GetRecordSetNoLock conn,rs,sql,result
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">数据库没有记录！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	CloseRs rs
  CloseConn conn
	Response.End
End If
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="../css/teacher.css" rel="stylesheet" type="text/css" />
<script src="../scripts/jquery-1.6.3.min.js" type="text/javascript"></script>
<script src="../scripts/query.js" type="text/javascript"></script>
<script src="../scripts/utils.js" type="text/javascript"></script>
<script src="../scripts/expert.js" type="text/javascript"></script>
</head>
<body class="exp"><center><div class="content">
<form id="profile" action="updateProfile.asp" method="post" enctype="multipart/form-data">
<input type="hidden" name="teacherid" value="<%=TeacherId%>">
<b><font class="title">个人信息编辑</font></b>
<p><span class="tip">以下信息均为必填项</span></p>
<table class="tblform" width="1000" cellspacing=1 cellpadding=3>
<tr height="30">
	<td bgcolor="gainsboro" width="65" align="center">姓名</td>
	<td bgcolor="white"><input type="text" name="teachername" class="txt" value="<%=HtmlEncode(rs("EXPERT_NAME"))%>" /></td>
	<td bgcolor="gainsboro" width="65" align="center">性别</td>
	<td bgcolor="white"><input type="radio" name="sex" value="男"<%If rs("SEX")="男" Then%> checked<%End If%> />男
	<input type="radio" name="sex" value="女"<%If rs("SEX")="女" Then%> checked<%End If%> />女</td>
	<td bgcolor="gainsboro" width="75" align="center">专业技术职务</td>
	<td bgcolor="white"><input type="text" class="txt" name="pro_duty_name" id="pro_duty_name" value="<%=HtmlEncode(rs("PRO_DUTY_NAME"))%>" /></td>
</tr>
<tr height="30">
	<td bgcolor="gainsboro" width="65" align="center">学科专长</td>
	<td bgcolor="white"><input type="text" class="txt" name="expertise" id="expertise" value="<%=HtmlEncode(rs("EXPERTISE"))%>" /></td>
	<td bgcolor="gainsboro" width="65" align="center">电子邮箱</td>
	<td bgcolor="white"><input name="email" type="text" class="txt" id="email" value="<%=HtmlEncode(rs("EMAIL"))%>" /></td>
	<td bgcolor="gainsboro" align="center">邮编</td>
	<td bgcolor="white"><input type="text" class="txt" name="mailcode" id="mailcode" value="<%=HtmlEncode(rs("MAILCODE"))%>" onkeyup="replNoNum(this)" onbeforepaste="replClipboardData('trimNoNum')" /></td>
</tr>
<tr height="30">
	<td bgcolor="gainsboro" align="center">联系电话（办公室）</td>
	<td bgcolor="white"><input type="text" class="txt" name="telephone" id="telephone" value="<%=HtmlEncode(rs("TELEPHONE"))%>" /></td>
	<td bgcolor="gainsboro" align="center">联系电话（移动）</td>
	<td bgcolor="white"><input type="text" class="txt" name="mobile" id="mobile" value="<%=HtmlEncode(rs("MOBILE"))%>" onkeyup="replNoNum(this)" onbeforepaste="replClipboardData('trimNoNum')" /></td>
	<td bgcolor="gainsboro" align="center">银行账户号</td>
	<td bgcolor="white"><input type="text" class="txt" name="bankaccount" id="bankaccount" value="<%=HtmlEncode(rs("BANK_ACCOUNT"))%>" onkeyup="replNoNum(this)" onbeforepaste="replClipboardData('trimNoNum')" />
<span class="tip">请填写工行账号</span></td>
</tr>
<tr height="30">
	<td bgcolor="gainsboro" align="center">身份证号码</td>
	<td bgcolor="white" colspan="3"><input type="text" class="txt" name="idcard_no" id="idcard_no" value="<%=HtmlEncode(rs("IDCARD_NO"))%>" style="width:100%" /></td>
	<td bgcolor="gainsboro" align="center">开户行</td>
	<td bgcolor="white"><input type="text" class="txt" name="bankname" id="bankname" value="<%=HtmlEncode(rs("BANK_NAME"))%>" style="width:100%" /></td>
</tr>
<tr height="30">
	<td bgcolor="gainsboro" align="center">单位名称（含院系）</td>
	<td bgcolor="white" colspan="5"><input type="text" class="txt" name="workplace" id="workplace" value="<%=HtmlEncode(rs("WORKPLACE"))%>" style="width:100%" /></td>
</tr>
<tr height="30">
	<td bgcolor="gainsboro" align="center">通信地址（最多25字）</td>
	<td bgcolor="white" colspan="5"><input type="text" class="txt" name="address" id="address" value="<%=HtmlEncode(rs("ADDRESS"))%>" style="width:100%" /></td>
</tr>
<tr bgcolor="white"><td colspan="6" align="center">
<input type="button" id="btnsubmit" value="提 交" />&nbsp;
<input type="button" id="btnreturn" value="返 回" /></td></tr></table>
<p><b><font class="title">登录密码修改</font></b></p>
<table class="tblform" width="1000" cellspacing=1 cellpadding=3>
<tr height="30">
<td bgcolor="white" colspan="6" align="center">请输入新密码：<input type="password" class="txt" name="newpwd" id="newpwd" style="width:150px" />&emsp;
确认新密码：<input type="password" class="txt" name="repeatpwd" id="repeatpwd" style="width:150px" /></td>
</tr>
<tr bgcolor="white"><td colspan="6" align="center">
<input type="button" value="修改密码" onclick="submitForm(this.form)" /></td></tr></table></form></div></center></body></html><%
CloseRs rs
CloseConn conn
%>