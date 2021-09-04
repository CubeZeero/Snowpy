;popupmenu3.as		Ver. 1.02
;popupmenu.dllのインクルードファイル
#ifndef POPUPMENU_AS__
#define POPUPMENU_AS__

#uselib "popupmenu.dll"
#func pumSetHspVer3 setHspVer3 $202
#func pummake pummake 2
#func pumadd pumadd 4
#func pumshow pumshow 0
#func pumsetstate pumsetstate 0
#func pumSetName pumSetName 4
#func pumMenuHandle pumMenuHandle 1
#func pumOwnWidth pumOwnWidth 0
#func pumOwnActWidth pumOwnActWidth 1
#func pumBmpSet pumBmpSet 0
#func pumBmpDel pumBmpDel 0
#func pumItemDel pumItemDel 0
#func pumSetSubmenu pumSetSubmenu 0
#func pumDel pumDel 0

#func dispTrayIcon dispTrayIcon 6
#func delTrayIcon delTrayIcon 0
#func chkTrayIcon chkTrayIcon 1

#module "pummod"
#func setbmscr setbmscr 2
#func pumOwnSet_ pumOwnSet 2
#func pumBmpMake_ pumBmpMake 1

#deffunc pumBmpMake var hbmp, int x_, int y_, int w_, int h_
	x=x_
	y=y_
	w=w_
	h=h_
	;mref hbmp,16: ;mref x,1: ;mref y,2: ;mref w,3: ;mref h,4
	setbmscr
	pumBmpMake_ hbmp,x<<16|y,w,h
return

#deffunc pumOwnSet int iid_, int winid_, int x__0, int y__0
	iid=iid_
	winid=winid_
	x=x__0
	y=y__0
	;mref iid,0: ;mref winid,1: ;mref x,2: ;mref y,3
	mref bmscr,67
	wid=bmscr.18
	gsel winid
	pumOwnSet_ iid,x,y
	gsel wid
return
#global

	pumSetHspVer3 hspver
#endif		; POPUPMENU_AS__
