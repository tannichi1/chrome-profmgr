#Name chrome-profmgr.ps1 - Google Chrome 用プロファイルマネージャー
#	en: Profle Manager for  Google Chrome
#
Set-StrictMode -Version Latest
###  アセンブリのロード  ###
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic	# InputBox
Add-Type -Assembly System.IO.Compression.FileSystem	# IO.Compression.ZipFile


###  設定  ###
#	  本当は、JSON で記述して外部ファイルとマージしたいのですが、
#	PowerShell 5 では、ConvertFrom-Json -AsHashtable が使えない
#	ので、PowerShell のハッシュテーブル記法でやります。 
#		※ PSCustomObject は階層的なデータ操作には向かないと思う
$config = @{
	# ---  メッセージ  ---
	"message{lang}"= @{
		#	  日本語を正しく表示させるために、このファイルは
		#	UTF8 (BOM付き) エンコードで保存してください。
		#	  To display Japanese characters correctly,
		#	save this file in UTF8 (with BOM) encoding.
		"translate_author"= @{
			"ja"= "tan1"
			"en"= "google translate [need help, Please correct the mistake]"
		}
		"topForm_ChromeProfileManager"= @{
			"ja"= "Chrome プロファイルマネージャー"
			"en"= "Chrome Profile Manager"
		}
		"profLabelText_ProfileList"= @{
			"ja"= "プロファイル一覧"
			"en"= "Profile List"
		}
		"profRecurseText_RecursiveSsearch"= @{
			"ja"= "再帰的に検索"
			"en"= "Recursive search"
		}
		
		#---  ボタン「新規作成」  ---
		"createBtnText_New"= @{
			"ja"= "新規作成..."
			"en"= "New..."
		}
		"createAnnounceText_NewNameInput"= @{
			"ja"= "新規に作成するプロファイル名を入力してください。`n　　※名前は既存のものと重複しないように`n`n　　作成すると実際に起動し、テーマの設定ページを開きます"
			"en"= "Enter the name of the new profile you want to create.`n　　※The name must not overlap with an existing one`n`n　　Once created, it will actually launch and open the theme settings page."
		}
		"createAnnounceTitle_NewNameInput"= @{
			"ja"= "新規プロファイル名の入力"
			"en"= "New Pfofile name Input"
		}
		"createDuplicateErrorText_DuplicateError"= @{
			"ja"= "その名前(フォルダまたはファイル)は存在します。`n　別の名前にしてください"
			"en"= "The name (folder or file) exists.`n　Please choose another name"
		}
		"createDuplicateErrorTitle_DuplicateError"= @{
			"ja"= "重複エラー"
			"en"= "Duplicate error"
		}
		
		#---  ボタン「フォルダを開く」  ---
		"explorerBtnText_OpenFolder"= @{
			"ja"= "フォルダを開く"
			"en"= "open folder"
		}
		"explorerBtnTooltip_OpenFolderInExplorer"= @{
			"ja"= "プロファイル配置フォルダをエクスプローラで開きます。`n　細かい操作を直接行いたい場合に使用してください。"
			"en"= "Open the profile deployment folder in Explorer.`n　Use this when you want to perform detailed operations directly."
		}
		
		#---  userAgnet  ---
		"uaLabelText_UaSwitch"= @{
			"ja"= "UA偽装"
			"en"= "UA-Switch"
		}
		"uaLabelTooltip_UaSwitch"= @{
			"ja"= "Webサーバーに対してスマートフォン上のブラウザからアクセスしていると見せかけます。`n　これによって、スマートフォン専用のブラウザアプリを開くことができます。"
			"en"= "It makes it appear as if you are accessing the web server from a browser on your smartphone.`n　This will open a browser app for your smartphone."
		}
		
		#---  引数  ---
		"argLabelText_Argumnents"= @{
			"ja"= "引数"
			"en"= "Argumnents"
		}
		
		#--- 選択されたプロファイル情報の取得  ---
		"lunchOpNoProf_SelectAProfile"= @{
			"ja"= "プロファイルを選択してください"
			"en"= "Please select a profile"
		}
		
		#--- ボタン「起動」 ---
		"lunchBtnText_Lunch"= @{
			"ja"= "起動"
			"en"= "Lunch"
		}
		
		#--- ボタン「ショートカット作成」 ---
		"linkBtnText_LinkCreate"= @{
			"ja"= "ショートカット作成..."
			"en"= "Create shortcut..."
		}
		"linkInputNameText_ProfNameInput"= @{
			"ja"= "ショートカットの名の名前を指定してください。`n　　※デスクトップ上に作成されます"
			"en"= "Specify the name of the shortcut.。`n　　※It will be created on your desktop"
		}
		"linkInputNameTitle_ProfNameInput"= @{
			"ja"= "新規ショートカットの名の"
			"en"= "Name of the new shortcut"
		}
		
		#--- ボタン「リネーム...」 ---
		"renameBtnText_Rename"= @{
			"ja"= "リネーム..."
			"en"= "rename..."
		}
		"renameNewNameText_NewName"= @{
			"ja"= "変更先のプロファイル名を入力してください。"
			"en"= "Enter the name of the profile you want to change to."
		}
		"renameNewNameTitle_NewName"= @{
			"ja"= "変更先プロファイル名の入力"
			"en"= "new profile name"
		}
		"renameDupErrText_NameDuplicate"= @{
			"ja"= "その名前(フォルダまたはファイル)は存在します。`n　別の名前にしてください"
			"en"= "The name (folder or file) exists.`n　Please choose another name"
		}
		"renameDupErrTitle_NameDuplicate"= @{
			"ja"= "重複エラー"
			"en"= "Duplicate error"
		}
		"renameCatchText_RenameException"= @{
			"ja"= "プロファイル名の変更に失敗しました。`n`n{0}"
			"en"= "Failed to change profile name.`n`n{0}"
		}
		"renameCatchTitle_RenameException"= @{
			"ja"= "プロファイル名の変更に失敗"
			"en"= "Failed to change profile name."
		}
		
		#--- ボタン「ダウンロード...」 ---
		"saveBtnText_Dounload"= @{
			"ja"= "ダウンロード..."
			"en"= "Download"
		}
		"saveNewNameText_NameSave"= @{
			"ja"= "作成するZIPファイル名を入力してください。`n　※注意:デスクトップに出力されます`n　※注意:結構時間がかかります"
			"en"= "Enter the name of the ZIP file to be created.`n　※caution:It will be output to your desktop.`n　※caution:It takes quite a while"
		}
		"saveNewNameTitle_NameSave"= @{
			"ja"= "保存ファイル名"
			"en"= "save file name"
		}
		"saveExceptionText_CompressFailed"= @{
			"ja"= "圧縮に失敗しました`n{0}"
			"en"= "Compression failed`n{0}"
		}
		"saveExceptionTitle_CompressFailed"= @{
			"ja"= "圧縮に失敗"
			"en"= "Compression failed"
		}
		
		
		#--- ボタン「アップロード...」 ---
		"loadBtnText_Upload"= @{
			"ja"= "アップロード..."
			"en"= "Upload..."
		}
		"loadBtnAnnounceText_NotThis"= @{
			"ja"= "残念 (っ*`👅´c)。その機能はここではありません。`n　プロファイル一覧に zip ファイルを Drag&Drop してください"
			"en"= "Sorry, that feature isn't available here.`n　Drag and drop the zip file into the profile list."
		}
		"loadBtnAnnounceTitle_OpError"= @{
			"ja"= "操作エラー"
			"en"= "Operation error"
		}
		"loadOneByOneText_PlzZipOneByOne"= @{
			"ja"= "zip ファイルはひとつずつ指定してください。"
			"en"= "Please specify each zip file one by one."
		}
		"loadOneByOneTitle_OperatonError"= @{
			"ja"= "操作エラー"
			"en"= "Operation error"
		}
		"loadNotZipText_NotZipFile"= @{
			"ja"= "zip ファイルを指定してください。`n`n{0}"
			"en"= "Please specify a zip file.`n`n{0}"
		}
		"loadNotZipTitle_DataError"= @{
			"ja"= "データーエラー"
			"en"= "data error"
		}
		"loadZipEmptyText_EmptyZipFile"= @{
			"ja"= "zip ファイルの中身が空です。"
			"en"= "The zip file is empty."
		}
		"loadZipEmptyTitle_DataError"= @{
			"ja"= "データーエラー"
			"en"= "data error"
		}
		"loadProfExistText_ProfileIsAlreadyExists"= @{
			"ja"= "書き込もうとしたプロファイルはすでに存在します。`n　既存のプロファイルを別の名前にするなどしてください。`n プロファイル名={0}"
			"en"= "The profile you are trying to write already exists.`n　Give your existing profile a different name, etc.`n profile name={0}"
		}
		"loadProfExistTitle_DuplicateError"= @{
			"ja"= "重複エラー"
			"en"= "Duplicate error"
		}
		"loadStartText_LoadProfileStart"= @{
			"ja"= "プロファイルの展開を開始します。`n　※少し時間がかかります`n プロファイル名={0}"
			"en"= "Start the profile deployment.`n　※It will take some time`n profile name={0}"
		}
		"loadStartTitle_LoadProfileStart"= @{
			"ja"= "プロファイル展開開始"
			"en"= "Start profile deployment"
		}
		"loadExceptionText_ExpandFailed"= @{
			"ja"= "解凍に失敗しました`n{0}"
			"en"= "UnCompression failed`n{0}"
		}
		"loadExceptionTitle_ExpandFailed"= @{
			"ja"= "圧縮に失敗"
			"en"= "UnCompression failed"
		}
		
		
		#--- ボタン「削除...」 ---
		"delBtnText_Delete"= @{
			"ja"= "削除..."
			"en"= "Delete..."
		}
		"delStartOKText_DelStartOK"= @{
			"ja"= "プロファイルを削除します。`n　※ 元に戻せませんよ。本当に削除しますか？`n プロファイル名={0}"
			"en"= "Delete your profile.`n　※ You can't undo it. Are you sure you want to delete it?`n profile name={0}"
		}
		"delStartOKTitle_DelStartOK"= @{
			"ja"= "プロファイル削除開始"
			"en"= "Start profile deletion"
		}
		"delExceptionText_DelException"= @{
			"ja"= "何かエラーになっちゃった。`n`n------`n{0}"
			"en"= "Something went wrong.`n`n------`n{0}"
		}
		"delExceptionTitle_DelException"= @{
			"ja"= "削除エラー"
			"en"= "Delete Error"
		}
		
		
		###  一覧用とか  ###
		"txt_None"= @{
			"ja"= "なし"
			"en"= "None"
		}
		"txt_Theme"= @{
			"ja"= "テーマ"
			"en"= "theme"
		}
	}
	
	
	# ---  UserAgent  ---
	"userAgentList" = @(
		@{ "name" = "txt_None"; "value" = "" }
		@{ "name" = "Android 4"; "value" = "Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2150.5 Mobile Safari/537.36" }
		@{ "name" = "Android 11"; "value" = "Mozilla/5.0 (Linux; Android 11; Pixel 4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.210 Mobile Safari/537.36" }
		@{ "name" = "iPhone 14"; "value" = "Mozilla/5.0 (iPhone; CPU iPhone OS 14_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/91.0.4472.80 Mobile/15E148 Safari/604.1" }
	)
	
	# ---  引数  ---
	"themesURL" = "https://chrome.google.com/webstore/category/themes"
	"argumentList" = @(
		@{ "name" = "txt_None"; "value" = "" }
		@{ "name" = "txt_Theme"; "value" = "https://chrome.google.com/webstore/category/themes" }
		@{ "name" = "gmail"; "value" = "https://mail.google.com/mail/" }
	)
	

	# ---  その他オプション  ---
	"link_with_icon" = $false	# ショートカット作成ときにアイコンを設定する
}

