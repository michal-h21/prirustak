# Skripty pro práci s XML soubory z ILS Aleph

Tento projekt obsahuje skripty, které používáme pro práci s XML soubory z
Alephu v Knihovně PedF UK. Některé jsou již zastaralé. Hlavní modul je
`parse_prir.lua`, který soubory parsuje. Nejužitečnějčí skript je
`prirtocsv.lua`, který vybere políčka z XML a na output vyhodí TSV pole, které
se pak dají otevřít v tabulkových kalulátorech.

# Instalace

     luarocks make
