
DOTTY = dot

# Sample codec file collection:
#
# lg-lw20 - notebook Claudio Matsuoka
# asus-w5f - notebook Gustavo Boiko
# dell-latitude-120l - notebook boto
# dell-latitude-d520 - notebook Flavio Bruno Leitner
# hp-dx2200 - HP Thomas
# hp-dx2250 - HP educ.ar
# hp-samba - HP Samba with autoconfig
# hp-atlantis - HP Atlantis notebook
# hp-spartan - HP Spartan notebook
# hp-nettle - HP Nettle
# hp-lucknow - HP Lucknow
# alc861 - alc861 found on the web
# hp-educ.ar - HP educ.ar machine
# alc883 - ALC883 found on the web
# alc882 - ALC882 found on the web
# alc888 - ALC888 on a SiS development board
# clevo-m540se - Clevo m540se notebook

samples = \
	asus-w5f asus-m2nbp-vm asus-m2npv-vm \
	dell-latitude-120l dell-latitude-d520 \
	lg-lw20 \
	hp-dx2200 hp-dx2250 \
	hp-atlantis hp-spartan hp-samba hp-nettle hp-lucknow \
	alc861 alc882 alc883 alc888 \
	clevo-m540se andreas thinkpad-t60

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
