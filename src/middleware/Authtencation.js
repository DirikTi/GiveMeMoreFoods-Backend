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
            "SELECT userId, companyId, roleCodes, userFullname, userSurname, userEmail, userPhoneNumber FROM users WHERE userLoginToken=CONVERT_UUID('" + secretMessage + "') LIMIT 1"
        );
        
        if(user[0].length == 0) {
            resp.json(errorResponse(null, "JWT Token not found user ==> IP_ADRESS " + req.ip, 401));
            return -1;
        }
        
        req.userID = user[0].userId;
        req.companyId = user[0].companyId;
        req.roleCodes = user[0].roleCodes;
        req.userFullname = user[0].userFullname;
        req.userSurname = user[0].userSurname;
        req.userEmail = user[0].userEmail;
        req.userPhoneNumber = user[0].userPhoneNumber;

        if(roleCode == "" || checkRoleName(req.roleCodes, roleCode)) {
            next();
        } else {
            if(req.baseUrl == "/api/v1/order") {
                let result = await mysqlAsi.executeQueryAsync("SELECT franchiseId FROM franchise WHERE userId='" + req.userID + " LIMIT 1");
                if(result[0].franchiseId == req.query.id) {
                    next();
                } else {
                    resp.json(errorResponse(null, "NOT_AUTH ", 401));
                    resp.end();
                }
            } else {
                resp.json(errorResponse(null, "NOT_AUTH ", 401));
                resp.end();
            }

        }
    } 
}

function checkRoleName(roleCodes, checkingRoleCodes) {
    let _roles = roleCodes.split(",");
    let _checkingRoleCodes = checkingRoleCodes.split(","); 
    for(let i = 0; i < _roles.length; i++) {
        for(let j = 0; j < _checkingRoleCodes.length; j++) {
            if(_checkingRoleCodes[j] == _roles[i] || _roles[i] == "admin") {
                return true;
            }
        }
        
    }

    return false;
}