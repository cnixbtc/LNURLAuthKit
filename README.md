# LNURLAuthKit

Tools for [LNURL-Auth](https://github.com/fiatjaf/lnurl-rfc/blob/luds/04.md) written in Swift.

## Installation

LNURLAuthKit is available as a [Swift Package Manager](https://swift.org/package-manager/) package.
To use it, add the following dependency to your `Package.swift` file:

``` swift
.package(url: "https://github.com/cnixbtc/LNURLAuthKit.git", from: "0.1.0"),
```

## Functionality

Use `LNURLAuthKit` to seamlessly create different online identities.
Each identity will be backed by a different keypair.
Different linking keys will be derived from this identity keypair for each service using the method described in [LUD-13](https://github.com/fiatjaf/lnurl-rfc/blob/luds/13.md).

``` swift
// Create two online identities: One for private use, one for work.

let privateIdentity = try LNURLAuthIdentity()
let workIdentity = try LNURLAuthIdentity()

// Login using your private identity:

let callbackForPrivateLogin = try LNURLAuth(
    identity: privateIdentity,
    url: await fetchStackerNewsLoginUrl()
).sign()

await login(callbackForPrivateLogin)

// Later on, login using your work identity:

let callbackForWorkLogin = try LNURLAuth(
    identity: workIdentity,
    url: fetchStackerNewsLoginUrl()
).sign()

login(callbackForWorkLogin)

// Helpers:

func fetchStackerNewsLoginUrl() async -> URL {
    // Get a LNURL-Auth login url from stacker.news...
    // Decoding the Bech32 LNURLs is still todo.
}

func login(callback url: URL) async {
    // Do a GET on callback url to login.
}
``` 
