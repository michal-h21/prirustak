local navigace = [[
<!DOCTYPE html>
<html>
<head>
<meta charset = "utf-8" />
<title>Menu konspektu</title>
<link rel="stylesheet" type="text/css" href="nove.css" />
<base target="jin"/>
</head>
<body>
<nav>
<h1>Tematická mapa fondu</h1>
<div class='konspekt' id='konspekt-1'><a href='{{doc}}#konspekt-1'>1. Antropologie, etnografie</a></div>
 <div class='konspekt' id='konspekt-2'><a href='{{doc}}#konspekt-2'>2. Biologické vědy</a></div>
 <div class='konspekt' id='konspekt-3'><a href='{{doc}}#konspekt-3'>3. Divadlo, film, tanec</a></div>
 <div class='konspekt' id='konspekt-4'><a href='{{doc}}#konspekt-4'>4. Ekonomické vědy, obchod</a></div>
 <div class='konspekt' id='konspekt-5'><a href='{{doc}}#konspekt-5'>5. Filozofie a náboženství</a></div>
 <div class='konspekt' id='konspekt-6'><a href='{{doc}}#konspekt-6'>6. Fyzika a příbuzné vědy</a></div>
 <div class='konspekt' id='konspekt-7'><a href='{{doc}}#konspekt-7'>7. Geografie. Geologie. Vědy o zemi</a></div>
 <div class='konspekt' id='konspekt-8'><a href='{{doc}}#konspekt-8'>8. Historie a pomocné historické vědy. Biografické studie</a></div>
 <div class='konspekt' id='konspekt-9'><a href='{{doc}}#konspekt-9'>9. Hudba</a></div>
 <div class='konspekt' id='konspekt-10'><a href='{{doc}}#konspekt-10'>10. Chemie. Krystalografie. Mineralogické vědy</a></div>
 <div class='konspekt' id='konspekt-11'><a href='{{doc}}#konspekt-11'>11. Jazyk, lingvistika, literární věda</a></div>
 <div class='konspekt' id='konspekt-12'><a href='{{doc}}#konspekt-12'>12. Knihovnictví, informatika, všeobecné, referenční literatura</a></div>
 <div class='konspekt' id='konspekt-13'><a href='{{doc}}#konspekt-13'>13. Matematika</a></div>
 <div class='konspekt' id='konspekt-14'><a href='{{doc}}#konspekt-14'>14. Lékařství</a></div>
 <div class='konspekt' id='konspekt-15'><a href='{{doc}}#konspekt-15'>15. Politické vědy (Politologie, politika, veřejná správa, vojenství)</a></div>
 <div class='konspekt' id='konspekt-16'><a href='{{doc}}#konspekt-16'>16. Právo</a></div>
 <div class='konspekt' id='konspekt-17'><a href='{{doc}}#konspekt-17'>17. Psychologie</a></div>
 <div class='konspekt' id='konspekt-18'><a href='{{doc}}#konspekt-18'>18. Sociologie</a></div>
 <div class='konspekt' id='konspekt-19'><a href='{{doc}}#konspekt-19'>19. Technika, technologie, inženýrství</a></div>
 <div class='konspekt' id='konspekt-20'><a href='{{doc}}#konspekt-20'>20. Tělesná výchova a sport. Rekreace</a></div>
 <div class='konspekt' id='konspekt-21'><a href='{{doc}}#konspekt-21'>21. Umění, architektura, muzeologie</a></div>
 <div class='konspekt' id='konspekt-22'><a href='{{doc}}#konspekt-22'>22. Výchova a vzdělávání</a></div>
 <div class='konspekt' id='konspekt-23'><a href='{{doc}}#konspekt-23'>23. Výpočetní technika</a></div>
 <div class='konspekt' id='konspekt-24'><a href='{{doc}}#konspekt-24'>24. Zemědělství</a></div>
 <div class='konspekt' id='konspekt-25'><a href='{{doc}}#konspekt-25'>25. Beletrie</a></div>
 </nav>
 </body>
 </html>
]]

local input = arg[1]
local output = navigace:gsub("{{doc}}",input)
print(output)
