# Data-encoding

[![Latest Version][version_badge]][library]
[![Documentation][documentation_badge]][documentation]
[![Latest License][license_badge]][license]
[![Build Status][travis_badge]][travis]
[![Build Status][appveyor_badge]][appveyor]
[![Coverage Status][coveralls_badge]][coveralls]

This repository provides a Rust [library] and a [binary] providing efficient
common and custom data-encodings.

## Common use-cases

The [library] provides the following common encodings:

- `HEXLOWER`: lowercase hexadecimal
- `HEXLOWER_PERMISSIVE`: lowercase hexadecimal with case-insensible decoding
- `HEXUPPER`: uppercase hexadecimal
- `HEXUPPER_PERMISSIVE`: uppercase hexadecimal with case-insensible decoding
- `BASE32`: RFC4648 base32
- `BASE32_NOPAD`: RFC4648 base32 without padding
- `BASE32HEX`: RFC4648 base32hex
- `BASE64`: RFC4648 base64
- `BASE64_NOPAD`: RFC4648 base64 without padding
- `BASE64URL`: RFC4648 base64url
- `BASE64_MIME`: RFC2045-like base64

Typical usage looks like:

```rust
// allocating functions
BASE64.encode(&input_to_encode)
HEXLOWER.decode(&input_to_decode)
// in-place functions
BASE32.encode_mut(&input_to_encode, &mut encoded_output)
BASE64_URL.decode_mut(&input_to_decode, &mut decoded_output)
```

See the [documentation] or the [changelog] for more details.

## Custom use-cases

The [library] also provides the possibility to define custom little-endian ASCII
base-conversion encodings for bases of size 2, 4, 8, 16, 32, and 64 (for which
all above use-cases are simply instances). It supports:

- padded and non-padded encodings
- canonical encodings (trailing bits are checked)
- in-place encoding and decoding functions
- partial decoding functions
- character translation (for case-insensitivity for example)
- most and least significant bit-order
- ignoring characters when decoding
- wrapping the output when encoding

The typical definition of a custom encoding looks like:

```rust
lazy_static! {
    static ref DNSCURVE: data_encoding::Encoding = {
        use data_encoding::{Specification, BitOrder};
        let mut spec = Specification::new();
        spec.symbols.push_str("0123456789bcdfghjklmnpqrstuvwxyz");
        spec.translate.from.push_str("BCDFGHJKLMNPQRSTUVWXYZ");
        spec.translate.to.push_str("bcdfghjklmnpqrstuvwxyz");
        spec.bit_order = BitOrder::LeastSignificantFirst;
        spec.encoding().unwrap()
    };
}
```

See the [documentation] or the [changelog] for more details.

## Performance

The performance of the encoding and decoding functions (for both common and
custom encodings) are similar to existing implementations in C, Rust, and other
high-performance languages. You may run the benchmarks with `make bench`.

## Swiss-knife binary

The [binary] is mostly a wrapper around the library. You can run `make install`
to install it from the repository. By default, it will be installed as
`~/.cargo/bin/data-encoding`. You can also run `cargo install data-encoding-bin`
to install the latest version published on `crates.io`. This does not require to
clone the repository.

Once installed, you can run `data-encoding --help` (assuming `~/.cargo/bin` is
in your `PATH` environment variable) to see the usage:

```
Usage: data-encoding --mode=<mode> --base=<base> [<options>]
Usage: data-encoding --mode=<mode> --symbols=<symbols> [<options>]

Options:
    -m, --mode <mode>   {encode|decode|describe}
    -b, --base <base>   {16|hex|32|32hex|64|64url}
    -i, --input <file>  read from <file> instead of standard input
    -o, --output <file> write to <file> instead of standard output
        --block <size>  read blocks of about <size> bytes
    -p, --padding <padding>
                        pad with <padding>
    -g, --ignore <ignore>
                        when decoding, ignore characters in <ignore>
    -w, --width <cols>  when encoding, wrap every <cols> characters
    -s, --separator <separator>
                        when encoding, wrap with <separator>
        --symbols <symbols>
                        define a custom base using <symbols>
        --translate <new><old>
                        when decoding, translate <new> as <old>
        --ignore_trailing_bits 
                        when decoding, ignore non-zero trailing bits
        --least_significant_bit_first 
                        use least significant bit first bit-order

Examples:
    # Encode using the RFC4648 base64 encoding
    data-encoding -mencode -b64     # without padding
    data-encoding -mencode -b64 -p= # with padding

    # Encode using the MIME base64 encoding
    data-encoding -mencode -b64 -p= -w76 -s$'\r\n'

    # Show base information for the permissive hexadecimal encoding
    data-encoding --mode=describe --base=hex

    # Decode using the DNSCurve base32 encoding
    data-encoding -mdecode \
        --symbols=0123456789bcdfghjklmnpqrstuvwxyz \
        --translate=BCDFGHJKLMNPQRSTUVWXYZbcdfghjklmnpqrstuvwxyz \
        --least_significant_bit_first
```

[appveyor]: https://ci.appveyor.com/project/ia0/data-encoding
[appveyor_badge]:https://ci.appveyor.com/api/projects/status/wm4ga69xnlriukhl/branch/master?svg=true
[binary]: https://crates.io/crates/data-encoding-bin
[changelog]: https://github.com/ia0/data-encoding/blob/master/lib/CHANGELOG.md
[coveralls]: https://coveralls.io/github/ia0/data-encoding
[coveralls_badge]: https://coveralls.io/repos/ia0/data-encoding/badge.svg?branch=master&service=github
[documentation]: https://docs.rs/data-encoding
[documentation_badge]: https://docs.rs/data-encoding/badge.svg
[library]: https://crates.io/crates/data-encoding
[license]: https://github.com/ia0/data-encoding/blob/master/LICENSE
[license_badge]: https://img.shields.io/crates/l/data-encoding.svg
[travis]: https://travis-ci.org/ia0/data-encoding
[travis_badge]: https://travis-ci.org/ia0/data-encoding.svg?branch=master
[version_badge]: https://img.shields.io/crates/v/data-encoding.svg
