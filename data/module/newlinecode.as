#module crlf

#const	TRUE	1
#const	FALSE	0

/* コード番号 */
#const	global	CODE_CR			13
#const	global	CODE_LF			10

/* 改行コード形式 */
#const	global	TYPE_CRLF		0
#const	global	TYPE_CR			1
#const	global	TYPE_LF			2
#const	global	TYPE_NO_CRLF	100	// 改行コードが見つからなかった
#const	global	NUM_TYPE_CRLF	3	// 種類数

/**********************************************************/
// 改行コード形式を識別
/**********************************************************/
#defcfunc id_crlf var buf_to_id
	char = "\n"
	if instr(buf_to_id,0,char)>=0 {
		return TYPE_CRLF
	}
	char = " "
	poke char,0,CODE_CR
	if instr(buf_to_id,0,char)>=0 {
		return TYPE_CR
	}
	poke char,0,CODE_LF
	if instr(buf_to_id,0,char)>=0 {
		return TYPE_LF
	}
	return TYPE_NO_CRLF

/**********************************************************/
// 改行コードを別形式に変換
/**********************************************************/
#deffunc conv_crlf var buf_to_conv, int conv_type
	/****************/
	/* 引数チェック */
	/****************/
	if strlen(buf_to_conv)<=0	: return		// 文字列が空
	if (conv_type>TYPE_LF) | (conv_type<TYPE_CRLF)	: return	// conv_typeが不正

	/********************/
	/* 現在の形式を取得 */
	/********************/
	cur_type = id_crlf(buf_to_conv)
	if cur_type=TYPE_NO_CRLF	: return	// 改行コードは含まれていない

	/**********************/
	/* 現在のコードの設定 */
	/**********************/
	if cur_type=TYPE_CRLF {
		if conv_type=TYPE_CRLF	: return	// 変換の必要なし
	}
	if cur_type=TYPE_CR {
		if conv_type=TYPE_CR	: return	// 変換の必要なし
		cur_code = CODE_CR					// getstrのp4用
	}
	if cur_type=TYPE_LF {
		if conv_type=TYPE_LF	: return	// 変換の必要なし
		cur_code = CODE_LF					// getstrのp4用
	}

	/**********************/
	/* 変換後コードの設定 */
	/**********************/
	if conv_type=TYPE_CRLF	: new_crlf = "\n"
	if conv_type=TYPE_CR	: new_crlf = " "		: poke new_crlf,0,CODE_CR
	if conv_type=TYPE_LF	: new_crlf = " "		: poke new_crlf,0,CODE_LF

	/********/
	/* 変換 */
	/********/
	/* 処理対象文字列の末尾が改行コードかどうかチェック */
	tail = strmid(buf_to_conv,-1,2)	// 処理対象文字列の末尾2文字を取得
	if tail="\n" {
		flag = TRUE
		goto *@f
	}

	tail = strmid(tail,-1,1)	// 末尾1文字を取得
	char = ""	: poke char,0,CODE_CR
	if tail=char	: flag = TRUE	: goto *@f

	char = ""	: poke char,0,CODE_LF
	if tail=char	: flag = TRUE	: goto *@f

	flag = FALSE
*@

	/*
		getstrで改行コードの手前まで取得した文字列を新しい改行コードと
		一緒に別のバッファにためていき最後にまとめて元のバッファに戻す
	*/
	i = 0
	tmpbuf = ""
	len = strlen(buf_to_conv)
	repeat
		if cur_type=TYPE_CRLF {
			getstr tmpstr,buf_to_conv,i
		}
		else {
			getstr tmpstr,buf_to_conv,i,cur_code
		}
		i += strsize
		if i>=len {		// 最後の行
			if flag {	// 処理対象文字列の末尾が改行コード
				tmpbuf += tmpstr+new_crlf
			}
			else {
				tmpbuf += tmpstr
			}
			break
		}
		else {
			tmpbuf += tmpstr+new_crlf
		}
	loop
	buf_to_conv = tmpbuf
	return

/**********************************************************/
// 改行コードを削除
/**********************************************************/
#deffunc rm_crlf var buf_to_rm
	/* getstr検索用改行コード */
	crlfs = 0,CODE_CR,CODE_LF	// CRLFは必要なし

	/* 改行コードを種類ごとに削除 */
	repeat NUM_TYPE_CRLF
		crlftype = cnt
		i = 0
		tmpbuf = ""
		len = strlen(buf_to_rm)
		/*
			getstrで改行コードの手前まで取得した文字列を別のバッファ
			にためていき最後にまとめて元のバッファに戻す
		*/
		repeat
			if i>=len {
				break
			}
			getstr tmpstr,buf_to_rm,i,crlfs(crlftype)
			i += strsize
			tmpbuf += tmpstr
		loop
		buf_to_rm = tmpbuf
	loop
	return

/**********************************************************/

#global