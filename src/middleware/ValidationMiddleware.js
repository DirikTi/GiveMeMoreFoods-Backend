import { errorResponse, failureResponse } from "../helpers/ResponseService.js";
import { ValidationError } from "../models/Errors.js";

/**
 * @description Validation Middleware
 * @param  {...Array} param 
 */
export default function ValidationMiddleware(param) {
    /**
     * @param {Request} req
     * @param {Response} resp
     * @param {NextFunction} next
     */
    return function (req, resp, next) {

        if(deepEqual(req.body, param)) {
            next();
        } else {
            resp.status(400);
            resp.end();
        }
    }
}

function deepEqual(x, model) {
    
    return (typeof x == "string" || typeof x == "boolean" || typeof x == "number") ? (typeof x == model.name.toLowerCase()) 
    : x.map != undefined ? deepEqual(x[0], model[0]) 
    : Object.keys(x).length == Object.keys(model).length && 
    (Object.keys(x).filter((myX) => (
        Object.keys(model).findIndex((myY) => (myX == myY && deepEqual(x[myX], model[myX]))) == -1
    ))).length == 0
    
    /*
    if (typeof x == "string" || typeof x == "boolean" || typeof x == "number") {
        return typeof x == model.name.toLowerCase()
    } else {
        if(x.map != undefined ) {
           return deepEqual(x[0], model[0]) 
        } else {
            let data = (Object.keys(x).filter((myX) => {
                let result = Object.keys(model).findIndex((myY) => 
                {
                    let a = myX == myY && deepEqual(x[myX], model[myY])
                    return a
                })

                return result == -1;
            }));
            return data == 0;
        }
    }
    */
}
