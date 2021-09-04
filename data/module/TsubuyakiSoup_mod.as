#include "tCup_mod.as"
#include "jsonParse.as"

#module
//============================================================
/*  [HDL symbol infomation]

%index
getAuthorizeAddress
�A�N�Z�X�������߂�URL�𐶐�

%prm
()

%inst
���[�U�ɃA�N�Z�X�������߂�A�h���X�𐶐����A�߂�l�Ƃ��ĕԂ��܂��B

������Twitter�ƒʐM���A���N�G�X�g�g�[�N�����擾���Ă��܂��B���N�G�X�g�g�[�N���̎擾�Ɏ��s�����ꍇ�́A"Error"�Ƃ����������Ԃ��܂��B

%group
TwitterAPI����֐�

%*/
//------------------------------------------------------------
#defcfunc getAuthorizeAddress
	// �A�N�Z�X�g�[�N���擾
	sdim arguments
	arguments(0) = "oauth_callback=oob"
	execRestApi "oauth/request_token", arguments, METHOD_GET
	if stat != 200 : return "Error"
	// �g�[�N���̎��o��
	gaa_body = getResponseBody()
	;request_token
	TokenStart = instr(gaa_body, 0, "oauth_token=") + 12
	TokenEnd = instr(gaa_body, TokenStart, "&")
	requestToken = strmid(gaa_body, TokenStart, TokenEnd)
	;request_token_secret
	SecretStart = instr(gaa_body, 0, "oauth_token_secret=") + 19
	SecretEnd = instr(gaa_body, SecretStart, "&")
	requestSecret = strmid(gaa_body, SecretStart, SecretEnd)
	setRequestToken requestToken, requestSecret
return "https://api.twitter.com/oauth/authorize?oauth_token="+ requestToken
//============================================================


//============================================================
/*  [HDL symbol infomation]

%index
GetAccessToken
OAuth��AccessToken��Secret�擾

%prm
p1, p2, p3, p4
p1 = �ϐ�        : Access Token��������ϐ�
p2 = �ϐ�        : Access Secret��������ϐ�
p3 = �ϐ�        : ���[�U����������ϐ�
p4 = ������      : PIN�R�[�h

%inst
TwitterAPI�uoauth/access_token�v�����s���AOAuth������Access Token��Access Secret���擾���܂��B

p1, p2�ɂ��ꂼ��Access Token, Access Secret��������ϐ����w�肵�Ă��������B

p3�ɂ́A���[�U����������ϐ����w�肵�Ă��������B�u���[�UID,���[�U���v�ƃJ���}��؂�Ń��[�U��񂪑������܂��B

p4�ɂ́APIN�R�[�h���w�肵�Ă��������BPIN�R�[�h�́AGetAuthorizeAdress�Ŏ擾����URL�ɃA�N�Z�X���A���[�U���u���v�{�^�����������Ƃ��ɕ\������܂��B�ڂ����́A���t�@�����X���������������B

Access Token��Secret�́A��x�擾����Ɖ��x���g�p���邱�Ƃ��ł��܂��i���݂�Twitter�̎d�l�ł́j�B���̂��߁A��xAccess Token��Secret���擾������ۑ����Ă������Ƃ��������߂��܂��B
�܂��AAccess Token��Secret�̓��[�U���ƃp�X���[�h�̂悤�Ȃ��̂Ȃ̂ŁA�Í������ĕۑ�����ȂǊǗ��ɂ͋C�����Ă��������BOAuth/xAuth�̏ڂ������Ƃ́A���t�@�����X���������������B

%href
GetAuthorizeAdress
GetxAuthToken
SetAccessToken

%group
TwitterAPI���얽��

%*/
//------------------------------------------------------------
#deffunc publishAccessToken var p1, var p2, var p3, str p4
	sdim p1
	sdim p2
	sdim p3
	sdim arguments
	arguments(0) = "oauth_verifier=" + p4
	execRestApi "oauth/access_token", arguments, METHOD_POST
	statcode = stat

	pat_body = getResponseBody()
	if statcode = 200  {
		//�g�[�N���̎��o��
		;request_token
		TokenStart = instr(pat_body, 0, "oauth_token=") + 12
		TokenEnd = instr(pat_body, TokenStart, "&")
		p1 = strmid(pat_body, TokenStart, TokenEnd)
		;request_token_secret
		TokenStart = instr(pat_body, 0, "oauth_token_secret=") + 19
		TokenEnd = instr(pat_body, TokenStart, "&")
		p2 = strmid(pat_body, TokenStart, TokenEnd)
		;User���
		TokenStart = instr(pat_body, 0, "user_id=") + 8
		TokenEnd = instr(pat_body, TokenStart, "&")
		p3 = strmid(pat_body, TokenStart, TokenEnd) +","
		TokenStart = instr(pat_body, 0, "screen_name=") + 12
		TokenEnd = strlen(pat_body)
		p3 += strmid(pat_body, TokenStart, TokenEnd)
	}
