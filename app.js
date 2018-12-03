const { app, BrowserWindow } = require("electron");
var size = {
    width: 1280,
    height: 720
};

function createWindow() {
    var win = new BrowserWindow({
        width: size.width,
        height: size.height,
        fullscreen: true,
        autoHideMenuBar: true
    });
    
    win.loadFile("index.html");
    //win.webContents.openDevTools();
    win.on('closed', () => {
        win = null;
        app.quit();
    });
}
app.commandLine.appendSwitch('autoplay-policy', 'no-user-gesture-required');
app.on("ready", createWindow);