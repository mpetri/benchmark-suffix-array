#!/bin/bash

make all

#files="english.200MB dna.200MB"
files="english.200MB"
#psi_samples="32 64 128 256"
psi_samples="32 256"

for file in $files; do
    echo $file
    ln -s `pwd`/../../data/$file 
    for psi_sample in $psi_samples; do
        echo $psi_sample
        filename="$file.$psi_sample"
        echo $filename
        ./build_index $file dummy "filename=$filename;samplerate=1048576;samplepsi=$psi_sample"

        ./run_queries $filename C < files.pat >> res.txt
    done
done
