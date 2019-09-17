#!/usr/bin/env bash
#
# Converts Excel xlsx files to csv files.
# Each sheet will be converted to its own file.
#

set -eo pipefail

programname=$0

usage() {
  echo "usage: $programname [-f infile] [-o outfolder]"
  echo "  -h      display help"
  echo "  -f infile     specify input file infile"
  echo "  -o outfolder  specify output folder"
  exit 1
}

while getopts ":f:o:" o; do
  case "${o}" in
  f)
    input_file=${OPTARG}
    ;;
  o)
    output_directory=${OPTARG}
    ;;
  *)
    usage
    ;;
  esac
done

shift $((OPTIND-1))

if [ -z "${input_file}" ] || [ -z "${output_directory}" ]; then
    usage
fi


basename=${input_file##*/}
ssconvert -S "${input_file}" "${output_directory}/${basename%.*}-%s.csv"
