<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="sha1.asp"-->
<!--#include file="Cls_jssdk.asp"-->
<%
	session.codepage=65001
	response.charset="utf-8"
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="format-detection" content="telephone=no">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;" name="viewport">
<title>微信分享测试</title>
</head>
<body>
<%
Dim wxsdk
set wxsdk = new JSSDK
	wxsdk.APPID="xxxxxxx"
	wxsdk.SECRET="xxxxxxxxxxxxxxxxxxx"
Dim signPackage : set signPackage = wxsdk.GetSignPackage()
%>
<script src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
<script>
  /*
   * 注意：
   * 1. 所有的JS接口只能在公众号绑定的域名下调用，公众号开发者需要先登录微信公众平台进入“公众号设置”的“功能设置”里填写“JS接口安全域名”。
   * 2. 如果发现在 Android 不能分享自定义内容，请到官网下载最新的包覆盖安装，Android 自定义分享接口需升级至 6.0.2.58 版本及以上。
   * 3. 常见问题及完整 JS-SDK 文档地址：http://mp.weixin.qq.com/wiki/7/aaa137b55fb2e0456bf8dd9148dd613f.html
   *
   * 开发中遇到问题详见文档“附录5-常见错误及解决办法”解决，如仍未能解决可通过以下渠道反馈：
   * 邮箱地址：weixin-open@qq.com
   * 邮件主题：【微信JS-SDK反馈】具体问题
   * 邮件内容说明：用简明的语言描述问题所在，并交代清楚遇到该问题的场景，可附上截屏图片，微信团队会尽快处理你的反馈。
   */
  wx.config({
    debug: false,
    appId: '<%=signPackage("appId")%>',
    timestamp: <%=signPackage("timestamp")%>,
    nonceStr: '<%=signPackage("nonceStr")%>',
    signature: '<%=signPackage("signature")%>',
    jsApiList: ['onMenuShareTimeline', 'onMenuShareAppMessage']
  });


</script>
<script type="text/javascript">
        //完成wx.config，执行这里
         wx.ready(function () {
             //分享到朋友圈
             wx.onMenuShareTimeline({
                 title: '1111111', // 分享标题
                 link:window.location.href,
                 imgUrl: "http://www.decenthomes.cn/img/imgdemo/180x180.gif", // 分享图标
                 success: function () {
            // 分享成功执行此回调函数
                    alert('success');
                 },
                 cancel: function () {
                    alert('cancel');
                 }
             });

             //分享给朋友
             wx.onMenuShareAppMessage({
                 title: '22222', // 分享标题
                 desc: '22222',
                 link:window.location.href,
                 imgUrl: "http://www.decenthomes.cn/img/imgdemo/180x180.gif", // 分享图标
                 trigger: function (res) {
                     // 不要尝试在trigger中使用ajax异步请求修改本次分享的内容，因为客户端分享操作是一个同步操作，这时候使用ajax的回包会还没有返回
                 },
                 success: function (res) {
             // 分享成功执行此回调函数
                     alert('已分享');
                 },
                 cancel: function (res) {
                     alert('已取消');
                 },
                 fail: function (res) {
                     alert(JSON.stringify(res));
                 }
             });
         });

</script>

</body>
</html>
