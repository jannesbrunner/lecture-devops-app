const express = require('express');
const routes = express.Router();


routes.get('/env', (req, res) => {
    console.log(`Got query: ${req.query}`)
    res.send( process.env );
});


module.exports = routes;
