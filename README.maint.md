libmongocrypt Ruby Helper - Maintainer Guide
============================================

## Packaging New libmongocrypt Version

Edit `lib/libmongocrypt_helper/version.rb` and:

1. Update the `LIBMONGOCRYPT_VERSION` constant to the version of
`libmongocrypt` that you want to package.
2. Update the `VERSION` constant to the version of the helper, which is
derived from `libmongocrypt` version as described below.
3. Download the source code of the corresponding version of `libmongocrypt` from
https://github.com/mongodb/libmongocrypt/releases/, and unpack it to
`ext/libmongocrypt/libmongocrypt`.
4. Commit the changes including the new shared library.
5. Run `./release.sh` to create a gem and push it to RubyGems.

## Helper Version Scheme

Ruby gems have a relatively primitive versioning system where any non-numeric
version component causes the version to be interpreted as a pre-release.
For example, a scheme like `1.0p1` where "p1" stands for the first package
of the 1.0 version of some library doesn't work.

To work around this, libmongocrypt helper is versioned as `X.0.Y` where
`X` is the version of `libmongocrypt` that is being packaged and `Y` is
the package version plus 1000. Thus, the first package for `libmongocrypt`
1.5.2 would have the helper version of 1.5.2.0.1001, and if that version
of `libmongocrypt` needs to be repackaged for any reason, the next helper
version would be 1.5.2.0.1002, and so on.

Starting package versions from 1001 makes it easy to identify the package
revision vs the `libmongocrypt` version.

## Crypto

`libmongocrypt` can be built while linking to the operating system's
crypto libraries (i.e. OpenSSL) or not. If `libmongocrypt` is not linked
to the operating system's crypto libraries, a crypto implementation must be
provided at runtime, which the Ruby MongoDB driver does.
