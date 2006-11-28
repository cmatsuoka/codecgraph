
DOTTY = dot

codecs = claudio boiko boto-120l fbl hp alc861

allnames = $(addprefix codecs/, $(codecs))

psfiles = $(addsuffix .ps, $(allnames))
dotfiles = $(addsuffix .dot, $(allnames))
pngfiles = $(addsuffix .png, $(allnames))

all: $(psfiles) $(dotfiles)


pngs: $(pngfiles)

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
