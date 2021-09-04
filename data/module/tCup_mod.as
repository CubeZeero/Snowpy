//======================================================================
//    TsubuyakiSoup_mod
//----------------------------------------------------------------------
//    HSPからTwitterを操作するモジュール。
//    OAuthに対応。API1.1へ対応。画像付きツイート対応。
//----------------------------------------------------------------------
//  Version : 2.2
//  Author : Takaya
//	Modification : kanahiron
//  CreateDate : 10/07/29
//  LastUpdate : 17/06/07
//======================================================================
/*  [HDL module infomation]

%dll
TsubuyakiSoup

%ver
2.2

%date
2017/06/07

%note
TsubuyakiSoup_mod.asをインクルードすること。

%port
Win

%*/

#include "encode.as"
#undef                  sjis2utf8n(%1, %2)
#define global          sjis2utf8n(%1, %2) _FromSJIS@mod_encode %2, CODEPAGE_S_JIS, %1, CODEPAGE_UTF_8
#undef                  utf8n2sjis(%1)
#define global ctype    utf8n2sjis(%1)     _ToSJIS@mod_encode(%1, CODEPAGE_UTF_8,  CODEPAGE_S_JIS)

#module tCup

#uselib "advapi32.dll"
#cfunc _CryptAcquireContext "CryptAcquireContextA" var, sptr, sptr, int, int
#cfunc _CryptCreateHash "CryptCreateHash" sptr, int, int, int, var
#cfunc _CryptHashData "CryptHashData" sptr, sptr, int, int
#cfunc _CryptSetHashParam "CryptSetHashParam" sptr, int, var, int
#cfunc _CryptGetHashParam "CryptGetHashParam" sptr, int, sptr, var, int
#cfunc _CryptImportKey "CryptImportKey" sptr, var, int, int, int, var
#func _CryptDestroyKey "CryptDestroyKey" int
#func _CryptDestroyHash "CryptDestroyHash" int
#func _CryptReleaseContext "CryptReleaseContext" int, int
#cfunc _CryptDeriveKey "CryptDeriveKey" int, int, int, int, var
#cfunc _CryptEncrypt "CryptEncrypt" int, int, int, int, int, var, int
#cfunc _CryptDecrypt "CryptDecrypt" int, int, int, int, var, var
//---------------
//  wininet.dll
//---------------
#uselib "wininet.dll"
#cfunc _InternetOpen "InternetOpenA" sptr, int, sptr, sptr, int
#cfunc _InternetOpenUrl "InternetOpenUrlA" int, str, sptr, int, int, int
#func _InternetReadFile "InternetReadFile" int, var, int, var
#func _InternetCloseHandle "InternetCloseHandle" int
#cfunc _InternetConnect "InternetConnectA" int, str, int, sptr, sptr, int, int, int
#cfunc _HttpOpenRequest "HttpOpenRequestA" int, sptr, str, sptr, sptr, sptr, int, int
#cfunc _HttpSendRequest "HttpSendRequestA" int, sptr, int, sptr, int
#cfunc _HttpQueryInfo "HttpQueryInfoA" int, int, var, var, int
#func _InternetQueryDataAvailable "InternetQueryDataAvailable" int, var, int, int
#func _InternetSetOption "InternetSetOptionA" int, int, int, int
//---------------
//  crtdll.dll
//---------------
#uselib "crtdll.dll"
#func _time "time" var

#define HP_HMAC_INFO                            0x0005
#define PLAINTEXTKEYBLOB                        0x8
#define CUR_BLOB_VERSION                        2
#define PROV_RSA_FULL                           1
#define CRYPT_IPSEC_HMAC_KEY                    0x00000100
#define HP_HASHVAL                              0x0002
#define ALG_CLASS_HASH                          (4 << 13)
#define ALG_TYPE_ANY                            (0)
#define ALG_SID_SHA1                            4
#define ALG_SID_HMAC                            9
#define ALG_CLASS_DATA_ENCRYPT                  (3 << 13) // 0x6000
#define ALG_TYPE_BLOCK                          (3 << 9)  // 0x0600
#define ALG_SID_RC2                             2         // 0x0002
#define CALG_SHA1                               (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_SHA1)
#define CALG_HMAC                               (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_HMAC)
#define CALG_RC2                                (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_RC2)

