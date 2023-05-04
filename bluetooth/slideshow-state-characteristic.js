var util = require('util');
var bleno = require('bleno');

var CHARACTERISTIC_NAME = 'Slideshow State';

function SlideshowStateCharacteristic(lampiState) {
    SlideshowStateCharacteristic.super_.call(this, {
        uuid: '0004A7D3-D8A4-4FEA-8174-1736E808C066',
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

    this.lampiState = lampiState;

}

util.inherits(SlideshowStateCharacteristic, bleno.Characteristic);

SlideshowStateCharacteristic.prototype.onWriteRequest = function(data, offset, withoutResponse, callback) {
    console.log('Slideshow State Write Request');

    if(offset) {
        callback(this.RESULT_ATTR_NOT_LONG);
    }

    else {

        this.slideshow_state = data.toString('utf-8');
        this.lampiState.set_slideshow_state(this.slideshow_state);

        callback(this.RESULT_SUCCESS);
    }
}

module.exports = SlideshowStateCharacteristic;
