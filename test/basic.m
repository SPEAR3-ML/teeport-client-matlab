client = SimpleClient('ws://zeta:8080');
msg = jsonencode(struct('type', 'matlab', 'data', [1, 2, 3]));
client.send(msg);
client.close();
