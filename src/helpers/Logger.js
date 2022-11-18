'use strict'
import fs from 'fs';
import { PATH } from '../Config.js';

const PATH_LOG = PATH + "/logs/log_info.log";
const PATH_LOG_ERROR = PATH + "/logs/log_error.log";
const PATH_LOG_SYSTEM = PATH + "/logs/log_system.log";

/**
 * @description ENUM LOG_TYPES 
 * 
 * F-U-C-KKKKKKKKKKKKKKKKK JS
 * 
 */
export const LOG_TYPES = Object.freeze({
    INFO: "INFO",
    WARNING: "WARNING",
    ERROR: "ERROR"
})

/**
 * @desc    Log errors failure requests
 *   
 * @param   {string} message message=Success SERVICE
 * @param   {LOG_TYPES} type 
 */
export function log_info(message, type = "INFO") {
    if(message == "")
        return null;
    
    
    let logText =  getTime() + " " + type + " '" + message + ".'\n";

    fs.appendFileSync(PATH_LOG, logText, getError);

}



/**
 * @desc    Log errors failure requests
 *   
 * @param   {string} message message= SYSTEM LOGGER
 * @param   {boolean}  error
 */
export function log_system(message, error = "") {
    if(message == "")
        return null;

    let logText = getTime() + " " + LOG_TYPES.ERROR + " MESSAGE:'" + message + ".'\n" + error + "\n\n";
    
    fs.appendFile(PATH_LOG_SYSTEM, logText, getError);
}

/**
 * @desc    Log errors failure requests
 *   
 * @param   {string} type message=DATABASE, FILE, ERRORS
 * @param   {string} message message=Description error message
 * @param   {string}  error
 */
export function log_error(type ,message, error = null) {
    if(message == "")
        return null;
    
    let logText = getTime() + " " + LOG_TYPES.ERROR + " '" + type + "' MESSAGE: '" + message + "'\n" + error + "\n\n";

    fs.appendFile(PATH_LOG_ERROR, logText, getError);
}
/**
 * @private 
 */
function getError(err) {
    console.log(err);
    if(err) {
        console.log("ERROR Not found File Logger.js\n" + err);
    }
}

/**
 * @private
 */
const getTime = () => {
    let date_ob = new Date();
    
    let date = ("0" + date_ob.getDate()).slice(-2);
    let month = ("0" + (date_ob.getMonth() + 1)).slice(-2);
    let year = date_ob.getFullYear();
    let hours = date_ob.getHours();
    let minutes = date_ob.getMinutes();
    let seconds = date_ob.getSeconds();
    
    return year +  "-" + month + "-" + date + " " + hours + ":" + minutes + ":" + seconds;
}