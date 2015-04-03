# qrcreate

Simple qrencode wrapper on bash

## Just run it

Or you can use one of this options:

`-e` — change qrencode error correction level, possible values are: `L`, `M`, `Q`, `H`. L — lowest, H — highest. Default: `L`

`-m` — set resulting file margin between egde of the file and QR-code itself. Set in pixels, default is `4`

`-f` — set output format, one of PNG,EPS,ANSI,ANSI256, default is `EPS`.

`-c` — set case sensivity, true — do not touch my input, false — IT WILL BE CAPS ALL OVER! Default is `true`