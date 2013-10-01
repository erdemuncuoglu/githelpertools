GitHelperTools
==============

Simple tools to help mastering Git

1. First Time Installation:
---------------------------
After cloning repository run './install.sh`.
If completed successfully, installer would request to type 'exec bash -l' to apply changes.

2. Updating GitHelperTools:
---------------------------
If you are informed about a newer version when you start bash, or any time you like type 'git update`.

3. Configuration:
-----------------
You may/must customize some files for your specific needs.
Common rules for those files:
    o All custom configuration files must be located under 'user' directory.
    o Any configuration file must have an extension '.conf', '.repo' or '.alias' depending on its purpose.
    o Empty lines and lines starting with a # (sharp) sign are considered as a comment line and ignored.

3.1. '.conf' files :
--------------------
Default conf file is 'conf/core.conf'. Each option is explained in this file.

3.2. '.repo' files :
---------------------
At least one repo file is mandatory to start using GitHelperTools.
Syntax is simple:
First non comment line must be an absolute path for a folder holding repositories.
Each proceeding line contains repo name and repo alias in a format like:
    alias=repository

3.3. '.alias' files :
---------------------
These files are converted to git aliases hence the formatting is same as .gitconfig file except no section header (e.g. '[alias]').
For more information on git aliases visit <https://git.wiki.kernel.org/index.php/Aliases>
Some common aliases are defined in 'conf/core.alias'. For many useful aliases visit <https://gist.github.com/igal/53855>.
