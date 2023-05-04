var events = require('events');
var util = require('util');
var mqtt = require('mqtt');

function LampiState() {
    events.EventEmitter.call(this);

    this.bearerToken = '';
    this.clientId = 'lamp_bt_peripheral';

    var that = this;
    var client_connection_topic = 'lamp/connection/' + this.clientId + '/state';

    var mqtt_options = {
    clientId: this.clientId,
    'will' : {
        topic: client_connection_topic,
        payload: '0',
        qos: 2,
        retain: true,
        },
    }

    var mqtt_client = mqtt.connect('mqtt://localhost', mqtt_options);
    mqtt_client.on('connect', function() {
        console.log('connected!');
        mqtt_client.publish(client_connection_topic,
            '1', {qos:2, retain:true})
    });

    this.mqtt_client = mqtt_client;
}

util.inherits(LampiState, events.EventEmitter);

LampiState.prototype.set_bearer_token = function(bearer_token) {
    this.bearer_token = bearer_token;
    this.mqtt_client.publish('lamp/set_oauth_creds', this.bearer_token);
    console.log('New bearer token received = ', this.bearer_token);
};

LampiState.prototype.set_acct_creds = function(acct_creds) {
    this.acct_creds = acct_creds;
    this.mqtt_client.publish('lamp/set_acct_creds', this.acct_creds);
    console.log('New account credentialas received = ', this.acct_creds);
};

LampiState.prototype.set_slideshow_settings = function(slideshow_settings) {
    this.slideshow_settings = slideshow_settings;
    this.mqtt_client.publish('lamp/set_slideshow_settings', this.slideshow_settings);
    console.log('New slideshow settings received = ', this.slideshow_settings);
};

LampiState.prototype.set_slideshow_state = function(slideshow_state) {
    this.slideshow_state = slideshow_state;
    this.mqtt_client.publish('lamp/set_slideshow_state', this.slideshow_state);
    console.log('New slideshow state received = ', this.slideshow_state);
};

module.exports = LampiState;