#define CRYPT_NEWKEYSET			$00000008
#define CRYPT_VERIFYCONTEXT     $F0000000
#define CRYPT_DELETEKEYSET		$00000010
#define CRYPT_MACHINE_KEYSET	$00000020
//
#define INTERNET_OPEN_TYPE_DIRECT               1
#define INTERNET_OPTION_CONNECT_TIMEOUT         2
#define INTERNET_OPTION_HTTP_DECODING           65
#define INTERNET_DEFAULT_HTTPS_PORT             443
#define INTERNET_SERVICE_HTTP                   3
#define INTERNET_FLAG_RELOAD                    0x80000000
#define INTERNET_FLAG_SECURE                    0x00800000
#define INTERNET_FLAG_NO_CACHE_WRITE            0x04000000
#define INTERNET_FLAG_DONT_CACHE                INTERNET_FLAG_NO_CACHE_WRITE
#define INTERNET_FLAG_IGNORE_CERT_DATE_INVALID  0x00002000
#define INTERNET_FLAG_IGNORE_CERT_CN_INVALID    0x00001000

#define HTTP_QUERY_MIME_VERSION 0
#define HTTP_QUERY_CONTENT_TYPE 1
#define HTTP_QUERY_CONTENT_TRANSFER_ENCODING 2
#define HTTP_QUERY_CONTENT_ID 3
#define HTTP_QUERY_CONTENT_DESCRIPTION 4
#define HTTP_QUERY_CONTENT_LENGTH 5
#define HTTP_QUERY_CONTENT_LANGUAGE 6
#define HTTP_QUERY_ALLOW 7
#define HTTP_QUERY_PUBLIC 8
#define HTTP_QUERY_DATE 9
#define HTTP_QUERY_EXPIRES 10
#define HTTP_QUERY_LAST_MODIFIED 11
#define HTTP_QUERY_MESSAGE_ID 12
#define HTTP_QUERY_URI 13
#define HTTP_QUERY_DERIVED_FROM 14
#define HTTP_QUERY_COST 15
#define HTTP_QUERY_LINK 16
#define HTTP_QUERY_PRAGMA 17
#define HTTP_QUERY_VERSION 18
#define HTTP_QUERY_STATUS_CODE 19
#define HTTP_QUERY_STATUS_TEXT 20
#define HTTP_QUERY_RAW_HEADERS 21
#define HTTP_QUERY_RAW_HEADERS_CRLF 22
#define HTTP_QUERY_CONNECTION 23
#define HTTP_QUERY_ACCEPT 24
#define HTTP_QUERY_ACCEPT_CHARSET 25
#define HTTP_QUERY_ACCEPT_ENCODING 26
#define HTTP_QUERY_ACCEPT_LANGUAGE 27
#define HTTP_QUERY_AUTHORIZATION 28
#define HTTP_QUERY_CONTENT_ENCODING 29
#define HTTP_QUERY_FORWARDED 30
#define HTTP_QUERY_FROM 31
#define HTTP_QUERY_IF_MODIFIED_SINCE 32
#define HTTP_QUERY_LOCATION 33
#define HTTP_QUERY_ORIG_URI 34
#define HTTP_QUERY_REFERER 35
#define HTTP_QUERY_RETRY_AFTER 36
#define HTTP_QUERY_SERVER 37
#define HTTP_QUERY_TITLE 38
#define HTTP_QUERY_USER_AGENT 39
#define HTTP_QUERY_WWW_AUTHENTICATE 40
#define HTTP_QUERY_PROXY_AUTHENTICATE 41
#define HTTP_QUERY_ACCEPT_RANGES 42
#define HTTP_QUERY_SET_COOKIE 43
#define HTTP_QUERY_COOKIE 44
#define HTTP_QUERY_REQUEST_METHOD 45
#define HTTP_QUERY_MAX 45
#define HTTP_QUERY_CUSTOM 65535
#define HTTP_QUERY_FLAG_REQUEST_HEADERS 0x80000000
#define HTTP_QUERY_FLAG_SYSTEMTIME 0x40000000
#define HTTP_QUERY_FLAG_NUMBER 0x20000000
#define HTTP_QUERY_FLAG_COALESCE 0x10000000
#define HTTP_QUERY_MODIFIER_FLAGS_MASK (HTTP_QUERY_FLAG_REQUEST_HEADERS|HTTP_QUERY_FLAG_SYSTEMTIME|HTTP_QUERY_FLAG_NUMBER|HTTP_QUERY_FLAG_COALESCE)
#define HTTP_QUERY_HEADER_MASK (~HTTP_QUERY_MODIFIER_FLAGS_MASK)


//------------------------------
//  定数
//------------------------------
//HTTPメソッド
#define global METHOD_GET    0
#define global METHOD_POST   1
#define global METHOD_DELETE 2
#define global METHOD_PUT    3
#define global FORMAT_JSON   0
#define global FORMAT_XML    1




