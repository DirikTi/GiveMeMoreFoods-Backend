import { Server, Socket } from "socket.io";

const __connections = [];

export function SocketInit(server) {
    console.log("Socket initlizaing...");
    
    const io = new Server();
    io.listen(server);
    
   
    io.on("connection", (socket) => {
        console.log("connection a socket");
        
        socket.on("register", async (registered_user_id) => {
            socket.userID = registered_user_id;
            __connections.push(socket);
        })

        socket.on('disconnect', () => {
            __connections.splice(__connections.indexOf(socket), 1);
        });

    })
    
}

/**
 * 
 * @param {String} userID 
 * @returns {Socket}
 */
export const getConnection = (userID) => {
    for(let i = 0; i < __connections.length; i++) {
        if(__connections[i].userID == userID) {
            return __connections[i];
        }
    }
    return null;
}