const path = require( 'path' );

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const dbClientInstance_ = require('./db/mongo.js');
const todoRoutes = require('./routes/todo');
const userRoutes = require('./routes/user');
const errorRoutes = require('./routes/error');
const envRoute = require('./routes/env.js');
let cookieParser = require('cookie-parser');
const auth = require('http-auth');

const app = express();
const port = process.env.PORT || 5000;



const corsOptions = {
    origin: `http://127.0.0.1:${ port }`,
    credentials: true
};

const basic = auth.basic({realm: 'Monitor Area'}, function(user, pass, callback) {
    callback(user === 'admin' && pass === process.env.ADMIN_PW);
  });

  // Set '' to config path to avoid middleware serving the html page (path must be a string not equal to the wanted route)
  const statusMonitor = require('express-status-monitor')({ path: '' });
  app.use(statusMonitor.middleware); // use the "middleware only" property to manage websockets
  app.get('/status', basic.check(statusMonitor.pageRoute)); // use the pageRoute property to serve the dashboard html page

app.use(express.json());
// app.use(cors(corsOptions));

app.use(cookieParser());

app.use(helmet());
app.use(helmet.contentSecurityPolicy({
    directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self' 'unsafe-inline'"],
        scriptSrc: ["'self' 'unsafe-inline' 'unsafe-eval'"]
    }
}));

app.use(todoRoutes);
app.use(userRoutes);
app.use('/', express.static(path.resolve(__dirname, `./public`)));
// IMPORTANT: Educational purpose only! Possibly exposes sensitive data.
app.use(envRoute);
// NOTE: must be last one, because is uses a wildcard (!) that behaves aa
// fallback and catches everything else
app.use(errorRoutes);

(async function main(){
    try{
        await new Promise( (__ful, rej__ )=>{
            app.listen(port, function(){
                console.log( `ToDo server is up on port ${ port }`);
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
