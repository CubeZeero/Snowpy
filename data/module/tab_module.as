#module

#uselib "user32"
#func GetClientRect "GetClientRect" int, int
#func SetWindowLong "SetWindowLongA" int, int, int
#func SetParent "SetParent" int, int

#uselib "gdi32"
#cfunc GetStockObject "GetStockObject" int

;	CreateTab p1, p2, p3, p4
;	�^�u�R���g���[����ݒu���܂��Bstat�Ƀ^�u�R���g���[���̃n���h����
;	�Ԃ�܂��B
;	p1�`p2=�^�u�R���g���[����X/Y�����̃T�C�Y
;	p3(1)=�^�u�̍��ڂƂ��ē\��t����bgscr���߂̏���E�B���h�EID�l
;	p4=�^�u�R���g���[���̒ǉ��E�B���h�E�X�^�C��

#deffunc CreateTab int p1, int p2, int p3, int p4
	winobj "systabcontrol32", "", , $52000000 | p4, p1, p2
	hTab = objinfo(stat, 2)
	sendmsg hTab, $30, GetStockObject(17)

	TabID = p3
	if TabID = 0 : TabID = 1

	dim rect, 4

	return hTab

;	InsertTab "�^�u�܂ݕ����̕�����"
;	�^�u�R���g���[���ɍ��ڂ�ǉ����܂��B

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

;	�^�u�؂�ւ������p

#deffunc ChangeTab
	gsel wID + TabID, -1

	sendmsg hTab, $130B
	wID = stat
	gsel wID + TabID, 1

	return

#global


/*
;	�ȉ��A�T���v��
	screen , 400, 300

	syscolor 15 : boxf


;	�^�u�R���g���[���̐ݒu�B��3�p����bgscr���߂ō쐬����E�B���h�E
;	ID�̏����l�ł��B���Ƃ��΁A���̂悤�ɢ1��Ń^�u�̍��ڂ�4�����
;	����ƁA1�`4�̃E�B���h�E���g���܂��B�2��Ń^�u�̍��ڂ�5�Ƃ���ƁA
;	2�`6���g���܂��B�ʂŎg�p����E�B���h�EID�l�Ɣ��Ȃ��悤���ӁB
	pos 50, 50
	CreateTab 300, 200, 1
;	�^�u�܂ݐ؂�ւ����ɗ��p����^�u�R���g���[���̃n���h�����擾
	hTabControl = stat

;	���̃T���v����ł�bgscr���߂ō쐬�����E�B���h�EID�l�1����g���
;	�܂��B
	InsertTab "AAA"
;		bgscr���ߏ�ɃI�u�W�F�N�g��u�����o�ŏ����������܂��B
		pos 50, 50 : mes "A"

	InsertTab "BBB"
		pos 50, 50 : mes "B"

	InsertTab "CCC"
		pos 50, 50 : mes "C"

;	bgscr���߃E�B���h�E��ID�l�4����g���܂��B
	InsertTab "DDD"
		pos 50, 50 : mes "D"

;	�^�u�̍��ڒǉ����I�������A�^�u���ɓ\��t����bgscr���߂���\��
;	��ԂɂȂ��Ă���̂ŁA�\�������悤gsel���߂��w��BCreateTab���߂�
;	�w�肵���E�B���h�EID�̏����l�Ɠ����l���w�肵�܂��B
	gsel 1, 1

;	���X��screen���߂̃E�B���h�EID 0�ɕ`����߂��܂��B
	gsel

;	�^�u���ڐ؂�ւ��������̃��b�Z�[�W (WM_NOTIFY)
	oncmd gosub *notify, $4E

	stop


;	�^�u���ڐ؂�ւ����������ł��B
*notify
	dupptr nmhdr, lparam, 12
	if nmhdr.0 = hTabControl & nmhdr.2 = -551 {
		ChangeTab
;		���X��screen���߂̃E�B���h�EID 0�ɕ`����߂��܂��B
		gsel
	}
	return

�z�z�� http://lhsp.s206.xrea.com/hsp_object6.html
(.as�Ń��W���[���v���O�C�������Ă��܂�)
*/