#---  言語一覧  ---
$config.langList = @(
	((Get-UICulture).Name),
	((Get-UICulture).Name).Substring(0, 2),
	($env:LANG),
	#((Get-Culture).Name),
	((Get-WinUserLanguageList).LanguageTag),
	"en"
)
Write-Host "langList=$($config.langList)"


#---  言語依存のテキストを解決  ---
function config_parse_lang_a($src){
	$dst = @{}
	:nameLoop foreach($name in $src.Keys){	# ERR: Keys が無いと言われる
	#:nameLoop foreach($name in $src.psobject.Properties.Name){
		$vals = $src[$name]
		#Write-Host "name=$name, vals=$vals"
		foreach($lang in $config.langList){
			if($vals.ContainsKey($lang)){
			#if($vals.psobject.Properties[$lang]){
				$dst[$name] = $vals.$lang
				#Write-Host ("set $name="+ $dst[$name])
				continue nameLoop
			}
		}
		# 無かったら名前の下線以下を設定する
		$usidx = $name.IndexOf("_")
		$dst[$name] = $name.Substring($usidx + 1)
		#Write-Host ("set $name="+ $dst[$name])
	}
	return	$dst
}
$config.message = config_parse_lang_a($config."message{lang}")
#$config.message | ConvertTo-Json


