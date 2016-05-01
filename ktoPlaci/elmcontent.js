var elmcontent = document.querySelector('div');
var body = document.querySelector('body');
console.log(body);
body.removeChild(elmcontent);
var toinject = document.getElementById("elmcontent");
toinject.appendChild(elmcontent);