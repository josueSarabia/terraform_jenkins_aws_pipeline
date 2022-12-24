require('dotenv').config()
const express = require('express')
const client = require('prom-client')
const app = express()
const cors = require('cors')
const PORT = 8081
const getProductsFromDB = require('./db').getProductsFromDB


let register = new client.Registry()
let requestCount = new client.Counter({
    name: "request_count",
    help: "number of request to an endpoint"
})
register.registerMetric(requestCount)

register.setDefaultLabels({
    app: 'simple-web-api'
})

client.collectDefaultMetrics({ register })

let corsOptions = {
    origin: `${process.env.BASE_URL}`
};

// app.set('view engine', 'ejs');
app.use(cors(corsOptions))
app.disable("x-powered-by");

app.get('/products', function(req, res) {
    requestCount.inc(1)
    const productsFromDB = getProductsFromDB()
    res.send({items: productsFromDB});
});

app.get('/metrics', async function(req, res) {
    res.setHeader('Content-type', register.contentType)
    res.end(await register.metrics())
});

app.listen(PORT, () => {
    console.log("listening!!")
})