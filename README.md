flamingbear
===========

This is a simple server monitor written in plain sh as a Charles University school project
in Introduction to UNIX. It is based on 'smon' by Ladislav Láska aka Krakonoš (http://kam.mff.cuni.cz/~laska).
The name is a contribution of the GitHub repository name generator.

Usage
-----

0. Install rrdtool.

1. Create some server configuration files in etc/machines. Some examples are bundled.
   Tweak etc/watchman.conf to suit your machine. Make sure that the directories you list
   can be created by flamingbear.

2. Run prepare.sh. It will create the RRD databases.

3. Create a crontab entry to run collect.sh.

Run plot.sh to generate measurement graphs.

Bugs
----

Ubiquitous.
