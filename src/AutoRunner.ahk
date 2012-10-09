#SingleInstance, Force
#Persistent
#InstallKeybdHook
#InstallMouseHook
SetTitleMatchMode, 2
SetKeyDelay, -1
OnExit, Exit
SetWorkingDir, % A_ScriptDir
Initialize()
if(A_IsCompiled)
	Menu, tray, Icon, %A_ScriptName%, 1
Menu, Tray, NoStandard
Menu, Tray, Add, &Options, Options
Menu, Tray, Add, &Help!, Help
Menu, Tray, Add, &About, About
Menu, Tray, Default, &Options
Menu, Tray, Click, 2
Menu, Tray, Add, E&xit, Exit
Return

Initialize()
	{
		global 																							; Compatibility/lazy scripting
		Check_ForUpdate("AutoRunner", 0.013, "http://www.barrowdev.com/update/AutoRunner/Version.ini")
		
		; _________________________________________________________________
		
		IniRead, arHotkeyDisplay, Settings.ini, Hotkeys, hotkeyDisplay
		if(arHotkeyDisplay != "ERROR")																	; Legacy support
		{
			IniWrite, %arHotkeyDisplay%, Settings.ini, Hotkeys, arHotkeyDisplay
		}
		else
			IniRead, arHotkeyDisplay, Settings.ini, Hotkeys, arHotkeyDisplay							; So we don't have to re-parse the human-readable version of the AutoRun hotkey
		IniDelete, Settings.ini, Hotkeys, hotkeyDisplay
		
		if(arHotkeyDisplay == "ERROR")
		{
			arHotkeyDisplay := "none"
		}
		
		; _________________________________________________________________
		
		IniRead, arHotkey, Settings.ini, Hotkeys, hotkeyFinal
		if(arHotkey != "ERROR")																			; Legacy support
		{
			IniWrite, %arHotkey%, Settings.ini, Hotkeys, arHotkey
		}
		else
			IniRead, arHotkey, Settings.ini, Hotkeys, arHotkey 											; AutoRun hotkey
		IniDelete, Settings.ini, Hotkeys, hotkeyFinal
		
		if(arHotkey == "ERROR")
			arHotkey := "none"
		else if (arHotkey != "none")
		{
			Hotkey, *%arHotkey%, ARToggle, On 															; Enable the AutoRun hotkey
		}
		
		; _________________________________________________________________
		
		IniRead, customTarget, Settings.ini, Hotkeys, customTarget										; So we don't have to re-parse the human-readable version of the Custom hotkey
		StringLower, customTarget, customTarget
		if(customTarget == "ERROR")
		{
			customTarget := "none"
		}
		else
		{
			Hotkey, $*%customTarget%, CustomDown, On
			Hotkey, $%customTarget% up, CustomUp, On
		}
		
		; _________________________________________________________________
		
		IniRead, customHotkeyDisplay, Settings.ini, Hotkeys, customHotkeyDisplay						; So we don't have to re-parse the human-readable version of the Custom hotkey
		if(customHotkeyDisplay == "ERROR")
		{
			customHotkeyDisplay := "none"
		}
		
		; _________________________________________________________________
		
		IniRead, customHotkey, Settings.ini, Hotkeys, customHotkey 										; Custom hotkey
		if(customHotkey == "ERROR")
			customHotKey := "none"
		else if (customHotkey != "none" && customTarget != "none")										; If a target for the Custom hotkey is set
		{
			Hotkey, *%customHotkey%, CustomToggle, On 													; Enable the Custom hotkey
		}
		
		; _________________________________________________________________
		
		IniRead, chatHotkeyDisplay, Settings.ini, Hotkeys, chatHotkeyDisplay							; So we don't have to re-parse the human-readable version of the Chat hotkey
		if(chatHotkeyDisplay == "ERROR")
		{
			chatHotkeyDisplay := "none"
		}
		
		; _________________________________________________________________
		
		IniRead, chatHotkey, Settings.ini, Hotkeys, chatHotkey 											; Chat hotkey
		if(chatHotkey == "ERROR")
			customHotKey := "none"
		else if (chatHotkey != "none")
		{
			Hotkey, ~*%chatHotkey%, chatToggle, On 														; Enable the Custom hotkey
		}
		
		; _________________________________________________________________
		
		IniRead, useControlSend, Settings.ini, Preferences, useControlSend 								; Whether or not to use "send to background" functionallity
		if(useControlSend == "ERROR")
		{
			IniWrite, false, Settings.ini, Preferences, useControlSend
			useControlSend := false
		}
		
		; _________________________________________________________________
		
		IniRead, targetWindow, Settings.ini, Preferences, targetWindow 									; Target window for hotkeys
		if(targetWindow == "ERROR")
		{
			targetWindow := ""
		}
		
		; _________________________________________________________________
		
		toggle := false 																				; Start with AutoRun state disabled
		spam := "gmail.com"
		anti := "Barrow.Dev"
		Return
	}

