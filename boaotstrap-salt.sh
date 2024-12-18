#!/usr/bin/env bash
set -Eeu

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __fetch_url
#  DESCRIPTION:  Retrieves a URL and writes it to a given path
#----------------------------------------------------------------------------------------------------------------------
__fetch_url() {

    # shellcheck disable=SC2086
    curl -L -s -f -o "$1" "$2" >/dev/null 2>&1     ||
        wget -q -O "$1" "$2" >/dev/null 2>&1       ||
            fetch -q -o "$1" "$2" >/dev/null 2>&1 ||  # FreeBSD
                fetch -q -o "$1" "$2" >/dev/null 2>&1          ||  # Pre FreeBSD 10
                    ftp -o "$1" "$2" >/dev/null 2>&1           ||  # OpenBSD
                        (echoerror "$2 failed to download to $1"; exit 1)
}

# Download the bootstrap-salt.sh script using __fetch_url
__fetch_url "bootstrap-salt.sh" "https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.sh"

# Run the downloaded script
sh bootstrap-salt.sh

# Check if the script was successful
if [ $? -eq 0 ]; then
    echo "Bootstrap script ran successfully."
    # Run the salt-pip install command
    echo "Installing Credstash."
    salt-pip install credstash
    echo "Corteva Bootstrap Complete."
else
    echo "Bootstrap script failed."
    exit 1
fi
