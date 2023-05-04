var util = require('util');
var bleno = require('bleno');

var CHARACTERISTIC_NAME = 'Google OAuth Credentials';
var BEARER_TOKEN_PARTS = 1;

function GoogleOAuthCharacteristic(lampiState) {
    GoogleOAuthCharacteristic.super_.call(this, {
        uuid: '0003A7D3-D8A4-4FEA-8174-1736E808C066',
        properties: ['write'],
        secure: [],
        descriptors: [
            new bleno.Descriptor({
                uuid: '2901',
                value: CHARACTERISTIC_NAME,
            }),
            new bleno.Descriptor({
                uuid: '2904',
                value: new Buffer([0x19, 0x00, 0x27, 0x00, 0x01, 0x00, 0x00])
	    }),
	],
    });

    this.bearer_token_temp = '';
    this.token_parts_received = 0;
    this.lampiState = lampiState;

}

util.inherits(GoogleOAuthCharacteristic, bleno.Characteristic);

GoogleOAuthCharacteristic.prototype.onWriteRequest = function(data, offset, withoutResponse, callback) {
    console.log('Bearer Token Write Request');

    if(offset) {
        callback(this.RESULT_ATTR_NOT_LONG);
    }

    else {
        this.bearer_token_temp = this.bearer_token_temp.concat(data.toString('utf8'));
        this.token_parts_received = this.token_parts_received + 1;

        if (this.token_parts_received >= BEARER_TOKEN_PARTS) {
            this.token_parts_received = 0;
            this.lampiState.set_bearer_token(this.bearer_token_temp);
            console.log(this.bearer_token_temp);
            this.bearer_token_temp = '';
        };

        callback(this.RESULT_SUCCESS);
    }
}

module.exports = GoogleOAuthCharacteristic;