; ===============================================================================================
	
Options:
	Gui, Add, Button, x2 y0 w240 h60, Set the AutoRun Key
	Gui, Add, Button, x2 y60 w240 h60, Set the Custom Key
	Gui, Add, Button, x2 y120 w240 h60, Set the Chat Key
	Gui, Add, Button, x2 y180 w240 h60, Select the Target Window
	Gui, Add, CheckBox, x2 y240 w240 h30 Center Checked%useControlSend% vuseControlSend gChangeControlSend, AutoRun when the window isn't focused.
	Gui, Show, x427 y347 h274 w250, Options
	Return

; ===============================================================================================

GuiClose:
	Gui, Submit
	Gui, Destroy
	Return

; ===============================================================================================

ChangeControlSend:
	Gui, Submit, NoHide
	Return

; ===============================================================================================
	
ButtonSetTheAutoRunKey:
	Suspend, On
	arHotkeyNew := HotkeyGUI(, arHotkey,,,"Set the AutoRun key")
	if(ErrorLevel) 																						; If user cancelled entry
	{
		Suspend, Off
		Return
	}
		
	arHotkeyDisplay := toHumanReadable(arHotkeyNew) 													; Human readable hotkey
	
	IniWrite, %arHotkeyDisplay%, Settings.ini, Hotkeys, arHotkeyDisplay
	IniWrite, %arHotkeyNew%, Settings.ini, Hotkeys, arHotkey
	
	if(arHotkey != "None" && arHotkey != "ERROR" && arHotkey)
	{
		Hotkey, *%arHotkey%, ARToggle, Off 																; Disable the old hotkey
	}
	Hotkey, *%arHotkeyNew%, ARToggle, On 
	
	arHotkey := arHotkeyNew
	Suspend, Off
	Return

; ===============================================================================================
	