return statcode
//============================================================




#deffunc getMentionsTimeline int count

	sdim arguments
	arguments(0) = "count="+ count
	execRestApi "statuses/mentions_timeline.json", arguments, METHOD_GET
return stat


#deffunc getUserTimeline str screen_name, int count

	sdim arguments
	arguments(0) = "screen_name="+ screen_name
	arguments(1) = "count="+ count
	execRestApi "statuses/user_timeline.json", arguments, METHOD_GET
return stat


#deffunc getHomeTimeline int count

	sdim arguments
	arguments(0) = "count="+ count
	execRestApi "statuses/home_timeline.json", arguments, METHOD_GET
return stat

#deffunc getRetweetsOfMe int count

	sdim arguments
	arguments(0) = "count="+ count
	execRestApi "statuses/retweets_of_me.json", arguments, METHOD_GET
return stat


#deffunc getRetweets str id

	sdim arguments
	execRestApi "statuses/retweets/"+id+".json", arguments, METHOD_GET
return stat


#deffunc showStatus str id

	sdim arguments
	execRestApi "statuses/show/"+id+".json", arguments, METHOD_GET
return stat



#deffunc destoryStatus str id

	sdim arguments
	execRestApi "statuses/destroy/"+id+".json", arguments, METHOD_POST
return stat



#deffunc retweetStatus str id

	sdim arguments
	execRestApi "statuses/retweet/"+id+".json", arguments, METHOD_POST
return stat



//============================================================
/*  [HDL symbol infomation]

%index
Tweet
�c�C�[�g����

%prm
p1, p2
p1 = ������      : �c�C�[�g���镶����
p2 = ������      : �ԐM(reply)�Ώۂ̃X�e�[�^�XID

%inst
TwitterAPI�ustatuses/update�v�����s���ATwitter�֓��e���܂��B���ʂ�SetFormatType���߂Ŏw�肵���t�H�[�}�b�g�Ŏ擾���܂��B

p1�Ƀc�C�[�g����140���ȓ��̕�������w�肵�Ă��������B140���ȏ�̏ꍇ�A140���Ɋۂ߂Ă���c�C�[�g����܂��B

p2�ɕԐM(reply)�Ώۂ̃X�e�[�^�XID���w�肷�邱�Ƃłǂ̃X�e�[�^�X�ɑ΂���ԐM���𖾎��ł��܂��Bp2�ɋ󕶎����w�肷�邩�ȗ������ꍇ�́A��������܂���B
TwitterAPI�̎d�l��A���݂��Ȃ��A���邢�̓A�N�Z�X�����̂������Ă���X�e�[�^�XID���w�肵���ꍇ�ƁAp1�Ŏw�肵��������Ɂu@���[�U���v���܂܂�Ȃ��A���邢��@���[�U���v�Ŏw�肵�����[�U�����݂��Ȃ��ꍇ�́A��������܂��B

TwitterAPI�����s�����ۂ̃X�e�[�^�X�R�[�h�̓V�X�e���ϐ�stat�ɑ������܂��B

API�����K�p�ΏۊO��API���g�p���Ă��܂����A1����1000��܂łƂ������s�񐔏�����ݒ肳��Ă��܂�(API�ȊO����̓��e���J�E���g�Ώ�)�B

%href
DelTweet
ReTweet

%group
TwitterAPI���얽��

%*/
//------------------------------------------------------------
#deffunc _Tweet str p1, str p2, str p3, str p4, str p5, str p6
	tmpBuf = p1
	tmpStr = p1

	//utf-8�֕ϊ��B
	//sjis2utf8n tmpStr, tmpBuf
	//nkfcnv tmpStr,tmpBuf,"Ww"
	//POST
	sdim arguments,256
	arguments(0) = "status="+ form_encode(tmpStr, 1)
	if p2 != "" : arguments(1) = "in_reply_to_status_id="+ p2
	if p3 != "" : arguments(2) = "media_ids="+form_encode(p3, 1)
	if p4 != "" : arguments(3) = p4
	if p5 != "" : arguments(4) = p5
	if p6 != "" : arguments(5) = p6
	
	execRestApi "statuses/update.json", arguments, METHOD_POST
return stat
#define global Tweet(%1, %2="", %3="", %4="", %5="", %6="") _Tweet %1, %2, %3, %4, %5, %6
//============================================================


#deffunc media_upload array p1 ,int p3,var p2
	
	sdim rawtext,512
	sdim p2,512
	sdim picname,256
	status = 0
	repeat p3
		exist p1(cnt)
		if strsize <= 0:status = -2:break
	
		picname = p1(cnt)
		execRestApi "media/upload.json", picname, METHOD_POST
		if stat != 200 :status = -1:break
		
		rawtext = "["+getResponseBody()+"]"
		json_sel rawText
		p2 += json_val("[0].media_id_string") + ","
		json_unsel
		await 50
	loop
	p2 = strmid(p2, 0, strlen(p2)-1)

return status

#global

