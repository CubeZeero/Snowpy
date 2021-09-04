#module

#uselib "user32"
#func GetClientRect "GetClientRect" int, int
#func SetWindowLong "SetWindowLongA" int, int, int
#func SetParent "SetParent" int, int

#uselib "gdi32"
#cfunc GetStockObject "GetStockObject" int

;	CreateTab p1, p2, p3, p4
;	タブコントロールを設置します。statにタブコントロールのハンドルが
;	返ります。
;	p1～p2=タブコントロールのX/Y方向のサイズ
;	p3(1)=タブの項目として貼り付けるbgscr命令の初回ウィンドウID値
;	p4=タブコントロールの追加ウィンドウスタイル

#deffunc CreateTab int p1, int p2, int p3, int p4
	winobj "systabcontrol32", "", , $52000000 | p4, p1, p2
	hTab = objinfo(stat, 2)
	sendmsg hTab, $30, GetStockObject(17)

	TabID = p3
	if TabID = 0 : TabID = 1

	dim rect, 4

	return hTab

;	InsertTab "タブつまみ部分の文字列"
;	タブコントロールに項目を追加します。

#deffunc InsertTab str p2
	pszText = p2 : tcitem = 1, 0, 0, varptr(pszText)
	sendmsg hTab, $1307, TabItem, varptr(tcitem)

	GetClientRect hTab, varptr(rect)
	sendmsg hTab, $1328, , varptr(rect)

bgscr TabID + TabItem, rect.2 - rect.0, rect.3 - rect.1, 2, rect.0, rect.1
	SetWindowLong hwnd, -16, $40000000
	SetParent hwnd, hTab

	TabItem++
	return

;	タブ切り替え処理用

#deffunc ChangeTab
	gsel wID + TabID, -1

	sendmsg hTab, $130B
	wID = stat
	gsel wID + TabID, 1

	return

#global


/*
;	以下、サンプル
	screen , 400, 300

	syscolor 15 : boxf


;	タブコントロールの設置。第3パラはbgscr命令で作成するウィンドウ
;	IDの初期値です。たとえば、下のように｢1｣でタブの項目が4個あると
;	すると、1～4のウィンドウが使われます。｢2｣でタブの項目が5個とすると、
;	2～6が使われます。別で使用するウィンドウID値と被らないよう注意。
	pos 50, 50
	CreateTab 300, 200, 1
;	タブつまみ切り替え時に利用するタブコントロールのハンドルを取得
	hTabControl = stat

;	このサンプル上ではbgscr命令で作成したウィンドウID値｢1｣が使われ
;	ます。
	InsertTab "AAA"
;		bgscr命令上にオブジェクトを置く感覚で処理を書きます。
		pos 50, 50 : mes "A"

	InsertTab "BBB"
		pos 50, 50 : mes "B"

	InsertTab "CCC"
		pos 50, 50 : mes "C"

;	bgscr命令ウィンドウのID値｢4｣が使われます。
	InsertTab "DDD"
		pos 50, 50 : mes "D"

;	タブの項目追加が終わったら、タブ内に貼り付けたbgscr命令が非表示
;	状態になっているので、表示されるようgsel命令を指定。CreateTab命令で
;	指定したウィンドウIDの初期値と同じ値を指定します。
	gsel 1, 1

;	元々のscreen命令のウィンドウID 0に描画先を戻します。
	gsel

;	タブ項目切り替え処理時のメッセージ (WM_NOTIFY)
	oncmd gosub *notify, $4E

	stop


;	タブ項目切り替え処理部分です。
*notify
	dupptr nmhdr, lparam, 12
	if nmhdr.0 = hTabControl & nmhdr.2 = -551 {
		ChangeTab
;		元々のscreen命令のウィンドウID 0に描画先を戻します。
		gsel
	}
	return

配布元 http://lhsp.s206.xrea.com/hsp_object6.html
(.asでモジュールプラグイン化しています)
*/