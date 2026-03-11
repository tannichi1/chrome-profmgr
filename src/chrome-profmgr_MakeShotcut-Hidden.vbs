'名前 XXXX_MakeShotcut[-hide][-v7].vbs - PowerShell の起動用ショートカットを作成
'説明
'	  PowerShell スクリプトの起動用ショートカットを作成します。
'
'	  PowerShell スクリプトは、このコマンド(vbsファイル) と同じ
'	フォルダにある、XXXX.ps1 というファイル名になります。ただし、
'	ps1 ファイルをこのコマンド(vbs ファイル) の起動時のコマンドライン
'	引数にした (一つまたは複数の ps1 ファイルを Drag & Drop して
'	このコマンドを起動した) 場合は、XXXX 部分は無視されて指定された
'	それぞれの ps1 ファイル用のショートカットを作成します。
'
'	  ショートカット作成パラメータはこのコマンド(vbsファイル) の
'	ファイル名から取得します。大文字・小文字は無視されます。
'		-hide または -hidden
'			PowerShell をウィンドウ非表示（サイレント）で実行します
'		-v7 または -pwsh
'			PowerShell 7 を使用してスクリプトを起動します。
'		-v5 (既定値)
'			PowerShell 5 を使用してスクリプトを起動します。
'
'
Option Explicit

'	--- 自分自身のパス名から各種パラメーターを取得する
Dim sVbsFullName, fso, sVbsFolder, sVbsBase
sVbsFullName = WScript.ScriptFullName
Set fso = CreateObject("Scripting.FileSystemObject")
sVbsFolder = fso.GetParentFolderName(sVbsFullName)
sVbsBase = fso.GetBaseName(sVbsFullName)

' PowerShell スクリプトの情報
Dim sPsFolder, sPsBase, sPsPath, sLinkName
sPsFolder = sVbsFolder
sPsBase = Mid(sVbsBase, 1, InStr(sVbsBase, "_") - 1)
sPsPath = sPsFolder & "\" & sPsBase & ".ps1"
sLinkName = sPsBase

' コマンドライン引数が与えられているならそれを ps1 ファイルとする
Dim aPsPath, i
aPsPath = Array(sPsPath)
If WScript.Arguments.Count > 0 Then
	ReDim aPsPath(WScript.Arguments.Count - 1)
	For i = 0 to (WScript.Arguments.Count - 1)
		aPsPath(i) = WScript.Arguments(i)
	Next
End If


' 動作パラメータ
Dim sVbsAfter, sVbsOpt, aVbsOpt
sVbsAfter = Mid(sVbsBase, InStr(sVbsBase, "_") + 1)
sVbsOpt = Mid(sVbsAfter, InStr(sVbsAfter, "-") + 1)
aVbsOpt = Split(sVbsOpt, "-")

'WScript.Echo "sPsBase=" & sPsBase
'WScript.Echo "sVbsAfter=" & sVbsAfter
'WScript.Echo "sVbsOpt=" & sVbsOpt

' 起動オプション
Dim sLinkOpt, sOpt, nWindowStyle, sTargetPath
nWindowStyle = 4 ' 3=Maximized 7=Minimized 4=Normal
sLinkOpt = "-ExecutionPolicy ByPass"
sTargetPath = "powershell"
For Each sOpt in aVbsOpt
	Select Case LCase(sOpt)
	  Case "MakeShotcut"
	  	' オプションが何もない場合
	  Case "hide", "hidden"
		sLinkOpt = sLinkOpt & " -WindowStyle Hidden"
		nWindowStyle = 7
	  Case "v7", "pwsh "
		sTargetPath = "pwsh"
	  Case "v6"
		sTargetPath = "powershell"
	  Case Else
		WScript.Echo "[X] Invalid option """ & sOpt & """"
		WScript.Quit
	End Select
Next ' sOpt


' --- ショートカットを作成する  ---
For i = 0 to Ubound(aPsPath)
	sPsPath = aPsPath(i)
	sLinkName = fso.GetBaseName(sPsPath)
	
	Dim WshShell, oLnk, sDesktop
	Set WshShell = WScript.CreateObject("WScript.Shell")
	sDesktop = WshShell.SpecialFolders("Desktop")
	Set oLnk = WshShell.CreateShortcut(sDesktop &"\"& sLinkName &".lnk")
	oLnk.TargetPath = sTargetPath
	oLnk.Arguments  = sLinkOpt & " -File " & sPsPath
	oLnk.WorkingDirectory = sPsFolder
	oLnk.WindowStyle = nWindowStyle
	oLnk.Save()
	WScript.Echo "Shortcut crated. name=" & sLinkName
Next

'###  END OF FILE  ###
