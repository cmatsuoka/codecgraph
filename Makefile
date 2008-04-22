PREFIX = /usr/local
DOTTY = dot

samples = \
	acer-tm4070 \
	apple-imac24 apple-macbook apple-macbook3_1 \
	arima-820di1 \
	asus-eeepc-701 \
	asus-m2nbp-vm asus-m2npv-vm asus-p5b-deluxe-wifi asus-m2a-vm-hdmi \
	asus-p5ld2-vm asus-p5gc-mx asus-m2n-vm-dvi \
	asus-w2p asus-w5f asus-x55sv \
	clevo-m540se clevo-m720r clevo-m720sr \
	compal-jft02 \
	corrino-691sr \
	dell-inspiron-530 \
	dell-latitude-120l dell-latitude-d520 dell-latitude-d620 \
	dell-latitude-d820 \
	dell-precision-490 \
	everex-cloudbook \
	fujitsu-siemens-amilo-pi-1505 \
	gateway-mt3707 gateway-mp6954 \
	hp-dc5750 hp-dx2200 hp-dx2250 \
	hp-atlantis hp-spartan hp-victoria hp-spartan-ng \
	hp-samba hp-nettle hp-lucknow \
	hp-pavillion-dv9782eg \
	intel-dg965ss intel-dp965lt \
	lenovo-3000-n100 lenovo-thinkpad-t60 lenovo-thinkpad-t61 lenovo-f41a \
	lg-lw20 lg-lw60 lg-le50 \
	msi-ms-7267 msi-p35-neo \
	quanta-il1 \
	shuttle-xpc-sg33g5m \
	sony-vaio-sz110 sony-vaio-vgn-s5vpb sony-vaio-vgc-rc102 \
	sony-vaio-vgn-g21xp \
	toshiba-satellite-p105 toshiba-qosmio-f30-111 \
	toshiba-equium-l30149 toshiba-tecra-m9 \
	uniwill-m30

txtfiles = $(addprefix samples/, $(addsuffix .txt, $(samples)))
psfiles = $(addprefix out/, $(addsuffix .ps, $(samples)))
dotfiles = $(addprefix out/, $(addsuffix .dot, $(samples)))
pngfiles = $(addprefix out/, $(addsuffix .png, $(samples)))
svgfiles = $(addprefix out/, $(addsuffix .svg, $(samples)))

all:

dot: $(dotfiles)
ps: $(psfiles)
png: $(pngfiles)
svg: $(svgfiles)

install:
	install -m755 -D codecgraph $(DESTDIR)$(PREFIX)/bin/codecgraph
	install -m755 -D codecgraph.py $(DESTDIR)$(PREFIX)/bin/codecgraph.py
	install -m644 -D codecgraph.1 $(DESTDIR)$(PREFIX)/man/man1/codecgraph.1

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

