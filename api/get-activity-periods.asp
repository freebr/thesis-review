<%
'==========================================
' API 名称：    get-activity-periods
' API 功能：    提供已录入的评阅活动的开放时间信息
' API 输入类型：GET/POST
' API 输出类型：JSON
' 修订日期：    2019-04-27
'==========================================
%><!--#include file="../inc/global.inc"-->
<!--#include file="../admin/common.asp"-->
<!--#include file="../inc/api.asp"--><%

Function main(args)
    Dim data: Set data=CreateDictionary()
    Dim arg: Set arg=CreateDictionary()
    ensureArgument args, arg, data
    Dim conn,rs,sql,count
    Connect conn
    sql="DECLARE @a int=?,@b int=?;SELECT StuType,StuTypeName,COUNT(StuType) AS PeriodCount FROM ViewActivityPeriods WHERE ActivityId=@a AND (@b&StuTypeBitwise)<>0 GROUP BY StuType,StuTypeName ORDER BY StuTypeName;"&_
        "SELECT LTRIM(STR(StuType))+'-'+LTRIM(STR(SectionId)) Id,ClientTypeName+'/'+SectionName Name,StuType,ClientType,SectionId,Enabled,StartTime,EndTime FROM ViewActivityPeriods WHERE ActivityId=@a AND (@b&StuTypeBitwise)<>0 ORDER BY StuTypeName,ClientType,SectionId"
    Dim ret:Set ret=ExecQuery(conn,sql,_
        CmdParam("@a",adInteger,4,arg("activity_id")),_
        CmdParam("@b",adInteger,4,Session("AdminType")("ManageStuTypes")))
    Dim rsGroup:Set rsGroup=ret("rs")
    count=ret("count")

    Set rs=rsGroup.NextRecordSet()
    Dim arrGroup(): ReDim arrGroup(rsGroup.RecordCount-1)
    Dim arr
    Dim i: i=0
    Dim j
    Dim currentType
    Do While Not rs.EOF
        If currentType<>rs(2).Value Then
            currentType=rs(2).Value
            arr=Array(): ReDim arr(rsGroup(2).Value-1)
            Set arrGroup(i)=CreateDictionary()
            arrGroup(i).Add "id", rsGroup(0).Value
            arrGroup(i).Add "name", rsGroup(1).Value
            i=i+1
            j=0
            rsGroup.MoveNext()
        End If
        Dim dictItem: Set dictItem=CreateDictionary()
        Dim k
        For k=0 To rs.Fields.Count-1
            dictItem.Add rs.Fields(k).Name, rs(k).Value
        Next
        Set arr(j)=dictItem
        If j=UBound(arr) Then arrGroup(i-1)("children")=arr
        j=j+1
        rs.MoveNext()
    Loop
    data.Add "status", "ok"
    data.Add "data", arrGroup

    CloseRs rs
    CloseConn conn
    
    Call (new JSONWriter)(Response, data)
End Function

Call main("activity_id")
%>