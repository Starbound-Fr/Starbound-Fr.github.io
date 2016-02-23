#!/bin/bash
mkdir temp -p

find wp-content/uploads -type f | sort -V > temp/unfiltred.txt
find wp-content/uploads -type f | grep "[0-9]\{1,5\}x[0-9]\{1,5\}" | sort -V > temp/filtred.txt

rm temp/veryfiltred.txt
for line in $(cat temp/unfiltred.txt); do
    withoutext="${line%.*}"
    echo $withoutext
    grep "${withoutext}-[0-9]\{1,5\}x[0-9]\{1,5\}" temp/unfiltred.txt >> temp/veryfiltred.txt
done

yes no | rm -vi $(cat temp/veryfiltred.txt | tr '\n' ' ')

# diff temp/unfiltred.txt temp/filtred.txt