var express = require('express'),
    { Pool } = require('pg'),
    cookieParser = require('cookie-parser'),
    app = express(),
    server = require('http').Server(app),
    io = require('socket.io')(server),
    path = require('path');

var port = process.env.PORT || 4000;

io.on('connection', function (socket) {
  socket.emit('message', { text: 'Welcome!' });

  socket.on('subscribe', function (data) {
    socket.join(data.channel);
  });
});

const pool = new Pool({
  host: 'pgpool',
  port: 5432,
  user: 'postgres',
  password: 'adminpassword',
  database: 'postgres',
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
});

pool.on('error', (err) => {
  console.error('Unexpected PG pool error', err);
});

async function getVotes() {
  try {
    const result = await pool.query(
      'SELECT vote, COUNT(id) AS count FROM votes GROUP BY vote'
    );

    const votes = collectVotesFromResult(result);
    io.sockets.emit("scores", JSON.stringify(votes));

  } catch (err) {
    console.error('DB query failed:', err.message);
  }

  setTimeout(getVotes, 1000);
}

getVotes(); // 

function collectVotesFromResult(result) {
  var votes = { a: 0, b: 0 };

  result.rows.forEach(row => {
    votes[row.vote] = parseInt(row.count);
  });

  return votes;
}

app.use(cookieParser());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(__dirname + '/views'));

app.get('/', function (req, res) {
  res.sendFile(path.resolve(__dirname + '/views/index.html'));
});

server.listen(port, function () {
  console.log('App running on port ' + port);
});

