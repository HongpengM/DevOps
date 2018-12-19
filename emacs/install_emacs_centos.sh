#!/bin/bash

function download_emacs(){
    wget http://ftp.wayne.edu/gnu/emacs/emacs-26.1.tar.gz
    wget http://ftp.wayne.edu/gnu/emacs/emacs-26.1.tar.gz.sig
}
# If emacs installer valid, return true
# Else, return false in the invalid case.

function verify_emacs_installer(){
    # import GNU keyrings| TODO only import emacs keys
    echo "Import GNU keyrings"
    gpg --import <(curl https://ftp.gnu.org/gnu/gnu-keyring.gpg) 1> /dev/null 2>&1
    echo "Verify downloaded package"
    # Get verified case
    verify_result=$(gpg --verify emacs-26.1.tar.gz.sig emacs-26.1.tar.gz 2>&1)
    echo "Verify string" $verify_result
    if [[ $verify_result == *"Good signature from"* ]]; then
	# 0 = true
	return 0
    else
	# 1 = false
	return 1
    fi;
}
function remove_unverified_installer(){
    rm emacs-*.tar.*
}
function verify_downloaded_recent(){
    if verify_emacs_installer; then
	echo "downloaded package usable"
    else
	echo "downloaded failed to pass verification"
	remove_unverified_installer
    fi;
}
emacs_file=`ls emacs-*.tar.gz`
emacs_sig="${emacs_file}.sig"
echo  $emacs_file $emacs_sig
if [ -z $emacs_file ] && [ -z $emacs_sig ]; then
    echo "download emacs"
    download_emacs
elif [ -z $emacs_file ] || [ -z $emacs_sig ]; then
    echo "clean emacs downloads"
    remove_unverified_installer
    echo "download emacs"
    download_emacs
    verify_downloaded_recent
elif verify_emacs_installer; then
    echo "verified pass"
else
    echo "download and verify, if failed exit"
    verify_downloaded_recent
fi;


tar -xzf $emacs_file
emacs_dir=`find . -maxdepth 1 -type d -name "emacs*"`
echo "Emacs dir " $emacs_dir
emacs_build_dir="${emacs_dir}/build"
mkdir -p $emacs_build_dir
cd $emacs_build_dir && bash ../configure --without-x --with-gnutls=no
cd $emacs_build_dir && make 

#if ls emacs*.tar.gz 1> /dev/null 2>&1; then
#    echo " emacs installation file not exist "
#    download_emacs
#else
#    continue
#fi;

# wget http://ftp.wayne.edu/gnu/emacs/emacs-26.1.tar.gz
# wget http://ftp.wayne.edu/gnu/emacs/emacs-26.1.tar.gz.sig
# curl -O http://ftp.wayne.edu/gnu/emacs/emacs-26.1.tar.gz
# curl -O http://ftp.wayne.edu/gnu/emacs/emacs-26.1.tar.gz.sig

