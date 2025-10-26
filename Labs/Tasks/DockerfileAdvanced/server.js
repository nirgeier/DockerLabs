/**
 * @fileoverview Simple HTTP server that responds with the current timestamp
 * @author Nir Geier
 */

const http = require("http");

/**
 * The port number requested from environment variable or default to 8080
 * @type {number}
 */
const requestedPort = parseInt(process.env.LISTEN_PORT || "8080", 10);

/**
 * The actual port to use, fallback to 8080 if requestedPort is invalid
 * @type {number}
 */
const port = Number.isNaN(requestedPort) ? 8080 : requestedPort;

/**
 * HTTP server instance that responds with current timestamp
 * @type {http.Server}
 */
const server = http.createServer((req, res) => {
  /**
   * Response message containing current ISO timestamp
   * @type {string}
   */
  const message = `Current time: ${new Date().toISOString()}\n`;
  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end(message);
});

/**
 * Start the server and listen on the specified port and all network interfaces
 * @listens {number} port - The port number to listen on
 * @listens {string} "0.0.0.0" - Listen on all available network interfaces
 */
server.listen(port, "0.0.0.0", () => {
  console.log(`Listening on port ${port}`);
});