ButtonSetTheCustomKey:
	Suspend, On
	
	MsgBox, First`, please select the key you want the program to hold down.
	customTargetNew := HotkeyGUI(, customTarget, 2046,,"Set the key to ""hold down""")
	StringLower, customTargetNew, customTargetNew
	if(ErrorLevel) 																						; If user cancelled entry
	{
		Suspend, Off
		Return
	}
	
	MsgBox, Now choose the key you want to press to toggle holding %customTargetNew%.
	customHotkeyNew := HotkeyGUI(, customHotkey,,,"Set the Custom key")
	if(ErrorLevel) 																						; If user cancelled entry
	{
		Suspend, Off
		Return
	}
	
	if(customTargetNew == customHotkeyNew)
	{
		MsgBox, Sorry, but you cannot set %customTargetNew% to hold itself down. Paradoxes are not allowed.
		Suspend, Off
		Return
	}
	
	customHotkeyDisplay := toHumanReadable(customHotkeyNew) 											; Human readable hotkey
	
	IniWrite, %customHotkeyDisplay%, Settings.ini, Hotkeys, customHotkeyDisplay
	IniWrite, %customHotkeyNew%, Settings.ini, Hotkeys, customHotkey
	IniWrite, %customTargetNew%, Settings.ini, Hotkeys, customTarget
	
	if(customHotkey != "None" && customHotkey != "ERROR" && customHotkey)
	{
		Hotkey, *%customTarget%, CustomDown, Off 														; Disable the old hotkeys
		Hotkey, %customTarget% up, CustomUp, Off
		Hotkey, *%customHotkey%, CustomToggle, Off
	}
	Hotkey, $*%customTargetNew%, CustomDown, On
	Hotkey, $%customTargetNew% up, CustomUp, On
	Hotkey, *%customHotkeyNew%, CustomToggle, On 
	
	customHotkey := customHotkeyNew
	customTarget := customTargetNew
		
	Suspend, Off
	Return
	
; ===============================================================================================

ButtonSetTheChatKey:
	Suspend, On
	chatHotkeyNew := HotkeyGUI(, chatHotkey,,,"Set the Chat key")
	if(ErrorLevel) 																						; If user cancelled entry
	{
		Suspend, Off
		Return
	}
		
	chatHotkeyDisplay := toHumanReadable(chatHotkeyNew) 													; Human readable hotkey
	
	IniWrite, %chatHotkeyDisplay%, Settings.ini, Hotkeys, chatHotkeyDisplay
	IniWrite, %chatHotkeyNew%, Settings.ini, Hotkeys, chatHotkey
	
	if(chatHotkey != "None" && chatHotkey != "ERROR" && chatHotkey)
	{
		Hotkey, ~*%chatHotkey%, ChatToggle, Off 																; Disable the old hotkey
	}
	Hotkey, ~*%chatHotkeyNew%, ChatToggle, On 
	
	chatHotkey := chatHotkeyNew
	Suspend, Off
	Return

; ===============================================================================================
	
ButtonSelectTheTargetWindow:
	programList := 
	WinGet, openPrograms, List
	Loop %openPrograms%
	{
		currentID := openPrograms%A_Index%
		WinGetTitle, currentTitle, % "ahk_id " currentID
		StringReplace, currentTitle, currentTitle, |, %A_Space%, All
		if(!currentTitle)
			Continue
		programList .= currentTitle "|"
		if(currentTitle == targetWindow)
		{
			programList .= "|"
		}
	}
	Gui, Programs:New
	Gui, Programs:Add, DropDownList, x2 y10 w600 h80 Sort vtargetWindow, DropDownList, %programList%
	Gui, Programs:Add, Button, x2 y50 w100 h30 , Accept
	Gui, Programs:Add, Button, x112 y50 w100 h30 , Cancel
	Gui, Programs:Add, Button, x492 y50 w110 h30 , Disable
	Gui, Programs:Show, x507 y480 h87 w615, Select the Target Window
	Return

; ===============================================================================================
	
ProgramsButtonAccept:
	Gui, Submit
ProgramsButtonCancel:
ProgramsGuiClose:
	Gui, Destroy
	Return
	
ProgramsButtonDisable:
	targetWindow :=
	Gui, Destroy
	Return

; ===============================================================================================

Help:
	helpMessage :=
	if(useControlSend)
		helpMessage .= " You are using the ""background send"" feature. You may want to disable this if you're having trouble getting your keys to work."
	if(arHotkeyDisplay == "none")
		helpMessage .= "You do not have a hotkey set for AutoRun currently."
	else
		helpMessage .= "Your current AutoRun key is " arHotkeyDisplay "."
	if(customHotkeyDisplay == "none" && customTarget == "none")
		helpMessage .= " You do not have a custom hotkey set currently."
	else
		helpMessage .= " You have a custom hotkey to hold " customTarget " set to " customHotkeyDisplay "."
	if(chatHotkey != "none")
		helpMessage .= " You are using " chatHotkey " to start chatting."
	if(targetWindow)
		helpMessage .= " You are currently configured to only use hotkeys inside the program " targetWindow "."
	if(arToggle)
		helpMessage .= " AutoRun is currently toggled on."
	if(customToggle)
		helpMessage .= " Your custom hotkey is currently toggled on."
	helpMessage .= "`n`nIf this information doesn't fix your problem, please e-mail this information and a description of the problem to " anti "@" spam "."
	
	MsgBox, 0x0, Self-Help, %helpMessage%
	Return

; ===============================================================================================

About:
	MsgBox, 0x0, About, Made by %anti%@%spam% in Autohotkey.`nFeel free to e-mail with questions, comments, and concerns.
	Return

; ===============================================================================================

Exit:
	IniWrite, %arHotkeyDisplay%, Settings.ini, Hotkeys, arHotkeyDisplay
	IniWrite, %arHotkey%, Settings.ini, Hotkeys, arHotkey
	IniWrite, %customTarget%, Settings.ini, Hotkeys, customTarget	
	IniWrite, %customHotkeyDisplay%, Settings.ini, Hotkeys, customHotkeyDisplay
	IniWrite, %customHotkey%, Settings.ini, Hotkeys, customHotkey
	IniWrite, %chatHotkeyDisplay%, Settings.ini, Hotkeys, chatHotkeyDisplay
	IniWrite, %chatHotkey%, Settings.ini, Hotkeys, chatHotkey
	IniWrite, %targetWindow%, Settings.ini, Preferences, targetWindow
	IniWrite, %useControlSend%, Settings.ini, Preferences, useControlSend 
	ExitApp

