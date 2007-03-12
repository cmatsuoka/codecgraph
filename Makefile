
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

codecs = claudio boiko boto-120l fbl \
	 hp hp-samba hp-samba-6stack-dig hp-samba-6stack-dig-fullvol \
	 hp-educ.ar hp-atlantis \
	 alc861 alc882 alc883 \
	 clevo-m540se

allnames = $(addprefix codecs/, $(codecs))

psfiles = $(addsuffix .ps, $(allnames))
dotfiles = $(addsuffix .dot, $(allnames))
pngfiles = $(addsuffix .png, $(allnames))


all:


dot: $(dotfiles)
ps: $(psfiles)
png: $(pngfiles)

thumbs: pngs
	for p in $(pngfiles);do \
		convert -resize 25%x25% $$p codecs/thumb-`basename $$p`; \
	done

%.dot: %.txt codecgraph.py
	python codecgraph.py $< > $@

%.ps: %.dot
	$(DOTTY) -Tps -o $@ $<

%.png: %.dot
	$(DOTTY) -Tpng -o $@ $<


clean:
	rm -f $(psfiles)
	rm -f $(dotfiles)
	rm -f $(pngfiles)
