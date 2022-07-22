#!/bin/bash
filename=''
output=''
start='0'
time='10'
width='640'

usage()
{
    echo "usage: gif_gen.sh [[[-f file ] [-o output]  [-s start=0]  [-t time=10] [-w width=640]] | [-h]]"
}

while [ "$1" != "" ]; do
    case $1 in
        -f | --file )           shift
                                filename=$1
                                ;;
        -o | --output )         shift
                                output=$1
                                ;;
        -s | --start )          shift
                                start=$1
                                ;;
        -t | --time )           shift
                                time=$1
                                ;;
        -w | --width )          shift
                                width=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ "$filename" = "" ] || [ "$output" = ""]; then
    echo "must specify filename and output"
    usage
    exit 1
fi


ffmpeg -y -ss $start -t $time -i $filename \
-vf fps=10,scale=$width:-1:flags=lanczos,palettegen palette.png

ffmpeg -ss $start -t $time -i $filename -i palette.png -filter_complex \
"fps=10,scale=$width:-1:flags=lanczos[x];[x][1:v]paletteuse" $output

rm palette.png
