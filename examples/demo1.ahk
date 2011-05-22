#SingleInstance force
#NoEnv
#KeyHistory 0
#Include Thumbnail.ahk
SetWorkingDir %A_WorkingDir%

Gui +AlwaysOnTop
Gui +LastFound
HwndDest := WinExist()
xDest := 25
yDest := 25
wDest := 400
hDest := 300

Hotkey, #!6, CreateMyThumb
current_opacity := 255
return


CreateMyThumb:

WinGet, Hwnd_S, ID, A
xSource := 0
ySource := 0

MsgBox % thumb_ := Thumbnail_Create(HwndDest, Hwnd_S)
Thumbnail_GetSourceSize(thumb_, width, heigth)
Thumbnail_SetRegion(thumb_, xDest, yDest, wDest, hDest, xSource, ySource, width, heigth)
Thumbnail_Show(thumb_)

Gui, Show, w450 h350 NA, Aero
return

!#1::
xSource := xSource + 50
Thumbnail_SetRegion(thumb_, xDest, yDest, wDest, hDest, xSource, ySource, width, heigth)
return

!#2::
ySource := ySource + 50
Thumbnail_SetRegion(thumb_, xDest, yDest, wDest, hDest, xSource, ySource, width, heigth)
return

!#3::
width := width * 2
heigth := heigth * 2
Thumbnail_SetRegion(thumb_, xDest, yDest, wDest, hDest, 0, 0, width, heigth)
return

!#4::
width := width / 2
heigth := heigth / 2
Thumbnail_SetRegion(thumb_, xDest, yDest, wDest, hDest, 0, 0, width, heigth)
return

!#5::
current_opacity-=25
Thumbnail_SetOpacity(thumb_, current_opacity)
return

!#7::
Thumbnail_Destroy(thumb_)
Gui Destroy
Gui +LastFound
Gui +AlwaysOnTop
HwndDest := WinExist()
Gosub CreateMyThumb
return

!#8::
Thumbnail_Destroy(thumb_)
Reload
return

GuiClose:
Thumbnail_Destroy(thumb_)
ExitApp
return