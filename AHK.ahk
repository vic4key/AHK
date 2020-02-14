; Author    Vic P.
; Email     vic4key@gmail.com

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

    Var = %Var%Switching Virtual Desktop : ALT 1 & ALT 2`n
    Var = %Var%`n

    Var = %Var%Set Always On Top : WIN SPACE`n
    Var = %Var%`n

    Var = %Var%Open folder of an active window : WIN O`n
    Var = %Var%`n

    Var = %Var%Help : WIN H`n

    MsgBox, 0x1040, INFORMATION, %Var%
}

OpenFolderActiveWindow()
{
    WinGet, WID, ID, A
    WinGet, FilePath, ProcessPath, ahk_id %WID%
    SplitPath, FilePath,, FileDir
    Run, %FileDir%
}

DisplayInfoActiveWindow()
{
    WinGet, PID, PID, A
    WinGet, WID, ID, A

    Bits := ProcessGetBits(PID)

    WinGetTitle, TitleName, A
    WinGetClass, ClassName, A
    WinGetPos, PosX, PosY, Width, Height, A

    WinGet, FilePath, ProcessPath, ahk_id %WID%
    SplitPath, FilePath, FileName, FileDir, , , FileDrive

    Var = %Var%`n[+] Process`n
    Var = %Var%`tPID : %PID%`n
    Var = %Var%`tBits : %Bits%`n

    Var = %Var%`n[+] Window`n
    Var = %Var%`tTitle Name : %TitleName%`n
    Var = %Var%`tClass Name : %ClassName%`n
    Var = %Var%`tPosition XY : %PosX%, %PosY%`n
    Var = %Var%`tWidth Height : %Width%, %Height%`n

    Var = %Var%`n[+] File`n
    Var = %Var%`tFile Name : %FileName%`n
    Var = %Var%`tFile Directory : %FileDir%`n
    ; Var = %Var%`tFile Path : %FilePath%`n

    MsgBox, 0x1040, INFORMATION, %Var%
}

ProcessGetBits(ProcessID)
{
    hp := DllCall("kernel32\OpenProcess", UInt, 0x400, Int, 0, UInt, ProcessID, Ptr)
    DllCall("kernel32\IsWow64Process", Ptr, hp, IntP, IsWow64)
    DllCall("kernel32\CloseHandle", Ptr, hp)

    if !A_Is64bitOS or IsWow64 return "32-bit"

    return "64-bit"
}
