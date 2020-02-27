﻿<%
Function getDateTimeId(t)
	getDateTimeId=Replace((Year(t)-2000)&FormatNumber(Month(t)/100,2)&FormatNumber(Day(t)/100,2),".","")
End Function

Function getTeachTypeIdByName(teachtype_name)
	Dim ret
	Select Case UCase(teachtype_name)
	Case "MBA":ret=6
	Case "ME":ret=5
	Case "EMBA":ret=7
	Case "MPACC":ret=9
	Case Else:ret=0
	End Select
	getTeachTypeIdByName=ret
End Function

Function getTeacherIdByName(name)
	If IsNull(name) Then
		getTeacherIdByName=-1
		Exit Function
	End If
	Dim conn,rsTeacher,sql,count
	name=Replace(name," ",vbNullString)
	name=Replace(name,"　",vbNullString)
	name=Replace(name,"'","''")
	name=Replace(name,"""","""""")
	ConnectOriginDb conn
	sql="SELECT TEACHERID,TEACHERNAME FROM TEACHER_INFO WHERE TEACHERNAME='"&name&"' AND VALID=0"
	GetRecordSetNoLock conn,rsTeacher,sql,count
	If rsTeacher.EOF Then
		getTeacherIdByName=-1
	Else
		getTeacherIdByName=rsTeacher("TEACHERID")
	End If
	CloseRs rsTeacher
	CloseConn conn
End Function

Function getProDutyNameOf(tid)
	Dim conn,rs,sql,count
	Connect conn
	sql="SELECT PRO_DUTYNAME FROM ViewTeacherInfo WHERE TEACHERID="&tid
	GetRecordSetNoLock conn,rs,sql,count
	If Not rs.EOF Then
		getProDutyNameOf=rs(0)
	End If
	CloseRs rs
	CloseConn conn
End Function

Function getAdminType(user_id)
	Dim conn,rs,sql,count,dict
	Connect conn
	sql="EXEC spGetEduAdminType ?"
	Dim ret:Set ret=ExecQuery(conn,sql,CmdParam("UserID",adInteger,4,user_id))
    Set rs=ret("rs")
    count=ret("count")
	Set dict=Server.CreateObject("Scripting.Dictionary")
	Dim admin_type
	If rs.EOF Then
		admin_type=0
	Else
		admin_type=rs("AdminType").Value
	End If
	dict.Add "ManageStuTypes", admin_type
	For Each item In dictStuTypes
		If (admin_type And 2^(item-1)) <> 0 Then
			dict.Add dictStuTypes(item)(1), True
		End If
	Next
	Set getAdminType=dict
	CloseRs rs
	CloseConn conn
End Function

Function setAdminType(user_id, arrManageStuTypes)
	Dim admin_type,i
	admin_type=0
	For i=0 To UBound(arrManageStuTypes)
		admin_type=admin_type+2^Int(arrManageStuTypes(i)-1)
	Next
	Dim conn,sql
	Connect conn
	sql="EXEC spSetEduAdminType ?,?"
	ExecNonQuery conn,sql,_
		CmdParam("UserID",adInteger,4,user_id),_
		CmdParam("AdminType",adInteger,4,admin_type)
	CloseConn conn
End Function

Function getNoticeText(stuType,noticeName)
	Dim conn,rs,sql,count
	Connect conn
	sql="EXEC spGetNoticeText ?,?"
	Dim ret:Set ret=ExecQuery(conn,sql,_
		CmdParam("StudentType",adInteger,4,stuType),_
		CmdParam("NoticeName",adVarWChar,50,noticeName))
	Set rs=ret("rs")
    count=ret("count")
	If rs.EOF Then
		getNoticeText="【无】"
	Else
		getNoticeText=rs(0).Value
	End If
	CloseRs rs
	CloseConn conn
End Function

Function setNoticeText(stuType,noticeName,noticeContent)
	Dim conn,sql
	Connect conn
	sql="EXEC spSetNoticeText ?,?,?"
	ExecNonQuery conn,sql,_
		CmdParam("StudentType",adInteger,4,stuType),_
		CmdParam("NoticeName",adVarWChar,50,noticeName),_
		CmdParam("NoticeContent",adVarWChar,65535,noticeContent)
	CloseConn conn
End Function

Function addAuditRecord(dissertation_id,filename,audit_type,audit_time,auditor_id,is_passed,eval_text)
	If Len(eval_text)=0 Then
		If is_passed Then eval_text="审核通过" Else eval_text="审核不通过"
	End If
	Dim conn,sql
	Connect conn
	sql="EXEC spAddAuditRecord ?,?,?,?,?,?,?,?"
	ExecNonQuery conn,sql,_
		CmdParam("dissertation_id",adInteger,4,dissertation_id),_
		CmdParam("audit_file",adVarWChar,50,filename),_
		CmdParam("audit_type",adInteger,4,audit_type),_
		CmdParam("audit_time",adDate,4,audit_time),_
		CmdParam("auditor_id",adInteger,4,auditor_id),_
		CmdParam("is_passed",adVarWChar,500,is_passed),_
		CmdParam("comment",adLongVarWChar,5000,eval_text),_
		CmdParam("creator",adInteger,4,Session("TId"))
	CloseConn conn
End Function

Function sendEmailToStudent(dissertation_id,file_type_name,is_pass,ByVal eval_text)
	If Len(eval_text)=0 Then eval_text="无"
	Dim conn:Connect conn
	Dim sql:sql="SELECT ActivityId,TEACHTYPE_ID,STU_NAME,STU_NO,CLASS_NAME,SPECIALITY_NAME,EMAIL,THESIS_SUBJECT,TUTOR_NAME,TUTOR_EMAIL FROM ViewDissertations WHERE ID=?"
	Dim ret:Set ret=ExecQuery(conn,sql,CmdParam("ID",adInteger,4,dissertation_id))
	Dim rs:Set rs=ret("rs")
	Dim activity_id:activity_id=rs("ActivityId")
	Dim stu_type:stu_type=rs("TEACHTYPE_ID")
	Dim dict:Set dict=CreateDictionary()
	Dim template_name,operation_name,is_sent
	dict("stuname")=rs("STU_NAME")
	dict("stuno")=rs("STU_NO")
	dict("stuclass")=rs("CLASS_NAME")
	dict("stuspec")=rs("SPECIALITY_NAME")
	dict("stumail")=rs("EMAIL")
	dict("subject")=rs("THESIS_SUBJECT")
	dict("tutorname")=rs("TUTOR_NAME")
	dict("tutormail")=rs("TUTOR_EMAIL")
	CloseRs rs
	CloseConn conn

	If Len(file_type_name)=0 Then
		template_name="pyyjqrtzyj"
		operation_name="确认评阅书"
	Else
		If is_pass Then
			template_name="lwshtgtzyj"
			operation_name=Format("审核通过[{0}]",file_type_name)
		Else
			template_name="lwshwtgtzyj"
			operation_name=Format("审核不通过[{0}]",file_type_name)
		End If
	End If
	is_sent=sendNotifyMail(activity_id,stu_type,template_name,dict("stumail"),dict)
	writeNotificationEventLog usertypeAdmin,Session("name"),operation_name,usertypeStudent,_
		dict("stuname"),dict("stumail"),notifytypeMail,is_sent
	sendEmailToStudent=is_sent
End Function

Sub outputNumber(val)
	If val=0 Then Exit Sub
	Response.Write val
End Sub

If Not IsEmpty(Session("Id")) And IsEmpty(Session("AdminType")) Then
	Set Session("AdminType")=getAdminType(Session("Id"))
End If

Dim arrTable,reportBaseDir
arrTable=Array("","开题报告表","中期检查表","预答辩申请表","答辩审批材料")
reportBaseDir="/PaperReview/admin/upload/report/"
%>