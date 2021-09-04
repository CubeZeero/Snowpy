#module crlf

#const	TRUE	1
#const	FALSE	0

/* �R�[�h�ԍ� */
#const	global	CODE_CR			13
#const	global	CODE_LF			10

/* ���s�R�[�h�`�� */
#const	global	TYPE_CRLF		0
#const	global	TYPE_CR			1
#const	global	TYPE_LF			2
#const	global	TYPE_NO_CRLF	100	// ���s�R�[�h��������Ȃ�����
#const	global	NUM_TYPE_CRLF	3	// ��ސ�

/**********************************************************/
// ���s�R�[�h�`��������
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
// ���s�R�[�h��ʌ`���ɕϊ�
/**********************************************************/
#deffunc conv_crlf var buf_to_conv, int conv_type
	/****************/
	/* �����`�F�b�N */
	/****************/
	if strlen(buf_to_conv)<=0	: return		// �����񂪋�
	if (conv_type>TYPE_LF) | (conv_type<TYPE_CRLF)	: return	// conv_type���s��

	/********************/
	/* ���݂̌`�����擾 */
	/********************/
	cur_type = id_crlf(buf_to_conv)
	if cur_type=TYPE_NO_CRLF	: return	// ���s�R�[�h�͊܂܂�Ă��Ȃ�

	/**********************/
	/* ���݂̃R�[�h�̐ݒ� */
	/**********************/
	if cur_type=TYPE_CRLF {
		if conv_type=TYPE_CRLF	: return	// �ϊ��̕K�v�Ȃ�
	}
	if cur_type=TYPE_CR {
		if conv_type=TYPE_CR	: return	// �ϊ��̕K�v�Ȃ�
		cur_code = CODE_CR					// getstr��p4�p
	}
	if cur_type=TYPE_LF {
		if conv_type=TYPE_LF	: return	// �ϊ��̕K�v�Ȃ�
		cur_code = CODE_LF					// getstr��p4�p
	}

	/**********************/
	/* �ϊ���R�[�h�̐ݒ� */
	/**********************/
	if conv_type=TYPE_CRLF	: new_crlf = "\n"
	if conv_type=TYPE_CR	: new_crlf = " "		: poke new_crlf,0,CODE_CR
	if conv_type=TYPE_LF	: new_crlf = " "		: poke new_crlf,0,CODE_LF

	/********/
	/* �ϊ� */
	/********/
	/* �����Ώە�����̖��������s�R�[�h���ǂ����`�F�b�N */
	tail = strmid(buf_to_conv,-1,2)	// �����Ώە�����̖���2�������擾
	if tail="\n" {
		flag = TRUE
		goto *@f
	}

	tail = strmid(tail,-1,1)	// ����1�������擾
	char = ""	: poke char,0,CODE_CR
	if tail=char	: flag = TRUE	: goto *@f

	char = ""	: poke char,0,CODE_LF
	if tail=char	: flag = TRUE	: goto *@f

	flag = FALSE
*@

	/*
		getstr�ŉ��s�R�[�h�̎�O�܂Ŏ擾�����������V�������s�R�[�h��
		�ꏏ�ɕʂ̃o�b�t�@�ɂ��߂Ă����Ō�ɂ܂Ƃ߂Č��̃o�b�t�@�ɖ߂�
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
		if i>=len {		// �Ō�̍s
			if flag {	// �����Ώە�����̖��������s�R�[�h
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
// ���s�R�[�h���폜
/**********************************************************/
#deffunc rm_crlf var buf_to_rm
	/* getstr�����p���s�R�[�h */
	crlfs = 0,CODE_CR,CODE_LF	// CRLF�͕K�v�Ȃ�

	/* ���s�R�[�h����ނ��Ƃɍ폜 */
	repeat NUM_TYPE_CRLF
		crlftype = cnt
		i = 0
		tmpbuf = ""
		len = strlen(buf_to_rm)
		/*
			getstr�ŉ��s�R�[�h�̎�O�܂Ŏ擾�����������ʂ̃o�b�t�@
			�ɂ��߂Ă����Ō�ɂ܂Ƃ߂Č��̃o�b�t�@�ɖ߂�
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