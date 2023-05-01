# Model pro automatické skloňování českých jmen v LuaTeXu

Tento repositář obsahuje kód pro automatické skloňování českých jmen v LuaTeXu,
který vznikl pro účely článku [*Nápadovník jmen postav pro tvůrčí psaní v
LuaTeXu*][1].

Pro spuštění kódu potřebujeme programy GNU Make, `wget`, Python 3 a TeX Live:

``` bash
$ sudo apt update
$ sudo apt install make wget python3 texlive-full
```

Nejprve si stáhneme seznam českých jmen mužů a žen ze serveru rodina.cz
do souborů [`krestni-jmena-zeny.tex`][6] a [`krestni-jmena-muzi.tex`][7]:

``` bash
$ make krestni-jmena-zeny.tex
$ make krestni-jmena-muzi.tex
```

Následně si nainstalujeme potřebné pythonové balíčky a na základě seznamu
jmen sestavíme pomocí serveru sklonuj.cz pravidla pro skloňování, která
uložíme do souborů [`krestni-jmena-zeny.decl`][2],
[`krestni-jmena-zeny.names`][3], [`krestni-jmena-muzi.decl`][4],
[`krestni-jmena-muzi.names`][5].

``` bash
$ python3 -m pip install -r requirements.txt
$ make krestni-jmena-zeny.decl krestni-jmena-zeny.names
$ make krestni-jmena-muzi.decl krestni-jmena-muzi.names
```

Dále si stáhneme soubory [`randomnames.lua`][10], [`randomnames.tex`][11] a
[`randomnames.sty`][12] s balíčkem pro generování jmen příběhových postav,
který jsme v vyvinuli v článku *Nápadovník jmen postav pro tvůrčí psaní v
LuaTeXu*:

``` bash
$ make randomnames.lua randomnames.tex randomnames.sty
```

Nakonec si vysázíme ukázkový dokument [`example.tex`][8] pomocí LuaTeXu:

``` bash
$ latexmk -lualatex example.tex
```

Vznikne nám PDF dokument [`example.pdf`][9] s následujícím textem:

> Když se setkali na výstavě psů, Romand a Lornélie si okamžitě uvědomili, že
> se už nikdy nebudou chtít rozloučit. Lornélie si uvědomila, že bez Romanda
> nechce žít. Romand si ve stejný okamžik uvědomil, že s Lornélií chce žít
> navždy.

 [1]:  https://github.com/witiko/character-name-generator-for-creative-writing-in-luatex
 [2]:  https://github.com/xvrabcov/declension_names/releases/download/krestni-jmena-zeny.decl
 [3]:  https://github.com/xvrabcov/declension_names/releases/download/krestni-jmena-zeny.names
 [4]:  https://github.com/xvrabcov/declension_names/releases/download/krestni-jmena-muzi.decl
 [5]:  https://github.com/xvrabcov/declension_names/releases/download/krestni-jmena-muzi.names
 [6]:  https://github.com/witiko/character-name-generator-for-creative-writing-in-luatex/releases/download/krestni-jmena-zeny.tex
 [7]:  https://github.com/witiko/character-name-generator-for-creative-writing-in-luatex/releases/download/krestni-jmena-muzi.tex
 [8]:  https://github.com/xvrabcov/declension_names/blob/example/example.tex
 [9]:  https://github.com/xvrabcov/declension_names/releases/download/example.pdf
 [10]: https://github.com/witiko/character-name-generator-for-creative-writing-in-luatex/releases/download/latest/randomnames.lua
 [11]: https://github.com/witiko/character-name-generator-for-creative-writing-in-luatex/releases/download/latest/randomnames.tex
 [12]: https://github.com/witiko/character-name-generator-for-creative-writing-in-luatex/releases/download/latest/randomnames.sty
