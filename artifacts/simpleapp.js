var http = require('http');
var os = require("os");
var datetime = new Date();
var MongoClient = require('mongodb').MongoClient;
var url = "mongodb://192.168.5.2:27017/test";

var server = http.createServer(function (request, response) {
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.write("Hello!\n");
  response.write("My hostname is " + os.hostname() + "\n");
  response.write("Date and Time: " + datetime + "\n");
  MongoClient.connect(url, function(err, db) {
	  if (err) throw err;
	  db.collection("myapp").findOne({}, function(err, result) {
		  if (err) throw err;
		  db.collection("myapp").updateMany({}, {$inc: {hit: 1} }, function(err, result) {
			  if (err) throw err;
			  db.collection("myapp").findOne({}, function(err, result) {
				if (err) throw err;
				response.end("This page was hit " + result.hit + " times");
			 	console.log("This page was hit " + result.hit + " times");  
				db.close();
			  });
		  });
	  });
  });
});
server.listen(8080);
console.log("Server running at http://127.0.0.1:8080/");