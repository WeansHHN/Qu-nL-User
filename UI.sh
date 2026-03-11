#!/bin/bash

echo "Installing TV UI..."

sudo apt update
sudo apt install -y chromium xorg openbox lightdm unclutter ir-keytable

mkdir -p ~/.tvui

cat << 'EOF' > ~/.tvui/index.html
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>

body{
background:#111;
color:white;
font-family:sans-serif;
display:flex;
flex-direction:column;
align-items:center;
justify-content:center;
height:100vh;
margin:0;
}

.grid{
display:grid;
grid-template-columns:repeat(3,200px);
gap:30px;
}

.app{
background:#222;
border-radius:20px;
padding:40px;
text-align:center;
font-size:22px;
cursor:pointer;
}

.app:focus{
outline:3px solid #4CAF50;
}

</style>
</head>

<body>

<h1>TV BOX</h1>

<div class="grid">

<div tabindex="1" class="app" onclick="launch('kodi')">Kodi</div>
<div tabindex="2" class="app" onclick="launch('youtube')">YouTube</div>
<div tabindex="3" class="app" onclick="launch('browser')">Browser</div>
<div tabindex="4" class="app" onclick="launch('files')">Files</div>
<div tabindex="5" class="app" onclick="launch('settings')">Settings</div>

</div>

<script>

/* ---- remote support ---- */

document.addEventListener("keydown",function(e){

if(e.key==="Enter"){
document.activeElement.click()
}

if(e.key==="ArrowRight"){
moveFocus(1)
}

if(e.key==="ArrowLeft"){
moveFocus(-1)
}

})

function moveFocus(step){

let items=document.querySelectorAll(".app")
let index=Array.from(items).indexOf(document.activeElement)

let next=index+step

if(next>=0 && next<items.length){
items[next].focus()
}

}

/* ---- launcher placeholder ---- */

function launch(app){

if(app==="browser"){
window.location.href="https://youtube.com"
}

}

</script>

</body>
</html>
EOF


cat << 'EOF' > ~/.tvui/start.sh
#!/bin/bash

xset s off
xset -dpms
xset s noblank

unclutter &

chromium \
--kiosk \
--noerrdialogs \
--disable-infobars \
~/.tvui/index.html
EOF

chmod +x ~/.tvui/start.sh

mkdir -p ~/.config/openbox

cat << 'EOF' >> ~/.config/openbox/autostart

xset s off
xset -dpms
xset s noblank

~/.tvui/start.sh &

EOF

echo "Install complete."
echo "Reboot to start TV UI."
