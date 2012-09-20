.pragma library

/* This JS library is a small helper that redefines in JS some of the enums
   from the the camera API described here:
   https://bazaar.launchpad.net/~rocket-scientists/aal%2B/trunk/view/head%3A/compat/camera/camera_compatibility_layer.h

   FIXME: when switching to the real Camera just run a global replace on CameraEnums to Camera
          and then delete this file
*/

var FlashModeOff = "FlashModeOff";
var FlashModeOn = "FlashModeOn";
var FlashModeAuto = "FlashModeAuto";
var FlashModeTorch = "FlashModeTorch";
