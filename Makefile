.PHONY: all

all: \
	krestni-jmena-muzi.names krestni-jmena-muzi.decl \
	krestni-jmena-zeny.names krestni-jmena-zeny.decl \
	randomnames.tex randomnames.sty randomnames.lua

krestni-jmena-%.txt randomnames.%:
	wget https://github.com/Witiko/character-name-generator-for-creative-writing-in-luatex/releases/download/latest/$@

krestni-jmena-%.names krestni-jmena-%.decl: krestni-jmena-%.txt get_data.py
	python3 ./get_data.py $< $(basename $@)
