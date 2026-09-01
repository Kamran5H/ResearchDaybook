' Research Daybook launcher
' Opens the app ONCE per calendar day, only at/after 10:00 AM.
' Marker + log live in %LOCALAPPDATA%\ResearchDaybook for reliability.
Option Explicit
Dim fso, sh, base, dataDir, marker, todayStr, last, testMode, hr, ov, f, g, targetHtml

Set fso = CreateObject("Scripting.FileSystemObject")
Set sh  = CreateObject("WScript.Shell")
base = fso.GetParentFolderName(WScript.ScriptFullName)

dataDir = sh.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\ResearchDaybook"
If Not fso.FolderExists(dataDir) Then fso.CreateFolder dataDir

testMode = (sh.ExpandEnvironmentStrings("%RDB_TEST%") = "1")
If testMode Then
  marker = dataDir & "\lastshown_test.txt"
Else
  marker = dataDir & "\lastshown.txt"
End If

todayStr = Year(Now) & "-" & Right("0" & Month(Now),2) & "-" & Right("0" & Day(Now),2)

' --- time guard (RDB_HOUR overrides the clock for testing only) ---
hr = Hour(Now)
ov = sh.ExpandEnvironmentStrings("%RDB_HOUR%")
If ov <> "" And ov <> "%RDB_HOUR%" And IsNumeric(ov) Then hr = CInt(ov)
If hr < 10 Then
  WriteLog "skip: before 10:00 (hr=" & hr & ")"
  WScript.Quit
End If

' --- once-per-day guard ---
last = ""
If fso.FileExists(marker) Then
  On Error Resume Next
  Set f = fso.OpenTextFile(marker, 1)
  If Not f.AtEndOfStream Then last = Trim(f.ReadLine)
  f.Close
  On Error Goto 0
End If

If last = todayStr Then
  WriteLog "skip: already shown today (" & todayStr & ")"
  WScript.Quit
End If

' --- mark FIRST (prevents double-opening if multiple triggers fire simultaneously) ---
On Error Resume Next
Set g = fso.CreateTextFile(marker, True)
g.WriteLine todayStr
g.Close
On Error Goto 0

targetHtml = base & "\daybook.html"
If Not fso.FileExists(targetHtml) Then
  targetHtml = "C:\Users\chkam\OneDrive\Desktop\BrandFinder\ResearchDaybook\daybook.html"
End If
If Not fso.FileExists(targetHtml) Then
  targetHtml = "C:\Users\chkam\OneDrive\Desktop\Research Daybook\daybook.html"
End If

If testMode Then
  WriteLog "TEST: would open app (" & targetHtml & "); marker set to " & todayStr
Else
  WriteLog "opened app (" & targetHtml & " on " & todayStr & ")"
  Dim browserExe
  browserExe = ""
  If fso.FileExists("C:\Program Files\Google\Chrome\Application\chrome.exe") Then
    browserExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"
  ElseIf fso.FileExists("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe") Then
    browserExe = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
  ElseIf fso.FileExists("C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe") Then
    browserExe = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
  ElseIf fso.FileExists("C:\Program Files\Microsoft\Edge\Application\msedge.exe") Then
    browserExe = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
  End If

  If browserExe <> "" Then
    sh.Run """" & browserExe & """ """ & targetHtml & """", 1, False
  Else
    sh.Run "cmd.exe /c start """" """ & targetHtml & """", 0, False
  End If
End If

Sub WriteLog(msg)
  Dim lf
  On Error Resume Next
  Set lf = fso.OpenTextFile(dataDir & "\log.txt", 8, True)
  lf.WriteLine Now & "  " & msg
  lf.Close
  On Error Goto 0
End Sub
