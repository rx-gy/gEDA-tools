/* README
 *
 * Copyright 2009-2014 Nixotic Design
 *
 * This file is part of Nixotic gEDA-tools.
 *
 * Nixotic gEDA-tools is free software: you can redistribute it and/or modify
 * it under the terms of the Lesser GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Nixotic gEDA-tools is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Lesser GNU General Public License for more details.
 *
 * You should have received a copy of the Lesser GNU General Public License
 * along with Nixotic gEDA-tools.  If not, see <http://www.gnu.org/licenses/>.
 */


This is a collection of scripts and so forth that I have found helpful for my gEDA workflow.


These tools may presuppose the following directory structure however you may be able to modify them to suit your own setup.

project-dir/
project-dir/Makefile  
project-dir/gitignore
project-dir/sch/  
procect-dir/sch/gafrc
project-dir/sch/gschemrc
project-dir/sch/gnetlistrc
project-dir/sch/subcircuits/
project-dir/sch/sym/
project-dir/pcb/
project-dir/release/
project-dir/release/img
project-dir/release/gerber

The tools also assume you are using a git repository to track your files.


Quick Start:
1. Copy this directory and all contents to desired location.
```shell
git clone https://github.com/nixotic/gEDA-tools
mkdir projectName
cp -r gEDA-tools/* projectName/
cd projectName
2. Modify Makefile and example.sch to suit your project.
        Change the NAME=example line to the desired name of your project.
        Set the AUTHOR= and EMAIL= lines.
        Rename sch/example.sch to match the Makefile NAME= setting.
3. Create the pcb file:
```shell
make pcb
```
        Select 'file'->'import schematic'
        Select <projectname>.sch (as set up in the previous step)
        Save the pcb file
4. Set up git:
```shell
git init
git add *
git commit -am 'initial commit'
git tag 'release_0.1'
```
5. Start working on your schematic!
```shell
make sch
```