#---  テキスト変換処理  ---
function msg() {
	#$fmt = $args[0]
	#$params = @()
	#if($args.Length -gt 1){
	#	$params = $args[1..($args.Length - 1)]
	#}
	param(
		[string] $fmt,
		[Parameter(ValueFromRemainingArguments)] [string[]]$params
	)
	if($config.message.ContainsKey($fmt)){
		$fmt = $config.message[$fmt]
	}
	return ($fmt -f $params)
}


###  環境及び Google Chrome の 情報  #####
$desktopDir = [System.Environment]::GetFolderPath("Desktop")
$usrDataDirBase = "$env:LOCALAPPDATA\Google\Chrome"
#$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

# アプリ情報を取得
#	参照	PowerShellでアプリ情報を取得する
#		https://qiita.com/sakekasunuts/items/106f9c0f828a07e81592
$chromeInstallPathObj = Get-ChildItem -Path (
	'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
	'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
	'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall') |
	% { Get-ItemProperty $_.PsPath |
		Where-Object { $_.PSObject.Properties['DisplayName'] } |
		Where-Object { $_.DisplayName -eq "Google Chrome" } |
		Select-Object InstallLocation }
$chromeInstallPath = $chromeInstallPathObj[0].InstallLocation
#$chromeExePath = $chromeInstallPath "\chrome.exe"
$chromeExePath = Join-Path -Path $chromeInstallPath -ChildPath "chrome.exe"
Write-Host "chromeInstallPath=$chromeInstallPath"
Write-Host "chromeExePath=$chromeExePath"



###  画面の作成  #####
# フォームが閉じられたときに実行される関数
function screen_formclosing(){
    param(
        [System.Windows.Forms.Form]$send_from,
        [System.Windows.Forms.FormClosingEventArgs]$eh
    )
    #[void] [System.Windows.Forms.MessageBox]::show("バイバイ", "",[System.Windows.Forms.MessageBoxButtons]::OK)
	#Write-Host "フォームが閉じられました"
}


#---  画面の配置やサイズ  ---
$buttonSize = New-Object System.Drawing.Size(100, 20)
$buttonX0	= 10	# 左端のボタン X 座標
function button_location_prof($line, $column){	#プロファイル依存のボタンの配置
	$x = 10  + (($column - 1) * 110)
	$y = 260 + (($line   - 1) * 30)
	return	New-Object System.Drawing.Point($x, $y)
}


#--- プロファイル依存のコントロールの活性化  ---
$lunchBtn = @{ Enabled = $false }
$linkBtn = @{ Enabled = $false }
$renameBtn = @{ Enabled = $false }
$saveBtn = @{ Enabled = $false }
$loadBtn = @{ Enabled = $false }
$deleteBtn = @{ Enabled = $false }
function prof_depend_enable($enable){
	$lunchBtn.Enabled = $enable
	$linkBtn.Enabled = $enable
	$renameBtn.Enabled = $enable
	$saveBtn.Enabled = $enable
	#$loadBtn.Enabled = $enable
	$saveBtn.Enabled = $enable
	$deleteBtn.Enabled = $enable
}



#---  フォームの作成・表示  ---
$topForm  = New-Object System.Windows.Forms.Form -Property @{
	Size		= New-Object System.Drawing.Size(500, 380)
	MinimumSize	= New-Object System.Drawing.Size(400, 340)
	Text = (msg topForm_ChromeProfileManager)
	SizeGripStyle = [System.Windows.Forms.SizeGripStyle]::Show
	Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($chromeExePath)
}
$topForm.Show()
$topForm.Activate()
$topForm.Add_FormClosing({param($s,$e) screen_formclosing $s $e})

#---  ツールチップ(共有)  ---
$tooltip = New-Object System.Windows.Forms.ToolTip -Property @{
	AutoPopDelay = 5000
	InitialDelay = 1000
	ReshowDelay = 500
	ShowAlways = $true
}


# ラベルを表示
$profLabel = New-Object System.Windows.Forms.Label -Property @{
	Location = New-Object System.Drawing.Point(10,10)
	Size = New-Object System.Drawing.Size(100,20)
	Text = (msg profLabelText_ProfileList)
}
$topForm.Controls.Add($profLabel)

