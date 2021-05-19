#!/bin/bash

printf '%s\n' "${SUDO_USER:-$USER}"

echo $(ip route | grep default | cut -d ' ' -f 3)
