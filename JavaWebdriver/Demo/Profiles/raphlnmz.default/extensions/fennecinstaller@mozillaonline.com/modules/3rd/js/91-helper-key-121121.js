// 按钮下拉菜单
function zsAppShow(obj){
	obj.getElementsByTagName("div").item(0).style.display="block";
}
function zsAppHide(obj){
	obj.getElementsByTagName("div").item(0).style.display="none";
}

var Key = new function () {


    //获取url中的指定参数值1
    function getParameter(url, paramName) {
        var re = new RegExp("(^|\\?|&)" + paramName + "=([^&]*)(\s|&|$)", "i");
        if (re.test(url))
            return RegExp.$2;
        else
            return null;
    }

    String.prototype.containDBChar = function () { if (this.match(/[^\x00-\xff]/g) == null) return false; return this.match(/[^\x00-\xff]/g).length > 0; }

    function $id(id) {
        return document.getElementById(id);
    }

    var codeBase = "onekey",
		style = "",
		info = "",
		imgsUrl = "" //图片目录
    previewImgs = [
    "http://img1.91huo.cn/zs/images/api/v3/bg.jpg",
    "http://img1.91huo.cn/zs/images/v3/48.png",
    "http://img1.91huo.cn/zs/images/api/v3/spr.png",
    "http://img1.91huo.cn/zs/images/api/v3/line.jpg",
    "http://img1.91huo.cn/zs/2013/08/08/pop/spr.png",
    "http://img1.91huo.cn/zs/images/api/v3/soft.jpg",
    "http://img1.91huo.cn/zs/2013/08/08/pop/pic1.jpg",
    "http://img1.91huo.cn/zs/images/api/v3/icon.jpg",
    "http://img1.91huo.cn/zs/2013/08/08/pop/pic2.jpg"]; //图片名称 （预加载)


    style += "<style type=\"text\/css\">";
    style += "body, div, span, form, input, h1, h2, h3, h4, h6, p, a, em, img, b, dl, dt, dd, ul, li, label{ padding: 0; margin: 0;}";
    style += "input { vertical-align:middle;}";
    style += "input, select { font:12px Tahoma, Geneva, Arial, Helvetica, sans-serif;}";
    style += "img { border: 0; }";
    style += "em { font-style:normal; }";
    style += "ul { list-style: none; }";
    style += "h1, h2, h3, h4, h6 { font-size: 100%; }";
	style += '.clearfix:after{ content:""; height:0; visibility:hidden; display:block; clear:both;}';
	style += '.clearfix{ zoom:1;}';
	style += '.onekey_preview { position: absolute; width: 0px; height: 0px; overflow: hidden; left: 0; top: 0; }';
	style += '.onekey_bg { position: absolute; left: 0; top: 0; background-color: #000; opacity: 0.6; filter: alpha(opacity=60); width: 100%; height: 1px; display: none; z-index: 10000; }';
	style += '.onekey_con { display: none; width: 570px; height: 397px; overflow: hidden; zoom: 1; position: fixed; _position: absolute; top: 6%; left: 50%; margin-left: -285px; _top:expression(documentElement.scrollTop+0.76*documentElement.clientHeight-this.offsetHeight);z-index: 12000; }';
	style += '.yjf_box { width: 568px; height: 395px; background:#fff; overflow: hidden; zoom: 1; font-family: "Microsoft YaHei"; position: relative; border:1px #d1d1d1 solid; }';
	style += '.yjf_box_header { width:568px; height: 26px; overflow: hidden; background:#383d3f url(http://img1.91huo.cn/zs/2013/08/08/pop/headerBg.jpg) no-repeat right;}';
	style += '.yjf_box_title, .yjf_box_colse { background: url(http://img1.91huo.cn/zs/2013/08/08/pop/spr.png) no-repeat; display: block; width: 0; height: 0; overflow: hidden;}';
	style += '.yjf_box_title { padding-left: 63px; padding-top: 26px; background-position: 0 0; margin-left: 5px; float: left }';
	style += '.yjf_box_colse { padding-top: 26px; padding-left: 27px; background-position: 0 -26px; float: right; cursor: pointer }';
	style += '.yjf_box_con { padding: 15px 50px; overflow: hidden; zoom: 1 }';
	style += '.yjf_box_line { background: url(http://img1.91huo.cn/zs/images/api/v3/line.jpg) no-repeat center bottom; }';
	style += '.yjf_box_top img { display: block; float: left; width: 48px; height: 48px; margin-right: 15px; }';
	style += '.yjf_box_top p { height: 48px; line-height: 48px;  color: #2b2b2b; font-size: 22px; }';
	style += '.yjf_box_con2 { padding: 20px 50px; }';
	style += '.yjf_box_con2 img { display: block; float: right; }';
	style += '.yjf_box_con2_l { overflow: hidden; zoom: 1; width: 230px; float: left }';
	style += '.yjf_box_con2_l h3 { font-size: 22px; font-weight: normal; color: #404040; margin-bottom: 20px; padding-top: 15px; }';
	style += '.yjf_box_con2_l p { color: #2b2b2b; font-size: 14px; line-height: 24px; }';
	style += '.yjf_box_con3 { text-align: right; padding: 5px 50px; }';
	style += '.yjf_box_btn { background: url(http://img1.91huo.cn/zs/2013/08/08/pop/spr.png) no-repeat; display: inline-block; width: 0; height: 0; overflow: hidden;  padding-top: 37px; cursor:pointer;}';
	style += 'a.yjf_box_btn1 { padding-left: 155px; background-position:0 -52px; margin-right: 20px; }';
	style += 'a.yjf_box_btn1:hover { background-position: 0 -89px; }';
	style += 'a.yjf_box_btn2 { padding-left: 133px; background-position: 0 -126px; }';
	style += 'a.yjf_box_btn2:hover { background-position: 0 -163px; }';
	style += '.yjf_box_con4 { padding: 5px 50px; }';
	style += '.yjf_box_con4_txt1 { text-align:center; color: #2b2b2b; font-size: 16px; }';
	style += '.yjf_box_con4_img { text-align: center; padding: 10px 0 }';
	style += '.yjf_box_con4_txt2 { font-size: 12px; padding-bottom: 5px; color: #2b2b2b; text-align: center }';
	style += '.yjf_box_con4_txt2 a { color: #0098f5; text-decoration: none; padding: 0 5px; }';
	style += '.yjf_box_con4_txt2 a:hover { text-decoration: underline }';
	style += '.yjf_box_con5 { padding: 5px 50px; text-align: right; font-size: 12px; color: #2b2b2b }';
	style += '.yjf_box_con5 em { color: #f00; padding: 0 5px; }';
	style += '.zsDoubleApp{ position:relative; display:inline-block; z-index:9999;}';
	style += '.zsDoubleApp img{ position:relative; z-index:10;}';
	style += '.zsDoubleApp .list{ position:absolute;  padding:0 4px; display:none;}';
	style += '.zsDoubleApp .list a{ display:block; text-align:center; text-decoration:none;}';
	style += '.zsDoubleApp .list a:hover{ background:#000;}';
	style += '.zsDoubleApp_white_b .list a:hover,.zsDoubleApp_white_m .list a:hover,.zsDoubleApp_white_s .list a:hover{background:#bebebe;}';
	style += '.zsDoubleApp_black_b .list a,.zsDoubleApp_black_m .list a,.zsDoubleApp_black_s .list a{color:#fff; background:#292729;}';
	style += '.zsDoubleApp_white_b .list a,.zsDoubleApp_white_m .list a,.zsDoubleApp_white_s .list a{color:#565656; background:#fff; font-weight:bold;}';
	style += '.zsDoubleApp_black_b,.zsDoubleApp_white_b{ width:390px; height:140px; }';
	style += '.zsDoubleApp_black_b .list,.zsDoubleApp_white_b .list{width:375px; left:2px; top:130px;}';
	style += '.zsDoubleApp_black_b .list a,.zsDoubleApp_white_b .list a{ height:40px; line-height:40px;}';
	style += '.zsDoubleApp_black_m,.zsDoubleApp_white_m{ width:280px; height:100px;}';
	style += '.zsDoubleApp_black_m .list,.zsDoubleApp_white_m .list{width:265px;top:86px;left:0px;}';
	style += '.zsDoubleApp_black_m .list a,.zsDoubleApp_white_m .list a{ height:35px; line-height:35px;}';
	style += '.zsDoubleApp_black_s,.zsDoubleApp_white_s{ width:210px; height:77px;}';
	style += '.zsDoubleApp_black_s .list,.zsDoubleApp_white_s .list{width:197px; top:70px; left:0px;}';
	style += '.zsDoubleApp_black_s .list a,.zsDoubleApp_white_s .list a{ height:30px; line-height:30px;}';
    style += "<\/style>";










    //先加载背景图片，不显示
    for (var i = 0; i < previewImgs.length; i++) {
        info += "<div class=\"onekey_preview\"><img src=\"" + imgsUrl + previewImgs[i] + "\" alt=\"\" \/><\/div>";
    }
    info += "<div class=\"onekey_bg\" id=\"onekey_float_bg\"></div>";
    info += "<div class=\"onekey_con\" id=\"onekey_float_con\"></div>";


    document.write(style + info);
    var bg = document.getElementById("onekey_float_bg");
    var con = document.getElementById("onekey_float_con");
    //关闭窗口
    var globalTime = 15;
    var globalTimeId;

    function setCookie(sName, sValue, oExpires, sPaht, sDomain, bSecure) {
        var sCookie = sName + "=" + encodeURIComponent(sValue);
        if (oExpires) {
            sCookie += "; expires=" + oExpires.toGMTString();
        }
        if (sPaht) {
            sCookie += "; path=" + sPaht;
        }
        if (sDomain) {
            sCookie += "; domain=" + sDomain;
        }
        if (bSecure) {
            sCookie += "; secure";
        }
        document.cookie = sCookie;
    }

    function getCookie(sName) {
        var sRE = "(?:; )?" + sName + "=([^;]*);?";
        var oRE = new RegExp(sRE);
        if (oRE.test(document.cookie)) {
            return decodeURIComponent(RegExp["$1"]);
        } else {
            return null;
        }
    }


    function closeWindows() {
        $id("onekey_float_bg").style.display = "none";
        $id("onekey_float_con").style.display = "none";
        $id("onekey_float_con").innerHTML = "";
        globalTime = 15;
        clearInterval(globalTimeId);
    }

    function autoClose() {
        document.getElementById("times").innerHTML = globalTime--;
        if (globalTime == -1) {
            globalTime = 15;
            clearInterval(globalTimeId);
            closeWindows();
        }
    }

    function SetDisplay() {
        $id("onekey_float_con").style.display = "block";
        $id("onekey_float_bg").style.height = (document.documentElement.scrollHeight > document.documentElement.clientHeight) ? document.documentElement.scrollHeight + "px" : document.documentElement.clientHeight + "px";
        $id("onekey_float_bg").style.display = "block";
        var sCookie = getCookie("onekey");
        if (sCookie) {
            globalTimeId = setInterval(autoClose, 1000);
        }
    }
    function checkUrl(url) {
        try {
            setTimeout(function () { location = url; }, 100);
        } catch (err) { }
    }

    this.hidePopup = function () {
        $id("onekey_float_bg").style.display = "none";
        $id("onekey_float_con").style.display = "none";
        $id("onekey_float_con").innerHTML = "";
        globalTime = 15;
        clearInterval(globalTimeId);
    }
    function showPopup() {
        $id("onekey_float_bg").style.display = "block";
        $id("onekey_float_con").style.display = "block";
    }
    this._fnSetCookie = function () {
       var cdate = new Date();
		 cdate.setMinutes(cdate.getMinutes() + 1);
		 if(cdate.getMinutes()>59){
			 cdate.setMinutes(0);
			 cdate.setHours(cdate.getHours()+1)
		 }
        setCookie("onekey", "1", cdate);
        Key.Open(Key.objThis, Key.platformThis);
    };
    this.objThis = "";
    this.platformThis = "";
    this.downloadurlThis = "";
    this.actionTypeThis = "";

    this.urlThis = "";
    this.softIcon = "http://img1.91huo.cn/zs/images/api/v3/icon.jpg";
    this._fnReload = function () {
        checkUrl("mobile91://" + this.urlThis);
    };
    function GetWin(obj, platform, downloadurl, url) {
        var simg = obj.attributes["SoftIcon"];
        if (simg) {
            Key.softIcon = simg.value;
        }
        //        Key.objThis = obj;
        //        Key.platformThis = platform;
        Key.downloadurlThis = downloadurl;
        Key.urlThis = url;
        var win1 = "", win2 = "";
        win1 += "<div class=\"yjf_box\" id=\"onekey_win_null\">";
        win1 += "<div class=\"yjf_box_header\">";
        win1 += "<h1 class=\"yjf_box_title\">91\u52A9\u624B</h1>";
        win1 += "<a class=\"yjf_box_colse\" onclick=\"Key.hidePopup();\">\u5173\u95ED</a>";
        win1 += "</div>";
        win1 += "<div class=\"yjf_box_con yjf_box_line yjf_box_top\">";
        win1 += "<img src=\"" + Key.softIcon + "\" alt=\"\" width=\"48\" height=\"48\" />";
        win1 += "<p>\u6B63\u5728\u542F\u52A8\u4E00\u952E\u5B89\u88C5</p>";
        win1 += "</div>";
        win1 += "<div class=\"yjf_box_con yjf_box_con2\">";
        win1 += "<div class=\"yjf_box_con2_l\">";
        win1 += "<h3>\u60A8\u5B89\u88C591\u52A9\u624B\u4E86\u5417\uFF1F</h3>";
        win1 += "<p>\u4F7F\u7528\u4E00\u952E\u5B89\u88C5\u529F\u80FD\uFF0C\u9700\u5B89\u88C591\u52A9\u624B\u3002 91\u52A9\u624B\u542F\u52A8\u540E\u5C06\u81EA\u52A8\u5B89\u88C5\u5E94\u7528\u81F3\u60A8\u7684 \u8BBE\u5907\u4E0A\uFF0C\u4ECE\u6B64\u4E00\u952E\u5B89\u88C5\u8F6F\u4EF6\u3002</p>";
        win1 += "</div>";
        win1 += "<img src=\"http://img1.91huo.cn/zs/2013/08/08/pop/pic1.jpg\" alt=\"\" width=\"230\" height=\"170\" />";
        win1 += "</div>";
        win1 += "<div class=\"yjf_box_con3\">";
        win1 += "<a class=\"yjf_box_btn yjf_box_btn1\" href=\"" + downloadurl + "\">\u4E0B\u8F7D91\u52A9\u624B</a>";
        win1 += "<a class=\"yjf_box_btn yjf_box_btn2\" onclick=\"Key._fnSetCookie();\" >\u6211\u5DF2\u5B89\u88C5</a>";
        win1 += "</div>";
        win1 += "</div>";

        win2 += "<div class=\"yjf_box\" id=\"onekey_win\">";
        win2 += "<div class=\"yjf_box_header\">";
        win2 += "<h1 class=\"yjf_box_title\">91\u52A9\u624B</h1>";
        win2 += "<a class=\"yjf_box_colse\" onclick=\"Key.hidePopup();\">\u5173\u95ED</a>";
        win2 += "</div>";
        win2 += "<div class=\"yjf_box_con yjf_box_line yjf_box_top\">";
        win2 += "<img src=\"" + Key.softIcon + "\" alt=\"\" width=\"48\" height=\"48\" />";
        win2 += "<p>\u6B63\u5728\u6253\u5F0091\u52A9\u624B\u4E3A\u60A8\u5B89\u88C5\u5E94\u7528\uFF0C\u8BF7\u7A0D\u4FAF...</p>";
        win2 += "</div>";
        win2 += "<div class=\"yjf_box_line yjf_box_con4\">";
        win2 += "<p class=\"yjf_box_con4_txt1\">\u60A8\u53EF\u5728\u301091\u52A9\u624B\u3011\u4EFB\u52A1\u4E2D\u5FC3\u67E5\u770B\u5B89\u88C5\u8FDB\u5EA6</p>";
        win2 += "<p class=\"yjf_box_con4_img\"><img src=\"http://img1.91huo.cn/zs/2013/08/08/pop/pic2.jpg\" alt=\"\" width=\"431\" height=\"177\" /></p>";
        win2 += "<p class=\"yjf_box_con4_txt2\">\u5982\u679C91\u52A9\u624B\u6CA1\u6709\u6253\u5F00\uFF0C\u8BF7<a href=\"javascript:void(0);\" onclick=\"Key._fnReload();\">\u91CD\u8BD5</a> \u5982\u679C\u60A8\u672A\u5B89\u88C591\u52A9\u624B\uFF0C\u8BF7<a href=\"" + downloadurl + "\">\u4E0B\u8F7D\u5B89\u88C5</a></p>";
        win2 += "</div>";
        win2 += "<div class=\"yjf_box_con5\">\u672C\u7A97\u53E3\u5C06\u5728<em id=\"times\">15</em>\u79D2\u540E\u81EA\u52A8\u5173\u95ED</div>";
        win2 += "</div>";


        var sCookie = getCookie("onekey");
        if (sCookie) {
            return win2;
        }
        else {
            return win1;
        }
		return win1;
    }

    $id("onekey_float_bg").onclick = closeWindows;
    this.Open = function (obj, platform, actionType) {
        if (obj && obj.tagName && obj.tagName.toLowerCase() == "a") {
            if (!obj.href) { alert("您的应用下载地址没有填写，请在A标签的href中输入您的应用下载地址"); return false; }
            if (!obj.name) { alert("您的应用中文名称没有填写，请在A标签的name中输入您的应用中文名称"); return false; }
            Key.objThis = obj;
            Key.platformThis = platform;
            Key.actionTypeThis = actionType;
            this.getJson("scrAssistantLatest", "http://zs.91.com/script/api/1key.shtml");
            this.getJson("scrOneKey", "http://zy.91.com/Services/OneKeyInstall.aspx?downurl=" + encodeURIComponent(obj.href) + "&platform=" + platform);
            return false;
        }
    };

    this.checkUrl = function (url) {
        checkUrl(url);
    }

    this.getJson = function (sid, url) {
        var scriptTag = document.getElementById(sid);
        var oHead = document.getElementsByTagName('HEAD').item(0);
        var oScript = document.createElement("script");

        if (scriptTag) {
            oHead.removeChild(scriptTag);
        }
        oScript.id = sid;
        oScript.language = "javascript";
        oScript.type = "text/javascript";
        oScript.src = url;
        oHead.appendChild(oScript);
    }

    this.callBack = function (data) {
        var obj = Key.objThis;
        var platform = Key.platformThis;
        var downloadurl = Key.downloadurlThis;
        var actionType = Key.actionTypeThis;

        var url = obj.href.replace(/^\S*?:\/\//gi, "");
        var fname = getParameter(obj.href, "f_name");
        var aname = obj.name;
        if (obj.name != "" && aname.containDBChar()) {
            url = url.replace("f_name=" + fname, "f_name=" + escape(aname));
        }
        else {
            if (fname.containDBChar()) {
                url = url.replace("f_name=" + fname, "f_name=" + escape(fname));
            }
        }




        if (data) {
            url += "&did=" + data.resId + "&position=" + data.posId;
        }


        if (actionType && actionType == 1) { //客户端已装91助手
            checkUrl("mobile91://" + url);
            return false;
        }

        showPopup();
        SetDisplay();

		var downUrl = "http://dl.sj.91.com/business/assistant/91assistant_5.0695.sfx.exe";
        //try {
//            if (assistantLatestUrl) {
//                downUrl = assistantLatestUrl;
//            }
//        } catch (e) {
//
//        }

        if (obj.attributes["downloadurl"]) {

            downUrl = obj.attributes["downloadurl"].value;
        }
        var sWin = GetWin(obj, platform, downUrl, url);
        $id("onekey_float_con").innerHTML = sWin;

        var sCookie = getCookie("onekey");
        if (sCookie) {
            checkUrl("mobile91://" + url);
        }
    }
};