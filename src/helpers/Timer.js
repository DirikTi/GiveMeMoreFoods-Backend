import mysqlAsi from "../database/MysqlAsi";


export function TimerInit() {
    if (mysqlAsi.mysqlConnection == undefined) {
        setTimeout(() => {
            TimerInit();
        }, 3000);

        return -1;
    }

    StartupTimerTrendCategory(5);
    
}

const getCategoryTrendQuery = () => {
    return `SELECT c.categoryId, categoryName, description, (
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