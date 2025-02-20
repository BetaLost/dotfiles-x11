# Prompt
NL=$'\n'
#PROMPT="%B%F{red}%~${NL}%F{blue}❯ %b%f"
#PROMPT="%F{39} %f%~${NL}%F{39}❯ %b%f"
#PROMPT="%F{#66d9ef} %f%~${NL}%F{#66d9ef}❯ %b%f"
PROMPT="%F{#66d9ef} %f%~${NL}%F{#ff6188}❯%F{#ffd866}❯%F{#a9dc76}❯ %b%f"

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
# setopt SHARE_HISTORY

# Aliases
alias ls="exa -l"
alias vim="nvim"
alias build="make; sudo make clean install"
alias rconf="source $HOME/.zshrc"

# Key bindings
bindkey "^[[Z" end-of-line 
bindkey ";5C" forward-word
bindkey ";5D" backward-word

# Interacting with packages
alias upd="sudo pacman -Syy"
alias upg="sudo pacman -Syu"
alias purge="sudo pacman -Rsn $(pacman -Qdtq)" 
alias sp="pacman -Ss"
alias gp="sudo pacman -S"
alias rp="sudo pacman -Rs"

# Install from Arch User Repository
auri() {
	for aurpkg in $@
	do
		git clone https://aur.archlinux.org/$aurpkg.git
		cd $aurpkg
		makepkg -si
		cd ..
		rm -rf $aurpkg
	done
}

# Change time zone
ctz() {
	echo -e "Select \e[4;33mRegion\e[0m:"
	REGIONS=("Africa" "America" "Antarctica" "Asia" "Australia" "Europe" "Pacific")
	
	select region in "${REGIONS[@]}"; do
		SELECTED_REGION=$region
		break
	done
	
	clear
	
	echo -e "Select \e[4;35mCity\e[0m:"
	CITIES=($(/bin/ls /usr/share/zoneinfo/$SELECTED_REGION))
	
	select city in "${CITIES[@]}"; do
		SELECTED_CITY=$city
		break
	done
	
	sudo timedatectl set-timezone $SELECTED_REGION/$SELECTED_CITY
}

# Downloading files
wg() { 
	for arg in $@
	do
		arr=(${(s. .)arg})
		wget -O $arr[1] --user-agent="Mozilla" $arr[2]
	done
}

# Mounting NAS
mns() { 
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "Usage: mns (--options) SERVER_HOSTNAME SHARE_NAME"
		echo ""
		echo "options:"
		echo "-h, --help	 Show this help message"
		echo "-u, --username	 Mount with a username"
		echo "-m, --mount	 Mount without a username (guest/anonymous)"
		echo "-n, --unmount	 Unmount the NAS"
		echo ""
		echo "Examples:"
		echo "	mns --username myusername 192.168.0.159 homeshare"
		echo "	mns -m homeserver myshare"
		echo "	mns -n"
	elif [ "$1" = "-u" ] || [ "$1" = "--username" ]; then
		mkdir -p $HOME/shared/
		sudo mount -t cifs -o username=$2,dir_mode=0777,file_mode=0777 //$3/$4 $HOME/shared/
	elif [ "$1" = "-m" ] || [ "$1" = "--mount" ]; then
		mkdir -p $HOME/shared/
		sudo mount -t cifs -o guest,dir_mode=0777,file_mode=0777 //$3/$4 $HOME/shared/
	elif [ "$1" = "-n" ] || [ "$1" = "--unmount" ]; then
		sudo umount $HOME/shared/
		rmdir $HOME/shared/
	else
		echo "Usage: mns (--options) SERVER_HOSTNAME SHARE_NAME"
		echo ""
		echo "options:"
		echo "-h, --help	 Show this help message"
		echo "-u, --username	 Mount with a username"
		echo "-m, --mount	 Mount without a username (guest/anonymous)"
		echo "-n, --unmount	 Unmount the NAS"
		echo ""
		echo "Examples:"
		echo "	mns --username myusername 192.168.0.159 homeshare"
		echo "	mns -m homeserver myshare"
		echo "	mns -n"
	fi
}

# Mount Microsoft Windows Partition
mwp() {
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "Usage: mwp (--options) /dev/sdXX"
		echo ""
		echo "options:"
		echo "-h, --help	 Show this help message"
		echo "-m, --mount	 Mount partition"
		echo "-n, --unmount	 Unmount the partition"
		echo ""
		echo "Examples:"
		echo "	mwp -m /dev/sda3"
		echo "	mwp --unmount"
	elif [ "$1" = "-m" ] || [ "$1" = "--mount" ]; then
		sudo mkdir -p /mnt/MSW/
		sudo mount $2 /mnt/MSW/
		cd /mnt/MSW/
	elif [ "$1" = "-n" ] || [ "$1" = "--unmount" ]; then
		cd $HOME/
		sudo umount /mnt/MSW/
		sudo rmdir /mnt/MSW/
	else
		echo "Usage: mwp (--options) /dev/sdXX"
		echo ""
		echo "options:"
		echo "-h, --help	 Show this help message"
		echo "-m, --mount	 Mount partition"
		echo "-n, --unmount	 Unmount the partition"
		echo ""
		echo "Examples:"
		echo "	mwp -m /dev/sda3"
		echo "	mwp --unmount"
	fi
}

# Encrypt data
sef() {
	gpg --symmetric --no-symkey-cache --cipher-algo AES256 $1
}

# Decrypt data
sdf() {
	gpg --output ${1%.gpg} --decrypt --no-symkey-cache $1
}

# Get IP Address
getip() { ip -o -4 addr list $1 | awk '{print $4}' | cut -d / -f 1 }

# Compile and run any cpp files in current directory
cr() {
	for file in *.cpp; do g++ $file -o "${file%.cpp}"; done
	./${file%.cpp}
}

# Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
