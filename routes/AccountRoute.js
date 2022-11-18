import { query, Router } from 'express';
import { MyCrypto, MyJWT } from '../src/helpers/Encryption.js';
import { errorResponse, failureResponse, successResponse } from '../src/helpers/ResponseService.js';
import mysqlAsi from '../src/database/MysqlAsi.js';
import ValidationMiddleware from '../src/middleware/ValidationMiddleware.js';
import Validations from '../src/models/Validations/Validations.js';
import { randomUUID } from 'crypto';

const router = Router();


router.post('/login', [ValidationMiddleware(Validations.loginAccout)], async (req, resp) => {
    const email = req.body.email;
    const encrpytionTargetPassword = MyCrypto.encrpytion(req.body.password);

    const token = randomUUID();
    const loginJWT = MyJWT.createToken(token);

    let query = "CALL sp_LoginUser('" + email + "', '" + encrpytionTargetPassword + "', '" + token + "')";
    let results = await mysqlAsi.executeQueryAsync(query);

    if (results[0] == undefined) {
        resp.json(failureResponse(null, "Not Found User"));
    } else {
        resp.json(successResponse({ ...results[0][0], jwtToken: loginJWT }, "Login User"));
    }

    resp.end();
});

router.post("/register", [ValidationMiddleware(Validations.createAccount)], async (req, resp) => {
    const { email, fullname, surname, phoneNumber, companyName, companyDescription, countryId, cityId, districtId
    } = req.body;
    console.log(req.body);
    const encrpytionTargetPassword = MyCrypto.encrpytion(req.body.password);
    const confirmCode = generateEmailCode();

    let query = "CALL sp_CreateAdmin('" + companyName + "','" + companyDescription + "',1,'" + fullname + "','"
    + surname + "','" + email + "','" + encrpytionTargetPassword + "','" + confirmCode + "','" + phoneNumber + 
    "',0," + countryId + "," + cityId + "," + districtId + ")";

    MailSender.sendEmailVerify(email, "", companyName, 
    "http://localhost:3000/account/email/verify?token=" + confirmCode + "&email=" + email);

    /*
    const result = await mysqlAsi.executeQueryAsync(query);
    let myResult = result[0][0].RESULT;

    if (myResult == 'SUCCESS') {
        resp.json(successResponse(null, "SUCCESS"));
    } else if (myResult == "HAS_USER" || myResult == "HAS_COMPANY") {
        resp.json(failureResponse(null, myResult));
    } else {
        resp.sendStatus(500);
    }
    
    */

    resp.json(failureResponse(null, "HAS_COMPANY"));

    resp.end();
});

router.post("/has", async (req, resp) => {
    let tokenText = req.headers["authorization"];


    if (!tokenText || tokenText == "null" || tokenText == null) {
        resp.json(errorResponse(null, "JWT HEADER Token not set", 401));
        return -1;
    }

    let token = tokenText.replace("Bearer ", "");

    if (token == "") {
        resp.json(errorResponse(null, "JWT Token not found", 401));
        return -1;
    }

    let secretMessage = MyJWT.decodeToken(token);

    let result = await mysqlAsi.executeQueryAsync("CALL sp_LoginUserWithToken('" + secretMessage + "');");

    if (result[0] == undefined) {
        resp.json(errorResponse(null, "JWT Token not found user ==> IP_ADRESS " + req.ip, 401));
        return -1;
    }

    resp.json(successResponse(result[0][0]));
})


export default router;