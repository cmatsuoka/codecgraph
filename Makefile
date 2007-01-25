
DOTTY = dot

codecs = claudio boiko boto-120l fbl hp hp-samba alc861 hp-samba-6stack-dig

allnames = $(addprefix codecs/, $(codecs))

psfiles = $(addsuffix .ps, $(allnames))
dotfiles = $(addsuffix .dot, $(allnames))
pngfiles = $(addsuffix .png, $(allnames))
all: $(psfiles) $(dotfiles)


pngs: $(pngfiles)

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
