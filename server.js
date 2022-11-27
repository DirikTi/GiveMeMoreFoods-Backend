import express, { response } from "express";
import { createServer } from 'http';
import cors from 'cors';
import bodyParser from 'body-parser';
//Routers
import AccountRoute from './routes/AccountRoute.js';
import FoodRoute from './routes/FoodRoute.js';

//Service
import { SocketInit } from "./service/SocketService.js";
import { LOG_OPTIONS } from "./src/Config.js";

// Middlewares
import LogsMiddleware from "./src/middleware/LogsMiddleware.js";


const app = express();
app.use(express.json());
app.use(cors());
app.use(express.static("public"));
app.use(bodyParser.urlencoded({extended: false}));


if (LOG_OPTIONS.REQUEST_LOG == true) {
    app.use(LogsMiddleware());
}

app.use("/api/v1/account/", AccountRoute);
app.use("/api/v1/foods/", FoodRoute)

/*
 * ERROR'S
*/

const server = createServer(app);


//SocketInit(server);

server.listen(process.env.PORT || '3000', () => {
    console.log('Server is runnig on port 3000');
});



// Start Up functions

function changeConsoleLOG() {
    // Change Log
    const { log } = console;

    function proxiedLog(...args) {
        const line = (((new Error('log'))
            .stack.split('\n')[2] || '…')
            .match(/\(([^)]+)\)/) || [, 'not found'])[1];
        log.call(console, `${line}\n`, ...args);
    }

    console.info = proxiedLog;
    console.log = proxiedLog;
}