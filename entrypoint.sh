#!/usr/bin/env bash

if [ -z "$BP_URL" ]; then
	export BP_URL="https://github.com/cloudfoundry/go-buildpack.git"
else
	echo "Buildpack defined by user"
fi

if [ -z "$BP_VERSION" ]; then
	export BP_VERSION="v1.2.0"
else
	echo "Buildpack version defined by user"
fi

git clone $BP_URL /buildpack && cd /buildpack && git checkout $BP_VERSION && git submodule update --init --recursive

# Here we detect if the file is zipped
if [ "$(file /object | grep -b -i directory | wc -l)" -eq 1 ];then
	cp -rp /object/* $HOME
else
	echo "You must bind a Directory with your code to the /object path"
	exit 1
fi
cd $HOME
/buildpack/bin/compile $HOME $TMPDIR
if [ -d $HOME/.profile.d ]; then
	for profile in $(ls $HOME/.profile.d); do
		source $HOME/.profile.d/$profile
	done
fi
$RUN_COMMAND
