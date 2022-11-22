import mysql from 'mysql';
import { MYSQL_INFO } from '../Config.js';
import { DatabaseError } from '../models/Errors.js';


class Mysql {
    
    constructor(options){
        try {
            this.mysqlConnection = mysql.createConnection(options);
            this.mysqlConnection.connect(err => {
                if(err) {
                    console.log(err);
                    new DatabaseError(err, "MYSQL NOT CONNECTED");
                } else {
                    console.log("MYSQL CONNECTED");
                    this.startupMemoryCategory();
                }
            })
        } catch (error) {
            new DatabaseError(error, "MYSQL NOT CONNECTED");
        }

    }

    /**
     * @private
     */
    startupMemoryCategory() {
        this.mysqlConnection.query("SELECT COUNT(1) AS count FROM category", (err, result) => {
            if(result[0].count == 0) {
                this.mysqlConnection.query("INSERT INTO category (categoryName, description) VALUES " + 
                    "('Tatlılar', 'Çeşit çeşit tatlılar bulunmakta')," + 
                    "('Çorbalar', 'Çorba çeşitleri içerir')," + 
                    "('Pilavlar', 'Çeşitli pilavlar bulunmakta');"
                );
            }
        });
    }

    /**
    * @description start begin transaction
    * @param {function} callback 
    */
    beginTransaction(callback) {
        
        this.mysqlConnection.beginTransaction((err) => {
            if(err)
                throw new DatabaseError(err, "Transaction is not started");
    
            if(!callback) 
                throw Error("CALLBACK Function is null");
            
            callback();
    
        })
    }
    
    /**
     * @description Commit the database
     */
    commit() {
        this.mysqlConnection.commit((err) => {
            if(err) {
                rollback();
                throw new DatabaseError(err);
            }
        })
    }
    
    /**
     * @description cancel all your process in database
     *  
     */
    rollback() {
        this.mysqlConnection.rollback((err) => {
            if(err)
                throw new DatabaseError(err, "Rollback is not started");
        })
    }
    
    /**
     * @description Execute query sql You can just use EXEC, INSERT, UPDATE, DELETE
     * @param {string} queryString 
     */
    executeQuery(queryString) {
        if(queryString == undefined || typeof queryString != "string")
            throw "ERROR Query is null";
        
        this.mysqlConnection.query(queryString, (err, result) => {
            console.log(err);
            if(err)
                throw new DatabaseError(err);
            
            return result;
        })
    
    }
    
    /**
     * @description Execute query sql with Async Promise
     * @param {string} queryString 
     */
    async executeQueryAsync(queryString) {
        if(queryString == undefined && typeof queryString != "string")
            throw "ERROR Query is null";
            
        return new Promise((resolve, reject) => {
            this.mysqlConnection.query(queryString, (err, results) => {
                if(err) {
                    console.log(err);
                    return reject(new DatabaseError(err, "Cannot execute sql query without Async"));
                }
                    
                return resolve(results);
            })
        })    
    }
    
}

const mysqlAsi = new Mysql(MYSQL_INFO);
export default mysqlAsi;