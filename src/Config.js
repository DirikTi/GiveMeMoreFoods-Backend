export const PATH = process.cwd();

/**
 * @description {enabled, disabled}
 */
export const LOG_OPTIONS = {
    INFO: true,
    WARNING: true,
    ERROR: true,
    REQUEST_LOG: true,
}

export const MYSQL_INFO = {
    connectTimeout: 10000,
    password: '',
    user: 'root',
    database: 'foods',
    host: 'localhost',
    port: 3306,
    multipleStatements: true
}

export const SECRET_KEYS = {
    JwtKey: "Your Secret Key in here",
}

export const IYZICO_CONFIG = {
    apiKey: "sandbox-seEWb9tPubQJ5JN5Bcr2cxf0tPy9dyyk",
    secretKey: "sandbox-zSht1WoyUgYtWvmcrvwscmLkCIBaL0Ko",
    uri: "https://sandbox-api.iyzipay.com"
}

export const CONFIG = {
    corsOptions: {
        origin: 'http://localhost:8080',
        optionsSuccessStatus: 200,
    },
    memcached: {
        retries: 10,
        retry: 10000,
        remove: true
    }
}