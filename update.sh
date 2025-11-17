#!/bin/sh

# Total steps for progress calculation
TOTAL_STEPS=23
CURRENT_STEP=0

progress() {
	CURRENT_STEP=$((CURRENT_STEP + 1))
	PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
	FILLED=$((PERCENT / 5))
	EMPTY=$((20 - FILLED))
	printf "\r[%${FILLED}s%${EMPTY}s] %d%% - %s" | tr ' ' '=' | sed "s/=/ /g; s/^/[/; s/$PERCENT%/]$PERCENT%/"
	printf "\r["
	printf "%${FILLED}s" | tr ' ' '='
	printf "%${EMPTY}s" | tr ' ' ' '
	printf "] %d%% - %s\n" "$PERCENT" "$1"
}

progress "Cleaning up old files and creating directories"
xargs rm -f < _delList.txt
mkdir -p snd loc img beta/loc beta/img beta/snd

progress "Downloading grab.txt"
wget -qO grab.txt -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "http://orteil.dashnet.org/patreon/grab.php"

progress "Downloading index.html"
wget -qO index.html -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "https://orteil.dashnet.org/cookieclicker"

progress "Patching index.html"
sed -i '/<!-- ad -->/,/<!-- \/ad -->/d' index.html

for i in 1 2; do
	progress "Downloading main assets (pass $i)"
	grep -hoE "[\"'][^/\"']+\.(js|css|html)([?][^\"']+)?[\"']" index.html *.js *.css 2>/dev/null | sed "s/[\"']//g;s/[?].*//" | sort -u > _miscList.txt
	xargs -P 8 -I {} wget -qnc "https://orteil.dashnet.org/cookieclicker/{}" < _miscList.txt
done

progress "Patching main.js"
sed -i "s|ajax('/patreon/grab.php'|ajax('grab.txt'|" main.js

progress "Generating main file lists"
wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/snd/ | grep -oP '(?<=href=")[^"]+\.mp3' > snd/_sndList.txt
wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/loc/ | grep -oP '(?<=href=")[^"]+\.js' > loc/_locList.txt
wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/img/ | grep -oP '(?<=href=")[^"]+\.(png|jpg|db|gif)' > img/_imgList.txt

progress "Downloading main sounds"
xargs -P 8 -a snd/_sndList.txt -I{} wget -qO snd/{} "https://orteil.dashnet.org/cookieclicker/snd/{}"

progress "Downloading main localizations"
xargs -P 8 -a loc/_locList.txt -I{} wget -qO loc/{} "https://orteil.dashnet.org/cookieclicker/loc/{}"

progress "Downloading main images"
xargs -P 8 -a img/_imgList.txt -I{} wget -qO img/{} "https://orteil.dashnet.org/cookieclicker/img/{}"

cd beta/

progress "Downloading beta index.html"
wget -qO index.html -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "https://orteil.dashnet.org/cookieclicker/beta/"

progress "Patching beta index.html"
sed -i '/<!-- ad -->/,/<!-- \/ad -->/d' index.html

cd ../

for i in 1 2; do
	progress "Downloading beta assets (pass $i)"
	grep -hoE "[\"'][^/\"']+\.(js|css|html)([?][^\"']+)?[\"']" beta/index.html beta/*.js beta/*.css 2>/dev/null | sed "s/[\"']//g;s/[?].*//" | sort -u > _miscList.txt
	cd beta/
	xargs -P 8 -I {} wget -qnc "https://orteil.dashnet.org/cookieclicker/beta/{}" < ../_miscList.txt
	cd ../
done

cd beta/

progress "Patching beta main.js"
sed -i "s|ajax('/patreon/grab.php'|ajax('../grab.txt'|" main.js

progress "Generating beta file lists"
wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/beta/snd/ | grep -oP '(?<=href=")[^"]+\.mp3' > snd/_sndList.txt
wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/beta/loc/ | grep -oP '(?<=href=")[^"]+\.js' > loc/_locList.txt
wget -qO- -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://orteil.dashnet.org/cookieclicker/beta/img/ | grep -oP '(?<=href=")[^"]+\.(png|jpg|db|gif)' > img/_imgList.txt

progress "Downloading beta sounds"
xargs -P 8 -a snd/_sndList.txt -I{} wget -qO snd/{} "https://orteil.dashnet.org/cookieclicker/beta/snd/{}"

progress "Downloading beta localizations"
xargs -P 8 -a loc/_locList.txt -I{} wget -qO loc/{} "https://orteil.dashnet.org/cookieclicker/beta/loc/{}"

progress "Downloading beta images"
xargs -P 8 -a img/_imgList.txt -I{} wget -qO img/{} "https://orteil.dashnet.org/cookieclicker/beta/img/{}"

cd ../

# Final update: scan all downloaded files and update _miscList.txt
progress "Updating _miscList.txt"
find . -type f ! -path './.git/*' ! -path '/.github*' ! -name 'update.yml' ! -name '_delList.txt' ! -name '_miscList.txt' ! -name 'README.md' ! -iname 'update.sh' -regex '.*\.\(html\|js\|css\)$' -exec grep -hoE "[\"'][^/\"']+\.(js|css|html)([?][^\"']+)?[\"']" {} \; | sed "s/[\"']//g;s/[?].*//" | sort -u > _miscList.txt

progress "Updating _delList.txt"
find . -type f ! -path './.git/*' ! -path '/.github*' ! -name 'update.yml' ! -name '_delList.txt' ! -name '_miscList.txt' ! -name 'README.md' ! -iname 'update.sh' > _delList.txt

progress "Complete"
