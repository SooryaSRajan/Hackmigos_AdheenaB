var socket = require('socket.io');
const fs = require('fs');
const csv = require('csv-parser');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;


let io;

exports.socketConnection = (server) => {
    io = socket(server);
    io.on('connection', (socket) => {
        console.info(`Client connected [id=${socket.id}]`);

        socket.on('disconnect', () => {
            console.info(`Client disconnected [id=${socket.id}]`);
            manageRecords(0, 0, socket.id, 1)
        });

        socket.on('coordinates', (lat, long) => {
            manageRecords(lat, long, socket.id, 0)
        });
    });
};

exports.emitEmergency = (lat, long, id) =>{
    if(io){
        io.sockets.to(id).emit('emergency', lat, long)
    }
}

function manageRecords(lat, long, id, state) {
    var data = [];
    fs.createReadStream('data.csv')
        .pipe(csv())
        .on('data', (row) => {
            if (row.uid && row.uid != '')
                data.push(row)
        })
        .on('end', () => {
            const csvWriter = createCsvWriter({
                path: 'data.csv',
                header: [
                    { id: 'uid', title: 'uid' },
                    { id: 'latitude', title: 'latitude' },
                    { id: 'longitude', title: 'longitude' },
                ]
            });
            
            data = data.filter(function (value, index, arr) {
                return value.uid != id;
            });

            if (state == 0) {
                data.push({
                    uid: id,
                    latitude: lat.toString(),
                    longitude: long.toString()
                })
            }

            csvWriter
                .writeRecords(data)
                .then(() => console.log('The CSV file was written successfully'));
        });
}


