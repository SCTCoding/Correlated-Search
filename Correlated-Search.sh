#! /bin/bash

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
      echo "-r path to ripgrep binary -p path to search with /* -s searches in single quotes with , and space between different searches -o for output location and name of output file -h brings up this help text"
      exit 0
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
	"${rgPath}"rg -luuui  "$s" ${sPath}/* >> /tmp/searchesInitial.txt
done

#cat "/tmp/searchesInitial.txt" | sort | uniq -d >> "$output"

cat "/tmp/searchesInitial.txt" | sort | uniq -c | awk -v reps="${#searchArray[@]}" '$1 >= reps {print $2}' >> "$output"

rm "/tmp/searchesInitial.txt"

exit 0