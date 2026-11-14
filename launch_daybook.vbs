' Research Daybook — Instant One-Click Launcher
Option Explicit
Dim WshShell, fso, appDir, targetHtml, candidates, cand
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

appDir = fso.GetParentFolderName(WScript.ScriptFullName)
targetHtml = appDir & "\daybook.html"

If Not fso.FileExists(targetHtml) Then
    Dim userProf
    userProf = WshShell.ExpandEnvironmentStrings("%USERPROFILE%")
    candidates = Array( _
        userProf & "\OneDrive\Desktop\02_Projects & Development\Research Daybook\daybook.html", _
        userProf & "\OneDrive\Desktop\Research Daybook\daybook.html", _
        userProf & "\OneDrive\Desktop\BrandFinder\ResearchDaybook\daybook.html", _
        userProf & "\Desktop\02_Projects & Development\Research Daybook\daybook.html" _
    )
    For Each cand In candidates
        If fso.FileExists(cand) Then
            targetHtml = cand
            appDir = fso.GetParentFolderName(cand)
            Exit For
        End If
    Next
End If

WshShell.CurrentDirectory = appDir
WshShell.Run "cmd.exe /c start """" """ & targetHtml & """", 0, False