//============================================================
/*  [HDL symbol infomation]

%index
tCupInit
TsubuyakiSoupの初期化

%prm
p1, p2, p3
p1 = 文字列      : ユーザエージェント
p2 = 文字列      : Consumer Key
p3 = 文字列      : Consumer Secret
p4 = 0〜(30)     : タイムアウトの時間(秒)

%inst
TsubyakiSoupモジュールの初期化をします。Twitter操作命令の使用前に呼び出す必要があります。

p1にユーザエージェントを指定します。ユーザエージェントを指定していないとSearchAPIなどで厳しいAPI制限を受けることがあります。

p2にConsumer Keyを、p3にConsumer Secretを指定してください。Consumer KeyとConsumer Secretは、Twitterから取得する必要があります。詳しくは、リファレンスをご覧ください。

p4にはTwitterと通信する際のタイムアウトの時間を秒単位で指定してください。

%href
TS_End

%group
TwitterAPI操作命令

%*/
//------------------------------------------------------------
#deffunc _tCupInit str p1, str p2, str p3, int p4
	//各種変数の初期化
;	rateLimit(0) = -1		// 15分間にAPIを実行できる回数
;	rateLimit(1) = -1		// APIを実行できる残り回数
;	rateLimit(2) = -1		// リセットする時間
	accessToken = ""		// AccessToken
	accessSecret = ""		// AccessTokenSecret
	requestToken = ""		// RequestToken
	requestSecret = ""		// RequestTokenSecret
	consumerKey = p2		// ConsumerKey
	consumerSecret = p3		// ConsumerSecret
	screenName = ""
	userId = ""
	formatType = "json"
	responseHeader = ""
	responseBody = ""
	timeOutTime = p4*1000
	gzipFlag = 1 // true /-------------------
	//インターネットオープン
	hInet = _InternetOpen( p1, INTERNET_OPEN_TYPE_DIRECT, 0, 0, 0)
	if hInet = 0:return -1
	_InternetSetOption hInet, INTERNET_OPTION_CONNECT_TIMEOUT, varptr(timeOutTime), 4
	_InternetSetOption hInet, INTERNET_OPTION_HTTP_DECODING, varptr(gzipFlag), 4
return 0
#define global tCupInit(%1,%2,%3,%4=30) _tCupInit %1, %2, %3, %4
//============================================================




//============================================================
/*  [HDL symbol infomation]

%index
tCupWash
TsubuyakiSoupの終了処理

%inst
TsubyakiSoupモジュールの終了処理を行ないます。
プログラム終了時に自動的に呼び出されるので明示的に呼び出す必要はありません。

%href
TS_Init

%group
TwitterAPI操作命令

%*/
//------------------------------------------------------------
#deffunc tCupWash onexit
	//ハンドルの破棄
	if (hRequest) : _InternetCloseHandle hRequest
	if (hConnect) : _InternetCloseHandle hConnect
	if (hInet) : _InternetCloseHandle hInet
return
//============================================================



//============================================================
/*  [HDL symbol infomation]

%index
getHmacSha1
HMAC-SHA1で署名を生成

%prm
(p1, p2)
p1 = 文字列    : 署名化する文字列
p2 = 文字列    : 鍵とする文字列

%inst
SHA-1ハッシュ関数を使用したハッシュメッセージ認証コード（HMAC）を返します。

p1に署名化する文字列を指定します。

署名化するための鍵（キー）は、p2で文字列で指定します。

%href
sigEncode

%group
TsubuyakiSoup補助関数

%*/
//------------------------------------------------------------
#deffunc getHmacSha1 str _p1, str _p2, var ghc_dest

	ghc_p1 = _p1
	ghc_p2 = _p2

	hProv = 0
	hKey  = 0
	hHash = 0

	ghc_dataLength = 0
	sdim hmacInfo,14
	lpoke hmacInfo, 0, CALG_SHA1
	
	ghc_p2Length = strlen(ghc_p2)
	dim keyBlob, 3+(ghc_p2Length/4)+1
	
	poke keyBlob, 0, PLAINTEXTKEYBLOB
	poke keyBlob, 1, CUR_BLOB_VERSION
	wpoke keyBlob, 2, 0
	lpoke keyBlob, 4, CALG_RC2
	lpoke keyBlob, 8, ghc_p2Length
	memcpy keyBlob, ghc_p2, ghc_p2Length, 12, 0

	sdim ghc_dest, 20
	ghc_dest = "Error"

	//コンテキストの取得
	if ( _CryptAcquireContext(hProv, 0, 0, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) ) {
		//キーのインポート
		if ( _CryptImportKey(hProv, keyBlob, (12+ghc_p2Length), 0, CRYPT_IPSEC_HMAC_KEY, hKey) ) {
			if ( _CryptCreateHash(hProv, CALG_HMAC, hKey, 0, hHash) ) {
				if ( _CryptSetHashParam(hHash, HP_HMAC_INFO, hmacInfo, 0) ) {
					if ( _CryptHashData(hHash, ghc_p1, strlen(ghc_p1), 0) ) {
						if ( _CryptGetHashParam(hHash, HP_HASHVAL, 0, ghc_dataLength, 0) ) {
							ghc_dest = ""
							if ( _CryptGetHashParam(hHash, HP_HASHVAL, varptr(ghc_dest), ghc_dataLength, 0) ) {
							}
						}
					}
				}
				//ハッシュハンドルの破棄
				_CryptDestroyHash hHash
			}
			//キーハンドルの破棄
			_CryptDestroyKey hKey
		}
		//ハンドルの破棄
		_CryptReleaseContext hProv, 0
	}

