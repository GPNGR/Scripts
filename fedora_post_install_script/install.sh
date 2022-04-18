#!/usr/bin/env bash

#!/usr/bin/env bash

# Title: Fedora post install script
# Description: Script to install dependencies and applications on a minimal Fedora install.
# This script is mostly a test and provided AS IS!
# Author: GPNGR
# Date: 2022/04/18
# Version: 0.2

# >>>>>>>>>>>>>>>>>>>>>>>> formatting >>>>>>>>>>>>>>>>>>>>>>>>
RED=$(tput setaf 1)
MAGENTA=$(tput setaf 5)
RESET=$(tput sgr0)
# <<<<<<<<<<<<<<<<<<<<<<<< formatting <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> variables >>>>>>>>>>>>>>>>>>>>>>>>
hostName=''
cwd=$PWD
# <<<<<<<<<<<<<<<<<<<<<<<< variables <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> event handlers >>>>>>>>>>>>>>>>>>>>>>>>
function on_ctrl_c() {
    echo       # Set cursor to the next line of '^C'
    tput cnorm # show cursor. You need this if animation is used.
    cleanup && exit 1
}
# <<<<<<<<<<<<<<<<<<<<<<<< event handlers <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions >>>>>>>>>>>>>>>>>>>>>>>>
function install_dependencies() {
    if ! sudo dnf install -y Xorg xinit nano; then
        echo "${RED}Failed installing dependencies${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed dependencies${RESET}"
    fi
}

function install_sddm() {
    if ! sudo dnf install -y sddm; then
        echo "${RED}Failed installing sddm${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed sddm${RESET}"
    fi

    if ! systemctl set-default graphical.target; then
        echo "${RED}Failed installing dependencies${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed dependencies${RESET}"
    fi

    if ! sudo systemctl enable sddm; then
        echo "${RED}Failed installing dependencies${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed dependencies${RESET}"
    fi
}

function install_qtile() {
    if ! sudo dnf install -y polybar rofi alacritty; then
        echo "${RED}Failed installing Qtile${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed Qtile${RESET}"
    fi
    sudo dnf copr enable frostyx/qtile
    if ! sudo dnf install -y qtile; then
        echo "${RED}Failed installing Qtile${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed Qtile${RESET}"
    fi
}

function install_applications() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update

    if
        ! sudo dnf install -y code \
            thefuck \
            ripgrep \
            exa \
            bat \
            fd-find \
            fish \
            starship \
            neovim \
            python3-neovim \
            bpytop \
            neofetch \
            ranger \
            nemo \
            git \
            gzip \
            tar \
            wget \
            curl \
            rust \
            cargo
    then
        echo "${RED}Failed installing applications${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed applications${RESET}"
    fi

    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    if ! flatpak install flathub io.gitlab.librewolf-community \
        im.pidgin.Pidgin \
        com.discordapp.Discord \
        com.bitwarden.desktop \
        com.spotify.Client; then
        echo "${RED}Failed installing flatpaks${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed flatpaks${RESET}"
    fi

    if ! curl -sLf https://spacevim.org/install.sh | bash; then
        echo "${RED}Failed installing spacevim${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed spacevim${RESET}"
    fi
    curl -s https://api.github.com/repos/wtfutil/wtf/releases/latest |
        grep "browser_download_url.*linux_amd64.tar.gz" |
        cut -d : -f 2,3 |
        tr -d \" |
        wget -qi -

    F=$(ls | grep ".tar.gz")

    if ! tar -xf "$F"; then
        echo "${RED}Failed decompressing wtfutil${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully decompressed wtfutil${RESET}"
    fi
    DIR=${F%%".tar.gz"}
    cd "$DIR" || {
        echo "Failure wtfutil"
        exit 1
    }

    if ! sudo cp wtfutil /usr/local/wtfutil; then
        echo "${RED}Failed copying wtfutil${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully copyed wtfutil${RESET}"
    fi
    if ! sudo chmod a+x /usr/local/bin/wtfutil; then
        echo "${RED}Failed installing wtfutil${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed wtfutil${RESET}"
    fi
}

