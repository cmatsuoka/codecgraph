PREFIX = /usr/local
DOTTY = dot

samples = \
	abit-kn9-ultra abit-i-41cv \
	acer-aspire-5520 acer-aspire-5920g acer-aspire-6920g \
	acer-aspire-x1700 acer-tm4070 \
	alienware-m15x \
	apple-imac24 apple-macbook apple-macbook3_1 apple-macbookair1,1 \
	apple-macbookpro4,1 \
	arima-820di1 \
	asrock-h55m \
	asus-eeepc-701 \
	asus-m2nbp-vm asus-m2npv-vm asus-p5b-deluxe-wifi asus-m2a-vm-hdmi \
	asus-m4a78-pro \
	asus-p5ld2-vm asus-p5gc-mx asus-m2n-vm-dvi asus-p5kc asus-p5ql \
	asus-p5n-e-sli asus-p5q3-deluxe-wifi asus-p5q-pro asus-p5q-deluxe \
	asus-p6t \
	asus-p7p55d-pro \
	asus-w2p asus-w5f asus-x55sv asus-f6s0 asus-a6jc-q077 asus-m2n68-vm \
	classmatepc-2nd-gen \
	clevo-m540se clevo-m720r clevo-m720sr \
	compal-jft02 \
	compaq-presario-f755la \
	corrino-691sr \
	dell-inspiron-530 dell-inspiron-580 dell-inspiron-6400 \
	dell-latitude-120l dell-latitude-d520 dell-latitude-d620 \
	dell-latitude-d820 \
	dell-precision-490 \
	dell-studio-15 \
	dell-vostro-1700 \
	dell-xps-m1330 \
	dell-xps-l502x \
	ecs-ka3-mvp \
	everex-cloudbook \
	fujitsu-siemens-amilo-pi-1505 \
	fujitsu-siemens-esprimo-u9200 \
	fujitsu-siemens-lifebook-e8210 \
	gateway-mt3707 gateway-mp6954 \
	gigabyte-ma790fx-ds5 gigabyte-ga965p-ds4 gigabyte-ga-p43t-es3g \
	hp-dc5750 hp-dx2200 hp-dx2250 \
	hp-atlantis hp-spartan hp-victoria hp-spartan-ng \
	hp-compaq-6720s hp-compaq-6530b \
	hp-nx7400 \
	hp-samba hp-nettle hp-lucknow \
	hp-pavilion-dv9782eg hp-pavilion-tx1420us hp-pavilion-dv7 \
	hp-pavilion-dv6330ea hp-pavilion-dv6535ep \
	intel-cougarpoint-hdmi \
	intel-ibexpeak-hdmi \
	intel-dg965ss intel-dp965lt \
	lenovo-3000-n100 \
	lenovo-3000-n500 \
	lenovo-e680a \
	lenovo-thinkpad-t60 lenovo-thinkpad-t61 lenovo-f41a \
	lenovo-thinkpad-sl500 lenovo-w500 lenovo-ideapad-y430 \
	lg-lw20 lg-lw60 lg-le50 lg-p300 \
	medion-rim2050 \
	msi-ms-7267 msi-p35-neo msi-k9n6sgm-v \
	msi-p55-cd53-_ms-7586_ \
	nec-m370 \
	packard-bell-easynote-ts11hr-uk \
	panasonic-cf-52-toughbook \
	quanta-il1 \
	qemu-0_15 \
	samsung-q45 samsung-x60-student-edition \
	shuttle-xpc-sg33g5m \
	sony-vaio-sz110 sony-vaio-vgn-s5vpb sony-vaio-vgc-rc102 \
	sony-vaio-vgn-g21xp sony-vaio-fe41e \
	toshiba-satellite-p105 toshiba-qosmio-f30-111 \
	toshiba-equium-l30149 toshiba-tecra-m9 toshiba-nb200 \
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
	cp SVGPan.js out/

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
	@echo -e '\n\x1b[1mGenerate graph for $*\x1b[0m'
	./codecgraph.py $< > $@

%.ps: %.dot
	$(DOTTY) -Tps -o $@ $<

%.png: %.dot
	$(DOTTY) -Tpng -o $@ $<

%.svg: %.dot
	$(DOTTY) -Tsvg -o $@ $<
	perl -pi -e 's|(^<svg).*|$$1|;s|.*?(xmlns.*)|$$1\n<script xlink:href="SVGPan.js"/>|' $@ 

clean:
	rm -f $(psfiles)
	rm -f $(dotfiles)
	rm -f $(pngfiles)

