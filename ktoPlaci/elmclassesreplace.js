var changeMap = [
	["zaplacil-table", "table"],
	["zaplacil-button", "button btn-default btn-s"]
]


changeMap.forEach(function(node) {
	var queries = document.getElementsByClassName(node[0])
	console.log(queries);
	for (i = 0; i < queries.length; i++) {
		var temp = queries.item(i);
		temp.setAttribute("class", node[1]);
		console.log(temp);
	}
});