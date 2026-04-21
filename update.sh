#!/bin/sh

xargs rm -f < _delList.txt
mkdir -p snd loc img beta/loc beta/img beta/snd

wget -O grab.txt -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "http://orteil.dashnet.org/patreon/grab.php"
wget -O index.html -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "https://orteil.dashnet.org/cookieclicker"
sed -i '/<!-- ad -->/,/<!-- \/ad -->/d' index.html

for i in 1 2; do
	grep -hoE "[\"'][^/\"']+\.(js|css|html)([?][^\"']+)?[\"']" index.html *.js *.css 2>/dev/null | sed "s/[\"']//g;s/[?].*//" | sort -u > _miscList.txt
	xargs -P 8 -I {} wget -nc "https://orteil.dashnet.org/cookieclicker/{}" < _miscList.txt
done

sed -i "s|ajax('/patreon/grab.php'|ajax('grab.txt'|" main.js

wget -O- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/snd/ | grep -oP '(?<=href=")[^"]+\.mp3' > snd/_sndList.txt
wget -O- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/loc/ | grep -oP '(?<=href=")[^"]+\.js' > loc/_locList.txt
wget -O- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/img/ | grep -oP '(?<=href=")[^"]+\.(png|jpg|db|gif)' > img/_imgList.txt

xargs -P 8 -a snd/_sndList.txt -I{} wget -O snd/{} "https://orteil.dashnet.org/cookieclicker/snd/{}"
xargs -P 8 -a loc/_locList.txt -I{} wget -O loc/{} "https://orteil.dashnet.org/cookieclicker/loc/{}"
xargs -P 8 -a img/_imgList.txt -I{} wget -O img/{} "https://orteil.dashnet.org/cookieclicker/img/{}"

cd beta/

wget -O index.html -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "https://orteil.dashnet.org/cookieclicker/beta/"
sed -i '/<!-- ad -->/,/<!-- \/ad -->/d' index.html

cd ../

for i in 1 2; do
	grep -hoE "[\"'][^/\"']+\.(js|css|html)([?][^\"']+)?[\"']" beta/index.html beta/*.js beta/*.css 2>/dev/null | sed "s/[\"']//g;s/[?].*//" | sort -u > _miscList.txt
	cd beta/
	xargs -P 8 -I {} wget -nc "https://orteil.dashnet.org/cookieclicker/beta/{}" < ../_miscList.txt
	cd ../
done

cd beta/

sed -i "s|ajax('/patreon/grab.php'|ajax('../grab.txt'|" main.js

wget -O- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/beta/snd/ | grep -oP '(?<=href=")[^"]+\.mp3' > snd/_sndList.txt
wget -O- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/beta/loc/ | grep -oP '(?<=href=")[^"]+\.js' > loc/_locList.txt
wget -O- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/beta/img/ | grep -oP '(?<=href=")[^"]+\.(png|jpg|db|gif)' > img/_imgList.txt

xargs -P 8 -a snd/_sndList.txt -I{} wget -O snd/{} "https://orteil.dashnet.org/cookieclicker/beta/snd/{}"
xargs -P 8 -a loc/_locList.txt -I{} wget -O loc/{} "https://orteil.dashnet.org/cookieclicker/beta/loc/{}"
xargs -P 8 -a img/_imgList.txt -I{} wget -O img/{} "https://orteil.dashnet.org/cookieclicker/beta/img/{}"

cd ../

find . -type f ! -path './.git/*' ! -path '/.github*' ! -name 'update.yml' ! -name '_delList.txt' ! -name '_miscList.txt' ! -name 'README.md' ! -iname 'update.sh' -regex '.*\.\(html\|js\|css\)$' -exec grep -hoE "[\"'][^/\"']+\.(js|css|html)([?][^\"']+)?[\"']" {} \; | sed "s/[\"']//g;s/[?].*//" | sort -u > _miscList.txt
find . -type f ! -path './.git/*' ! -path '/.github*' ! -name 'update.yml' ! -name '_delList.txt' ! -name '_miscList.txt' ! -name 'README.md' ! -iname 'update.sh' > _delList.txt
