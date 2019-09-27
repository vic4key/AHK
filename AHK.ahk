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
^!SPACE:: Winset, Alwaysontop, , A  ; CTRL ALT SPACE