# チェック □再帰的に検索
$profRecurse = New-Object System.Windows.Forms.CheckBox -Property @{
	Location = New-Object System.Drawing.Point(110,10)
	Size	= New-Object System.Drawing.Size(150,20)
	Text	= (msg profRecurseText_RecursiveSsearch)
	Checked	= $false
}
$topForm.Controls.Add($profRecurse)

$profListBox = New-Object System.Windows.Forms.ListBox -Property @{
	Location = New-Object System.Drawing.Point(10,30)
	Size = New-Object System.Drawing.Size(210,150)
	#Size = New-Object System.Drawing.Size(180,100)
	HorizontalScrollbar = $true
	AllowDrop = $true
}
$topForm.Controls.Add($profListBox)

$iconImage = New-Object Windows.Forms.PictureBox -Property @{
	Location = New-Object System.Drawing.Point(250,30)
	Size = New-Object System.Drawing.Size(100,100)
	SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
}
$topForm.Controls.Add($iconImage)


### プロファイル一覧のロード  #####
#Get-ChildItem -Path "$env:LOCALAPPDATA\Google\Chrome\User Data" -Recurse -File -Include first_party_sets.db | Select-Object -ExpandProperty FullName

New-Variable -Option AllScope -Name profArray
$profArray = @()
function prof_reload(){
	Write-Host "in prof_reload, Recurse=" $profRecurse.Checked
	$iconImage.Image = $null
	[void] $profListBox.Items.Clear()
	$udds = $null
	#$basePath = "${usrDataDirBase}\*\first_party_sets.db"
	#$basePath = "${usrDataDirBase}\*\heavy_ad_intervention_opt_out.db"
	$basePath = (
		#"${usrDataDirBase}\*\heavy_ad_intervention_opt_out.db",
		"${usrDataDirBase}\*\first_party_sets.db")
	if($profRecurse.Checked -eq $true){
		###$udds = Get-ChildItem -Path $usrDataDir -Recurse -File -Include first_party_sets.db | Split-Path -Parent
		$udds = Get-ChildItem -Path $basePath -Recurse | Split-Path -Parent
	}else{
		$udds = Get-ChildItem -Path $basePath | Split-Path -Parent
	}
	#$profArray = @()	##NG: ローカル変数を作成してしまう
	#Clear-Variable profArray
	#[System.Array]::Clear($profArray, 0, $profArray.Length)
	$script:profArray = @()
	foreach($udd in $udds){
		#Write-Host $udd
		#$profName = $udd.Substring($usrDataDirBase.Length + 1)
		$profObj = [PSCustomObject]@{
			dir=$udd;
			name=$udd.Substring($usrDataDirBase.Length + 1);
			icon=$null
		}
		$profArray += $profObj
		#Write-Host $profObj.name
		[void] $profListBox.Items.Add($profObj.name)
	}
	#Write-Host "配列数: " $profArray.Count " or " $profArray.Length
	prof_depend_enable $false
}
$profRecurse.Add_CheckStateChanged({
	prof_reload
})
prof_reload


$profListBox.Add_SelectedIndexChanged({
	$index = $profListBox.SelectedIndex
    if ($index -ne -1) {
		$profObj = $profArray[$index]
		Write-Host "選択された項目: [" $index "]=" $profObj.name
		#$imagePath = $profObj.dir + "\Default\Google Profile Picture.png"
		#try{
		#	$iconImage.Image = [System.Drawing.Image]::FromFile($imagePath)
		#}catch{
		#	$iconImage.Image = $null
		#}
		$iconImage.Image = $null
		$profObjDir = $profObj.dir
		$profObj.icon = $null
		:imgFind foreach($imagePath in (
				"$profObjDir\Default\Google Profile Picture.png",
				"$profObjDir\Google Profile Picture.png")){
			if(Test-Path $imagePath){
				$profObj.icon = $imagePath
				#NG $iconImage.Image = [System.Drawing.Image]::FromFile($imagePath)
				# ファイルがロックされて、リネームや削除ができなくなる
				#see https://stackoverflow.com/questions/788335/why-does-image-fromfile-keep-a-file-handle-open-sometimes
				$iconImage.Image = [System.Drawing.Image]::FromStream(
					[System.IO.MemoryStream]::new([System.IO.File]::ReadAllBytes($imagePath)))
				break imgFind
			}
		}
		
		prof_depend_enable $true
   }
})


###  プロファイルの新規作成  ###
#---  ボタン「新規作成」  ---
$createBtn = New-Object Windows.Forms.Button -Property @{
	Location = New-Object System.Drawing.Point(250,160)
	Size	= New-Object System.Drawing.Size(100, 20)
	text	= (msg createBtnText_New)
}
$createBtn.Add_Click({
	#Write-Host "ボタン「新規作成」が押されました"
	#$profName = [Microsoft.VisualBasic.Interaction]::InputBox(
	#	"新規に作成するプロファイル名を入力してください。" +
	#		"`n　　※名前は既存のものと重複しないように" +
	#		"`n`n　　作成すると実際に起動し、テーマの設定ページを開きます",
	#	"新規プロファイル名の入力")
	$profName = [Microsoft.VisualBasic.Interaction]::InputBox(
		(msg createAnnounceText_NewNameInput).
		(msg createAnnounceTitle_NewNameInput))
	Write-Host "profName=$profName"
	if([string]::IsNullOrWhiteSpace($profName)){
		return;	# キャンセル または 未入力 (区別する簡単な方法は無いらしい)
	}
	
	$profPath = Join-Path -Path $usrDataDirBase -ChildPath $profName
	if(Test-Path -Path $profPath){
		#	"その名前(フォルダまたはファイル)は存在します。" +
		#		"`n　別の名前にしてください",
		#	"重複エラー",
		[void] [System.Windows.Forms.MessageBox]::show(
			(msg createDuplicateErrorText_DuplicateError),
			(msg createDuplicateErrorTitle_DuplicateError),
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Error)
		return
	}
	
	#   空のフォルダを作成すると失敗した場合にゴミが残るのでしない
	# ただし、プロファイルの再検索のタイミングに注意する必要がある
	$args = " --user-data-dir=""$profPath"" $config.themesURL"
	Write-Host "args=$args"
	Start-Process $chromeExePath -ArgumentList $args -WorkingDirectory $chromeInstallPath
	
	
	# 少し待ってプロファイルの再検索を行う
	Start-Sleep -Seconds 3.0	# 結構ヒマがかかる
	prof_reload
})
$topForm.Controls.Add($createBtn)


