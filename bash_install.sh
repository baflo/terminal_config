# Ask only if this is a new install
echo "New version is being installed..."
PRE_UPDATE_PKGS=()
PRE_UPDATE_REPOS=()
POST_UPDATE_PKGS=()
POST_INSTALL_CMDS=()

if [ ! -f nvim ]
then
	function askYN() {
		echo -ne "${yellow}Install/upgrade $1?${white} [y/n]: "
		read -n 1 -r
		echo
	}

	# Setup installation of neovim
	askYN neovim
	if [[ "$REPLY" =~ [yY] ]]
	then
		PRE_UPDATE_PKGS+=("software-properties-common")
		PRE_UPDATE_REPOS+=("ppa:neovim-ppa/stable")
		POST_UPDATE_PKGS+=("neovim")
		POST_INSTALL_CMDS+=("mkdir -p ~/.config/nvim/autoload && curl_nc_tf https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim ~/.config/nvim/autoload/plug.vim && curl_nc_tf $BASH_CONFIG_GIT_PATH/nvim_init.vim ~/.config/nvim/init.vim && curl_nc_tf $BASH_CONFIG_GIT_PATH/nvim_plug.vim  ~/.config/nvim/nvim_plug.vim && nvim -u ~/.config/nvim/nvim_plug.vim -c ':PlugInstall' -c ':qa'")
	fi

	# Setup installation of tmux
	askYN tmux
	if [[ "$REPLY" =~ [yY] ]]
	then
		POST_UPDATE_PKGS+=("tmux")
		POST_INSTALL_CMDS+=("curl_nc_tf $BASH_CONFIG_GIT_PATH/.tmux.conf ~/.tmux.conf")
	fi

        # Setup installation of notes
        askYN notes
        if [[ "$REPLY" =~ [yY] ]]
        then
            POST_UPDATE_PKGS+=("make")
            POST_INSTALL_CMDS+=("curl -L https://rawgit.com/pimterry/notes/latest-release/install.sh | bash && mkdir -p ~/.config/notes && curl_nc_tf $BASH_CONFIG_GIT_PATH/notes_config ~/.config/notes/config && curl https://cdn.rawgit.com/pimterry/notes/latest-release/notes.bash_completion | sudo tee /usr/share/bash-completion/completions/notes > /dev/null")
        fi

	if [ ! -z ${PRE_UPDATE_PKGS[0]}  ] ; then sudo apt-get -y install ${PRE_UPDATE_PKGS[@]}; fi
	if [ ! -z ${PRE_UPDATE_REPOS[0]} ] ; then sudo add-apt-repository -y ${PRE_UPDATE_REPOS[@]}; fi
	if [ ! -z ${PRE_UPDATE_REPOS[0]} ] ; then sudo apt-get -y update; fi
	if [ ! -z ${POST_UPDATE_PKGS[0]} ] ; then sudo apt-get -y install ${POST_UPDATE_PKGS[@]}; fi

	for cmd in "${POST_INSTALL_CMDS[@]}"
	do
		eval $cmd
	done
fi


