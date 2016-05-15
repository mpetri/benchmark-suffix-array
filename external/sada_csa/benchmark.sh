#!/bin/bash

make all

files="english.200MB dna.200MB dblp.xml.200MB proteins.200MB"
#files="english.200MB"
#psi_samples="32 64 128 256"
psi_samples="32 64 128 256"

for file in $files; do
    echo $file
    ln -s `pwd`/../../data/$file 
    for psi_sample in $psi_samples; do
        echo $psi_sample
        filename="$file.$psi_sample"
        echo $filename
        if [ ! -e $filename.idx ]; then 
            echo "build index"
            ./build_index $file dummy "filename=$filename;samplerate=1048576;samplepsi=$psi_sample"
        fi
        ../../build/pat2pizzachili.x ../../build/patterns/${file}.sdsl > ${file}.pat
        
        ./run_queries $filename C < ${file}.pat >> res.txt
    done
done
