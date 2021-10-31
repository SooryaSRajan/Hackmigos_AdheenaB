const GenerateBcrypt = require("./routes/GenerateBcrypt");
const GenerateJWT = require("./routes/GenerateJWT");
const receiveCoordinatesRoute = require("./routes/ReceiveCoordinatesRoute");
const middlewareToken = require("./middleware/ValidateToken");
const socket = require('./modules/SocketIO');
const express = require('express');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

const app = express();
const http = require('http');
const server = http.createServer(app);

require('dotenv').config();

const PORT = process.env.PORT || 8080

app.use(express.json());
app.use(express.urlencoded({
  extended: true
}));

app.get("/", (req, res) => {
    res.send("Server root node");
});

//TODO: Remove in deployment stage 
app.get("/test", (req, res) => {
  res.sendFile(__dirname  + '/index.html');
});

app.use("/bcrypt", GenerateBcrypt); //TODO: Remove in deployment stage 
app.use("/get_jwt", GenerateJWT)
app.use("/coordinates", middlewareToken, receiveCoordinatesRoute)

const csvWriter = createCsvWriter({
  path: 'data.csv',
  header: [
      { id: 'uid', title: 'uid' },
      { id: 'latitude', title: 'latitude' },
      { id: 'longitude', title: 'longitude' },
  ]
});

csvWriter
.writeRecords('')
.then(() => console.log('CSV has been erased successfully'));

socket.socketConnection(server)
server.listen(PORT, () => {
    console.log('Server on port: ' + PORT)
})