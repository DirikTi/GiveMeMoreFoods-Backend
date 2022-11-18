import { Server } from "socket.io";


export function SocketInit(server) {
    const io = new Server(server);
    

    io.on("connection", (socket) => {
        console.log("Connection a socket");
        
    })
    
}