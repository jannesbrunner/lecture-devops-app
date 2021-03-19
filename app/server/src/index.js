const path = require( 'path' );
const fs = require('fs');
const https = require('https')
const http = require('https')

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const dbClientInstance_ = require('./db/mongo.js');
const todoRoutes = require('./routes/todo');
const userRoutes = require('./routes/user');
const errorRoutes = require('./routes/error');
const envRoute = require('./routes/env.js');
let cookieParser = require('cookie-parser');

const app = express();
const httpPort = process.env.SERVER_HTTP_PORT || 80;
const httpsPort = process.env.SERVER_HTTPS_PORT || 443;


const corsOptions = {
    origin: `https://127.0.0.1:${ httpPort }`,
    credentials: true
};

const privateKey = fs.readFileSync(path.resolve(__dirname) + '/server.key').toString();
const certificate = fs.readFileSync(path.resolve(__dirname) + '/server.cert').toString();
const credentials = {key: privateKey, cert: certificate};

app.use(express.json());
app.use(cors(corsOptions));

app.use(cookieParser());

app.use(helmet());
app.use(helmet.contentSecurityPolicy({
    directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self' 'unsafe-inline'"],
        scriptSrc: ["'self' 'unsafe-inline' 'unsafe-eval'"]
    }
}));

app.use(function(req,resp,next){
    if (req.headers['x-forwarded-proto'] == 'http') {
        return resp.redirect(301, 'https://' + req.headers.host + '/');
    } else {
        return next();
    }
  });

app.use(todoRoutes);
app.use(userRoutes);
app.use('/', express.static(path.resolve(__dirname, `./public`)));
// IMPORTANT: Educational purpose only! Possibly exposes sensitive data.
app.use(envRoute);
// NOTE: must be last one, because is uses a wildcard (!) that behaves aa
// fallback and catches everything else
app.use(errorRoutes);

const httpServer = http.createServer(app);
const httpsServer = https.createServer(credentials, app);

(async function main(){
    try{

        await new Promise( (__ful, rej__ )=>{
            httpServer.listen(httpPort, function(){
                console.log( `ToDo server is up on port ${ httpPort } with http`);
                __ful();
            }).on( 'error', rej__);
        });

        await new Promise( (__ful, rej__ )=>{
            httpsServer.listen(httpsPort, function(){
                console.log( `ToDo server is up on port ${ httpsPort } with https`);
                __ful();
            }).on( 'error', rej__);
        });

        process.on( 'SIGINT', ()=>{
            process.exit( 2 );
        });
    }catch( err ){
        console.error( err );
        process.exit( 1 );
    }
})();