#---  ボタン「フォルダを開く」  ---
$explorerBtn = New-Object Windows.Forms.Button -Property @{
	Location = New-Object System.Drawing.Point(360,160)
	Size	= New-Object System.Drawing.Size(100, 20)
	#text	= "フォルダを開く"
	text	= (msg explorerBtnText_OpenFolder)
}
$tooltip.SetToolTip($explorerBtn,
	#"プロファイル配置フォルダをエクスプローラで開きます。"+
	#	"`n　細かい操作を直接行いたい場合に使用してください。")
	(msg explorerBtnTooltip_OpenFolderInExplorer))
$explorerBtn.Add_Click({
	Invoke-Item	$usrDataDirBase
})
$topForm.Controls.Add($explorerBtn)


###  起動パラメーター  ###

#---  userAgnet  ---
$uaLabel = New-Object System.Windows.Forms.Label -Property @{
	Location = New-Object System.Drawing.Point(10,201);
	Size	= New-Object System.Drawing.Size(80,20);
	Text	= (msg uaLabelText_UaSwitch)
}
$tooltip.SetToolTip($uaLabel, (msg uaLabelTooltip_UaSwitch))
$topForm.Controls.Add($uaLabel)
$uaComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
	Location = New-Object System.Drawing.Point(100,200);
	Size	= New-Object System.Drawing.Size(100,20);
	DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList # 編集不可
}
$topForm.Controls.Add($uaComboBox)
foreach($uaObj in $config.userAgentList){
	$uaObj.name = (msg $uaObj.name)
    [void] $uaComboBox.Items.Add($uaObj.name)
}
$uaComboBox.SelectedIndex = 0

#---  引数  ---
$argLabel = New-Object System.Windows.Forms.Label -Property @{
	Location = New-Object System.Drawing.Point(10, 221);
	Size	= New-Object System.Drawing.Size(80, 20);
	Text	= (msg argLabelText_Argumnents)
}
$topForm.Controls.Add($argLabel)
$argComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
	Location = New-Object System.Drawing.Point(100, 221);
	Size	= New-Object System.Drawing.Size(100, 20);
	DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList # 編集不可
}
$topForm.Controls.Add($argComboBox)
foreach($argObj in $config.argumentList){
	$argObj.name = (msg $argObj.name)
    [void] $argComboBox.Items.Add($argObj.name)
}
$argComboBox.SelectedIndex = 0
$argTextBox = New-Object System.Windows.Forms.TextBox -Property @{
	Location = New-Object System.Drawing.Point(180, 220);
	Size	= New-Object System.Drawing.Size(280, 20);
	Text	= ""
}
$topForm.Controls.Add($argTextBox)
function arg_changed(){
	$index = $argComboBox.SelectedIndex
	$argObj = $config.argumentList[$index]
	$argTextBox.Text = $argObj.value
}
$argComboBox.Add_SelectedIndexChanged({ arg_changed })


###  選択されたプロファイルの操作  ###

#--- 選択されたプロファイル情報の取得  ---
function lunch_info_get(){
	$profIndex = $profListBox.SelectedIndex
    if($profIndex -lt 0){
		[void] [System.Windows.Forms.MessageBox]::show(
			(msg lunchOpNoProf_SelectAProfile),
			"",
			[System.Windows.Forms.MessageBoxButtons]::OK)
		return $null
	}
	Write-Host "profIndex=" $profIndex
	$profObj = $profArray[$profIndex]
	
	$uaIndex = $uaComboBox.SelectedIndex
	$uaObj = $config.userAgentList[$uaIndex]
	#$argIndex = $argComboBox.SelectedIndex
	#$argText  = $argTextBox.Text
	
	$args = ""
	if($uaObj.value -ne ""){
		$args += " --user-agent=""$($uaObj.value)"" "
	}
	$args += " --user-data-dir=""${usrDataDirBase}\$($profObj.name)"" "
	$args += " $($argTextBox.Text)"
	
	return	@{
		profIndex	= $profIndex
		profObj		= $profObj
		name		= $profObj.name
		uaIndex		= $uaIndex
		uaObj		= $uaObj
		argText		= $argTextBox.Text
		args		= $args
	}
}


#--- ボタン「起動」 ---
$lunchBtn = New-Object Windows.Forms.Button -Property @{
	Location = button_location_prof 1 1
	Size	= $buttonSize
	text	= (msg lunchBtnText_Lunch)
}
$lunchBtn.Add_Click({
	$lunch = lunch_info_get
	if($lunch -eq $null){
		return
	}
	Write-Host "args=$($lunch.args)"
	Start-Process $chromeExePath -ArgumentList $lunch.args -WorkingDirectory $chromeInstallPath
})
$topForm.Controls.Add($lunchBtn)


