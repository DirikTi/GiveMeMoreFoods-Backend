import mysqlAsi from "../database/MysqlAsi.js";
import cache from "memory-cache";


export function TimerInit() {
    if (mysqlAsi.mysqlConnection == undefined) {
        setTimeout(() => {
            TimerInit();
        }, 3000);

        return -1;
    } else {
        setTimeout(() => {
            
            StartupTimerTrendCategory(5);
            StartupTimerTrendProduct(1);
        }, 5000);
    }
    
}

const getCategoryTrendQuery = () => {
    return `SELECT c.categoryId, categoryName, description, imagePath, (
        (
            SELECT COALESCE(COUNT(phu.isHeart), 0)
            FROM products_heart_users phu
            WHERE phu.categoryId=c.categoryId AND phu.isHeart=1
        ) * 2.5 + (
            SELECT COALESCE(
                SUM(pvu.visited) + LOG(10, DATEDIFF(CURRENT_DATE(), pvu.createdDate))
                , 0)
            FROM products_visit_users pvu
            WHERE pvu.categoryId=c.categoryId
        )
    ) AS trendPoint
    FROM category c
    GROUP BY categoryId, categoryName, description ORDER BY trendPoint DESC;`;
}

const getProductTrendQuery = () => {
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
    GROUP BY p.productId
    ORDER BY trend_point DESC
    LIMIT 50;`
}


function StartupTimerTrendCategory(minute) {
    console.log("Running Category Trend Timer " + minute + " minute");
    mysqlAsi.executeQueryAsync(getCategoryTrendQuery()).then((recordset) => {
        cache.put("categoryTrend", recordset);
    })

    setInterval(() => {
        mysqlAsi.executeQueryAsync(getCategoryTrendQuery()).then((recordset) => {
            cache.put("categoryTrend", recordset);
        }) 
    }, 60000 * minute);
}


function StartupTimerTrendProduct(minute) {
    console.log("Running Product Trend Timer " + minute + " minute");
    mysqlAsi.executeQueryAsync(getProductTrendQuery()).then((recordset) => {
        cache.put("productTrend", recordset);
    })

    setInterval(() => {
        mysqlAsi.executeQueryAsync(getProductTrendQuery()).then((recordset) => {
            cache.put("productTrend", recordset);
        });
    }, 60000 * minute);
}