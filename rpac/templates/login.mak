<%!
    from tg.flash import get_flash,get_status
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta content="text/html; charset=utf-8" http-equiv="content-type">
    <title>r-pac - Login</title>
    <link href="/images/favicon.ico" type="images/x-icon" rel="shortcut icon">
    <link media="screen" href="/css/screen.css" type="text/css" rel="stylesheet">
    <script src="/js/jquery-1.11.0.min.js" type="text/javascript"></script>
    
    <script type="text/javascript" language="JavaScript">
    //<![CDATA[
        $(document).ready(function(){
            if ($.browser.msie && $.browser.version <'7.0' ) {
               $("#contenulogin").append("<div style='margin-top:30px;'>*You are using IE 6,it's recommended to upgrade your browser to IE 7 or higher to get the better view.</div>");
            }
        });
    //]]>
    </script>

</head>
<body onload="document.getElementById('login_name').focus()">
    <div id="contenulogin">
        <div id="logo-login"></div>
        <div id="boxlogin">
            <form action="${tg.url('/login_handler', came_from = came_from.encode('utf-8'), __logins = login_counter.encode('utf-8'))}" method="POST">
                <fieldset>
                    <!-- <legend>r-pac authentication</legend> -->
                    <legend style="width: 140px">&nbsp;</legend>
                        <p><label for="login_name" style="color:white">Login :  </label><input style="width:150px" type="text" name="login" id="login_name"></p>
                        <p><label for="login_password" style="color:white">Password : </label><input style="width:150px" type="password" name="password" id="login_password"></p>
                        <p style="text-align:center"><input type="submit" value="Login" class="submit"></p>
                        <p>You must provide your credentials before accessing this resource.</p>
                </fieldset>
            </form>
        </div>        
    </div>
</body>
</html>