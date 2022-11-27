import mysqlAsi from "../database/MysqlAsi.js";
import { PassThrough } from 'stream';
import { LOG_OPTIONS } from '../Config.js';

export default function LogsMiddleware() {

    /**
     * @param {import("express").Request} req
     * @param {import("express").Response} resp
     * @param {import("express").NextFunction} next
     */
    return async (req, resp, next) => {
        const _write = resp.write.bind(resp);
        const _end = resp.end.bind(resp);
        const ps = new PassThrough();
        const chunks = [];

        ps.on('data', data => chunks.push(data));

        resp.write = (...args) => {
            console.log(args);

            ps.write(...args);
            _write(...args);
        }

        resp.end = (...args) => {
            ps.end(...args);
            _end(...args);
        }

        resp.on('finish', () => {

            const body = Buffer.concat(chunks).toString('utf-8');

            toLogRequestDB({
                requestBody: typeof req.body == "object" ? JSON.stringify(req.body) : req.body,
                requestQuery: req.query,
                baseUrl: req.originalUrl,
                createdDate: new Date().getTime().toString(),
                headers: req.headers,
                method: req.method,
                responseBody: body == "" ? body : JSON.parse(body),
                senderIp: req.ip,
                user_id: req.userID
            });


        })
        next();
    };
}

/**
 * @param {import("../models/types/OtherModels").LogModel} logModel
 * @description "Log to database"
 */
function toLogRequestDB(logModel) {
    try {
        let jsonBody = logModel.responseBody;

        logModel.error = jsonBody.error != undefined ? jsonBody.error : false;
        logModel.status = jsonBody.status != undefined ? jsonBody.status : 200;

        let query = "INSERT INTO requests (request_body, request_query, base_url, headers, method, response_body, sender_ip_address, user_id, is_error, status, createdDate) VALUES " +
            "('" + JSON.stringify(logModel.requestBody) + "', '" + JSON.stringify(logModel.requestQuery) + "', '"
            + logModel.baseUrl + "', '" + JSON.stringify(logModel.headers) + "', '" + logModel.method + "', '" + JSON.stringify(logModel.responseBody)
            + "', '" + logModel.senderIp + "', '" + (logModel.user_id == undefined ? "" : logModel.user_id) + "', " + logModel.error + ", "
            + logModel.status + ",'" + logModel.createdDate + "');";

        mysqlAsi.executeQuery(query);

    } catch (error) {
        console.log(error)
    }
}