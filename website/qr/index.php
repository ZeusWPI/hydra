<?php
$userAgent = isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : '';
if(strpos($userAgent, 'iPhone') !== FALSE) {
    header("Location: itms-apps://itunes.apple.com/be/app/hydra/id602640924");
}
else if(strpos($userAgent, 'Android') !== FALSE) {
    header("Location: http://market.android.com/details?id=be.ugent.zeus.hydra");
}
else {
    header("Location: http://student.ugent.be/hydra/");
}
