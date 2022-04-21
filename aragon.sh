#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./all_functions.sh
#source "$(pwd -P)/all_functions.sh" "${BASH_SOURCE[0]}"

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
nvm install 10.24.1
nvm use 10.24.1
sudo npm install -g @aragon/cli
aragon -v

aragon dao install

log_end_of_script