#--- ボタン「ショートカット作成」 ---
$linkBtn = New-Object Windows.Forms.Button -Property @{
	Location = button_location_prof 1 2
	Size	= $buttonSize
	text	= (msg linkBtnText_LinkCreate)
}
$linkBtn.Add_Click({
	#Write-Host "ボタン「ショートカット作成」が押されました"
	$lunch = lunch_info_get
	if($lunch -eq $null){
		return
	}
	#Write-Host "lunch.args=$($lunch.args)"
	$linkOldName = $lunch.name
	if(-not [string]::IsNullOrEmpty($lunch.uaObj.value)){
		$linkOldName += ("(" + $lunch.uaObj.name +")")
	}
	$argIndex = $argComboBox.SelectedIndex
	$argObj = $config.argumentList[$argIndex]
	if(-not [string]::IsNullOrEmpty($argObj.value)){
		$linkOldName += ("(" + $argObj.name +")")
	}
	
	$linkName = [Microsoft.VisualBasic.Interaction]::InputBox(
		#"ショートカットの名の名前を指定してください。" +
		#	"`n　　※デスクトップ上に作成されます",
		#"新規ショートカットの名の入力")
		(msg linkInputNameText_ProfNameInput),
		(msg linkInputNameTitle_ProfNameInput),
		$linkOldName)
	#Write-Host "linkName=$linkName"
	if([string]::IsNullOrWhiteSpace($linkName)){
		return;	# キャンセル または 未入力 (区別する簡単な方法は無いらしい)
	}
	#$desktopDir = [System.Environment]::GetFolderPath("Desktop")
	$scPath = Join-Path -Path $desktopDir -ChildPath "${linkName}.lnk"
	Write-Host "scPath=$scPath)"
	
	# PowerShell にはショートカット作成の機能は無いみたいなので WSH を使用する
	$WshShell = New-Object -ComObject WScript.Shell
	$scObj = $WshShell.CreateShortcut($scPath)
	$scObj.WindowStyle = 4	# 3=Maximized 7=Minimized 4=Normal
	#---  アイコンを設定したかったが16色アイコンしか設定できなかった(T^T)  ---
	#$scObj.IconLocation = ???
	if($config.link_with_icon -and ($lunch.profObj.icon -ne $null)){
		# PNG ファイルは直接アイコンに指定できないので変換する
		$pngPath  = $lunch.profObj.icon
		$iconPath = [System.IO.Path]::ChangeExtension($pngPath, ".ico")
		if($true){ #if( -not (Test-Path $iconPath) ){	#毎回作る
			$img = [System.Drawing.Image]::FromFile($pngPath)
			$bitmap = [System.Drawing.Bitmap]$img
			$iconBitmap = New-Object System.Drawing.Bitmap($bitmap, 256, 256) # サイズ調整
			$stream = [System.IO.File]::Create($iconPath)
			#$iconBitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Icon) #NG エラーになる
			# bitmap を直接 Save するとエラーになるので、一旦 Icon を作成する
			#	ただしこの方法だと、16色になってしまう
			$icon = [System.Drawing.Icon]::FromHandle($iconBitmap.GetHicon())
			$icon.Save($stream)
			$icon.Dispose()
			$stream.Close()
			$iconBitmap.Dispose()
			$img.Dispose()
		}
		$scObj.IconLocation = $iconPath
	}
	
	$scObj.TargetPath 	= ${chromeExePath}
	$scObj.Arguments	= $lunch.args
	#$scObj.Hotkey = "ALT+CTRL+F"
	$scObj.Save()
})
$topForm.Controls.Add($linkBtn)


#--- ボタン「リネーム...」 ---
$renameBtn = New-Object Windows.Forms.Button -Property @{
	Location = (button_location_prof 2 1)
	Size	= $buttonSize
	Text	= (msg renameBtnText_Rename)
}
$renameBtn.Add_Click({
	$lunch = lunch_info_get
	if($lunch -eq $null){
		return
	}
	$profOldName = $lunch.profObj.name
	$profNewName = [Microsoft.VisualBasic.Interaction]::InputBox(
		#"変更先のプロファイル名を入力してください。" +
		#	"`n　元の名前は 「" + $profOldName + "」 です",
		#"変更先プロファイル名の入力")
		(msg renameNewNameText_NewName),
		(msg renameNewNameTitle_NewName),
		$profOldName)
	Write-Host "profName=$profOldName -> $profNewName"
	if([string]::IsNullOrWhiteSpace($profNewName)){
		return;	# キャンセル または 未入力 (区別する簡単な方法は無いらしい)
	}
	
	$profOldPath = Join-Path -Path $usrDataDirBase -ChildPath $profOldName
	$profNewPath = Join-Path -Path $usrDataDirBase -ChildPath $profNewName
	if(Test-Path -Path $profNewPath){
		[void] [System.Windows.Forms.MessageBox]::show(
			#"その名前(フォルダまたはファイル)は存在します。" +
			#	"`n　別の名前にしてください",
			#"重複エラー",
			(msg renameDupErrText_NameDuplicate),
			(msg renameDupErrTitle_NameDuplicate),
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Error)
		return
	}
	
	try{
		Rename-Item -Path $profOldPath -NewName $profNewPath -ErrorAction Stop
	}catch{
		$ex = $_
		[void] [System.Windows.Forms.MessageBox]::show(
			(msg renameCatchText_RenameException $ex),
			(msg renameCatchTitle_RenameException),
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Error)
		return
	}
	
	# プロファイルを再読み込みする(待たない)
	prof_reload
})
$topForm.Controls.Add($renameBtn)


