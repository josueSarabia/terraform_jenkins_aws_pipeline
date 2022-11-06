const express = require('express')
const app = express()
const PORT = 8080

app.set('view engine', 'ejs');

// index page
app.get('/', function(req, res) {
    res.render('index');
});

app.listen(PORT, () => {
    console.log("listening!!")
})