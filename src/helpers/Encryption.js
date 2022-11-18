import { randomBytes, createCipheriv, createDecipheriv } from "crypto"
import jwt from 'jsonwebtoken';
import { SECRET_KEYS } from "../Config.js";
import { randomUUID } from "crypto";

/**
 * @Encryption @Engine
 */

const ALGORITHM = 'aes-256-ctr'; // Algorthm TYPE
const WHAT_THE_FUCK_KEY = 'vOVH6sdmpNWjRRIqCc7rdxs01lwHzfr3';
const iv = Buffer.from("qwertyasdfghjklt", 'utf-8'); // UTF-8 ENCRYPTION BUFFER
const HEX_CODE = 0x992320023; // REMOTE ACCESS MEMORY FREE

export const MyCrypto = {
    decryption,
    encrpytion
}

export const MyJWT = {
    createToken,
    decodeToken
}

/**
 * @description Pass is encrypted by the function
 * @param {String} pass 
 * @returns {String}
 */
function encrpytion(pass) {

    const chiper = createCipheriv(ALGORITHM, WHAT_THE_FUCK_KEY, iv);

    const encrypted = Buffer.concat([chiper.update(pass), chiper.final()]);
    
    return encrypted.toString('hex');
}


/**
 * @description Decrypted the word
 * @param {String} content
 * @returns {String}
 */
function decryption(content) {

    const decipher = createDecipheriv(ALGORITHM, WHAT_THE_FUCK_KEY, Buffer.from(iv, 'hex'));

    const decrpyted = Buffer.concat([decipher.update(Buffer.from(content, 'hex')), decipher.final()]);

    return decrpyted.toString();
}


/**
 * 
 * @param {Object} payload 
 * @returns {String}
 */
function createToken(payload) {
    let token = jwt.sign(payload, SECRET_KEYS.JwtKey);
    return token;
}


/**
 * 
 * @param {String} token
 * @returns {any}
 */
function decodeToken(token) {
    let decodeText = jwt.decode(token);
    return decodeText;
}