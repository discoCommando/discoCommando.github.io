<?php 
echo "<!DOCTYPE html>
<html>
<head>
	<title>Page</title>
</head>
<body>
	<h1>
		Login
	</h1>
	<form method='POST' action='/index.php'>
		<input type='text' name='username'>	
		<input type='password' name='password'>
		<input type='submit' name=''>
	</form>

</body>
</html>";

if (isset($_POST["username"])) {
	echo "POSTED";
}
 ?>
}
