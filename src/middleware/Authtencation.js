import mysqlAsi from '../database/MysqlAsi.js';
import { MyJWT } from '../helpers/Encryption.js';
import { errorResponse } from '../helpers/ResponseService.js';


export default function AuthMiddleware(roleCode = "") {

    /**
     * @param {import("express").Request} req
     * @param {import("express").Response} resp
     * @param {import("express").NextFunction} next
     */
    return async (req, resp, next) => {
        
        let tokenText = req.headers["authorization"];
        
        
        if(!tokenText || tokenText == "null" || tokenText == null){
            resp.json(errorResponse(null, "JWT HEADER Token not set", 401));
            return -1;
        }
            
        let token = tokenText.replace("Bearer ", "");
    
        if(token == ""){
            resp.json(errorResponse(null, "JWT Token not found", 401));
            return -1;
        }
    
        let secretMessage = MyJWT.decodeToken(token);

        let user = await mysqlAsi.executeQueryAsync(
            "SELECT userId FROM users WHERE userLoginToken=CONVERT_UUID('" + secretMessage + "') LIMIT 1"
        );

        if(user[0].length == 0) {
            resp.json(errorResponse(null, "JWT Token not found user ==> IP_ADRESS " + req.ip, 401));
            return -1;
        }
        
        req.userID = user[0].userId;
    } 
}