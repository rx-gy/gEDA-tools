.PHONY: sch pcb gerbv clean 

#if [ ! -f version ]; then echo 0 > version; fi ;
SHELL := /bin/bash

# DIRECTORY/NAME MACROS
# OUT: output directory
# IMG: image directory
# PCB: directory for the PCB files
# SCH: directory for the schematics
# SS: subdirectory of $SCH for sub-circuits
# NAME: root name of the project, used for files etc.

# NAMES
NAME=
AUTHOR=
EMAIL=

# INPUT DIRS
PCB=pcb
SCH=sch
SS=subcircuits

# OUTPUT DIRS
OUT=release
IMG=$(OUT)/img
HACKVANA=$(OUT)/hackvana
GERBER=$(OUT)/gerber

# MAKE SURE OUTPUT DIRS EXIST
$(shell mkdir -p $(HACKVANA))
$(shell mkdir -p $(GERBER))
$(shell mkdir -p $(IMG))


# COMMAND MACROS

COLORS=--layer-color-1 '\#ff0000' --layer-color-2 '\#ff0000' --layer-color-3 '\#0000ff' --layer-color-4 '\#0000ff' --layer-color-5 '\#00868b' --layer-color-6 '\#228b22'
SHADOW=convert $< \( +clone -background black -shadow 75x20+20+20 \) +swap -background white -layers merge  $@
MINISH=convert $< \( +clone -background black -shadow 75x20+20+20 \) +swap -background white -layers merge -resize 50% $@
PHOTO=pcb -x png $(COLORS) --only-visible --use-alpha --dpi 1000 --photo-mode --outfile $@ $<
PHOTOFLIP=pcb -x png $(COLORS) --only-visible --use-alpha --dpi 1000 --photo-mode --photo-flip-y --outfile $@ $<
ROUTE=pcb -x png $(COLORS) --only-visible --use-alpha --dpi 1000 --as-shown --outfile $@ $<
CP=cp $< $@
DIR=rsync -r --delete $</ $@
# The BOM can include custom attributes simply by adding them to the schematic and the -Oattribs comma separated list.
BOM=gnetlist -g bom $< -o $@ -Oattribs=footprint,price_single,price_100,supplier,supplier_part_number,manufacturer,manufacturer_part_number
GITDESC=$(shell git describe --tags --abbrev=0)
UPDATECMD:=

# FILES
# RELEASE is an archive of all the source and output files that make up the project
# SCHFILES are the source schematic files

RELEASE=release.$(GITDESC).tar.bz2
SCHFILES=

COMMITFILES:=
VER:=

commit: .git/COMMIT_EDITMSG
	@echo $(COMMITFILES)
	$(UPDATECMD)
	$(if $(UPDATECMD), git commit -m "$(UPDATEMSG)" $(COMMITFILES))

.git/COMMIT_EDITMSG: $(SCHFILES)

$(SCH)/$(NAME).sch: FORCE
	$(eval COMMITFILES+=$(shell git add $@; if [[ $$(git status | grep -o [\(modified\)\(new\)].*$@) != '' ]]; then echo $@ ; fi))
	$(if $(findstring $@,$(COMMITFILES)), $(eval VER=$(shell echo `grep -o revision=[0-9]* $@ | grep -o [0-9]*`+1 | bc)))
	$(if $(findstring $@,$(COMMITFILES)), $(eval UPDATECMD+=sed "s/revision=[0-9]*/revision=$(VER)/" -i $@ ; ))
	$(if $(findstring $@,$(COMMITFILES)), $(eval UPDATECMD+=sed "s/git_tag=.*/git_tag=$(GITDESC)/" -i $@ ; ))
	$(if $(findstring $@,$(COMMITFILES)), $(eval UPDATEMSG+=$@: V$(VER)))

$(SCH)/$(SS)/reg5V_ss.sch: FORCE
	$(eval COMMITFILES+=$(shell git add $@; if [[ $$(git status | grep -o [\(modified\)\(new\)].*$@) != '' ]]; then echo $@ ; fi))
	$(if $(findstring $@,$(COMMITFILES)), $(eval VER=$(shell echo `grep -o revision=[0-9]* $@ | grep -o [0-9]*`+1 | bc)))
	$(if $(findstring $@,$(COMMITFILES)), $(eval UPDATECMD+=sed "s/revision=[0-9]*/revision=$(VER)/" -i $@ ; ))
	$(if $(findstring $@,$(COMMITFILES)), $(eval UPDATEMSG+=$@: V$(VER)))

$(SCH)/$(SS)/relay_ss.sch: FORCE
	$(eval COMMITFILES+=$(shell git add $@; if [[ $$(git status | grep -o [\(modified\)\(new\)].*$@) != '' ]]; then echo $@ ; fi))
	$(if $(findstring $@,$(COMMITFILES)), $(eval VER=$(shell echo `grep -o revision=[0-9]* $@ | grep -o [0-9]*`+1 | bc)))
	$(if $(findstring $@,$(COMMITFILES)), $(eval UPDATECMD+=sed "s/revision=[0-9]*/revision=$(VER)/" -i $@ ; ))
	$(if $(findstring $@,$(COMMITFILES)), $(eval UPDATEMSG+=$@: V$(VER)))
	
