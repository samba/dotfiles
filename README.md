Dotfiles tagging framework
==========================
Dotfiles provides a way to dynamically configure your shell, vim, and other tools based on where you are and your current user name.

The goal is to simplify managing user configuration across multiple hosts.

Examples:

	(.*)@yourhost             yourconfig
	(.*)@myhost               myconfig
	(.*)@(.*)\.work\.com      office    %dist workstation
	(.*)@(.*)\.home\.net      home      %dist
	user@(.*)                 personalized
	otheruser@(.*)\.work\.com testing !workstation


This project's primary focus is bash and vim. It should be easily extensible into other tools though.
If you find this project useful, please ***fork*** it. (Use the 'Fork' button at the top of the project page.)

This lets us track interesting customizations, and occasionally merge eachother's work.
If you have questions, please contact 'samba' on Freenode (IRC), or send me a message on GitHub.


Deployment instructions
-----------------------

	git clone git://github.com/samba/dotfiles.git ~/.dotfiles
	cd ~/.dotfiles
	git branch ${USER}
	git checkout ${USER}
	** copy conf/dotfiles.conf.sample to conf/dotfiles.conf, customize
	make install





