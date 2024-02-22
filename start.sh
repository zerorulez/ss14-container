#!/bin/bash
set -x

export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new -i /home/watchdog/.ssh/id_rsa"
export TargetFramework=net8.0
#export USE_SYSTEM_SQLITE=1

export DOTNET_FLAGS="-p USE_SYSTEM_SQLITE=1 --self-contained"


if [ -z "$PLATFORM" ]; then
	PLATFORM=arm64
fi
export PACKAGE_BUILD_ARGS="-p linux-$PLATFORM"

git_pull(){
	git -C src pull
	git -C src submodule update --init --recursive --force
	git -C src/Resources/Mining pull
}

git_clone(){
	git clone --single-branch --depth 1 https://github.com/Partmedia/mining-station-14 src
	git -C src submodule update --init --recursive --force
	pushd src/Resources
	git clone --single-branch --depth 1 ssh://git@github.com/Partmedia/ms14-resources Mining
	popd
}

git_rev(){
	git -C src show -s --pretty=format:'%h'
	printf -
	git -C src/Resources/Mining show -s --pretty=format:'%h'
}


if [ ! -d src ]; then
	CHANGED=1
	git_clone
else
	REV="`git_rev`"
	git_pull
	if [ "$REV" != "`git_rev`" ]; then
		CHANGED=1
	fi
fi


build (){
	pushd src
	make package
	popd
}

unpack(){
	rm -rf Resources > /dev/null
	rm *.dll *.pdb *.json *.so Content.Client.zip Robust.Packaging Robust.Server > /dev/null
        if [ -f server_config.toml ]; then
                unzip ../src/release/SS14.Server_linux-$PLATFORM.zip -x server_config.toml
        else
                unzip ../src/release/SS14.Server_linux-$PLATFORM.zip
        fi
}

if [ -n "$CHANGED" ]; then
	build
	mkdir -p ms14
	cd ms14
	unpack
else
	cd ms14
	echo "Nenhuma atualização a fazer!"
fi

run(){
	./Robust.Server
}

while true; do
	run
	sleep 30
done


