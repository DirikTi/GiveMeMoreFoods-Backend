import multer from 'multer';
import path from 'path';
import { MulterFileError } from '../models/Errors.js';

const optionsPhoto = {
    fileFilter: function(req, file, callback){
        let ext = path.extname(file.originalname);
        if(ext != '.png' && ext != '.jpg' && ext != '.jpeg' &&
        ext != '.PNG' && ext != '.JPG' && ext != '.JPEG')
            return callback(new MulterFileError("The photo is wrong name " + ext, "WRONG PHOTO"))
        

        callback(null, true);
    },
    limits: {
        fileSize: 4096 * 4096
    }
}

const optionsVideo = {
    fileFilter: function(req, file, callback) {

    }
}


export const uploadPhotoMiddleware = multer(optionsPhoto);