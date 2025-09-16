#!/bin/bash

source ./common.sh
app_name=payment

verify_root
app_setup
python_install
systemd_setup
print_time