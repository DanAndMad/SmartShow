var util = require('util');
var bleno = require('bleno');

var CHARACTERISTIC_NAME = 'Google Account Credentials';
var ACCOUNT_CREDENTIALS_PARTS = 2;

function GoogleAccountCredentialsCharacteristic(lampiState) {
    GoogleAccountCredentialsCharacteristic.super_.call(this, {
        uuid: '0002A7D3-D8A4-4FEA-8174-1736E808C066',
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

    this.acct_creds_temp = '';
    this.acct_parts_received = 0;
    this.lampiState = lampiState;

}

util.inherits(GoogleAccountCredentialsCharacteristic, bleno.Characteristic);

GoogleAccountCredentialsCharacteristic.prototype.onWriteRequest = function(data, offset, withoutResponse, callback) {
    console.log('Account Credentials Write Request');

    if(offset) {
        callback(this.RESULT_ATTR_NOT_LONG);
    }

    else {
        this.acct_creds_temp = this.acct_creds_temp.concat(data.toString('utf8'));
        this.acct_parts_received = this.acct_parts_received + 1;

        if (this.acct_parts_received >= ACCOUNT_CREDENTIALS_PARTS) {
            this.acct_parts_received = 0;
            this.lampiState.set_acct_creds(this.acct_creds_temp);
            console.log(this.acct_creds_temp);
            this.acct_creds_temp = '';
        };

        callback(this.RESULT_SUCCESS);
    }
}

module.exports = GoogleAccountCredentialsCharacteristic;
