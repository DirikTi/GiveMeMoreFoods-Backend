import fs from 'fs';
import mysql from 'mysql';


fs.readFile('./startup.sql', 'utf-8', (err, data) => {
    
    if(err) {
        console.error("FILE ERROR");
        throw new Error(err);
    }
    
    const PORT = 3306;
    const PASSWORD = ""

    let mysql_con = mysql.createConnection({
        host: "localhost",
        password: PASSWORD,
        port: PORT,
        user: "root",
        multipleStatements:true
    });

    mysql_con.connect((errConnect) => {
        if(errConnect) {
            console.error("CONNECTION ERROR");
            throw new Error(errConnect);
        }

        console.log("Connected Mysql");

        mysql_con.query(data, (errQuery, result) => {
            if(errQuery) {
                console.error("QUERY ERROR");
                throw new Error(errQuery);
            }
            process.exit(1);
        })
    })

})


 