return 
//============================================================




//============================================================
/*  [HDL symbol infomation]

%index
sigEncode
OAuth/xAuth用シグネチャを生成

%prm
(p1, p2)
p1 = 文字列    : 署名化する文字列
p2 = 文字列    : 鍵とする文字列

%inst
OAuth/xAuth用の署名を返します。

p1に署名化する文字列を指定します。

署名化するための鍵（キー）は、p2で文字列で指定します。

Twitterのシグネチャ生成の仕様より、
文字コードUTF-8でURLエンコードした文字列（p1）を、同じくURLエンコードした文字列（p2）をキーとしてHAMAC-SHA1方式で生成した署名を、BASE64エンコードしたうえURLエンコードしています。

%href
HMAC_SHA1

%group
TsubuyakiSoup補助関数

%*/
//------------------------------------------------------------
#defcfunc sigEncode str se_p1, str se_p2
	//utf-8へ変換
	sjis2utf8n SigTmp, se_p1
	sjis2utf8n SecretTmp, se_p2
	//URLエンコード
	SigEnc = form_encode(SigTmp, 0)
	SecretEnc = form_encode(SecretTmp, 0)
	getHmacSha1 SigEnc, SecretEnc, HmacSha1
	if (HmacSha1 == "Error"):return "Error"
	sdim base64HmacSha1,40
	Base64Encode HmacSha1,20,base64HmacSha1
return form_encode(str(base64HmacSha1), 0)
//============================================================


// str   p1 API
// array p2 argument
// int   p3 http method
#deffunc execRestApi str era_p1, array era_p2, int era_p3

	api = era_p1
	
	if (api != "media/upload.json") {
		arrayCopy era_p2, arguments
		argumentLength = length(arguments)
	} else {
		exist era_p2
		picsize = strsize
		sdim picdata,picsize+1
		bload era_p2,picdata
		sdim base64data,int(1.5*picsize)
		Base64Encode picdata,picsize,base64data
	}
	
	methodType = era_p3
	
	switch methodType
		case METHOD_GET
			method = "GET"
			swbreak
		case METHOD_POST
			method = "POST"
			swbreak
		case METHOD_PUT
			method = "PUT"
			swbreak
		case METHOD_DELETE
			method = "DELETE"
			swbreak
		default
			return 0
			swbreak
	swend
	
	sigArrayLength = 6+argumentLength
	sdim sigArray, 500, sigArrayLength

	hConnect = 0	// InternetConnectのハンドル
	hRequest = 0	// HttpOpenRequestのハンドル
	statcode = 0	// リクエストの結果コード
	dataLength = 0	// データ長
	rsize = 1024	// バッファ初期値
	hsize = 0		// 取得したバイト数が代入される変数

	apiVersion = "1.1"	// TwitterAPIのバージョン
	
	RequestURL = "api.twitter.com"
	if (api = "media/upload.json") {
		RequestURL = "upload.twitter.com"
	}

	apiUrl = apiVersion +"/"+ api
	transStr = method +" https://"+RequestURL+"/"+ apiVersion +"/"+ api +" "
	if (strmid(api,0,5) = "oauth") {
		apiUrl = api
		transStr = method +" https://api.twitter.com/"+ api +" "
	}
	
	usePort = 443
	requestFlag  = INTERNET_FLAG_RELOAD
	requestFlag |= INTERNET_FLAG_SECURE
	requestFlag |= INTERNET_FLAG_DONT_CACHE
	requestFlag |= INTERNET_FLAG_IGNORE_CERT_DATE_INVALID
	requestFlag |= INTERNET_FLAG_IGNORE_CERT_CN_INVALID

	tokenStr = accessToken
	sigKey = consumerSecret+" "+accessSecret
	logmes "sigkey="+sigKey
	if (api = "oauth/access_token") {
		tokenStr = requestToken
		sigKey = consumerSecret+" "+requestSecret
	}

