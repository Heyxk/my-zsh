main() {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e

  if ! command -v zsh >/dev/null 2>&1; then
    printf "${YELLOW}Zsh is not installed!${NORMAL} Please install zsh first!\n"
    exit
  fi

  if [ ! -n "$ZSH" ]; then
    ZSH=~/.oh-my-zsh
  fi
  
  if [ ! -d "$ZSH" ]; then
    printf "${YELLOW}Oh My Zsh is not installed.${NORMAL}\n"
    printf "${RED}You'll need to install Oh My Zsh first!${NORMAL}\n"
    exit
  fi
  
  if [ ! -n "$MYZSH" ]; then
    MYZSH=~/.oh-my-zsh/custom
  fi

  if [ -d "$MYZSH" ]; then
    printf "${YELLOW}My Zsh has been installed.${NORMAL}\n"
    printf "${RED}You'll need to delete "$MYZSH" first!${NORMAL}\n"    
    exit
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  printf "${BLUE}Cloning My Zsh...${NORMAL}\n"
  command -v git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }

  env git clone --depth=1 https://gitee.com/xiangk/my-zsh.git "$MYZSH" || {
    printf "Error: git clone of my-zsh repo failed\n"
    exit 1
  }


  cd "$MYZSH"
  git submodule init
  git submodule update
  cd "$MYZSH"/plugins/zsh-syntax-highlighting
  git checkout master
  git pull origin master


  printf "${BLUE}Looking for an existing zsh config...${NORMAL}\n"
  if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
    printf "${YELLOW}Found ~/.zshrc.${NORMAL} ${GREEN}Backing up to ~/.zshrc.pre-oh-my-zsh${NORMAL}\n";
    mv ~/.zshrc ~/.zshrc.pre-oh-my-zsh;
  fi

  printf "${BLUE}Using the My Zsh template file and adding it to ~/.zshrc${NORMAL}\n"
  cp "$MYZSH"/zshrc ~/.zshrc


  printf "${GREEN}"
  echo '                                  __   '
  echo '   ____ ___  __  __   ____  _____/ /_  '
  echo '  / __ `__ \/ / / /  /_  / / ___/ __ \ '
  echo ' / / / / / / /_/ /    / /_(__  ) / / / '
  echo '/_/ /_/ /_/\__, /    /___/____/_/ /_/  '
  echo '          /____/                       ....is now installed!'
  echo ''
}

main
