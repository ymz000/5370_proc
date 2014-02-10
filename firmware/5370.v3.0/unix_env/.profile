# ~/.profile: executed by Bourne-compatible login shells.

if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# path set by /etc/profile
# export PATH

export PATH=.:$PATH

export LS_OPTIONS='--color=auto'
export PROJ=5370