//  シグネチャ生成
	
	sigNonce = getRandomString(8, 32)
	_time sigTime
	sigArray(0) = "oauth_consumer_key=" + consumerKey
	sigArray(1) = "oauth_nonce=" + sigNonce
	sigArray(2) = "oauth_signature_method=HMAC-SHA1"
	sigArray(3) = "oauth_timestamp=" + sigTime
	sigArray(4) = "oauth_token="+ tokenStr
	sigArray(5) = "oauth_version=1.0"
	
	if (api != "media/upload.json") {
		repeat argumentLength
			sigArray(6+cnt) = arguments(cnt)
		loop
	}
	
	_sortStrArray sigArray, 0, sigArrayLength-1

	repeat sigArrayLength
		logmes sigArray(cnt)
		if sigArray(cnt) = "" : continue
		transStr += sigArray(cnt) +"&"
	loop
	
	transStr = strmid(transStr, 0, strlen(transStr)-1)
	signature = sigEncode(transStr, sigKey)
	
	
	
	if (methodType = METHOD_POST) {
	
		sdim boundary,128
		boundary = "-------------"+getRandomString(24, 32)
			
		sdim RequestHeader,1024*2
		RequestHeader = "Authorization: OAuth "
		
		repeat sigArrayLength
			RequestHeader += sigArray(cnt)+"," 
		loop
		
		RequestHeader += "oauth_signature=" +signature
		RequestHeader += "\r\nAccept-Encoding: gzip, deflate;"
		if (api = "media/upload.json") {
			RequestHeader += "\r\nContent-Type: multipart/form-data; boundary= "+boundary
		} else {
			RequestHeader += "\r\nContent-Type: application/x-www-form-urlencoded"
		}
		RequestHeader += "\r\n"
		RequestHeaderLength = strlen(RequestHeader)
	
		
		if (api = "media/upload.json") {
			sdim PostData,1024*4+strlen(base64data)
			PostData += "--"+boundary+"\n"
			PostData += "Content-Disposition: form-data; name=\"media_data\";\n\n"
			PostData += base64data
			PostData += "\n"
			PostData += "--"+boundary+"--\n"
		} else {
			sdim PostData,1024*4
			repeat argumentLength
				PostData += arguments(cnt)+"&"
			loop
			PostData = strmid(PostData, 0, strlen(PostData)-1) //後ろの&を除去
		}
		PostDataLength = strlen(PostData)
	}
	
	if (methodType = METHOD_GET) {
		apiUrl += "?"
		repeat sigArrayLength
			apiUrl += sigArray(cnt) +"&"
		loop
		apiUrl += "oauth_signature=" +signature
	
		RequestHeader = "Accept-Encoding: gzip, deflate;\nContent-Type: application/x-www-form-urlencoded"
		RequestHeaderLength = strlen(RequestHeader)
		PostData = 0
		PostDataLength = 0
	}
	
	
	//サーバへ接続
	hConnect = _InternetConnect(hInet, RequestURL, INTERNET_DEFAULT_HTTPS_PORT, 0, 0, INTERNET_SERVICE_HTTP, 0, 0)
	if (hConnect = 0) {
		//Connectハンドルを取得できなかった場合
		return -4
	}
	
	//リクエストの初期化
	hRequest = _HttpOpenRequest(hConnect, method, apiUrl, "HTTP/1.1", 0, 0, requestFlag, 0)
	if (hRequest = 0) {
		//Requestハンドルを取得できなかった場合
		_InternetCloseHandle hConnect
		return -3
	}
	
	//サーバへリクエスト送信
	if ( _HttpSendRequest(hRequest, RequestHeader, RequestHeaderLength, PostData, PostDataLength)) {
		//ヘッダを取得する変数の初期化
		responseHeaderSize = 3000
		sdim responseHeader, responseHeaderSize
		//ヘッダの取得
		if ( _HttpQueryInfo(hRequest, HTTP_QUERY_RAW_HEADERS_CRLF, responseHeader, responseHeaderSize, 0) ) {
			//ヘッダの解析
			notesel responseHeader
			repeat notemax
				noteget headerLine, cnt
				headerTokenPos = instr(headerLine, 0, "status: ")				//ステータスコード
				if (headerTokenPos != -1) : statcode = int(strmid(headerLine, headerTokenPos+8, 3))
				headerTokenPos = instr(headerLine, 0, "content-length: ")		//長さ
				if (headerTokenPos != -1) : responseBodyLength = int(strmid(headerLine, -1, strlen(headerLine)-headerTokenPos+16))
;				API_buf = instr(API_BufStr, 0, "X-RateLimit-Limit: ")		//60分間にAPIを実行できる回数
;				if (API_Buf != -1) : TS_RateLimit(0) = int(strmid(API_BufStr, -1, strlen(API_BufStr)-(API_buf+19)))
;				API_buf = instr(API_BufStr, 0, "X-RateLimit-Remaining: ")	//APIを実行できる残り回数
;				if (API_Buf != -1) : TS_RateLimit(1) = int(strmid(API_BufStr, -1, strlen(API_BufStr)-(API_buf+23)))
;				API_buf = instr(API_BufStr, 0, "X-RateLimit-Reset: ")		//リセットする時間
;				if (API_Buf != -1) : TS_RateLimit(2) = int(strmid(API_BufStr, -1, strlen(API_BufStr)-(API_buf+19)))
			loop
			noteunsel
			logmes ""+responseBodyLength
			//入手可能なデータ量を取得
			_InternetQueryDataAvailable hRequest, rsize, 0, 0
			//バッファの初期化
			logmes "srize : "+ rsize
			sdim responseBuffer, rsize+1
			sdim responseBody, 10240
			repeat 
				_InternetReadFile hRequest, responseBuffer, rsize, hsize
				if (hsize = 0) : break 
				responseBody += strmid(responseBuffer, 0, hsize)
				await 0
			loop
		} else {
			//ヘッダの取得ができなかった場合
			return -1
		}
		//Requestハンドルの破棄
		_InternetCloseHandle hRequest
	} else {
		//サーバへリクエスト送信できなかった場合
		return -2
	}
	
	sdim picdata
	sdim base64data
	sdim RequestHeader
	sdim PostData

