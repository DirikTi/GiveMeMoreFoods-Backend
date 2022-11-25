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

const getProductTrendQuery = (categoryId) => {
    return `SELECT p.productId, p.productName, p.productDesc, p.imagePath, 
    categoryId, heartCount, whoCreateUserId, username, avatar, (
        (
            SELECT COALESCE(
                SUM(pvu.visited) + LOG(10, DATEDIFF(CURRENT_DATE(), pvu.createdDate))
            , 0)
            FROM products_visit_users pvu
            WHERE pvu.productId=p.productId
        ) + 2.5 * heartCount
    ) AS trend_point
    FROM v_products p
    WHERE categoryId=` + categoryId + `
    GROUP BY p.productId
    ORDER BY trend_point DESC
    LIMIT 50;`
}

router.get("/", [AuthMiddleware()], async (req, resp) => {
    

});

router.get("/category/:id", async (req, resp) => {

});

router.get("/product/trend/:id", async (req, resp) => {
    let categoryId = req.params.id;

    if(categoryId == undefined) {
            
    }


})

export default router;