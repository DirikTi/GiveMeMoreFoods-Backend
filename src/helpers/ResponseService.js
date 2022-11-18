'use strict'
import { LOG_OPTIONS } from "../Config.js";
import { log_error, log_info, LOG_TYPES } from "./Logger.js"

/* Asikus Response Service */


/**
 * @desc    Send Success Response JSON
 *
 * @param   {any}  data Response Data default data=null
 * @param   {string} message message=Success SERVICE
 */
export function successResponse(data = null, message = "Success SERVICE") {

}

LOG_OPTIONS.INFO ? successResponse = function(data = null, message = "Success SERVICE") {

    LOG_OPTIONS.INFO ? log_info(message, LOG_TYPES.INFO) : null;

    return {
        data,
        status: 200,
        message,
        success: true,
        error: false,
    }
} : successResponse = function(data = null, message = "Successs SERVICE") {

    return {
        data,
        status: 200,
        message,
        success: true,
        error: false,
    }
}

/**
 * @desc    Send Failure Response JSON
 *
 * @param   {any}  data Response Data default data=null
 * @param   {string} message message=Fail Service
 */
export function failureResponse(data = null, message = "Fail SERVICE") { }

LOG_OPTIONS.INFO ? failureResponse = function(data = null, message = "Fail SERVICE") {

    LOG_OPTIONS.WARNING ? log_info(message, LOG_TYPES.WARNING) : null;


    return {
        data,
        status: 200,
        message,
        success: false,
        error: false
    }

} : failureResponse = function(data = null, message = "Fail SERVICE") {
    
    return {
        data,
        status: 200,
        message,
        success: false,
        error: false
    }
}


/**
 * @desc    Send Fail Response JSON
 *
 * @param   {any}  data Response Data default data=null
 * @param   {string} error error
 * @param   {string} message message=FAILURE
 */
export function errorResponse(data = null, message = "", status) { }

LOG_OPTIONS.ERROR ? errorResponse = function (data = null, message = "INTERNAL SERVER ERROR", status = 500) {
    log_info(message, LOG_TYPES.ERROR);

    return {
        data,
        status,
        message,
        success: false,
        error: true
    }
} : errorResponse = function (data = null, message = "", status) {

    return {
        data,
        status,
        message,
        success: false,
        error: true
    }
}