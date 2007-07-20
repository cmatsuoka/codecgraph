
DOTTY = dot

samples = \
	asus-w5f asus-m2nbp-vm asus-m2npv-vm asus-p5b-deluxe-wifi \
	asus-p5ld2-vm \
	dell-latitude-120l dell-latitude-d520 \
	lg-lw20 \
	hp-dc5750 hp-dx2200 hp-dx2250 \
	hp-atlantis hp-spartan hp-samba hp-nettle hp-lucknow \
	alc861 alc882 alc883 alc888 \
	clevo-m540se thinkpad-t60

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
