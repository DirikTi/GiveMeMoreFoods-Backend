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
    
    try {
        const encrpytionTargetPassword = MyCrypto.encrpytion(req.body.password);


        const token = randomUUID();
        const loginJWT = MyJWT.createToken(token);
    
        let query = "SELECT * FROM v_users WHERE userEmail='" + email + "', AND password='" + encrpytionTargetPassword + "' LIMIT 1";
        let results = await mysqlAsi.executeQueryAsync(query);
    
        if (results[0] == undefined) {
            resp.json(failureResponse(null, "Not Found User"));
        } else {
            query  = "UPDATE users SET lastLoginDate=CURRENT_TIMESTAMP() WHERE userId=" + results[0].userId;
            mysqlAsi.executeQuery(query);
            delete results[0].password;
            resp.json(successResponse({ ...results[0], jwtToken: loginJWT }, "Login User"));
        }
    } catch (error) {
        resp.json(errorResponse(null, "INTERNAL SERVER ERROR"));
    }

    resp.end();
});

router.post("/register", [ValidationMiddleware(Validations.createAccount)], async (req, resp) => {
    const { email, fullname, surname, username } = req.body;
    console.log(req.body);
    const encrpytionTargetPassword = MyCrypto.encrpytion(req.body.password);
    const confirmCode = generateEmailCode(); // For Email Access Code

    let query = "CALL sp_CreateAdmin('" + email + "','" + username + "','" + fullname + "','" + surname + 
    "','" + encrpytionTargetPassword + "')";

    /*
    MailSender.sendEmailVerify(email, "", companyName, 
    "http://localhost:3000/account/email/verify?token=" + confirmCode + "&email=" + email);
*/
    const result = await mysqlAsi.executeQueryAsync(query);
    let myResult = result[0][0].RESULT;

    if (myResult == 'SUCCESS') {
        resp.json(successResponse(null, "SUCCESS"));
    } else {
        resp.json(failureResponse(null, myResult));
    }
    
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

    let result = await mysqlAsi.executeQueryAsync("SELECT * FROM v_users loginUserToken=CONVERT_UUID('" + secretMessage + "')");

    if (result[0] == undefined) {
        resp.json(errorResponse(null, "JWT Token not found user ==> IP_ADRESS " + req.ip, 401));
        return -1;
    }
    mysqlAsi.executeQuery("UPDATE users SET lastLoginDate=CURRENT_TIMESTAMP WHERE userId=" + result[0].userId);

    resp.json(successResponse(result[0]));
    resp.end();
});

router.post("/avatar", [AuthMiddleware(), uploadPhotoMiddleware.single('image_path')], async(req, resp) => {
    let image_path = req.body.image_path;
    const imageBUFFER = req.file;

    if (image_path == undefined) {
        //image_path = await uploadImageFirebaseAsync(imageBUFFER.buffer);
    } else {
        if(isWoman == "1") {
            image_path = "http://localhost:3000/assets/images/avtar/default-man.png";
        } else {
            image_path = "http://localhost:3000/assets/images/avtar/default-woman.png"
        }
    }
});

export default router;