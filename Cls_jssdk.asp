<%
'surnfu@126.com  20150430
'根据官方PHP示例代码转换为ASP类
Class JSSDK
	Private APPID_
	Private appSecret_
	Private flag_ Rem 全局标识前缀
	Private sc4Json_

	Private Sub Class_Initialize()
		server.scripttimeout=999999
		Set sc4Json_ = Server.CreateObject("MSScriptControl.ScriptControl")
			sc4Json_.Language = "JavaScript"
			sc4Json_.AddCode "var itemTemp=null;function getJSArray(arr, index){itemTemp=arr[index];}"

	End Sub

    Private Sub Class_Terminate()
		set sc4Json_=nothing
    End Sub


	Public Property Let APPID(ByVal Val)
  		APPID_ = Trim(Val)
	End Property

	Public Property Let SECRET(ByVal Val)
  		appSecret_ = Trim(Val)
	End Property


	public function getSignPackage()
		Dim jsapiTicket : jsapiTicket = getJsApiTicket()
		Dim timestamp : timestamp = getTimer()
		Dim nonceStr : nonceStr = "1jk32jek23en32nmn" 'GetRndletter(16)
		Dim thisurl_ : thisurl_=GetURL()
		'response.Write("url:"& thisurl_ &"<br>")
		'这里参数的顺序要按照 key 值 ASCII 码升序排序
		Dim string_ : string_ = "jsapi_ticket="& jsapiTicket &"&noncestr="& nonceStr &"&timestamp="& timestamp &"&url="& thisurl_
		Dim signature : signature = sha1(string_)

		Dim Sys_
		Set Sys_=CreateObject("Scripting.Dictionary")
			Sys_.CompareMode=1
			Sys_.Add "appId" , appId_
			Sys_.Add "nonceStr" , nonceStr
			Sys_.Add "timestamp" , timestamp
			Sys_.Add "url" , thisurl_
			Sys_.Add "signature" , signature
			Sys_.Add "rawString" , string_
		Set getSignPackage=Sys_
	end function



	private function getJsApiTicket()
		'jsapi_ticket 应该全局存储与更新，以下代码以写入到文件中做示例
		if CacheExists("JsApiTicket") then
			Dim accessToken : accessToken = getAccessToken()
			if accessToken<>"" then
				' $url = "https://qyapi.weixin.qq.com/cgi-bin/get_jsapi_ticket?access_token=$accessToken"; 如果是企业号用以下 URL 获取 ticket
				Dim strJson : strJson=GetHttpURL("https://api.weixin.qq.com/cgi-bin/ticket/getticket?type=jsapi&access_token="& accessToken)
				Dim objRe : Set objRe = getJSONObject(strJson)
				if objRe.errmsg<>"ok" then
					'call InErr("获取JsApiTicket失败:"& strJson)
					'response.End()
					getJsApiTicket=strJson
				else
					Dim JsApiTicket_ : JsApiTicket_= objRe.ticket
					Set objRe=nothing
					Call AddCache("JsApiTicket", JsApiTicket_)

					getJsApiTicket = JsApiTicket_

				end if
			else
				getJsApiTicket=""
			end if
		else
			getJsApiTicket = GetCache("JsApiTicket")
		end if
	end function

	private function getAccessToken()
		'access_token 应该全局存储与更新
		if CacheExists("AccessToken") then
			'$url = "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$this->appId&corpsecret=$this->appSecret"; 如果是企业号用以下URL获取access_token
			Dim strJson : strJson=GetHttpURL("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid="& APPID_ &"&secret="& appSecret_)
			Dim objRe : Set objRe = getJSONObject(strJson)
			'response.Write("getAccessToken:"& strJson &"<br>")

			if InStr(strJson,"errcode")>0 then
				getAccessToken =strJson
				'call InErr("获取AccessToken失败:"& strJson)
				'response.End()
			else
				Dim AccessToken_ : AccessToken_= objRe.access_token
				Set objRe=nothing
				Call AddCache("AccessToken", AccessToken_)

				getAccessToken = AccessToken_

			end if
		else
			getAccessToken = GetCache("AccessToken")
		end if
	end function



	Private Function GetRndletter(Num)
		Dim Rndletter : Rndletter=""
		Dim letters : letters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		Dim i_
		Dim RndNumber
		For i_=1 to Num
			Randomize
			RndNumber=Int((len(letters) - 1 + 1) * Rnd + 1)
			Rndletter=Rndletter & Mid(letters, RndNumber, 1)
		Next
		GetRndletter=Rndletter
	End Function



	Private Function GetHttpURL(url)
		Dim http
		set http=server.createobject("Msxml2.ServerXMLHTTP.3.0")
			http.open "get",url,false
			http.setRequestHeader "If-Modified-Since","0"
			http.send()
			GetHttpURL=http.responsetext
		set http=nothing
	End Function


	Private Function getJSONObject(strJSON)
		sc4Json_.AddCode "var jsonObject = " & strJSON
		Set getJSONObject = sc4Json_.CodeObject.jsonObject
	End Function

	Private Sub getJSArrayItem(objDest,objJSArray,index)
		On Error Resume Next
		sc4Json_.Run "getJSArray",objJSArray, index
		Set objDest = sc4Json_.CodeObject.itemTemp
		If Err.number=0 Then Exit Sub
		objDest = sc4Json.CodeObject.itemTemp
	End Sub

	Private Function GetURL()
		Dim Url_
		If LCase(Request.ServerVariables("HTTPS")) = "off" Then
			Url_="http://"&	Request.ServerVariables("SERVER_NAME")
		Else
			Url_="https://"& Request.ServerVariables("SERVER_NAME")
		End If
		If Request.ServerVariables("SERVER_PORT") <> "80" and Request.ServerVariables("SERVER_PORT") <> "443" Then Url_ = Url_ & ":" & Request.ServerVariables("SERVER_PORT")
		Url_=Url_ & Request.ServerVariables("SCRIPT_NAME")
		If Request.ServerVariables("QUERY_STRING") <>"" Then Url_=Url_&"?"& Request.ServerVariables("QUERY_STRING")
		GetURL=Url_
	End Function



	Rem 检查全局缓存
	Private Function CacheExists(ByVal vNewName)
		Dim ObjExists
		CacheExists=True
		Dim CacheData : CacheData=Application(flag_ &"_"& LCase(vNewName))
		If Not IsArray(CacheData) Then Exit Function
		If Not IsDate(CacheData(1)) Then Exit Function
		If DateDiff("s",CDate(CacheData(1)),Now()) < 7000  Then
			ObjExists=False
		End If
	End Function


	Private Sub AddCache(ByVal vNewName, ByVal vNewValue)
		Dim ChildCacheName : ChildCacheName=LCase(vNewName)
		if ChildCacheName<>"" then
   				Dim CacheData : CacheData=Application(flag_ &"_"& ChildCacheName)
   				If IsArray(CacheData)  Then
					if IsObject(vNewValue) then
    					Set CacheData(0)=vNewValue
					else
						CacheData(0)=vNewValue
					end if
    				CacheData(1)=Now()
				else
				    ReDim CacheData(2)
					if IsObject(vNewValue) then
    					Set CacheData(0)=vNewValue
					else
						CacheData(0)=vNewValue
					end if
    				CacheData(1)=Now()
				end if
   				SetCache flag_ &"_"& ChildCacheName, CacheData
		end if
	End Sub


	Private Sub SetCache(SetName,NewValue)
		Application.Lock
		Application(SetName) = NewValue
		Application.unLock
	End Sub


	Private function GetCache(ByVal vNewName)
		Dim CacheData : CacheData=Application(flag_ &"_"& Lcase(ChildCacheName))
		If IsArray(CacheData) Then
			if IsObject(CacheData(0)) then
				Set GetCache=CacheData(0)
			else
				GetCache=CacheData(0)
			end if
		Else
			GetCache=""
		End If
	End function


	Private function getTimer()
		Dim strTime : strTime = Now()
		Dim intTimeZone : intTimeZone = 8
		 getTimer = DateAdd("h",-intTimeZone,strTime)
		 getTimer = DateDiff("s","1970-1-1 0:0:0", getTimer)
	End Function




	Rem 设置错误
	Private Sub InErr(ErrInfo)
		Err.Raise vbObjectError + 1, "JSSDK@surnfu 2015-4-30", ErrInfo
	End Sub

End Class

%>
