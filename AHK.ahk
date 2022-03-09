; Author    Vic P.
; Email     vic4key@gmail.com

DetectHiddenWindows, On

; Confirm Window Closing
; GroupAdd $GroupEscapeConfirmation, ahk_class Notepad
GroupAdd $GroupEscapeConfirmation, ahk_exe TortoiseProc.exe
GroupAdd $GroupEscapeConfirmation, ahk_exe TortoiseMerge.exe
GroupAdd $GroupEscapeConfirmation, ahk_exe TortoiseGitProc.exe
#IfWinActive ahk_group $GroupEscapeConfirmation
Esc::goto _EscapeCloseWindowConfirmation ; ESC
!F4::goto _EscapeCloseWindowConfirmation ; ALT F4
#IfWinActive

; Adjust Speakers
#F8::Send {Volume_Mute}   ; WIN F8
#Up::Send {Volume_Up}     ; WIN UP
#Down::Send {Volume_Down} ; WIN DOWN

; Supports paste clipboard to CMD
; #IfWinActive ahk_class ConsoleWindowClass
;   ^V::
;   SendInput {Raw}%clipboard%
;   return
; #IfWinActive

; Switching Virtual Desktop
<!2::Send, ^#{Right}  ; ALT 1
<!1::Send, ^#{Left}   ; ALT 2

; Set Always On Top
#T:: Winset, Alwaysontop, , A ; WIN T

; Prevent Window Closing
#SPACE::PreventWindowClosing() ; WIN SPACE

; Open Folder of an Active Window
#O:: OpenActiveWindowFolder() ; WIN O

; Termimate Active Window
#DEL:: TerminateActiveWindow() ; WIN DEL

; Display Active Window Information
#Y:: DisplayActiveWindowInformation() ; WIN Y

; Display Help
#H:: DisplayHelp() ; WIN H

; Functions

SystemMenu_Exists_Close(hWnd)
{
    hSysMenu := DllCall("user32\GetSystemMenu","UInt",hWnd,"UInt",FALSE)
    nCount := DllCall("user32\GetMenuItemCount","Int",hSysMenu)

    Result := False

    Loop %nCount%
    {
        Idx := A_Index - 1
        Id := DllCall("user32\GetMenuItemID", "Int", hSysMenu, "Int", Idx)

        MAX_COUNT := 100
        MF_BYPOSITION := 0x0400
        VarSetCapacity(lpString, MAX_COUNT, 0)
        DllCall("user32\GetMenuString", "UInt",hSysMenu, "UINT",Idx, "STR",lpString, "Int",MAX_COUNT, "UINT",MF_BYPOSITION)

        Txt := SubStr(lpString, 1, 6)
        If (Txt == "&Close")
        {
            ; MsgBox % Format("{:d}. '{}'", Idx, Txt)
            Result := True
            Break
        }
    }

    return Result
}

SystemMenu_Remove_Close(hWnd)
{
    hSysMenu := DllCall("user32\GetSystemMenu","UInt",hWnd,"UInt",FALSE)
    nCount := DllCall("user32\GetMenuItemCount","Int",hSysMenu)
    DllCall("user32\RemoveMenu","Int",hSysMenu,"UInt",nCount-1,"Uint","0x400") ; Close
    DllCall("user32\RemoveMenu","Int",hSysMenu,"UInt",nCount-2,"Uint","0x400") ; Separator
}

SystemMenu_Restore_Close(hWnd)
{
    hSysMenu := DllCall("user32\GetSystemMenu","UInt",hWnd,"UInt",1)
    DllCall("user32\DrawMenuBar","UInt",hWnd)
}

PreventWindowClosing()
{
    WinGet, hWnd, ID, A

    HasClose := SystemMenu_Exists_Close(hWnd)

    If (HasClose)
        SystemMenu_Remove_Close(hWnd)
    Else
        SystemMenu_Restore_Close(hWnd)
}

DisplayHelp()
{
    Var = %Var%Volume Mute : WIN F8`n
    Var = %Var%Volume Up : WIN UP`n
    Var = %Var%Volume Down : WIN DOWN`n
    Var = %Var%`n

    Var = %Var%View Active App Information : WIN Y`n
    Var = %Var%Terminate Current Active App : WIN DEL`n
    Var = %Var%Prevent Window Closing by System Menu : WIN SPACE`n
    Var = %Var%Confirm Window Closing by Escape: ESC & ALT F4`n
    Var = %Var%Set Active Window Always On Top : WIN T`n
    Var = %Var%Open Active App Containing Folder : WIN O`n
    Var = %Var%`n

    Var = %Var%Virtual Desktop Switching : ALT 1 & ALT 2`n
    Var = %Var%`n

    Var = %Var%Help : WIN H`n

    MsgBox, 0x1040, AHK Help, %Var%
}

OpenActiveWindowFolder()
{
    WinGet, WID, ID, A
    WinGet, FilePath, ProcessPath, ahk_id %WID%
    SplitPath, FilePath,, FileDir
    Run, %FileDir%
}

GetProcessBits(PID)
{
    hp := DllCall("kernel32\OpenProcess", UInt, 0x400, Int, 0, UInt, PID, Ptr)
    DllCall("kernel32\IsWow64Process", Ptr, hp, IntP, IsWow64)
    DllCall("kernel32\CloseHandle", Ptr, hp)

    if (not A_Is64bitOS or IsWow64)
    {
        return "32-bit"
    }

    return "64-bit"
}