all: alloutputs release

alloutputs: bom png files gerber dir hackvana

bom: $(OUT)/$(NAME)-bom.tsv 

png: $(IMG)/$(NAME)-top.png $(IMG)/$(NAME)-bottom.png $(IMG)/$(NAME)-route.png $(IMG)/$(NAME)-top-post.png $(IMG)/$(NAME)-bottom-post.png $(IMG)/$(NAME)-route-post.png 

gerber: $(GERBER)/$(NAME).top.gbr


hackvana: $(OUT)/hackvana-$(GITDESC).zip

$(OUT)/hackvana-$(GITDESC).zip: $(HACKVANA)/$(NAME).botom.gbl $(HACKVANA)/$(NAME).bottommask.gbs $(HACKVANA)/$(NAME).bottomsilk.gbo $(HACKVANA)/$(NAME).outline.gbr $(HACKVANA)/$(NAME).plated-drill.cnc $(HACKVANA)/$(NAME).top.gtl $(HACKVANA)/$(NAME).topmask.gts $(HACKVANA)/$(NAME).topsilk.gto $(HACKVANA)/$(NAME).non-plated_NPTH.drl
	zip -jr $@ $(HACKVANA)/*

$(HACKVANA)/%.gbl: $(GERBER)/$(NAME).bottom.gbr
	cp $< $@

$(HACKVANA)/%.gbo: $(GERBER)/$(NAME).bottomsilk.gbr
	cp $< $@

$(HACKVANA)/%.gbs: $(GERBER)/$(NAME).bottommask.gbr
	cp $< $@

$(HACKVANA)/%.gtl: $(GERBER)/$(NAME).top.gbr
	cp $< $@

$(HACKVANA)/%.gto: $(GERBER)/$(NAME).topsilk.gbr
	cp $< $@

$(HACKVANA)/%.gts: $(GERBER)/$(NAME).topmask.gbr
	cp $< $@

$(HACKVANA)/%.cnc: $(GERBER)/$(NAME).plated-drill.cnc
	cp $< $@

$(HACKVANA)/%.drl: $(GERBER)/$(NAME).unplated-drill.cnc
	cp $< $@

$(HACKVANA)/%.gbr: $(GERBER)/$(NAME).outline.gbr
	cp $< $@

# Each file that you want to be rolled up as part of a release should be identified here.
files: $(OUT)/$(NAME).sch $(OUT)/$(NAME).pcb $(OUT)/Makefile

# These are the directories that you want to have rolled into the release.
dir: $(OUT)/fp $(OUT)/sym 

release: $(RELEASE)

%.gbr: $(PCB)/$(NAME).pcb
	pcb -x gerber --fab-author "$(AUTHOR) $(EMAIL)" --gerberfile $(GERBER)/$(NAME) $<

%.cnc: $(PCB)/$(NAME).pcb
	pcb -x gerber --fab-author "$(AUTHOR) $(EMAIL)" --gerberfile $(GERBER)/$(NAME) $<


$(OUT)/$(NAME)-bom.tsv: $(SCH)/$(NAME).sch
	$(BOM)

$(IMG)/$(NAME)-top-post.png: $(IMG)/$(NAME)-top.png
	$(SHADOW)

$(IMG)/$(NAME)-top.png: $(PCB)/$(NAME).pcb
	$(PHOTO)

$(IMG)/$(NAME)-bottom-post.png: $(IMG)/$(NAME)-bottom.png
	$(SHADOW)

$(IMG)/$(NAME)-bottom.png: $(PCB)/$(NAME).pcb
	$(PHOTOFLIP)

$(IMG)/$(NAME)-route.png: $(PCB)/$(NAME).pcb
	$(ROUTE)

$(IMG)/$(NAME)-route-post.png: $(IMG)/$(NAME)-route.png
	$(SHADOW)

$(OUT)/Makefile: Makefile
	$(CP)

$(OUT)/%.sch: $(SCH)/$(SS)/%.sch
	$(CP)

$(OUT)/%.sch: $(SCH)/%.sch
	$(CP)

$(OUT)/%.pcb: $(PCB)/%.pcb
	$(CP)

$(OUT)/fp: $(PCB)/fp
	$(DIR)

$(OUT)/sym: $(SCH)/sym
	$(DIR)

$(RELEASE): $(SCHFILES) $(PCB)/$(NAME).pcb $(OUT)/$(NAME)-bom.tsv $(OUT)/Makefile
	if [ -f release*.tar.bz2 ]; then rm release*.tar.bz2; fi ;
	tar -jcf $@ $(OUT)


sch:
	cd $(SCH) ; gschem $(NAME).sch

pcb:
	cd sch; pcb ../$(PCB)/$(NAME).pcb

gerbv:
	gerbv $(GERBER)/*

clean:
	rm -rf $(OUT)
	rm -f $(RELEASE)

FORCE:
	
