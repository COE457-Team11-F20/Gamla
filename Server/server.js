var express = require("express");
var app = express();
var mqtt = require('mqtt')
var client = mqtt.connect('mqtt://test.mosquitto.org');


app.use (express.static ( __dirname + '/views' ));
app.use(express.json());
app.use(express.urlencoded({
    extended:false
}));

const port = 3000;

var connect_flat = false;


client.on('connect', function(){
    console.log("Connected to MQTT Broker");
    connect_flat=true;
})

const mongoose = require('mongoose');
const { json } = require("body-parser");
mongoose.connect('mongodb://localhost:27017/gamla', {useNewUrlParser: true, useUnifiedTopology: true});
console.log("Connected to MongoDB");

const planstschema = new mongoose.Schema({
    time: Date,
    temp: Number,
    light: Number,
    moisture: Number,
})

const plantQuality = mongoose.model("PlantQ", planstschema);

app.post("/", function(req,res){
    var body_obj = JSON.parse(JSON.stringify(req.body));
    var body_key = Object.keys(body_obj);
    body_key = JSON.parse(body_key);
    console.log("Temperature: " + body_key.temprature);
    console.log("Moisture: " + body_key.moisture);
    console.log("Light: " + body_key.light +"\n\n");

    const plant = new plantQuality({
        time: new Date(),
        temp: body_key.temprature,
        light: body_key.light,
        moisture: body_key.moisture
    })

    var mqttMessage = {
        time: new Date(),
        temp: body_key.temprature,
        light: body_key.light,
        moisture: body_key.moisture
    }

    plant.save();
    console.log("Saved Plant Data to MongoDB");

    var mqttMessageString = JSON.stringify(mqttMessage);

   if(connect_flat){
       client.publish('plant', mqttMessageString);
       console.log("Published Plant Data to MQTT Broker - Topic: plant");
   }

})

app.get("/getdata", async(req,res) => {
    const plantCount  = await plantQuality.count();
    const plantData = await plantQuality.find().skip(plantCount-1);
    res.send(plantData);
});

app.get("/test", async(req, res) => {
    console.log("Node-Red made a Request for Chart Data");

    const plantCount  = await plantQuality.countDocuments();
    var plantData = await plantQuality.find().skip(plantCount-100);

    var plantTemps = [], plantLightOn=0, plantLightOff=0, plantMoistures=[];
    plantData.forEach(function(data)
    {
        plantTemps.push(data.temp);
        plantMoistures.push(data.moisture);
        if(data.light == 1){
            plantLightOff++;
        }
        else if(data.light ==0)
        {
            plantLightOn++;
        }
    });

    var chartData = {
        "plantTemps" : plantTemps,
        "plantMoistures" : plantMoistures,
        "plantLightOn" : plantLightOn,
        "plantLightOff": plantLightOff
    }

    var mqttMessageString = JSON.stringify(chartData);

    if(connect_flat){
        client.publish('plantHistoricalData', mqttMessageString);
        console.log("Published Historical Plant Data to MQTT Broker - Topic: plantHistoricalData");
    }

    res.sendStatus(200);
});


app.listen(port, () => {
    console.log(`Gamla Server listening at http://localhost:${port}`)
})