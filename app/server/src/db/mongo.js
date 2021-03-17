const mongoose = require('mongoose');
const fs = require('fs');


// utilize event emitter to indicate connection retries in logs
// DOCS: https://mongoosejs.com/docs/connections.html#connection-events
const CONNECTION_EVENTS = [
    'connecting', 'connected', 'disconnecting', 'disconnected',
    'close', 'reconnectFailed', 'reconnected', 'error'
]

if( process.env.NODE_ENV === 'production' ){
    CONNECTION_EVENTS.forEach(( eventName )=>{
        return mongoose.connection.on( eventName, ()=>{
            console.log( `Connection state changed to: ${ eventName }` );
        });
    });
}

const dbUserPasswordRequired = process.env.DB_USERNAME && process.env.DB_PASSWORD;

const ca = fs.readFileSync(__dirname + '/rds-combined-ca-bundle.pem')

const mongodbURL = dbUserPasswordRequired ?
`${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@${process.env.DB_URL}` :
`${process.env.DB_URL}`

console.log('db_url:' + mongodbURL)
console.log('db_username:' + process.env.DB_USERNAME)

const mongooseInstance_ = mongoose.connect(
    `mongodb://${mongodbURL}`,
    {
        useNewUrlParser: true,
        useCreateIndex: true,
        useFindAndModify: false,
        ssl: dbUserPasswordRequired,
        sslValidate: true,
        sslCA: ca,
        useUnifiedTopology: true,
        heartbeatFrequencyMS: 1000 * 5,         // 1 sec * 5
        serverSelectionTimeoutMS: 1000 * 10     // 1 sec * 10
    }
);

mongooseInstance_
    .then(()=>{
        process.env.NODE_ENV !== 'test' && console.log( `Connect established to database: mongodb://${ mongodbURL }` );
    })
    .catch(( err )=>{
        console.error( `Cannot connect to database: mongodb://${ mongodbURL }` );
        console.log(err, 'Error')
    });


process.on( 'exit', async ()=>{
    const dbClient = await mongooseInstance_;
    dbClient.disconnect();
});


module.exports = mongooseInstance_;