#--- ボタン「ダウンロード...」 ---
$saveBtn = New-Object Windows.Forms.Button -Property @{
	Location = button_location_prof 2 2
	Size	= $buttonSize
	Text	= (msg saveBtnText_Dounload)
}
$saveBtn.Add_Click({
	$lunch = lunch_info_get
	if($lunch -eq $null){
		return
	}
	$profOldName = $lunch.profObj.name
	$saveOldName = $profOldName + "-" + (Get-Date -Format "yyyyMMdd") + ".zip"
	$saveNewName = [Microsoft.VisualBasic.Interaction]::InputBox(
		#"ダウンロード先のファイル名を入力してください。" +
		#	"`n　※注意:デスクトップに出力されます" +
		#	"`n　※注意:結構時間がかかります",
		#"ダウンロード先プロファイル名の入力",
		(msg saveNewNameText_NameSave),
		(msg saveNewNameTitle_NameSave),
		$saveOldName)
	Write-Host "profName=$profOldName -> $saveNewName"
	if([string]::IsNullOrWhiteSpace($saveNewName)){
		return;	# キャンセル または 未入力 (区別する簡単な方法は無いらしい)
	}
	
	#$desktopDir = [System.Environment]::GetFolderPath("Desktop")
	$profOldPath = Join-Path -Path $usrDataDirBase -ChildPath $profOldName
	$saveNewPath = Join-Path -Path $desktopDir -ChildPath $saveNewName
	if(Test-Path -Path $saveNewPath){
		[void] [System.Windows.Forms.MessageBox]::show(
			#"その名前(フォルダまたはファイル)は存在します。" +
			#	"`n　別の名前にしてください",
			#"重複エラー",
			(msg renameDupErrText_NameDuplicate),
			(msg renameDupErrTitle_NameDuplicate),
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Error)
		return
	}
	
	$oldCursor = $topForm.Cursor
	try{
		# うまく砂時計に変わらない
		$topForm.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
		#$topForm.Cursor = [System.Windows.Input.Cursors]::Wait
		$topForm.Enabled = $false
		#Start-Sleep -Seconds 3
		
		# 圧縮
		Compress-Archive -Path $profOldPath -DestinationPath $saveNewPath -ErrorAction Stop
		##	-CompressionLevel "Optimal"
		#$job = Start-Job -ScriptBlock {
		#	Compress-Archive -Path $profOldPath -DestinationPath $saveNewPath
		#}
	}catch{
		$ex = $_
		[void] [System.Windows.Forms.MessageBox]::show(
			(msg saveExceptionText_CompressFailed $ex),
			(msg saveExceptionTitle_CompressFailed),
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Error)
	}finally{
		$topForm.Cursor = $oldCursor
		$topForm.Enabled = $true
	}
})
$topForm.Controls.Add($saveBtn)


#--- ボタン「アップロード...」 ---
$loadBtn = New-Object Windows.Forms.Button -Property @{
	Location = button_location_prof 2 3
	Size	= $buttonSize
	text	= (msg loadBtnText_Upload) # "アップロード..."
}
$loadBtn.Add_Click({
	[void] [System.Windows.Forms.MessageBox]::show(
		#"残念。その機能はここではありません。  (>_<)" +
		#	"`n　プロファイル一覧に zip ファイルをドロップしてください",
		#"操作エラー",
		(msg loadBtnAnnounceText_NotThis),
		(msg loadBtnAnnounceTitle_OpError),
		[System.Windows.Forms.MessageBoxButtons]::OK,
		[System.Windows.Forms.MessageBoxIcon]::Error)
	return
})
$topForm.Controls.Add($loadBtn)
$profListBox.Add_DragDrop({
	# Drop でないなら用無し
	if(-not ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop))){
		return;
	}
	$zipPathList = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
	#Write-Host "drop Count=$($zipPathList.Count)"
	if($zipPathList.Count -gt 1){
		[void] [System.Windows.Forms.MessageBox]::show(
			#"zip ファイルはひとつずつ指定してください。",
			#"操作エラー",
			(msg loadOneByOneText_PlzZipOneByOne),
			(msg loadOneByOneTitle_OperatonError),
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Error)
		return
	}
	$zipPath = $zipPathList[0]
	Write-Host "zipPath=$($zipPath)"
	
	# ドロップされたファイルの検査
	$zipObj = $null
	try{
		$zipObj = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
	}catch{
		$ex = $_
		Write-Host "catch " $_
		[void] [System.Windows.Forms.MessageBox]::show(
			#"zip ファイルを指定してください。" +
			#	"`n`n------`n" + ($ex),
			#"データーエラー",
			(msg loadNotZipText_NotZipFile $ex),
			(msg loadNotZipTitle_DataError),
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Error)
		return
	}
	if($zipObj.Entries.Count -eq 0){
		[void] [System.Windows.Forms.MessageBox]::show(
			#"zip ファイルの中身が空です。",
			#"データーエラー",
			(msg loadZipEmptyText_EmptyZipFile),
			(msg loadZipEmptyTitle_DataError),
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Error)
		return
	}
	
	# 最初のファイルでフォルダの重複を検査
	$zip1stObj  = $zipObj.Entries[0]
	$zip1stPath = $zip1stObj.FullName
	Write-Host "zip1stPath=$($zip1stPath)"
	$zip1stSplit = ($zip1stPath -split '\\')
	$profNewName = $zip1stSplit[0]	# かなりいい加減
	$profNewPath = Join-Path -Path $usrDataDirBase -ChildPath $profNewName
	if(Test-Path -Path $profNewPath){
		[void] [System.Windows.Forms.MessageBox]::show(
			#"書き込もうとしたプロファイルはすでに存在します。" +
			#	"`n　既存のプロファイルを別の名前にするなどしてください" +
			#	"`n　プロファイル名=" + $profNewName,
			#"重複エラー",
			(msg loadProfExistText_ProfileIsAlreadyExists $profNewName),
			(msg loadProfExistTitle_DuplicateError),
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Error)
		return
	}
	
	$ok = [System.Windows.Forms.MessageBox]::show(
		#"プロファイルの展開を開始します。" +
		#	"`n　※ちょっと時間がかかります。" +
		#	"`n　プロファイル名=" + $profNewName,
		#"プロファイル展開開始",
		(msg loadStartText_LoadProfileStart $profNewName),
		(msg loadStartTitle_LoadProfileStart),
		[System.Windows.Forms.MessageBoxButtons]::OKCancel,
		[System.Windows.Forms.MessageBoxIcon]::Question,
		[System.Windows.Forms.MessageBoxDefaultButton]::Button2)
	if($ok -ne [System.Windows.Forms.DialogResult]::OK){
		return
	}
	
	$oldCursor = $topForm.Cursor
	try{
		# うまく砂時計に変わらない
		$topForm.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
		$topForm.Enabled = $false
		
		Expand-Archive -Path $zipPath -DestinationPath $usrDataDirBase -ErrorAction Stop
	}catch{
		$ex = $_
		[void] [System.Windows.Forms.MessageBox]::show(
			(msg loadExceptionText_ExpandFailed $ex),
			(msg loadExceptionTitle_ExpandFailed),
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Error)
	}finally{
		$topForm.Cursor = $oldCursor
		$topForm.Enabled = $true
	}
	
	# プロファイルを再読み込みする(待たない)
	prof_reload
})
$profListBox.Add_DragEnter({
	$_.Effect = [Windows.Forms.DragDropEffects]::Copy
})


