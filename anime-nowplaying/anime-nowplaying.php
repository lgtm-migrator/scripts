<html>
<head>
<title>
MyAnimeList PHP Updater v1.3 - Generic Updater Script by Injabie3
</title>
</head>
<body>
<b>MyAnimeList PHP Updater v1.3 - Generic Updater Script by Injabie3</b>
<br />
<br />
Usage: Use MalUpdater or Plex to send updates to this page.<br />
<br />
<br />
<b>Status (Main):</b>
<?php

include_once( "anime-nowplaying-config.php" );

// Connect to server and select database.
$con = new mysqli("$HOST", "$USERNAME", "$PASSWORD") or die("Cannot connect (Main)");
$con->select_db("$DB_NAME") or die(mysqli_error());
$con->query("SET NAMES 'utf8'");

// Get data passed to the script
$updateMode = $_GET["updateMode"];
$code = $_GET['code'];

// Declare variables outside.
$animeID = "";
$ep = 0;
$eptotal = 0;
$name = "";
$picurl = "";
$user = "";

$isPlex = $updateMode == "plex";
$isMAL = $updateMode == "malupdater";
if ($isPlex) {
    echo "(Plex updater) ";
    // Get the POST payload.
    $data = json_decode(implode('', $_POST));

    $animeID = 0;
    $ep = $data->Metadata->index;
    $eptotal = 0;
    $isVideo = in_array($data->Metadata->type, [ "movie", "episode" ]);
    $name = $data->Metadata->grandparentTitle;
    $picurl = "N/A";
    $user = $data->Account->title;
} elseif ($isMAL) {
    echo "(MAL updater) ";
    $animeID = $_POST['animeID'];
    $ep = $_POST['ep'];
    $eptotal = $_POST['eptotal'];
    $name = $_POST['name'];
    $picurl = $_POST['picurl'];
    $user = $_POST['user'];
} else {
    // We shouldn't be here. Take care of this later.
    echo "Unknown updater!";
    $con->close();
    exit();
}


$sqlTest  = <<<SQL
INSERT INTO $TABLE_NAME
(`ID`, `timestamp`, `user`, `animeID`, `name` ,`ep` ,`eptotal`,`picurl`)
VALUES
(NULL, CURRENT_TIMESTAMP, 'Test', '0', 'Database Test', '0', '0', '');
SQL;

$sqlInsert = <<<SQL
INSERT INTO $TABLE_NAME
(`ID`, `timestamp`, `user`, `animeID`, `name` ,`ep` ,`eptotal`,`picurl`)
VALUES
(NULL, CURRENT_TIMESTAMP, '$user', '$animeID', '$name', '$ep', '$eptotal', '$picurl');
SQL;

$sqlGetData = <<<SQL
SELECT * FROM `$TABLE_NAME`
ORDER BY `timestamp`
DESC LIMIT 0, 1;
SQL;

// Get one result back: used to not post duplicate entries.
$dataMAL=$con->query($sqlGetData) or die(mysqli_error());

while ($infoMAL = $dataMAL->fetch_array()) {
    if (isset($_GET['mal']) && $_GET['mal'] == "test") {
        $result = $con->query($sqlTest);
        if ($result) {
            echo "OK: Test update successful!";
        } else {
            echo mysqli_error();
        }
    } elseif ($code != $USERCODE ) {
        echo "Error: Incorrect code. Please try again.";
    } elseif ($isPlex && (!($data->event == "media.play" || $data->event == "media.resume")
                          || !$isVideo)) {
        echo "Not a media.play event, skipping.";
    } elseif ($isPlex && ($data->user != True || $data->owner != True)) {
        echo "Error: You are not the owner!";
    } elseif ($user == "") {
        echo "Error: Please send data using MalUpdater!";
    } elseif ($name == "") {
        echo "OK: Not playing anything, so no new information.Not updating database.";
    } elseif ($name == $infoMAL['name'] & $ep == $infoMAL['ep']) {
        echo "OK: Same information as last update. Not updating database.";
    } else {
        $result = $con->query($sqlInsert);
        if ($result) {
            echo "OK: Update posted successfully";
        } else {
            echo mysqli_error();
        }
    }
}
 
// close connection 
$con->close();
?>
</body>
</html>
