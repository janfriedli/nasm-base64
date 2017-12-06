# Algorithm

## Up and running
1. Clone this repo
2. run make
3. ./encode
4. ./decode

## Encoding
1. Read 6 byte of stdin
2. Match the decimal representation of these 6 bites to the corresponding char
using the given map
3. Loop 2. until we reached the end of file
4. If the number of bytes isn't dividable by 6 use "=" to indicate added zeros
5. Give out the new string o stdout


## Decoding
Do the reverse
