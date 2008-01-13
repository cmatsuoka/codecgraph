
DOTTY = dot

samples = \
	alc861 alc882 alc883 alc888 \
	asus-w2p asus-w5f \
	asus-m2nbp-vm asus-m2npv-vm asus-p5b-deluxe-wifi \
	asus-p5ld2-vm asus-p5gc-mx \
	apple-imac24 apple-macbook \
	clevo-m540se \
	corrino-691sr \
	dell-inspiron-530 \
	dell-latitude-120l dell-latitude-d520 dell-latitude-d620 \
	dell-latitude-d820 \
	gateway-mt3707 gateway-mp6954 \
	hp-dc5750 hp-dx2200 hp-dx2250 \
	hp-atlantis hp-spartan hp-victoria \
	hp-samba hp-nettle hp-lucknow \
	hp-spartan-ng \
	lenovo-thinkpad-t60 \
	lg-lw20 lg-lw60 \
	shuttle-xpc-sg33g5m \
	sony-vaio-sz110 sony-vaio-vgn-s5vpb sony-vaio-vgc-rc102 \
	toshiba-satellite-p105 toshiba-qosmio-f30-111 \
	uniwill-m30

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

thumbs: png
	for p in $(pngfiles);do \
		convert -resize 10%x10% $$p out/thumb-`basename $$p`; \
		echo "converting $$p"; \
	done

out/%.dot: samples/%.txt codecgraph.py
	./codecgraph.py $< > $@

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
