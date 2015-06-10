OUTPUT = sprites/svg-defs-sprite

reverse = $(2) $(1)
id      = $(shell basename $(1) | sed 's/^ic_//;s/_24px\.svg$$//;s/_/-/g' )
extract = $$(cat $(1) | egrep -o $(2) | tr '\n' ' ' | sed "s/id=\"/id=\"$(call id,$(1))-/g")

src  := $(wildcard */svg/production)
dest := $(patsubst %/svg/production,$(OUTPUT)/%.svg,$(src))

svg_start := '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><defs>'
svg_end   := '</defs></svg>'

get_svg  = $(addprefix $*/svg/production/,$(shell ls $*/svg/production | grep _24px.svg))
svg_as_g = $$(echo $(call extract,$(file),'<defs.*?</defs>') $(call extract,$(file),'<clipPath.*?</clipPath>') $$(cat $(file) | perl -pe "s/<defs.*?<\/defs>//g;s/<clipPath.*?<\/clipPath>//g" | sed "s/<svg[^>]*/<g id=\"$(call id,$(file))\"/g;s/<\/svg>/<\/g>/") | sed "s/\#/\#$(call id,$(file))-/;s/<\/*defs>//g")

.PHONY: all
all: $(dest)
	@echo
	@echo done building in $(OUTPUT)

$(OUTPUT)/%.svg:
	@mkdir -p $(OUTPUT)
	@echo - $*
	@echo $(svg_start)$(foreach file,$(get_svg),$(svg_as_g))$(svg_end) | \
		sed "s/> </></g" > $@

.PHONY: clean
clean:
	@rm -rf $(OUTPUT)
