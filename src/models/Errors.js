import { LOG_OPTIONS } from "../Config.js";
import { log_error, log_info, log_system } from "../helpers/Logger.js";

export class ParentError extends Error {

    constructor(message) {
        super(message);
    }

    LogError(error) {
        LOG_OPTIONS.ERROR ? log_error(this.name, this.message, error) : null;        
    }

    LogSystem( isError = false) {
        log_system(this.message, isError);
    }

    LogWarning(error) {
        LOG_OPTIONS.WARNING ? log_info( this.message, "WARNING" , error ) : null;
    }
    
}

export class DatabaseError extends ParentError {
    constructor(err, message = "DATABASE ERROR DEFAULT") {
        super(message);
        this.name = "DATABASE ERROR";
        
        this.LogError(err);
    }
}

export class FileError extends ParentError {
    constructor(err, message = "FILE PROCESS ERROR DEFAULT") {
        super(message);
        this.name = "FILE ERROR";

        this.LogError(err);
    }
}

export class GoogleAPIError extends ParentError {
    constructor(err, message = "GOOGLE API ERROR DEFAULT") {
        super(message);
        this.name = "GOOGLE API ERROR";

        this.LogError(err);
    }
}

export class MulterFileError extends ParentError {
    constructor(err, message = "Multer File(Video, Photo) ERROR DEFAULT") {
        super(message);
        this.name = "MULTER FILE ERROR";

        this.LogWarning(err);
    }
}

export class ValidationError extends ParentError {
    constructor(err, message = "VALIDATION ERROR DEFAULT") {
        super(message);
        this.name = "VALIDATION ERROR";

        this.LogWarning(err);
    }
}

export class MailError extends ParentError {
    constructor(err, message = "MAIL ERROR DEFAULT") {
        super(message);
        this.name = "MAIL ERROR";

        this.LogError(err);
    }
}