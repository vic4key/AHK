; Author    Vic P.
; Email     vic4key@gmail.com

DetectHiddenWindows, On

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
#SPACE:: Winset, Alwaysontop, , A ; WIN SPACE

; Open folder of an active window
#O:: OpenFolderActiveWindow() ; WIN O

; Display help
#Y:: DisplayInfoActiveWindow() ; WIN Y

; Display help
#H:: DisplayHelp() ; WIN H

; Functions

DisplayHelp()
{
    Var = %Var%Volume Mute : WIN F8`n
    Var = %Var%Volume Up : WIN UP`n
    Var = %Var%Volume Down : WIN DOWN`n
    Var = %Var%`n

    Var = %Var%View Active App Information : WIN Y`n
    Var = %Var%Open Active App Containing Folder : WIN O`n
    Var = %Var%Set Active Window Always On Top : WIN SPACE`n
    Var = %Var%`n

    Var = %Var%Virtual Desktop Switching : ALT 1 & ALT 2`n
    Var = %Var%`n


    Var = %Var%Help : WIN H`n

    MsgBox, 0x1040, AHK Help, %Var%
}

OpenFolderActiveWindow()
{
    WinGet, WID, ID, A
    WinGet, FilePath, ProcessPath, ahk_id %WID%
    SplitPath, FilePath,, FileDir
    Run, %FileDir%
}

ProcessGetBits(ProcessID)
{
    hp := DllCall("kernel32\OpenProcess", UInt, 0x400, Int, 0, UInt, ProcessID, Ptr)
    DllCall("kernel32\IsWow64Process", Ptr, hp, IntP, IsWow64)
    DllCall("kernel32\CloseHandle", Ptr, hp)

    if (not A_Is64bitOS or IsWow64)
    {
        return "32-bit"
    }

    return "64-bit"
}

DisplayInfoActiveWindow()
{
    Gui, Destroy ; Destroy Exists

    WinGet, PID, PID, A
    WinGet, WID, ID, A

    0xPID := Format("{:X}", PID)

    Bits := ProcessGetBits(PID)

    WinGetTitle, TitleName, A
    WinGetClass, ClassName, A
    WinGetPos, PosX, PosY, Width, Height, A

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

    GUI, Font, s9, Courier New
    GUI, Add, Edit, hwndEDIT, %Var%

    GUI, Show, x%A_ScreenWidth% y%A_ScreenHeight%
    WinGet, Wnd, ID, A
    WinGetPos, _, _, W, H, ahk_id %Wnd%
    X := PosX + Width / 2 - W / 2
    Y := PosY + Height / 2 - H / 2
    GUI, Show, Hide
    GUI, Show, x%X% y%Y%, App Information

    SendMessage, 0x00B1, -1, 0, , % "ahk_id" EDIT ; EM_SETSEL = 0x00B1
    WinSet, AlwaysOnTop, On, App Information
}

GuiClose:
GuiEscape:
Gui, Destroy ; Destroy If Closes