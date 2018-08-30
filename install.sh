#!/usr/bin/env bash

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

ln -sf "$CUR_DIR/bashrc" ~/.bashrc
ln -sf "$CUR_DIR/vimrc" ~/.vimrc
ln -sf "$CUR_DIR/tmux.conf" ~/.tmux.conf
ln -sf "$CUR_DIR/inputrc" ~/.inputrc

if [[ -e ~/.local/bin/ ]]; then
   for s in $(ls $CUR_DIR/bin/*.*); do
      ln -sf "$s" ~/.local/bin/
   done

   # SSHRC setup
   if which sshrc 1>/dev/null 2>&1; then
      if [[ -e "$CUR_DIR/submodules/sshrc/sshrc" ]]; then
         ln -sf "$CUR_DIR/submodules/sshrc/sshrc" ~/.local/bin/
      else
         echo "WARN: Submodules may not be initialized. Run `git submodule init`"
      fi
   fi
else
   echo "WARN: '~/.local/bin' does not exist."
fi

if [[ -e "$CUR_DIR/submodules/vim-pathogen/autoload/pathogen.vim" ]]; then
   mkdir -p ~/.vim/autoload || true
   ln -sf "$CUR_DIR/submodules/vim-pathogen/autoload/pathogen.vim" ~/.vim/autoload/
   if [[ -e "$CUR_DIR/submodules/vim-sleuth/" ]]; then
      mkdir -p ~/.vim/bundle/ || true
      ln -sf "$CUR_DIR/submodules/vim-sleuth" ~/.vim/bundle/
   else
      echo "WARN: vim-sleuth no intialized. Run `git submodule init`"
   fi
   if [[ -e "$CUR_DIR/submodules/vim-sleuth/plugin/sleuth.vim" ]]; then
      mkdir -p ~/.vim/bundle/ || true
      ln -sf "$CUR_DIR/submodules/vim-go" ~/.vim/bundle/
   else
      echo "WARN: vim-go no intialized. Run `git submodule init`"
   fi
else
   echo "WARN: vim-pathogen no intialized. Run `git submodule init`"
fi

echo "Done!"
