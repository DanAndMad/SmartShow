var util = require('util');
var bleno = require('bleno');

var GoogleOAuthCredentials = require('./google-oauth-credentials-characteristic');
var GoogleAccountCredentials = require('./google-account-credentials-characteristic');
var SlideshowSettings = require('./slideshow-settings-characteristic')
var SlideshowState = require('./slideshow-state-characteristic')
function LampiService(lampiState) {
    bleno.PrimaryService.call(this, {
        uuid: '0005A7D3-D8A4-4FEA-8174-1736E808C066',
        characteristics: [
            new GoogleOAuthCredentials(lampiState),
            new GoogleAccountCredentials(lampiState),
            new SlideshowSettings(lampiState),
            new SlideshowState(lampiState),
        ]
    });
}

util.inherits(LampiService, bleno.PrimaryService);

module.exports = LampiService;
