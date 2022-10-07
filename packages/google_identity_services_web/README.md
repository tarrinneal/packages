<?code-excerpt path-base="excerpts/packages/google_identity_services_web_example"?>

# google_identity_services_web

A JS-interop layer for Google Identity's Sign In With Google SDK.

See the original JS SDK reference:

* [Sign In With Google](https://developers.google.com/identity/gsi/web)

## Usage

This package is the Dart JS-interop layer of the new **Sign In With Google**
SDK. Here's the API references for both of the sub-libraries:

* `id.dart`: [Sign In With Google JavaScript API reference](https://developers.google.com/identity/gsi/web/reference/js-reference)
* `oauth2.dart`: [Google 3P Authorization JavaScript Library for websites - API reference](https://developers.google.com/identity/oauth2/web/reference/js-reference)
* `loader.dart`: An (optional) loader mechanism that installs the library and
resolves a `Future<void>` when it's ready.

### Loading the SDK

There are two ways to load the JS SDK in your app.

#### Modify your index.html (most performant)

The most performant way is to modify your `web/index.html` file to insert a
script tag [as recommended](https://developers.google.com/identity/gsi/web/guides/client-library).
Place the `script` tag in the `<head>` of your site, next to the script tag that
loads `flutter.js`, so the browser can downloaded both in parallel:

<?code-excerpt "../../web/index-with-script-tag.html (script-tag)"?>
```html
<head>
<!-- ··· -->
  <!-- Include the GSI SDK below -->
  <script src="https://accounts.google.com/gsi/client" async defer></script>
  <!-- This script adds the flutter initialization JS code -->
  <script src="flutter.js" defer></script>
</head>
```

#### With the `loadWebSdk` function (on-demand)

An alternative way, that downloads the SDK on demand, is to use the
**`loadWebSdk`** function provided by the library. A simple location to embed
this in a Flutter Web only app can be the `main.dart`:

<?code-excerpt "main.dart (use-loader)"?>
```dart
import 'package:google_identity_services_web/loader.dart' as gis;
// ···
void main() async {
  await gis.loadWebSdk(); // Load the GIS SDK
  // The rest of your code...
// ···
}
```

(Note that the above won't compile for mobile apps, so if you're developing a
cross-platform app, you'll probably need to hide the call to `loadWebSdk`
behind a [conditional import/export](https://dart.dev/guides/libraries/create-library-packages#conditionally-importing-and-exporting-library-files).)

### Using the SDK

Once the SDK has been loaded, it can be used by importing the correct library:

* `import 'package:google_identity_services/id.dart' as id;` for Authentication
* `import 'package:google_identity_services/oauth2.dart' as oauth2;` for
  Authorization.

## Browser compatibility

The new SDK is introducing concepts that are on track for standardization to
most browsers, and it might not be compatible with older browsers.

Refer to the official documentation site for the latest browser compatibility
information of the underlying JS SDK:

* **Sign In With Google > [Supported browsers and platforms](https://developers.google.com/identity/gsi/web/guides/supported-browsers)**

## Testing

This web-only package uses `dart:test` to test its features. They can be run
with `dart test -p chrome`.

_(Look at `test/README.md` and `tool/run_tests.dart` for more info.)_
