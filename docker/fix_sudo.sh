#!/bin/bash

# Fix sudoers to not ask wheel group users for password
echo "%wheel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
