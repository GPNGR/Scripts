#!/usr/bin/env bash

# Title: Fedora post install script
# Description: Script to install dependencies and applications on a minimal Fedora install.
# This script is mostly a test and provided AS IS!
# Author: GPNGR
# Date: 2022/03/21
# Version: 0.1

# >>>>>>>>>>>>>>>>>>>>>>>> formating >>>>>>>>>>>>>>>>>>>>>>>>
RED=$(tput setaf 1)
MAGENTA=$(tput setaf 5)
RESET=$(tput sgr0)
# <<<<<<<<<<<<<<<<<<<<<<<< formating <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> variables >>>>>>>>>>>>>>>>>>>>>>>>
hostName=''
cwd=$PWD
# <<<<<<<<<<<<<<<<<<<<<<<< variables <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> event handlers >>>>>>>>>>>>>>>>>>>>>>>>
function on_ctrl_c() {
    echo # Set cursor to the next line of '^C'
    tput cnorm # show cursor. You need this if animation is used.
    cleanup && exit 1 
}
# <<<<<<<<<<<<<<<<<<<<<<<< event handlers <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions >>>>>>>>>>>>>>>>>>>>>>>>
function install_dependencies () {
    if ! sudo dnf install -y \
    git \
    rust \
    cargo \
    openssl \
    openssl-devel;
    then
        echo "${RED}Failed installing dependencies${RESET}"; exit 1
    else
        echo "${MAGENTA}Succesfully installed dependencies${RESET}"
    fi
}

function install_applications () {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
    if ! sudo dnf install -y \
    alacritty \
    calibre \
    lm_sensors \
    NetworkManager-openvpn-gnome \
    nano \
    wget \
    starship \
    fish \
    polybar \
    feh \
    rofi \
    bpytop \
    ranger \
    neofetch \
    ripgrep \
    exa \
    bat \
    code \
    flatpak;
    then
        echo "${RED}Failed installing applications${RESET}"; exit 1
    else
        echo "${MAGENTA}Succesfully installed applications${RESET}"
    fi
    
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    if ! flatpak install flathub io.gitlab.librewolf-community \
    im.pidgin.Pidgin \
    com.discordapp.Discord \
    com.bitwarden.desktop \
    com.spotify.Client;
    then
        echo "${RED}Failed installing applications${RESET}"; exit 1
    else
        echo "${MAGENTA}Succesfully installed applications${RESET}"
    fi
}

function install_gnome () {
    if ! sudo dnf install -y \
    @base-x \
    gnome-shell \
    alacritty;
    then
        echo "${RED}Failed installing gnome${RESET}"; exit 1
    else
        echo "${MAGENTA}Succesfully installed gnome${RESET}"
    fi
    
    if ! sudo systemctl set-default graphical.target;
    then
        echo "${RED}Failed setting graphical.target${RESET}"; exit 1
    else
        echo "${MAGENTA}Succesfully set graphical.target${RESET}"
    fi
}

function install_LeftWM () {
    if ! git clone https://github.com/leftwm/leftwm.git; then
        echo "${RED}Failed pulling LeftWM${RESET}"; exit 1
    fi
    
    cd leftwm || { echo "Failure LeftWM"; exit 1; }
    
    if ! cargo build --release; then
        echo "${RED}Failed building LeftWM${RESET}"; exit 1
    fi
    
    if ! sudo install -s -Dm755 ./target/release/leftwm ./target/release/leftwm-worker ./target/release/leftwm-state ./target/release/leftwm-check ./target/release/leftwm-command -t /usr/bin; then
        echo "${RED}Failed installing LeftWM${RESET}"; exit 1
    fi
    
    if ! sudo cp leftwm.desktop /usr/share/xsessions/; then
        echo "${RED}Failed installing LeftWM${RESET}"; exit 1
    fi
    
    cd ..
    if ! rm -rf leftwm;
    then
        echo "${RED}Failed installing LeftWM${RESET}"; exit 1
    else
        echo "${MAGENTA}Succesfully installed LeftWM${RESET}"
    fi
    
    if ! git clone https://github.com/leftwm/leftwm-theme; then
        echo "${RED}Failed pulling LeftWM-Theme${RESET}"; exit 1
    fi
    
    cd leftwm-theme || { echo "Failure LeftWM-Theme"; exit 1; }
    if ! cargo build --release; then
        echo "${RED}Failed building LeftWM-Theme${RESET}"; exit 1
    fi
    
    if ! sudo install -s -Dm755 ./target/release/leftwm-theme -t /usr/bin; then
        echo "${RED}Failed installing LeftWM-Theme${RESET}"; exit 1
    fi
    
    cd ..
    
    if ! rm -rf leftwm-theme;
    then
        echo "${RED}Failed removing leftwm-theme${RESET}"; exit 1
    else
        echo "${MAGENTA}Succesfully installed LeftWM-Theme${RESET}"
    fi
}

