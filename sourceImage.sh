#!/bin/bash

if [ -z $sourceImage ]; then
sourceImage=$(awk -F "=" '/^sourceImage/ {print $2}' .env.build)
fi

echo $sourceImage
