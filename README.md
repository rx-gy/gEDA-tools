# gEDA-tools

This is a collection of scripts and so forth that I have found helpful for my gEDA workflow.

These tools presuppose the use of git and the following directory structure.

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