; ===============================================================================================
	
toHumanReadable(inputKey)
{
	StringReplace, inputKey, inputKey, +, % "Shift + "
	StringReplace, inputKey, inputKey, ^, % "Ctrl + "
	StringReplace, inputKey, inputKey, !, % "Alt + "
	StringReplace, inputKey, inputKey, #, % "Win + "
	
	Return %inputKey%
}

; ===============================================================================================

#If (!targetWindow || WinActive(targetWindow))

ChatToggle:
	chatting := true
	Send, {w up}{%customTarget% up}
	Return

~*Enter::
~*Escape::
	chatting := false
	Return

; ===============================================================================================

#If ((!targetWindow || WinActive(targetWindow)) && !chatting)

; ===============================================================================================

~*s::
	if(customToggle)
	{
		customToggle := false
		Send, {%customTarget% up}
	}
	
	if(arToggle)																						; If the AutoRun state is set to on when we press "s"
	{
		arToggle := false																				; Toggle AutoRun state to off
		Send, {w up}																					; Release "w"
	}
	return

; ===============================================================================================

$*w::
	customToggle := false
	arToggle := false																					; If we pressed "w", turn the AutoRun state to off
	currentlyRunningManually := true																	; Set the state of "Running Manually" to on
	GetKeyState, testKeyState, w																		; ^v^v^v^v^ DEBUG: Possible fix for modifier bug ^v^v^v^v^ 
	if(testKeyState == "D")																				; ^v^v^v^v^ DEBUG: Possible fix for modifier bug ^v^v^v^v^ 
		Return																							; ^v^v^v^v^ DEBUG: Possible fix for modifier bug ^v^v^v^v^ 
	Send, {%customTarget% up}{w down}																	; When we press "w", send "w" down regardless
	Return

; ===============================================================================================
	
$w up::
	if(!pressedHotkeyWhileRunning)																		; If we didn't press the AutoRun key while we were running manually
	{
		Send, {w up}																					; Release "w"
	}
	pressedHotkeyWhileRunning := false																	; Otherwise, we're no longer pressing the AutoRun key while running manually
	currentlyRunningManually := false																	; Nor are we "Running Manually" anymore
	Return

; ===============================================================================================
CustomDown:
	arToggle := false
	customToggle := false
	currentlyCustomingManually := true
	GetKeyState, testKeyState, %customTarget%															; ^v^v^v^v^ DEBUG: Possible fix for modifier bug ^v^v^v^v^ 
	if(testKeyState == "D")																				; ^v^v^v^v^ DEBUG: Possible fix for modifier bug ^v^v^v^v^ 
		Return	
	Send, {w up}{%customTarget% down}
	Return
	
	
CustomUp:
	if(!pressedHotkeyWhileCustoming)
	{
		Send, {%customTarget% up}
	}
	pressedHotkeyWhileCustoming := false
	currentlyCustomingManually := false
	Return
	

CustomToggle:
	customToggle := !customToggle
	if(customToggle)					
	{
		if(arToggle)
		{
			arToggle := false
			Send, {w up}
		}
		
		if(!currentlyCustomingManually)
		{
			if(useControlSend)
			{
				WinGet, customPID, PID, A
				ControlSend,, {%customTarget% down}, ahk_pid %customPID%
			}
			else
				Send, {%customTarget% down}
		}
		else
		{
			pressedHotkeyWhileCustoming := true
		}
	}
	else
		Send, {%customTarget% up}
	return

; ===============================================================================================
	
ARToggle:
	arToggle := !arToggle																				; Toggle AutoRun state on/off
	if(arToggle)																						; If we weren't already AutoRunning when we pressed the hotkey
	{
		if(customToggle)
		{
			customToggle := false
			Send, {%customTarget% up}
		}
		if(!currentlyRunningManually)																	; And we're not currently running manually (to avoid double-pressing "w")
		{
			if(useControlSend)
			{
				WinGet, arPID, PID, A
				ControlSend,, {w down}, ahk_pid %arPID%
			}
			else
				Send, {w down}																			; Press "w"
		}
		else																							; But if we are running manually
		{
			pressedHotkeyWhileRunning := true															; Set the "Running Manually" state to on, and leave the "w" key depressed
		}
	}
	else																								; However, if we were already AutoRunning when we pressed the key
		Send, {w up}																					; We release "w" to toggle AutoRun off
	return
