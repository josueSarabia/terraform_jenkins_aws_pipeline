#!/bin/bash
awk -v old="$1" -v new="$2" '{
    sub(old,new)
}1' $3 > temp.txt && mv temp.txt $3
