import { randomUUID } from 'crypto';
import { initializeApp, cert } from 'firebase-admin/app';
import { getStorage } from 'firebase-admin/storage';
import { FIREABASE_ADMIN_CONFIG } from '../src/Config.js';

const _firebase = initializeApp({
    credential: cert(FIREABASE_ADMIN_CONFIG),
    storageBucket: 'gs://xxxxxx-3b8ab.appspot.com'
});

const storageRef = getStorage().bucket('gs://xxxxxx-3b8ab.appspot.com');

/**
 * 
 * @param {Buffer} image 
 * @returns 
 */
export async function uploadImageFirebaseAsync(image, imageName="") {

    if (image == null)
        throw new TypeError("You cannot set parameter null");

    const fileRef = storageRef.file(imageName == "" ? setNameImageUUID_V4() : imageName)
    await fileRef.save(image, {
        public: true
    });

    return fileRef.publicUrl(); 
}

function setNameImageUUID_V4() {
    return randomUUID() + ".jpg"
}
export default _firebase;