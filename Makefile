
DOTTY = dot

# Sample codec file collection:
#
# claudio - notebook Claudio Matsuoka
# boiko - notebook Gustavo Boiko
# boto-120l - Dell Latitude 120L
# fbl - notebook Flavio Bruno Leitner
# hp-dx2200 - HP Thomas (DX2200)
# hp-samba - HP Samba with autoconfig
# hp-atlantis - HP Atlantis notebook
# alc861 - alc861 found on the web
# hp-educ.ar - HP educ.ar machine
# alc883 - ALC883 found on the web
# alc882 - ALC882 found on the web
# alc888 - ALC888 on a SiS development board
# clevo-m540se - Clevo m540se notebook

samples = claudio boiko dell-latitude-120l fbl \
	 hp-dx2200 hp-samba \
	 hp-educ.ar hp-atlantis \
	 alc861 alc882 alc883 alc888 \
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
