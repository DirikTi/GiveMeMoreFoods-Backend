import { query, Router } from 'express';
import { MyCrypto, MyJWT } from '../src/helpers/Encryption.js';
import { errorResponse, failureResponse, successResponse } from '../src/helpers/ResponseService.js';
import mysqlAsi from '../src/database/MysqlAsi.js';
import ValidationMiddleware from '../src/middleware/ValidationMiddleware.js';
import Validations from '../src/models/Validations/Validations.js';
import { randomUUID } from 'crypto';
import AuthMiddleware from '../src/middleware/Authtencation.js';
import cache from 'memory-cache';

const router = Router();

const PRODUCT_TREND_LIMIT = 50
const getProductTrendQuery = (categoryId, top) => {
    top = (top - 1) * PRODUCT_TREND_LIMIT;
    return 
}

router.get("/", [AuthMiddleware()], async (req, resp) => {
    

});

router.get("/category/:id", async (req, resp) => {

});

router.get("/product/trend/:id", async (req, resp) => {
    const categoryId = req.params.id;

    if(categoryId == undefined) {
        const products = cache.get("productTrend");

        resp.json(successResponse(products));
        resp.end();
        return 1;
    }


    if(isNaN(categoryId)) {
        resp.json(errorResponse(null, "BAD REQUEST"));
        resp.end();
        return -1;
    }

    let productTop = 1;
    if(req.query.query != undefined && !isNaN(req.query.query)) {
        productTop = req.query.query;
    }
    
    productTop = (productTop - 1) * PRODUCT_TREND_LIMIT;
    let query = `SELECT p.productId, p.productName, SUBSTRING(p.productDesc, 1, 50) AS productDesc, p.imagePath, 
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
    LIMIT ` + PRODUCT_TREND_LIMIT + ` OFFSET ` + productTop + `;`;
    const products = await mysqlAsi.executeQueryAsync(query);

    resp.json(successResponse(products))
    resp.end();
})

export default router;