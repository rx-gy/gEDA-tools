 # Makefile
 #
 # Copyright 2009-2012 Nixotic Design
 #
 # This file is part of Nixotic gEDA-tools.
 #
 # Nixotic gEDA-tools is free software: you can redistribute it and/or modify
 # it under the terms of the Lesser GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # Nixotic gEDA-tools is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # Lesser GNU General Public License for more details.
 #
 # You should have received a copy of the Lesser GNU General Public License
 # along with Nixotic gEDA-tools.  If not, see <http://www.gnu.org/licenses/>.
 
 # See README for directory structure information

 # To use the commit target ensure that your schematic has a revision=0 attribute. I use this to automatically update the revision number in the schematic title block. This simply makes it easier to track changes in git more regularly.


.PHONY: sch pcb gerbv clean 

#if [ ! -f version ]; then echo 0 > version; fi ;
SHELL := /bin/bash


OUT=release
IMG=$(OUT)/img
PCB=pcb
SCH=sch
SS=subcircuits
NAME=SRS101


COLORS=--layer-color-1 '\#ff0000' --layer-color-2 '\#ff0000' --layer-color-3 '\#0000ff' --layer-color-4 '\#0000ff' --layer-color-5 '\#00868b' --layer-color-6 '\#228b22'
SHADOW=convert $< \( +clone -background black -shadow 75x20+20+20 \) +swap -background white -layers merge  $@
MINISH=convert $< \( +clone -background black -shadow 75x20+20+20 \) +swap -background white -layers merge -resize 50% $@
PHOTO=pcb -x png $(COLORS) --only-visible --use-alpha --dpi 1000 --photo-mode --outfile $@ $<
PHOTOFLIP=pcb -x png $(COLORS) --only-visible --use-alpha --dpi 1000 --photo-mode --photo-flip-y --outfile $@ $<
ROUTE=pcb -x png $(COLORS) --only-visible --use-alpha --dpi 1000 --as-shown --outfile $@ $<
CP=cp $< $@
DIR=rsync -r --delete $</ $@
BOM=gnetlist -g gbom $< -o $@
GITDESC=$(shell git describe --tags)
RELEASE=release.$(GITDESC).tar.bz2

SCHFILES=$(SCH)/$(NAME).sch $(SCH)/$(SS)/reg3V3_ss.sch $(SCH)/$(SS)/reg5V_ss.sch $(SCH)/$(SS)/relay_ss.sch
COMMITFILES:=
VER:=
UPDATECMD:=

commit: .git/COMMIT_EDITMSG
	@echo $(COMMITFILES)
	$(UPDATECMD)
	$(if $(UPDATECMD), git commit -m "$(UPDATEMSG)" $(COMMITFILES))

.git/COMMIT_EDITMSG: $(SCHFILES)

$(SCH)/$(NAME).sch: FORCE
	$(eval COMMITFILES+=$(shell git add $@; if [[ $$(git status | grep -o [\(modified\)\(new\)].*$@) != '' ]]; then echo $@ ; fi))
	$(if $(findstring $@,$(COMMITFILES)), $(eval VER=$(shell echo `grep -o revision=[0-9]* $@ | grep -o [0-9]*`+1 | bc)))
	$(if $(findstring $@,$(COMMITFILES)), $(eval UPDATECMD+=sed "s/revision=[0-9]*/revision=$(VER)/" -i $@ ; ))
	$(if $(findstring $@,$(COMMITFILES)), $(eval UPDATEMSG+=$@: V$(VER)))


#$(SCH)/$(SS)/filename.sch: FORCE
#	$(eval COMMITFILES+=$(shell git add $@; if [[ $$(git status | grep -o [\(modified\)\(new\)].*$@) != '' ]]; then echo $@ ; fi))
#	$(if $(findstring $@,$(COMMITFILES)), $(eval VER=$(shell echo `grep -o revision=[0-9]* $@ | grep -o [0-9]*`+1 | bc)))
#	$(if $(findstring $@,$(COMMITFILES)), $(eval UPDATECMD+=sed "s/revision=[0-9]*/revision=$(VER)/" -i $@ ; ))
#	$(if $(findstring $@,$(COMMITFILES)), $(eval UPDATEMSG+=$@: V$(VER)))
	
all: alloutputs release

alloutputs: bom png files gerber dir

bom: $(OUT)/$(NAME)-bom.csv 

png: $(IMG)/$(NAME)-top.png $(IMG)/$(NAME)-bottom.png $(IMG)/$(NAME)-route.png $(IMG)/$(NAME)-top-post.png $(IMG)/$(NAME)-bottom-post.png $(IMG)/$(NAME)-route-post.png 

gerber: $(OUT)/gerber


# Each file that you want to be rolled up as part of a release should be identified here.
files: $(OUT)/$(NAME).sch $(OUT)/reg3V3_ss.sch $(OUT)/reg5V_ss.sch  $(OUT)/$(NAME).pcb $(OUT)/relay_ss.sch $(OUT)/Makefile

# These are the directories that you want to have rolled into the release.
dir: $(OUT)/fp $(OUT)/sym

release: $(RELEASE)


$(OUT)/gerber: $(PCB)/$(NAME).pcb
	if [ ! -d $@ ]; then mkdir $@; else rm -r $@/*; fi ;
	pcb -x gerber --fab-author "Geoff Swan (geoff@nixotic.com)" --gerberfile $@/$(NAME) $<
	rename 's/group3/dimension-notes/' $@/$(NAME).group3.gbr

$(OUT)/$(NAME)-bom.csv: $(NAME).sch
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

%.sch: $(SCH)/$(SS)/%.sch
	$(CP)

%.pcb: $(PCB)/%.pcb
	$(CP)

$(OUT)/fp: $(PCB)/fp
	$(DIR)

$(OUT)/sym: $(SCH)/sym
	$(DIR)

$(RELEASE): $(OUT)/* $(OUT)/*/*
	if [ -f release*.tar.bz2 ]; then rm release*.tar.bz2; fi ;
	tar -jcf $@ $(OUT)


sch:
	cd $(SCH) ; gschem $(NAME).sch

pcb:
	cd sch; pcb ../$(PCB)/$(NAME).pcb

gerbv:
	gerbv $(OUT)/gerber/*

clean:
	rm -r $(OUT)/gerber/*
	rmdir $(OUT)/gerber
	rm -r $(OUT)/img/*
	rm -r $(OUT)/*

FORCE:
	
