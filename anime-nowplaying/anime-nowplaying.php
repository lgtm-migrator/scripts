<html>
<head>
<title>
MyAnimeList PHP Updater v1.2 - Generic Updater Script by Injabie3
</title>
</head>
<body>
<b>MyAnimeList PHP Updater v1.2 - Generic Updater Script by Injabie3</b>
<br />
<br />
Usage: Use MalUpdater to send updates to this page.<br />
Last Modified: 2016-12-27 - Migrated from mysql to mysqli.
Last Modified: 2017-02-05 - Fixed "" around mal index.
<br />
<br />
<b>Status (Main):</b>
<?php

include_once( "anime-nowplaying-config.php" );

// Connect to server and select database.
$con = new mysqli("$host", "$username", "$password") or die("Cannot connect (Main)");
$con->select_db("$dbName") or die(mysqli_error());
$con->query("SET NAMES 'utf8'");

// Get data from MAL Updater 
$user = $_POST['user'];
$animeID = $_POST['animeID'];
$name = $_POST['name'];
$ep = $_POST['ep'];
$eptotal = $_POST['eptotal'];
$picurl = $_POST['picurl'];
$code = $_GET['code'];


$sqlTest  = <<<SQL
INSERT INTO $tableName
(`ID`, `timestamp`, `user`, `animeID`, `name` ,`ep` ,`eptotal`,`picurl`)
VALUES
(NULL, CURRENT_TIMESTAMP, 'Test', '0', 'Database Test', '0', '0', '');
SQL;

$sqlInsert = <<<SQL
INSERT INTO $tableName
(`ID`, `timestamp`, `user`, `animeID`, `name` ,`ep` ,`eptotal`,`picurl`)
VALUES
(NULL, CURRENT_TIMESTAMP, '$user', '$animeID', '$name', '$ep', '$eptotal', '$picurl');
SQL;

$sqlGetData = <<<SQL
SELECT * FROM `$tableName`
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
    } elseif ($code != $usercode ) {
        echo "Error: Incorrect code. Please try again.";
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