function install_bluetooth() {
    if ! sudo dnf install -y blueman bluez bluez-tools blueberry; then
        echo "${RED}Failed installing bluetooth${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed bluetooth${RESET}"
    fi
}

function install_networking() {
    if ! sudo dnf install -y avahi nss-mdns gvfs; then
        echo "${RED}Failed installing audio${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed audio${RESET}"
    fi
}

function install_laptop_specifics() {
    if ! sudo dnf install lm_sensors tlp upower brightnessctl light; then
        echo "${RED}Failed installing laptop specifics${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed laptop specifics${RESET}"
    fi
}

function install_audio() {
    if ! sudo dnf install -y pipewire wireplumber audioicon; then
        echo "${RED}Failed installing audio${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed audio${RESET}"
    fi
}

function setup() {
    echo "${MAGENTA}Change Shell${RESET}"
    lchsh "$USER"
}

function install_fonts() {
    if ! git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git; then
        echo "${RED}Failed pulling NerdFonts${RESET}"
        exit 1
    fi

    cd nerd-fonts || {
        echo "Failure NerdFonts"
        exit 1
    }

    if ! ./install.sh Hack; then
        echo "${RED}Failed installing Hack Font${RESET}"
        exit 1
    fi

    if ! ./install.sh IBMPlexMono; then
        echo "${RED}Failed installing IBMPlexMono Font${RESET}"
        exit 1
    fi

    if ! ./install.sh FiraCode; then
        echo "${RED}Failed installing FiraCode Font${RESET}"
        exit 1
    fi

    if ! ./install.sh FiraMono; then
        echo "${RED}Failed installing FiraMono Font${RESET}"
        exit 1
    fi

    if ! ./install.sh SourceCodePro; then
        echo "${RED}Failed installing SourceCodePro Font${RESET}"
        exit 1
    fi

    if ! ./install.sh JetBrainsMono; then
        echo "${RED}Failed installing Hack JetBrainsMono${RESET}"
        exit 1
    fi

    cd ..
    if ! rm -rf nerd-fonts; then
        echo "${RED}Failed installing fonts${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully installed fonts${RESET}"
    fi
}

function set_hostname() {
    if ! sudo hostname "$1"; then
        echo "${RED}Failed setting hostname${RESET}"
        exit 1
    else
        echo "${MAGENTA}Successfully set hostname${RESET}"
    fi
}

function cleanup() {
    if [[ "$PWD" =~ "temp" ]]; then
        x=$PWD
        y=${x%%temp*}
        cd "$y" || {
            echo "Failure cleanup"
            exit 1
        }
        if ! rm -rf temp; then
            echo "${RED}Failed removing temp folder${RESET}"
            exit 1
        else
            echo "${MAGENTA}Successfully removed temp folder${RESET}"
        fi
    fi
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
while (($# > 0)); do
    case "${1}" in
    -h | --help)
        echo "run script as"
        echo "./install.sh"
        echo "or"
        echo -e "./install.sh -n ${MAGENTA}new_hostname${RESET}"
        exit 0
        ;;
    -n | --name)
        numOfArgs=1
        if (($# < numOfArgs + 1)); then
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
cd temp || {
    echo "Failure creating temp folder"
    exit 1
}
install_dependencies &&
    install_sddm &&
    install_qtile &&
    install_applications &&
    install_audio &&
    install_networking &&
    install_bluetooth &&
    install_laptop_specifics &&
    install_fonts &&
    setup &&
    if [[ "${hostName}" != "" ]]; then
        set_hostname "${hostName}"
    fi

cleanup

echo "Please reboot" && exit 0
# <<<<<<<<<<<<<<<<<<<<<<<< main code <<<<<<<<<<<<<<<<<<<<<<<<