GetActiveWindowInformation(PID)
{
    0xPID := Format("{:X}", PID)

    Bits := GetProcessBits(PID)

    WinGetTitle, TitleName, A
    WinGetClass, ClassName, A
    WinGetPos, PosX, PosY, Width, Height, A

    WinGet, WID, ID, A
    WinGet, FilePath, ProcessPath, ahk_id %WID%
    SplitPath, FilePath, FileName, FileDir, , , FileDrive

    FileSizeK = ?
    FileGetSize, FileSize, %FilePath%, K
    if (ErrorLevel == 0)
    {
        FileSizeK := Format("{:d} KB", FileSize)
    }

    FileTimeC = ?
    FileGetTime, FileTime, %FilePath%, C
    if (ErrorLevel == 0)
    {
        FormatTime, FileTimeC, %FileTime%, ddd MMM dd yyyy HH:mm:ss
    }

    FileTimeM = ?
    FileGetTime, FileTime, %FilePath%, M
    if (ErrorLevel == 0)
    {
        FormatTime, FileTimeM, %FileTime%, ddd MMM dd yyyy HH:mm:ss
    }

    FileTimeA = ?
    FileGetTime, FileTime, %FilePath%, A
    if (ErrorLevel == 0)
    {
        FormatTime, FileTimeA, %FileTime%, ddd MMM dd yyyy HH:mm:ss
    }

    Var = %Var%`n[+] Process`n
    Var = %Var%`tPID  : %PID% or 0x%0xPID%`n
    Var = %Var%`tBits : %Bits%`n

    Var = %Var%`n[+] Window`n
    Var = %Var%`tTitle : %TitleName%`n
    Var = %Var%`tClass : %ClassName%`n
    Var = %Var%`tPoint : %PosX%, %PosY%`n
    Var = %Var%`tSize  : %Width%, %Height%`n

    Var = %Var%`n[+] File`n
    Var = %Var%`tName : %FileName%`n
    Var = %Var%`tDir  : %FileDir%`n
    Var = %Var%`tPath : %FilePath%`n
    Var = %Var%`tSize : %FileSizeK%`n
    Var = %Var%`tCreated  : %FileTimeC%`n
    Var = %Var%`tModified : %FileTimeM%`n
    Var = %Var%`tAccessed : %FileTimeA%`n

    return Var
}

DisplayActiveWindowInformation()
{
    Gui, Destroy

    WinGet, PID, PID, A
    Var := GetActiveWindowInformation(PID)

    WinGetPos, PosX, PosY, Width, Height, A

    GUI, Font, s9, Courier New
    GUI, Add, Edit, hwndEDIT, %Var%
    GUI, Add, Button, g_TerminateActiveWindow, TERMINATE %PID%

    GUI, Show, x%A_ScreenWidth% y%A_ScreenHeight%
    WinGet, Wnd, ID, A
    WinGetPos, _, _, W, H, ahk_id %Wnd%
    X := PosX + Width  / 2 - W / 2
    Y := PosY + Height / 2 - H / 2
    GUI, Show, Hide
    GUI, Show, x%X% y%Y%, App Information

    SendMessage, 0x00B1, -1, 0, , % "ahk_id" EDIT ; EM_SETSEL = 0x00B1
    WinSet, AlwaysOnTop, On, App Information
}

TerminateActiveWindow()
{
    WinGet, PID, PID, A

    0xPID := Format("{:X}", PID)

    Bits := GetProcessBits(PID)

    WinGetTitle, TitleName, A
    WinGetClass, ClassName, A
    WinGetPos, PosX, PosY, Width, Height, A

    Var = %Var%`n[+] Process`n
    Var = %Var%`tPID  : %PID% or 0x%0xPID%`n
    Var = %Var%`tBits : %Bits%`n

    Var = %Var%`n[+] Window`n
    Var = %Var%`tTitle : %TitleName%`n
    Var = %Var%`tClass : %ClassName%`n

    ; 0x1000    System Modal (always on top)
    ; 0x100     Makes the 2nd button the default (Not Used)
    ; 0x20      Icon Question
    ; 0x4       Yes/No
    MsgBox, 0x1024, AHK Terminate Process, %Var%`n Are you sure to kill this process ?
    ifMsgBox, Yes
    {
        Process,Close,%PID%
    }
}

_EscapeCloseWindowConfirmation:
{
    WinGet, WID, ID, A
    WinGet, Active_Process, ProcessName, ahk_id %WID%

    WinGetTitle, TitleName, A

    TitleNameMaxLen := 40
    TitleNameLen := StrLen(TitleName)
    If (TitleNameLen > TitleNameMaxLen)
    {
        TitleName := SubStr(TitleName, 1, TitleNameMaxLen)
        TitleName = %TitleName%` ...`
    }

    Var = `Would you like to close this window ?`n
    Var = %Var%` `n
    Var = %Var%`Title Name : %TitleName%`n
    Var = %Var%`Process Name : %Active_Process%`n

    ; 0x1000    System Modal (always on top)
    ; 0x100     Makes the 2nd button the default
    ; 0x20      Icon Question
    ; 0x4       Yes/No
    MsgBox, 0x1124, AHK Close Window Confirmation, %Var%
    IfMsgBox, Yes
    WinClose A
}
return

_TerminateActiveWindow:
{
    RegExMatch(A_GuiControl, "\d+$", PID)
    Process,Close,%PID%
    Gui, Destroy
    ; 0x1000    System Modal (always on top)
    ; 0x100     Makes the 2nd button the default
    ; 0x20      Icon Question
    ; 0x4       Yes/No
    ; MsgBox, 0x1124, AHK Terminate Process, %Var%`nAre you sure to kill this process ?
    ; ifMsgBox,Yes
    ; {
    ;     Process,Close,%PID%
    ;     Gui, Destroy
    ; }
}
return

GuiClose:
GuiEscape:
Gui, Destroy ; Destroy If Closes