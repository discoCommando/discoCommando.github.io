<?php
header('Content-type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT, GET, POST");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");

$nazwaPliku = './dane.txt';


if (strcmp($_GET['mode'], "GET") == 0) 
	send();
else if (strcmp($_GET['mode'], "SET") == 0)
	save($_GET['content']);

function send() {
	$file = file_get_contents("./dane.txt");
	echo $file;
}

function checkContent($string) {
	return true;
}

function save($string) {
	if (checkContent($string))
		file_put_contents("./dane.txt", $string);
}

?>
