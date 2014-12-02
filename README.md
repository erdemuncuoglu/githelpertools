GitHelperTools
==============

Simple console tools to help mastering Git

1. First Time Installation:
---------------------------
After cloning repository type `./install.sh` to run installer.
If completed successfully, installer would request you to type `exec bash -l` to apply changes which would restart your bash.

2. Updating GitHelperTools:
---------------------------
GitHelperTools can inform you about new versions (configurable via options) every time you start a new bash session. To update just type `git update`.

3. Configuration:
-----------------
You may customize some files for your specific needs. Common rules for those files:

  * All custom configuration files must be located under 'user' directory.
  * All configuration files must have an extension of '.conf', '.repo' or '.alias' depending on its purpose. Naming is not important.
  * Empty lines and lines starting with a # (sharp) sign are considered as a comment line and ignored.

3.1. '*.conf' files :
---------------------
Default conf file is `conf/core.conf`. Each option is explained in this file.

3.2. '*.repo' files :
---------------------
These files store shortcuts to your projects. To define a project shortcut, add a line in a format like; `project_alias=path/to/project` then you can easily jump to that project by typing; `git cd project_alias`.

You can define both absolute and relative paths to projects. You may prefer relative paths if your  projects are grouped in folders. Before any group of relative path definitions you must define a single line of a absolute path.

Suppose you have a project tree like this;

    /path/to/workspace
    |-- group1
    |   |-- main-project
    |   |-- alter1
    |   +-- alter2
    +-- group2
        |-- test-project
        +-- prototype3

Your repo file should look similar to;

    # Absolute path to a project group
    /path/to/workspace/group1
    main=main-project
    a1=alter1
    a2=alter2
    # Absolute path to an other group
    /path/to/workspace/group2
    test=test-project
    proto=prototype3

3.3. '*.alias' files :
----------------------
These files are converted to git aliases hence the formatting is same as in .gitconfig file except no section header (e.g. '[alias]') is needed. Some common aliases are defined in `conf/core.alias`.

For more information on git aliases visit <https://git.wiki.kernel.org/index.php/Aliases>.
Some common aliases are defined in 'conf/core.alias'. For many useful aliases visit <https://gist.github.com/igal/53855>.

4. Tools :
----------
...under construction...