#--- ボタン「削除...」 ---
$deleteBtn = New-Object Windows.Forms.Button -Property @{
	Location = button_location_prof 2 4
	Size	= $buttonSize
	text	= (msg delBtnText_Delete)	# "削除..."
}
$deleteBtn.Add_Click({
	$lunch = lunch_info_get
	if($lunch -eq $null){
		return
	}
	$profDelName = $lunch.profObj.name

	$ok = [System.Windows.Forms.MessageBox]::show(
		#"プロファイルを削除します。" +
		#	"`n　※ 元に戻せませんよ。本当に削除しますか？" +
		#	"`n　プロファイル名=" + $profDelName,
		#"プロファイル削除開始",
		(msg delStartOKText_DelStartOK $profDelName),
		(msg delStartOKTitle_DelStartOK),
		[System.Windows.Forms.MessageBoxButtons]::OKCancel,
		[System.Windows.Forms.MessageBoxIcon]::Warning,
		[System.Windows.Forms.MessageBoxDefaultButton]::Button2)
	if($ok -ne [System.Windows.Forms.DialogResult]::OK){
		return
	}
	
	# 使用中のファイルがあって途中で失敗すると困るので、リネームしてから削除する
	$profDelPath = Join-Path -Path $usrDataDirBase -ChildPath $profDelName
	$profTmpPath = Join-Path -Path $usrDataDirBase -ChildPath ($profDelName + ",del")
	try{
		Rename-Item -Path $profDelPath -NewName $profTmpPath -ErrorAction Stop
		Remove-Item -Path $profTmpPath -Recurse -Force -ErrorAction Stop
	}catch{
		$ex = $_
		Write-Host "catch " $_
		[void] [System.Windows.Forms.MessageBox]::show(
			#"何かエラーになっちゃった。" +
			#	"`n`n------`n" + ($ex),
			#"何かエラー",
			(msg delExceptionText_DelException $ex),
			(msg delExceptionTitle_DelException),
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Error)
		return
	}
	
	# プロファイルを再読み込みする(待たない)
	prof_reload
})
$topForm.Controls.Add($deleteBtn)



#--- プロファイル依存のコントロールの活性化  ---
prof_depend_enable($false)

###  リサイズ処理  ###
#--- 初期状態を収集する  ---
$resizeObj = @{
	formOrgWidth	= $topForm.Width
	formOrgHeight	= $topForm.Height
	profOrgWidth	= $profListBox.Width
	profOrgHeight	= $profListBox.Height
	profOrgRight	= $profListBox.Right
	profOrgBottom	= $profListBox.Bottom
	controls = @()	# 子コントロールとその初期状態
	argTextOrgWidth	= $argTextBox.Width
}
foreach($control in $topForm.Controls){
    #Write-Host "Name: $($control.Name), Type: $($control.GetType().Name)"
	$resizeObj.controls += @{
		Top = $control.Top
		Left = $control.Left
		#Width = $control.Width
		obj	= $control
	}
}

$topForm.Add_Resize({
    $formNewWidth	= $topForm.Width
    $formNewHeight	= $topForm.Height
	$diffX = $formNewWidth  - $resizeObj.formOrgWidth
	$diffY = $formNewHeight - $resizeObj.formOrgHeight
	
	$profListBox.Width  = $resizeObj.profOrgWidth  + $diffX
	$profListBox.Height = $resizeObj.profOrgHeight + $diffY
	foreach($control in $resizeObj.controls){
		if($control.Top -gt $resizeObj.profOrgBottom){
			# 初期位置がプロファイル一覧より下にあるコントロールは上下に動かす
			$control.obj.Top = $control.Top + $diffY
		}elseif($control.Left -gt $resizeObj.profOrgRight){
			# それ以外で初期位置がプロファイル一覧より右にあるコントロールは左右に動かす
			$control.obj.Left = $control.Left + $diffX
			# ただしプロファイル一覧より下には行かない
			if($control.obj.Bottom -gt $profListBox.Bottom){
				$control.obj.Top = $profListBox.Bottom - $control.obj.Height
			}else{
				$control.obj.Top = $control.Top
			}
		}
	}
	$argTextBox.Width	= $resizeObj.argTextOrgWidth + $diffX

})


### イベントループ ###
[System.Windows.Forms.Application]::Run($topForm )
#フォームが閉じられた(FormClosed)ときに、Runから抜ける
#Write-Host "イベントループから脱出しました"


###  END OF FILE  ####
