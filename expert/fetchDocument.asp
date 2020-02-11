﻿<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%'If IsEmpty(Session("Tid")) Then Response.Redirect("../error.asp?timeout")
Dim arrFileListName,arrFileListNamePostfix,arrFileListPath,arrFileListField
arrFileListName=Array("","送审论文","论文评阅书 1","论文评阅书 2")
arrFileListNamePostfix=Array("","","论文评阅书(1)","论文评阅书(2)")
arrFileListPath=Array("","/ThesisReview/student/upload","/ThesisReview/expert/export","/ThesisReview/expert/export")
arrFileListField=Array("","THESIS_FILE2","REVIEW_FILE1","REVIEW_FILE2")
thesisID=Request.QueryString("tid")
filetype=Request.QueryString("type")
If Not IsNumeric(filetype) Then
	bError=True
	errdesc="参数无效。"
ElseIf filetype<1 Or filetype>3 Then
	bError=True
	errdesc="参数无效。"
End If
If bError Then
	showErrorPage errdesc, "提示"
End If

Connect conn
sql="SELECT *,LEFT(REVIEW_FILE,CHARINDEX(',',REVIEW_FILE)-1) AS REVIEW_FILE1,RIGHT(REVIEW_FILE,LEN(REVIEW_FILE)-CHARINDEX(',',REVIEW_FILE)) AS REVIEW_FILE2 FROM ViewDissertations WHERE ID="&thesisID&" AND Valid=1"
GetRecordSetNoLock conn,rs,sql,count
If rs.EOF Then
	CloseRs rs
	CloseConn conn
	showErrorPage "数据库没有该论文记录！", "提示"
End If

Dim source_file,fileExt,newfilename
Dim fso,file,stream
Set fso=Server.CreateObject("Scripting.FileSystemObject")
source_file=rs(arrFileListField(filetype))
If IsNull(source_file) Then
	source_file=""
Else
	fileExt=LCase(fso.GetExtensionName(source_file))
	If filetype=2 Or filetype=3 Then ' 评阅书则提供无学生信息版本
		source_file=arrFileListPath(filetype)&"/"&fso.GetBaseName(source_file)&"_nostu."&fileExt
	Else
		source_file=arrFileListPath(filetype)&"/"&source_file
	End If
	source_file=Server.MapPath(source_file)
End If
If Not fso.FileExists(source_file) Then
	Set fso=Nothing
	showErrorPage "该论文暂无"&arrFileListName(filetype)&"或已被删除！", "提示"
End If
Set file=fso.GetFile(source_file)
If Len(arrFileListNamePostfix(filetype)) Then
	newfilename=rs("SPECIALITY_NAME")&"-"&arrFileListNamePostfix(filetype)
Else
	subject=Replace(rs("THESIS_SUBJECT"),":","_")
	subject=Replace(subject,"""","_")
	subject=Replace(subject,"<","_")
	subject=Replace(subject,">","_")
	subject=Replace(subject,"?","_")
	subject=Replace(subject,"\","_")
	subject=Replace(subject,"/","_")
	subject=Replace(subject,"|","_")
	subject=Replace(subject,"*","_")
	newfilename=rs("SPECIALITY_NAME")&"-"&subject
End If
newfilename=newfilename&"."&fileExt
Set stream=Server.CreateObject("ADODB.Stream")
stream.Mode=3
stream.Type=1
stream.Open()
stream.LoadFromFile source_file
Response.Buffer=True
Response.Clear()
Session.Codepage=936
Response.AddHeader "Content-Disposition","attachment; filename="&newfilename
Response.AddHeader "Content-Type","application/octet-stream"
Response.AddHeader "Content-Length",file.Size
block_size=10240
Do While Not stream.EOS
	Response.BinaryWrite stream.Read(block_size)
	Response.Flush()
Loop
Session.Codepage=65001
stream.Close()
Set stream=Nothing
Set file=Nothing
Set fso=Nothing
CloseRs rs
CloseConn conn
%>