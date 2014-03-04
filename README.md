# gEDA-tools

This is primarily a makefile based workflow that provides some optimisations around git integration and portability of project settings.

The makefile presuppose the use of git and the following directory structure.

```
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
```
## Introduction:
This is the Makefile that has accreted around the development of my gEDA workflow. As this is tailored to my specific workflow, there may be some parts that are less useful in other workflows.

One of the underlying principals of this workflow is that each project maintains a local copy of any symbols or footprints used. This means that any symbols used are copied to the local symbol directory and then any modifications are made to that local copy. The workflow does not attempt to interact with a central library of components. This is because a component may well be modified over time. Should it be necessary years later to reproduce the same design, having the original component data rather than a reference to the latest version of component data is my preference.

The reason the schematic has both a _REVISION_ field and the _GIT TAG_ field is in part due to my complacency when it comes to committing design changes. The _REVISION_ field is intended to be incremented with every git commit regardless of how minor the change. The _REVISION_ number is used in the commit comment. This was specifically to make it easier for me to commit my changes more often without having to think too hard. Future improvements will hopefully allow me to append the ```make commit``` command with a more detailed comment... The _GIT TAG_ field  is intended to be used to manage hardware release versions. As soon as the design is produced, any further changes should be made using a different tag. The tag is used to identify the production and release archives.


## Commands:
```make sch``` - open the schematic in gschem. This command insures gschem is run with all the correct project settings in place.

```make pcb``` - open the pcb layout in pcb.

```make gerbv``` - open the gerbers in gerbv.

```make```, ```make commit``` - if changes have been made to the schematic, this will update the schematics REVISION attribute, apply the latest git tag to the schematic and then commit the changes to git.

```make bom``` - this will produce a bill of materials from the schematic in the ```release/``` directory

```make clean``` - this will clean the release directory, the primary purpose is to get rid of any gerber files.

```make gerber``` - this produces the gerber files from the pcb layout

```make png``` - produce photo renders of the pcb layout. The images will be in the ```release/img/``` directory.

```make production``` - package the gerbers into a zip using the current git tag to identify the release. This zip file should be ready to send directly to hackvana for production.

```make release``` - package the files needed to reproduce the current set production gerbers into a tar archive. It is a good idea to keep a snapshot of everything used to produce a PCB for future reference.

## Quick Start:

1. Copy this directory and all contents to desired location.

    ```shell
    git clone https://github.com/nixotic/gEDA-tools
    mkdir projectName
    cp -r gEDA-tools/* projectName/
    cd projectName
    ```
    The symbols in the lib directory will be browsable from gschem, however I recommend moving any schematic symbols you intend to use to your project local sch/sym directory as future modifications to a symbol could break an old project.
    Footprints for symbols used from the lib/ directory will need to be copied to the project local pcb/fp directory.

2. Modify Makefile and example.sch to suit your project.
   * Change the NAME=example line to NAME=_projectName_ (the desired name of your project).
   * Set the AUTHOR= and EMAIL= lines.
   * Rename sch/example.sch to match the Makefile NAME= setting.

3. Create the pcb file:

    ```shell
    make pcb
    ```
   Note: You will receive some warnings on the command line at this stage as git hasn't yet been set up.
   * Select _file_->_import schematic_
   * Select _projectName.sch_ (as set up in the previous step)
   * Save the pcb file
4. Set up git:

    ```shell
    mv gitignore .gitignore
    git init
    git add .
    git commit -am 'initial commit'
    git tag 'release_0.1'
    ```

5. Modify the basic schematic template with appropriate title, author etc...

    ```shell
    make sch
    ```
    Note: save changes!

6. Run the 'make' command to update the TAG and REVISION in the schematic

    ```shell
    make
    ```

7. __Start editing schematic for real!!__

    Remember, you can run the make command at any stage to automatically commit schematic changes to your git repository and update the schematic revision field.

