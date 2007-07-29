
DOTTY = dot

samples = \
	alc861 alc882 alc883 alc888 \
	asus-w5f asus-m2nbp-vm asus-m2npv-vm asus-p5b-deluxe-wifi \
	asus-p5ld2-vm \
	apple-imac24 apple-macbook \
	clevo-m540se \
	corrino-691sr \
	dell-latitude-120l dell-latitude-d520 \
	gateway-mt3707 gateway-mp6954 \
	hp-dc5750 hp-dx2200 hp-dx2250 \
	hp-atlantis hp-spartan hp-victoria \
	hp-samba hp-nettle hp-lucknow \
	lg-lw20 \
	sony-vaio-sz110 \
	toshiba-satellite-p105 \
	thinkpad-t60

psfiles = $(addprefix out/, $(addsuffix .ps, $(samples)))
dotfiles = $(addprefix out/, $(addsuffix .dot, $(samples)))
pngfiles = $(addprefix out/, $(addsuffix .png, $(samples)))
svgfiles = $(addprefix out/, $(addsuffix .svg, $(samples)))

all:

dot: $(dotfiles)
ps: $(psfiles)
png: $(pngfiles)
svg: $(svgfiles)

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

%.svg: %.dot
	$(DOTTY) -Tsvg -o $@ $<

clean:
	rm -f $(psfiles)
	rm -f $(dotfiles)
	rm -f $(pngfiles)
	if [ -d out ];then rmdir out;fi
