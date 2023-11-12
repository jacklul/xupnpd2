#!/bin/bash
#shellcheck disable=SC2086,SC2016,SC2115,SC1090

[ -z "$GITHUB_WORKSPACE" ] && exit 1
cd "$GITHUB_WORKSPACE" || exit 1

ARTIFACTS_DIR="$1"

[ -z "$ARTIFACTS_DIR" ] && { echo "ARTIFACTS_DIR is not set"; exit 1; }
[ -z "$UPLOAD_BRANCHES" ] && { echo "UPLOAD_BRANCHES is not set"; exit 1; }

echo "ARTIFACTS_DIR=$ARTIFACTS_DIR"
echo "UPLOAD_BRANCHES=$UPLOAD_BRANCHES"

###################

set -e

echo "Moving artifacts..."

for BRANCH in $UPLOAD_BRANCHES; do
    find "$ARTIFACTS_DIR" -type f -name "*-$BRANCH-*.tar.gz*" -exec mv -f {} . \;
done

echo "Filtering files..."

for FILE in *.tar.gz; do
    [ ! -f "$FILE" ] && continue

    FOUND=false

    for BRANCH in $UPLOAD_BRANCHES; do
        basename "$FILE" | grep -q "\-$BRANCH\-" && FOUND=true && break
    done

    [ "$FOUND" = false ] && rm -fv "$FILE" "$FILE.meta"
done

echo "Cleaning up work directory..."

find . -maxdepth 1 -type d -not -name ".git" -not -name "." -exec rm -frv {} \;

echo "Creating index.html..."

echo "<h2>Latest binaries for <a href="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY">$GITHUB_SERVER_URL/$GITHUB_REPOSITORY</a></h2>" > index.html

for BRANCH in $UPLOAD_BRANCHES; do
    echo "<h3>\"$BRANCH\" branch:</h3>" >> index.html
    echo "<ul>" >> index.html

    for FILE in *"-$BRANCH-"*.tar.gz; do
        [ ! -f "$FILE" ] && continue

        SIZE=
        DATE=
        [ -f "$FILE.meta" ] && . "$FILE.meta"

        if [ -n "$SIZE" ] && [ -n "$DATE" ]; then
            DATE="$(date '+%F %T' -d "@$DATE")"
            SIZE="$(echo "$SIZE" | numfmt --to=iec --suffix=B --format="%2.2f")"

            echo -e "<li><a href=\"$(basename $FILE)\">$(basename $FILE)</a> &#8212; <i><b>$DATE, $SIZE</b><br>(SHA256: $(sha256sum $FILE | awk '{print $1}'))</i></li>" >> index.html
        else
            echo -e "<li><a href=\"$(basename $FILE)\">$(basename $FILE)</a> &#8212; <i>($(sha256sum $FILE | awk '{print $1}'))</i></li>" >> index.html
        fi
    done

    echo "</ul>" >> index.html
done

cat index.html
ls -al .

echo "Done"
