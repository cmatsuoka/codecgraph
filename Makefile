
DOTTY = dot

# claudio - notebook Claudio Matsuoka
# boiko - notebook Gustavo Boiko
# boto-120l - Dell Latitude 120L Eduardo Habkost
# fbl - notebook Flavio Bruno Leitner
# hp - HP Thomas (DX2200
# hp-samba - HP Samba with autoconfig
# alc861 - alc861 found on the web
# hp-samba-6stack-dig - HP Samba with model=6stack-dig
# hp-samba-6stack-dig-fullvol # HP Samba w/ model=6stack-dig, full volume
# hp-educ.ar # HP educ.ar machine
# alc883 - ALC883 found on the web
# alc882 - ALC882 found on the web

samples = claudio boiko boto-120l fbl \
	 hp hp-samba hp-samba-6stack-dig hp-samba-6stack-dig-fullvol \
	 hp-educ.ar hp-atlantis \
	 alc861 alc882 alc883 \
	 clevo-m540se

psfiles = $(addprefix out/, $(addsuffix .ps, $(samples)))
dotfiles = $(addprefix out/, $(addsuffix .dot, $(samples)))
pngfiles = $(addprefix out/, $(addsuffix .png, $(samples)))


all:


dot: $(dotfiles)
ps: $(psfiles)
png: $(pngfiles)

out:
	mkdir out

thumbs: pngs
	for p in $(pngfiles);do \
		convert -resize 25%x25% $$p codecs/thumb-`basename $$p`; \
	done

out/%.dot: samples/%.txt codecgraph.py out
	python codecgraph.py $< > $@

%.ps: %.dot
	$(DOTTY) -Tps -o $@ $<

%.png: %.dot
	$(DOTTY) -Tpng -o $@ $<


clean:
	rm -f $(psfiles)
	rm -f $(dotfiles)
	rm -f $(pngfiles)
	if [ -d out ];then rmdir out;fi