return statcode

//===========================================================

#defcfunc getResponseHeader
return responseHeader

#defcfunc getResponseBody
return responseBody


//============================================================
/*  [HDL symbol infomation]

%index
SetAccessToken
AccessTokenとSecretを設定

%prm
p1, p2
p1 = 文字列      : Access Token
p2 = 文字列      : Access Secret

%inst
TsubuyakiSoupにAccess TokenとAccess Secretを設定します。

p1にAccess Tokenを、p2にAccess Secretを指定します。

このAccess TokenとAccess Secretは、GetAccessToken命令かGetxAuthToken命令で取得することができます。詳しくは、リファレンスをご覧ください。

%href
GetAccessToken
GetxAuthToken

%group
TwitterAPI操作命令

%*/
//------------------------------------------------------------
#deffunc setAccessToken str sat_p1, str sat_p2
	accessToken = sat_p1
	accessSecret = sat_p2
return
//============================================================




//============================================================
/*  [HDL symbol infomation]

%index
setRequestToken
RequestTokenとSecretを設定

%prm
p1, p2
p1 = 文字列      : Request Token
p2 = 文字列      : Request Secret

%inst
TsubuyakiSoupにRequest TokenとRequest Secretを設定します。

p1にRequest Tokenを、p2にRequest Secretを指定します。


%href
setAccessToken

%group
TwitterAPI操作命令

%*/
//------------------------------------------------------------
#deffunc setRequestToken str srt_p1, str srt_p2
	requestToken = srt_p1
	requestSecret = srt_p2
return
//============================================================



//============================================================
/*  [HDL symbol infomation]

%index
getRequestToken
RequestTokenとSecretを設定

%prm
()

%inst



%href
setAccessToken

%group
TwitterAPI操作命令

%*/
//------------------------------------------------------------
#defcfunc getRequestToken
return requestToken
//============================================================




//============================================================
/*  [HDL symbol infomation]

%index
getRequestSecret
RequestTokenとSecretを設定

%prm
()

%inst



%href
setAccessToken

%group
TwitterAPI操作命令

%*/
//------------------------------------------------------------
#defcfunc getRequestSecret
return requestSecret
//============================================================




//============================================================
/*  [HDL symbol infomation]

%index
setConsumerToken
AccessTokenとSecretを設定

%prm
p1, p2
p1 = 文字列      : Consumer Token
p2 = 文字列      : Consumer Secret

%inst
TsubuyakiSoupにConsumer TokenとConsumer Secretを設定します。

p1にConsumer Tokenを、p2にConsumer Secretを指定します。

%href
tCupInit

%group
TwitterAPI操作命令

%*/
//------------------------------------------------------------
#deffunc setConsumerToken str sct_p1, str sct_p2
	consumerToken = sct_p1
	consumerSecret = sct_p2
return
//============================================================




