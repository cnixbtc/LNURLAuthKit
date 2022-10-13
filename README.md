# LNURLAuthKit

Tools for [LNURL-Auth](https://github.com/fiatjaf/lnurl-rfc/blob/luds/04.md) clients written in Swift.

## Installation

LNURLAuthKit is available as a [Swift Package Manager](https://swift.org/package-manager/) package.
To use it, add the following dependency to your `Package.swift` file:

``` swift
.package(url: "https://github.com/cnixbtc/LNURLAuthKit.git", from: "0.2.0"),
```

## Functionality

Use `LNURLAuthKit` to seamlessly create different online identities.
Each identity will be backed by a different keypair.
Different linking keys will be derived from this identity keypair for each service using the method described in [LUD-13](https://github.com/fiatjaf/lnurl-rfc/blob/luds/13.md).

``` swift
let lnurl = "lnurl1..."

let workIdentity = try LNURLAuthIdentity()
let auth = try LNURLAuth(identity: workIdentity, lnurl: lnurl)

let signedUrl = try auth.sign()

// Do a GET on `signedUrl` to login using your work identity...
```
