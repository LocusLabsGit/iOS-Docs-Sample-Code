var ios;

locuslabs.setupIOS = function (callback) {
    if (typeof ios === 'undefined') {
        ios = {
            execute : function (url) { 
                var iframe = document.createElement("IFRAME");
                iframe.setAttribute("src", url); 
                document.documentElement.appendChild(iframe);
                iframe.parentNode.removeChild(iframe);
                iframe = null;
            },
            ready : function () {
                ios.execute('ios-ready://');
            },
            callFunction : function (uuid,json) {
                var url = 'ios-call-function://'+uuid+'/'+encodeURIComponent(json);
                ios.execute(url);
            },
            eventRelay : {
                submit : function (event) {
                    var json = JSON.stringify(event);
                    var url = 'ios-event://'+encodeURIComponent(json);
                    ios.execute(url);
                }
            }
        };
    }
    // Redirect JS logging to iOS
    console = console || {};
    console.log = function( log ) {
        var iframe = document.createElement( "IFRAME" );
        iframe.setAttribute( "src", "ios-log://" + encodeURIComponent( log ) );
        document.documentElement.appendChild( iframe );
        iframe.parentNode.removeChild( iframe );
        iframe = null;
    };
    console.debug = console.log;
    console.info = console.log;
    console.warn = console.log;

    locuslabs.log.debug = console.log;
    locuslabs.log.info = console.log;
    locuslabs.log.warn = console.log;
    locuslabs.log.error = console.log;

    locuslabs.iosSetupCallback = function () {
        locuslabs.ios = new locuslabs.Native( ios );

        console.error = console.log;

        // Use the native iOS panzoom mechanism
        locuslabs.config[ 'panZoomMethod' ] = 'iosScrollView';

        callback();
    };

    ios.execute( 'ios-setup://' );
};
