var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

app.get('/elm.js', function (req, res) {
    res.sendFile(__dirname + '/elm.js');
});

app.get('/', function (req, res) {
    res.sendFile(__dirname + '/index.html');
});


// global variable because I'm a bad programmer and this is a demo
var state = {
    count: 0
};

io.on('connection', function (socket) {
    if (socket.id in state || state.count >= 2) {
        return;
    }

    console.log('New Connection!');

    state[socket.id] = {
        value: 0,
        socket: socket
    };
    ++state.count;

    socket.on('disconnect', function () {
        console.log('Client ' + socket.id + ' disconnected!');
        delete state[socket.id];
        --state.count;
        console.log('Count is: ' + state.count);
    });

    socket.on('getClientID', function () {
        socket.emit('clientID', { clientID: socket.id });
    });

    socket.on('setValue', function (data) {
        state[data.clientID] = data.value;
        console.log('Client ' + data.clientID + ' has updated its value to ' + data.value);
        socket.broadcast.emit('setOther', { value: data.value });
    });
});

http.listen(3000, function () {
    console.log('Server running on localhost:3000');
});