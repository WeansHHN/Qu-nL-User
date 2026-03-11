#!/bin/bash

echo "Installing TV UI..."

sudo apt update
sudo apt install -y chromium xorg openbox xinit unclutter ir-keytable pcmanfm network-manager python3

mkdir -p ~/.tvui

# ---------------- UI ----------------

cat << 'EOF' > ~/.tvui/index.html
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">

<style>

body{
background:#0f1116;
color:white;
font-family:Arial;
margin:0;
height:100vh;
display:flex;
flex-direction:column;
align-items:center;
justify-content:center;
}

h1{
margin-bottom:40px;
font-weight:400;
}

.grid{
display:grid;
grid-template-columns:repeat(5,180px);
gap:30px;
}

.app{
background:#1a1d25;
border-radius:18px;
padding:35px;
text-align:center;
font-size:20px;
cursor:pointer;
transition:0.2s;
}

.app:hover{
background:#2a2f3a;
}

.app:focus{
outline:none;
background:#4CAF50;
}

</style>

</head>

<body>

<h1>TV Launcher</h1>

<div class="grid">

<div tabindex="0" class="app" onclick="launch('kodi')">Kodi</div>
<div tabindex="1" class="app" onclick="launch('youtube')">YouTube</div>
<div tabindex="2" class="app" onclick="launch('browser')">Browser</div>
<div tabindex="3" class="app" onclick="launch('files')">Files</div>
<div tabindex="4" class="app" onclick="launch('wifi')">WiFi</div>
<div tabindex="5" class="app" onclick="launch('language')">Language</div>

</div>

<script>

let items = document.querySelectorAll(".app")
let current = 0
items[current].focus()

document.addEventListener("keydown", function(e){

if(e.key==="ArrowRight"){ move(1) }
if(e.key==="ArrowLeft"){ move(-1) }
if(e.key==="ArrowDown"){ move(5) }
if(e.key==="ArrowUp"){ move(-5) }

if(e.key==="Enter"){
items[current].click()
}

})

function move(step){

let next=current+step

if(next>=0 && next<items.length){
current=next
items[current].focus()
}

}

function launch(app){

if(app==="youtube"){
window.location.href="/youtube"
}

if(app==="wifi"){
fetch("/wifi")
}

if(app==="language"){
fetch("/language")
}

if(app==="browser"){
window.location.href="https://google.com"
}

}

</script>

</body>
</html>
EOF


# ---------------- YOUTUBE ----------------

cat << 'EOF' > ~/.tvui/youtube.sh
#!/bin/bash

chromium \
--app=https://www.youtube.com/tv \
--user-agent="Mozilla/5.0 (SMART-TV; Linux; Tizen 6.0)" \
--start-maximized \
--disable-translate \
--disable-sync \
--no-first-run \
--enable-gpu \
--ignore-gpu-blocklist
EOF

chmod +x ~/.tvui/youtube.sh


# ---------------- WIFI SCRIPT ----------------

cat << 'EOF' > ~/.tvui/wifi.sh
#!/bin/bash
xterm -e nmtui
EOF

chmod +x ~/.tvui/wifi.sh


# ---------------- LANGUAGE SCRIPT ----------------

cat << 'EOF' > ~/.tvui/language.sh
#!/bin/bash
sudo dpkg-reconfigure locales
EOF

chmod +x ~/.tvui/language.sh


# ---------------- API SERVER ----------------

cat << 'EOF' > ~/.tvui/server.py
import http.server
import socketserver
import subprocess
import os

PORT = 7777

class Handler(http.server.SimpleHTTPRequestHandler):

    def do_GET(self):

        if self.path == "/youtube":
            subprocess.Popen([os.path.expanduser("~/.tvui/youtube.sh")])
            self.send_response(200)
            self.end_headers()
            return

        if self.path == "/wifi":
            subprocess.Popen([os.path.expanduser("~/.tvui/wifi.sh")])
            self.send_response(200)
            self.end_headers()
            return

        if self.path == "/language":
            subprocess.Popen([os.path.expanduser("~/.tvui/language.sh")])
            self.send_response(200)
            self.end_headers()
            return

        return http.server.SimpleHTTPRequestHandler.do_GET(self)

os.chdir(os.path.expanduser("~/.tvui"))
socketserver.TCPServer(("", PORT), Handler).serve_forever()
EOF


# ---------------- START SCRIPT ----------------

cat << 'EOF' > ~/.tvui/start.sh
#!/bin/bash

xset s off
xset -dpms
xset s noblank

unclutter &

python3 ~/.tvui/server.py &

chromium \
--kiosk \
--noerrdialogs \
--disable-infobars \
--disable-session-crashed-bubble \
--disable-translate \
--disable-sync \
--disable-extensions \
--disable-features=TranslateUI \
--no-first-run \
--fast \
--enable-gpu \
--ignore-gpu-blocklist \
--enable-zero-copy \
http://localhost:7777/index.html
EOF

chmod +x ~/.tvui/start.sh


# ---------------- OPENBOX ----------------

mkdir -p ~/.config/openbox

cat << 'EOF' > ~/.config/openbox/autostart

xset s off
xset -dpms
xset s noblank

~/.tvui/start.sh &

EOF


# ---------------- AUTO START X ----------------

cat << 'EOF' > ~/.xinitrc
openbox-session
EOF


cat << 'EOF' >> ~/.bash_profile

if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
startx
fi

EOF


echo "================================"
echo "TV UI installed successfully!"
echo "Reboot to start launcher."
echo "================================"