function install_fonts () {
    if ! git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git; then
        echo "${RED}Failed pulling NerdFonts${RESET}"; exit 1
    fi
    
    cd nerd-fonts || { echo "Failure NerdFonts"; exit 1; }
    
    if ! ./install.sh Hack; then
        echo "${RED}Failed installing Hack Font${RESET}"; exit 1
    fi
    
    if ! ./install.sh IBMPlexMono; then
        echo "${RED}Failed installing IBMPlexMono Font${RESET}"; exit 1
    fi
    
    if ! ./install.sh FiraCode; then
        echo "${RED}Failed installing FiraCode Font${RESET}"; exit 1
    fi
    
    if ! ./install.sh FiraMono; then
        echo "${RED}Failed installing FiraMono Font${RESET}"; exit 1
    fi
    
    if ! ./install.sh SourceCodePro; then
        echo "${RED}Failed installing SourceCodePro Font${RESET}"; exit 1
    fi
    
    if ! ./install.sh JetBrainsMono; then
        echo "${RED}Failed installing Hack JetBrainsMono${RESET}"; exit 1
    fi
    
    cd ..
    if ! rm -rf nerd-fonts;
    then
        echo "${RED}Failed installing fonts${RESET}"; exit 1
    else
        echo "${MAGENTA}Succesfully installed fonts${RESET}"
    fi
}

function set_hostname () {
    if ! sudo hostname "$1";
    then
        echo "${RED}Failed setting hostname${RESET}"; exit 1
    else
        echo "${MAGENTA}Succesfully set hostname${RESET}"
    fi
}

function cleanup () {
    if [[ "$PWD" =~ "temp" ]];
    then
    x=$PWD
    y=${x%%temp*}
    cd "$y" || { echo "Failure cleanup"; exit 1; }
        if ! rm -rf temp;
        then
            echo "${RED}Failed removing temp folder${RESET}"; exit 1
        else
            echo "${MAGENTA}Succesfully removed temp folder${RESET}"
        fi
    fi

    sudo dnf upgrade --best --allowerasing --refresh -y
    sudo dnf distro-sync -y
}

# <<<<<<<<<<<<<<<<<<<<<<<< functions <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> main code >>>>>>>>>>>>>>>>>>>>>>>>
trap on_ctrl_c SIGINT

if [ "$(id -u)" = 0 ]; then
    echo "This script should not be run as root!"
    echo -e "You may need to enter your password ${RED}multiple${RESET} times!"
    exit 1
fi

echo -e "${MAGENTA}GPGNR Fedora minimal install script${RESET}"

POSITIONAL=()
while (( $# > 0 )); do
    case "${1}" in
        -h|--help)
            echo "run script as"
            echo "./install.sh"
            echo "or"
            echo -e "./install.sh -n ${MAGENTA}new_hostname${RESET}"
            exit 0
        ;;
        -n|--name)
            numOfArgs=1
            if (( $# < numOfArgs + 1 )); then
                shift $#
            else
                hostName=$2
                shift $((numOfArgs + 1))
            fi
        ;;
        *)
            POSITIONAL+=("${1}")
            shift
        ;;
    esac
done

set -- "${POSITIONAL[@]}"
mkdir temp
cd temp || { echo "Failure creating temp folder"; exit 1; }

install_dependencies &&
install_gnome &&
install_LeftWM &&
install_fonts &&
install_applications &&

if [[ "${hostName}" != "" ]]; then
    set_hostname "${hostName}"
fi

cleanup

echo "Please Reboot" && exit 0
# <<<<<<<<<<<<<<<<<<<<<<<< main code <<<<<<<<<<<<<<<<<<<<<<<<
