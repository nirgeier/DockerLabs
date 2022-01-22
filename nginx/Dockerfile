//
// Filename: server.js
//
// Simple NodeJs Server
// The server is listening by default to port 8888
//

// import the HTTP module
var http = require('http');

// Define a port we want to listen to
// Later on we will pass the port as env parameter
// Default port is set to 8888
const PORT= process.env.PORT || 8888; 

// Create the server and listen for requests
// Create the server and listen for requests
http.createServer((request, response)=>{
response.end('Server is running.!! You asked for: ' + request.url);
}).listen(PORT, ()=>{
// Callback is triggered when server is getting a request
console.log("Server listening on: http://localhost:%s", PORT);
});