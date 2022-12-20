const express = require('express')
const app = express()
const cors = require('cors')
const PORT = 8081
const getProductsFromDB = require('./db').getProductsFromDB

// app.set('view engine', 'ejs');
app.use(cors())

app.get('/products', function(req, res) {
    const productsFromDB = getProductsFromDB()
    res.send({items: productsFromDB});
});

app.listen(PORT, () => {
    console.log("listening!!")
})