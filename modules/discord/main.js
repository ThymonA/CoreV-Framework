const { Client } = require('discord.js');
const { Cfx } = require('fivem-js');
const client = new Client();

global.config = require('./modules/discord/config.json');

client.on('ready', () => {
    console.log(`Discord Bot logged in as ${client.user.tag}`);
});

client.login(config.token);

client.on('message', (message) => {
});