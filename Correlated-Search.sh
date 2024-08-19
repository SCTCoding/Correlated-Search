# A little reverse engineering tool for using ripgrep to do correlative searches.
# Copyright (C) 2024 Simon Carlson-Thies
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

#! /bin/bash

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

A tool for reverse engineering. Specify multiple searches and then using ripgrep correlate those searches to
find all files that contain all of those terms. This tool is built off of ripgrep so be sure you have that.

NOTE
This tool will not work with regex searches. Additionally the ripgrep options are -luuui statically defined.
Furthermore, there is no real progress output so this may take a while and show no evidence that it is working.

Options:
  -r <path_to_ripgrep>   Path to the ripgrep binary. (Required)
  -p <path_to_search>    Directory path to search within. WITHOUT the trailing / or * (Required)
  -s '<searches>'        Comma-separated list of search terms. (Required)
                         Example: 'term1, term2' BE SURE: to quote strings with spaces.
  -o <output_file>       Path to the output file where results will be saved. (Required)
  -h                     Display this help message and exit.

Examples:
  $(basename "$0") -r "/usr/local/bin/" -p /home/user/documents -s 'foo, bar, baz' -o ~/Desktop/output.txt
  This command searches for files in '/home/user/documents' containing all terms 'foo', 'bar', and 'baz',
  and writes the list of matching files to '~/Desktop/output.txt'.

EOF
  exit 1
}

while getopts 'r:p:s:o:h' OPTION; do
  case "$OPTION" in
    r)
      rgPath="$OPTARG"
      ;;
    p)
      sPath="$OPTARG"
      ;;
    s)
      search="$OPTARG"
      ;;
    o)
      output="$OPTARG"
      ;;
    h)
      usage
      ;;
  esac
done


if [[ ! -e "$rgPath" ]]
then
	echo "Couldn't find ripgrep at this path."
	exit 1
fi


if [[ ! $(echo "$rgPath" | grep -E '/$') ]]
then
	rgPath=$(echo "${rgPath}/")
fi

IFS=',' read -r -a searchArray <<< "$search"

for s in "${searchArray[@]}"
do
	"${rgPath}"rg -luuui  "$s" "${sPath}"/* >> /tmp/searchesInitial.txt
done

#cat "/tmp/searchesInitial.txt" | sort | uniq -d >> "$output"

cat "/tmp/searchesInitial.txt" | sort | uniq -c | awk -v reps="${#searchArray[@]}" '$1 >= reps {print $2}' >> "$output"

#cat "/tmp/searchesInitial.txt" | awk -v reps="${#searchArray[@]}" '{ count[$0]++ } END { for (file in count) if (count[file] >= reps) print file }' > "$output"

rm "/tmp/searchesInitial.txt"

exit 0
