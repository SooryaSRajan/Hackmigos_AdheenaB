const Express = require("express");
const router = Express.Router();
const csv = require('csv-parser');
const fs = require('fs');
const socket = require('../modules/SocketIO');

function distance(lat1, lat2, lon1, lon2) {

    lon1 = lon1 * Math.PI / 180;
    lon2 = lon2 * Math.PI / 180;
    lat1 = lat1 * Math.PI / 180;
    lat2 = lat2 * Math.PI / 180;

    let dlon = lon2 - lon1;
    let dlat = lat2 - lat1;
    let a = Math.pow(Math.sin(dlat / 2), 2)
        + Math.cos(lat1) * Math.cos(lat2)
        * Math.pow(Math.sin(dlon / 2), 2);

    let c = 2 * Math.asin(Math.sqrt(a));
    let r = 6371;

    return (c * r);
}

const data = [];

router.post("/", (req, res) => {

    latitude = req.body.latitude;
    longitude = req.body.longitude;

    if(latitude == null || longitude == null) {
        res.status(400).send('Please attach coordinates')
        return;
    }
    
    data.splice(0, data.length);

    minimum_value = 999999
    let user_id = ''

    fs.createReadStream('data.csv')
        .pipe(csv())
        .on('data', (row) => {
            if (row.uid && row.uid != '')
                data.push(row)
        })
        .on('end', () => {
            console.log('CSV file successfully processed in receive coordinate route');
            data.forEach(function (value, index, array) {
                val = Math.min(distance(parseFloat(value.latitude), latitude, parseFloat(value.longitude), longitude), minimum_value)
                if(val != minimum_value){
                    minimum_value = val;
                    user_id = value.uid
                }
                console.log(value.latitude, latitude, value.longitude, longitude);
            });

            if (minimum_value != 999999) {
                console.log('Minimum value: ', minimum_value, user_id)
                socket.emitEmergency(latitude, longitude, user_id)
            }
        });


    res.send('Success')
});

module.exports = router;