const express = require('express')
const app = express()
const cors = require('cors')
const PORT = 8081
const getProductsFromDB = require('./db').getProductsFromDB

let corsOptions = {
    origin: 'myloadbalancerinaws.com'
};

// app.set('view engine', 'ejs');
app.use(cors(corsOptions))
app.disable("x-powered-by");

app.get('/products', function(req, res) {
    const productsFromDB = getProductsFromDB()
    res.send({items: productsFromDB});
});

app.listen(PORT, () => {
    console.log("listening!!")
})