#!/bin/sh

xargs rm -f < _delList.txt
mkdir -p snd loc img beta/loc beta/img beta/snd

wget -O grab.txt -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "http://orteil.dashnet.org/patreon/grab.php"

wget -O index.html -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "https://orteil.dashnet.org/cookieclicker"

xargs -P 8 -I {} wget -P ./ "https://orteil.dashnet.org/cookieclicker/{}" < _miscList.txt

wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/snd/ | grep -oP '(?<=href=")[^"]+\.mp3' > snd/_sndList.txt
wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/loc/ | grep -oP '(?<=href=")[^"]+\.js' > loc/_locList.txt
wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/img/ | grep -oP '(?<=href=")[^"]+\.(png|jpg|db|gif)' > img/_imgList.txt

xargs -P 8 -a snd/_sndList.txt -I{} wget -O snd/{} "https://orteil.dashnet.org/cookieclicker/snd/{}"
xargs -P 8 -a loc/_locList.txt -I{} wget -O loc/{} "https://orteil.dashnet.org/cookieclicker/loc/{}"
xargs -P 8 -a img/_imgList.txt -I{} wget -O img/{} "https://orteil.dashnet.org/cookieclicker/img/{}"

sed -i '/<!-- ad -->/,/<!-- \/ad -->/d' index.html
sed -i "s|ajax('/patreon/grab.php'|ajax('grab.txt'|" main.js

cd beta/

wget -O index.html -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "https://orteil.dashnet.org/cookieclicker/beta/"

xargs -P 8 -I {} wget -P ./ "https://orteil.dashnet.org/cookieclicker/beta/{}" < ../_miscList.txt

wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/beta/snd/ | grep -oP '(?<=href=")[^"]+\.mp3' > snd/_sndList.txt
wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/beta/loc/ | grep -oP '(?<=href=")[^"]+\.js' > loc/_locList.txt
wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/beta/img/ | grep -oP '(?<=href=")[^"]+\.(png|jpg|db|gif)' > img/_imgList.txt

xargs -P 8 -a snd/_sndList.txt -I{} wget -O snd/{} "https://orteil.dashnet.org/cookieclicker/beta/snd/{}"
xargs -P 8 -a loc/_locList.txt -I{} wget -O loc/{} "https://orteil.dashnet.org/cookieclicker/beta/loc/{}"
xargs -P 8 -a img/_imgList.txt -I{} wget -O img/{} "https://orteil.dashnet.org/cookieclicker/beta/img/{}"

sed -i '/<!-- ad -->/,/<!-- \/ad -->/d' index.html
sed -i "s|ajax('/patreon/grab.php'|ajax('../grab.txt'|" main.js

cd ../

find . -type f ! -path './.git/*' ! -path '/.github*' ! -name 'update.yml' ! -name '_delList.txt' ! -name '_miscList.txt' ! -name 'README.md' ! -iname 'update.sh' > _delList.txt

grep -Eho '["'\''][^/"'\'']+\.(js|css|html)(\?[^"'\''"]*)?["'\'']' $(grep -Fxv '' _delList.txt | grep -E '\.(html|js|css)$') |
grep -Ev '["'\''](https?:|\/\/)' |
sed -E "s/^['\"]//;s/['\"].*//;s/\?.*//" |
grep -v / | sort -u > _miscList.txt
