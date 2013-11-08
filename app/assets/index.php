<!doctype html>
<html xmlns:fb="http://www.facebook.com/2008/fbml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
    <meta property="fb:app_id"      content="<?= $facebook_config['appId'] ?>" /> 

    <meta property="og:type"        content="<? echo $ogtype; ?>" /> 
    <meta property="og:url"         content="<? echo $ogurl; ?>" /> 
    <meta property="og:title"       content="<? echo $ogtitle; ?>" /> 
    <meta property="og:image"       content="<? echo $ogimage; ?>" /> 
    <meta property="og:description" content="<? echo $ogdesc; ?>" /> 
    <link rel="stylesheet" type="text/css" href="css/style15.css"/>
    <link rel="stylesheet" type="text/css" href="css/getpro2.css"/>
    <link rel="stylesheet" type="text/css" href="css/toolbar.css"/>
    <link rel="stylesheet" type="text/css" href="css/fileview7.css"/>
    <link href="css/smoothness/jquery-ui.css" rel="stylesheet" type="text/css" media="screen"/>
    <link rel="stylesheet" href="stylesheets/app.css">

    <script src="https://connect.facebook.net/en_US/all.js"></script>

    <script src="javascripts/vendor.js"></script>
    <script src="javascripts/app.js"></script>
    <script>
        var CUST_SERVER = "<?= get_cust($server); ?>";        
        var UID = "<?= $user_id ?>";
        var SESSION = "<?=session_id()?>";
        var SERVER = "<?= $server ?>";
        var DOMAIN = "<?= $domain ?>";
        var SUBFOLDER = "<?= substr($user_id, -3); ?>";
        var CUST_HTTP = "<?= $cust_http_https ?>";
        var SKIP_CUST = <?= $skip_cust_server_number ? "true" : "false" ?>;
        var CUST_PREFIX = "<?= $cust_prefix ?>";
        var CSPACE = "<?= $cspace ?>";
        FB.init({appId: "<?= $facebook_config['appId'] ?>", status: true, cookie: true});

        <?php if($custom_page) { ?>
            var CUSTOM_PAGE = "<?= $custom_page; ?>";
        <?php } ?>
    </script>
    <script>require('application');</script> 
</head>
<body>
<div id="udialog" title="Add File" style="display:none;">
    <div style="text-align:left;">
        <table border=0 style="margin-top:0px;border-collapse:separate; border-spacing: 2px;">
            <tr><td colspan=2>
                <div id="upfn" style="width:325px;height:16px;overflow:hidden;margin-bottom:0px;"></div>
            </td></tr>
            <tr><td colspan=2>
                <input name="ufcomment" id="ufcomment" type="hidden" value="">
            </td></tr>
            <tr><td colspan=2>
                <b>Folder:</b>
                <select name="ufol" id="ufol" style="width:284px;border: 1px solid #AAA; height:20px;">
                    <option value=""></option>
                </select>
            </td></tr>
            <tr><td colspan=2>
                <div id="isharediv">
                    <input type="checkbox" checked id="ishare" name="ishare" value="yes">
                    <font color=grey><b>Share with all my friends. Post on my Timeline.</b></font>
                </div>
            </td></tr>
            <tr height=5><td colspan=2></td></tr>
            <tr>
            <td align=center><a class="btnPrime" id="udialog_ok"><b style="color: white;">Upload</b></a></td>
            <td align=center><a class="btn2" id="udialog_cancel"><b>Cancel</b></a></td>
            </tr>
        </table>
    </div>
</div>

<div class="container" id="container">

</div>

<div id="jquery_jplayer_1" class="jp-jplayer" style="width:0px;height:0px;" />
</body>
</html>