//============================================================
/*  [HDL symbol infomation]

%index
setUserInfo
ユーザ情報を設定

%prm
p1, p2
p1 = 文字列      : ユーザ名（スクリーン名）
p2 = 文字列      : ユーザID

%inst
TsubuyakiSoupにユーザ名（スクリーン名）とユーザIDを設定します。

p1にユーザ名（スクリーン名）を、p2にユーザIDを指定します。

TsubuyakiSoup2からユーザIDも文字列で処理しています。

%href
GetAccessToken
GetxAuthToken

%group
TwitterAPI操作命令

%*/
//------------------------------------------------------------
#deffunc setUserInfo str sui_p1, str sui_p2
	screenName = sui_p1
	userId = sui_p2
return
//============================================================



#global



#module

#uselib "kernel32.dll"
#cfunc _MultiByteToWideChar "MultiByteToWideChar" int, int, sptr, int, int, int

/*------------------------------------------------------------*/
//1バイト・2バイト判定
//
//	isByte(p1)
//		p1...判別文字コード
//		[0:1byte/1:2byte]
//
#defcfunc isByte int p1
return (p1>=129 and p1<=159) or (p1>=224 and p1<=252)
/*------------------------------------------------------------*/




// quick sort
// http://ja.wikipedia.org/wiki/%E3%82%AF%E3%82%A4%E3%83%83%E3%82%AF%E3%82%BD%E3%83%BC%E3%83%88
#deffunc _sortStrArray array p1, int p2, int p3
	p = p1((p2+p3)/2)
	i = p2
	j = p3

	repeat
		// i
		repeat
			if strcmp(p1(i), p) >= 0 : break
			i++
		loop
		// j
		repeat
			if strcmp(p1(j), p) <= 0 : break
			j--
		loop

		// 入れ替え

		if (i < j) {
			tmp = p1(i)
			p1(i) = p1(j)
			p1(j) = tmp
		} else {
			break
		}
		i++
		j--
	loop
	
	if ( i-p2 > 1 ) : _sortStrArray p1, p2, i-1
	if ( p3-j > 1 ) : _sortStrArray p1, j+1, p3
return



#defcfunc strcmp str _p1, str _p2

	p1n = _p1
	p2n = _p2
	
	p1v = peek(p1n, 0)
	p2v = peek(p2n, 0)
	n = 0
	while (p1v = p2v)
		if (p1v = 0 or p2v = 0) : _break
	
		n++
		p1v = peek(p1n, n)
		p2v = peek(p2n, n)
	wend
return p1v - p2v



#deffunc arrayCopy array ary1, array ary2
	dimtype ary2, vartype(ary1), length(ary1)
	foreach ary1
		ary2(cnt) = ary1(cnt)
	loop
return



/*------------------------------------------------------------*/
//半角・全角含めた文字数を取り出す
//
//	mb_strmid(p1, p2, p3)
//		p1...取り出すもとの文字列が格納されている変数名
//		p2...取り出し始めのインデックス
//		p3...取り出す文字数
//
#defcfunc mb_strmid var p1, int p2, int p3
	if vartype != 2 : return ""
	s_size = strlen(p1)
	trim_start = 0
	trim_num = 0
	repeat p2
		if (Is_Byte(peek(p1,trim_start))) : trim_start++
		trim_start++
	loop
	repeat p3
		if (Is_Byte(peek(p1,trim_start+trim_num))) : trim_num++
		trim_num++
	loop
return strmid(p1,trim_start,trim_num)




//p2 半角スペースの処理  0 : '&'  1 : '%20'
#defcfunc form_encode str p1, int p2
/*
09 az AZ - . _ ~
はそのまま出力
*/
fe_str = p1
fe_p1Long = strlen(p1)
sdim fe_val, fe_p1Long*3
repeat fe_p1Long
	fe_flag = 0
	fe_tmp = peek(fe_str, cnt)
	if (('0' <= fe_tmp)&('9' >= fe_tmp)) | (('A' <= fe_tmp)&('Z' >= fe_tmp)) | (('a' <= fe_tmp)&('z' >= fe_tmp)) | (fe_tmp = '-') | (fe_tmp = '.') | (fe_tmp = '_') | (fe_tmp = '~') :{
		poke fe_val, strlen(fe_val), fe_tmp
	} else {
		if fe_tmp = ' ' {
			if p2 = 0 : fe_val += "&"
			if p2 = 1 : fe_val += "%20"	//空白処理
		} else {
			fe_val += "%" + strf("%02X",fe_tmp)
		}
	}
loop
return fe_val

//ランダムな文字列を発生させる
//p1からp2文字まで
#defcfunc getRandomString int p1, int p2
;randomize
RS_Strlen = rnd(p2-p1+1) + p1
sdim RS_val, RS_Strlen
repeat RS_Strlen
	RS_rnd = rnd(3)
	if RS_rnd = 0 : RS_s = 48 + rnd(10)
	if RS_rnd = 1 : RS_s = 65 + rnd(26)
	if RS_rnd = 2 : RS_s = 97 + rnd(26)
	poke RS_val, cnt, RS_s
