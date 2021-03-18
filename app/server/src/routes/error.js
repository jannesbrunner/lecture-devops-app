const express = require('express');
const routes = express.Router();


routes.get('*', async (req, res) => {
    try {
        res.status(404).send({
            error: 'Not Found'
        });
        console.log(`404 caused by ${req.query}`)
    }
    catch (e) {
        res.status(500).send;
    }
});


module.exports = routes;
