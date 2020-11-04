﻿<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("TId")) Then Response.Redirect("../error.asp?timeout")
paper_id=Request.QueryString("tid")
filetype=Request.QueryString("type")
If Not IsNumeric(filetype) Then
	bError=True
	errMsg="参数无效。"
ElseIf filetype<1 Or filetype>3 Then
	bError=True
	errMsg="参数无效。"
End If
If bError Then
	showErrorPage errMsg, "提示"
End If

Connect conn
sql=Format("SELECT * FROM ViewDissertations_expert WHERE ID={0}",paper_id)
GetRecordSetNoLock conn,rs,sql,count
If rs.EOF Then
	CloseRs rs
	CloseConn conn
	showErrorPage "数据库没有该论文记录！", "提示"
End If

Dim source_file,file_ext,newfilename
Dim fso,file,stream
Set fso=CreateFSO()
source_file=rs(arrFileListField(filetype))
If IsNull(source_file) Then
	source_file=""
Else
	If filetype=2 Or filetype=3 Then ' 评阅书则提供无学生信息版本
		source_file=resolvePath(arrFileListPath(filetype),fso.GetBaseName(source_file)&"_nostu.pdf")
	Else
		source_file=resolvePath(arrFileListPath(filetype),source_file)
	End If
	source_file=Server.MapPath(resolvePath(basePath(),source_file))
	file_ext=LCase(fso.GetExtensionName(source_file))
End If
If Not fso.FileExists(source_file) Then
	Set fso=Nothing
	showErrorPage "该论文暂无"&arrFileListName(filetype)&"或已被删除！", "提示"
End If
Set file=fso.GetFile(source_file)

subject=toFilenameString(rs("THESIS_SUBJECT").Value)
If Len(arrFileListNamePostfix(filetype)) Then
	newfilename=subject&"-"&arrFileListNamePostfix(filetype)
Else
	newfilename=subject
End If
newfilename=newfilename&"."&file_ext
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