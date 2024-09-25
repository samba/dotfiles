#1/bin/bash

for i in {0..255}; do
    printf '\x1b[38;5;%dmcolour%d\x1b[0m\n' $i $i
done | sed -E 'N; N; N;   s@\n@ @g; '