loop
return RS_val

#global


//================================================================================
//【名    称】  mbase64 Version 1.00
//【制作者名】 イノビア 
//【動作環境】  Windows 2000 ,XP ,Vista ,7 (HSP3用のモジュールです)
//【公 開 日】  2010.01.26
//【更 新 日】　2010.01.26
//【開発言語】　HSP 3.2a + Microsoft Visual C++ 2008 Express Edition （マシン語のところのみ）
//================================================================================
//サポートURL : http://homepage2.nifty.com/MJHS/ ひねくれソフト工房 管理人 イノビア
//================================================================================
// マシン語で Base64!

#module "_machinebase64_"

#uselib "kernel32.dll"
#func VirtualProtect "VirtualProtect" var,int,int,var
#define xdim(%1,%2) dim %1,%2: VirtualProtect %1,%2*4,$40,AZSD

#deffunc Base64Encode var src, int size, var dest

	base64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	xdim base64enc,54
	base64enc.0 = 0x51EC8B55, 0x10558B51, 0xC9335653, 0x33F63357, 0x0C4D39FF, 0x89FC4D89
	base64enc.6 = 0x8E0FF84D, 0x000000AC, 0x8B08458B, 0xB60FF85D, 0xE3C10704, 0x89C30B08
	base64enc.12 = 0xF983F845, 0x6A377502, 0x458B5912, 0x145D8BF8, 0xE083F8D3, 0x18048A3F
	base64enc.18 = 0xFF420288, 0x8346FC45, 0x0E754CFE, 0x420D02C6, 0x420A02C6, 0x4583F633
	base64enc.24 = 0xE98302FC, 0x33D37906, 0xF84D89C9, 0x474101EB, 0x7C0C7D3B, 0x01F983AB
	base64enc.30 = 0x036A527C, 0x2BC78B5F, 0x0C4589C1, 0x097EC085, 0x65C1C88B, 0x754908F8
	base64enc.36 = 0x59126AF9, 0x7F0C7D39, 0xF8458B12, 0xD3145D8B, 0x3FE083F8, 0x8818048A
	base64enc.42 = 0xC603EB02, 0xFF423D02, 0x8346FC45, 0x0E754CFE, 0x420D02C6, 0x420A02C6
	base64enc.48 = 0x4583F633, 0x834F02FC, 0xC87906E9, 0x5FFC458B, 0x0002C65E, 0x10C2C95B
	prm.0 = varptr(src), size, varptr(dest), varptr(base64)
	return callfunc(prm, varptr(base64enc), 4)
	
#deffunc Base64Decode var src, int size, var dest//,var d1,var d2,var d3,var d4

	base64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	xdim base64dec,56
	base64dec.0 = 0x51EC8B55, 0x8B565351, 0xC0331075, 0x33D23357, 0x0C4539FF, 0x89F84589
	base64dec.6 = 0x8E0FFC45, 0x0000008A, 0x8A084D8B, 0xD98A0F0C, 0xC141EB80, 0xFB8006E2
	base64dec.12 = 0x0F087719, 0xE983C9BE, 0x8A22EB41, 0x61EB80D9, 0x7719FB80, 0xC9BE0F08
	base64dec.18 = 0xEB47E983, 0x80D98A10, 0xFB8030EB, 0x0F0A7709, 0xC183C9BE, 0xEBD10B04
	base64dec.24 = 0x2BF9801C, 0xCA830575, 0x8012EB3E, 0x05752FF9, 0xEB3FCA83, 0x3DF98008
	base64dec.30 = 0x45FF2375, 0x03F883F8, 0x45011875, 0x59106AFC, 0xF8D3C28B, 0x83460688
	base64dec.36 = 0xF47908E9, 0xC033D233, 0xEB4006EB, 0x06FAC103, 0x0C7D3B47, 0xFF768C0F
	base64dec.42 = 0x046AFFFF, 0x85C82B59, 0xC1067EC9, 0x754906E2, 0xFC458BFA, 0x8359106A
	base64dec.48 = 0xDA8B03C0, 0x1E88FBD3, 0x08E98346, 0x452BF479, 0x06C65FF8, 0xE8835E00
	base64dec.54 = 0xC2C95B03, 0x00000010
	prm.0 = varptr(src), size, varptr(dest), varptr(base64)
	//prm.4 = varptr(d1),varptr(d2),varptr(d3),varptr(d4) ;<- debug
	return callfunc(prm, varptr(base64dec), 4)

#global
