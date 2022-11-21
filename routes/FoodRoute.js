import { query, Router } from 'express';
import { MyCrypto, MyJWT } from '../src/helpers/Encryption.js';
import { errorResponse, failureResponse, successResponse } from '../src/helpers/ResponseService.js';
import mysqlAsi from '../src/database/MysqlAsi.js';
import ValidationMiddleware from '../src/middleware/ValidationMiddleware.js';
import Validations from '../src/models/Validations/Validations.js';
import { randomUUID } from 'crypto';
import MailSender, { generateEmailCode } from '../src/helpers/MailSender.js';
import AuthMiddleware from '../src/middleware/Authtencation.js';

const router = Router();


router.get("/", [AuthMiddleware()], async (req, resp) => {
    

});

router.get("/category/:id", async (req, resp) => {

});

export default router;