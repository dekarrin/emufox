#!/bin/bash

error()
{
	msg=
	[ -n "$2" ] && msg="$(basename $0): $2"
	echo "$msg" >&2
	exit $1
}

if [ $# -lt 1 ]
then
	error 1 "First argument must be path to EmuFox root (which will be created)"
fi
install_dir="$1"

cd "$(dirname $(realpath "$0"))"

[ "$(id -u)" == 0 ] || error 2 "root permissions are required"
[ -n "$(screen --version 2>/dev/null)" ] || error 3 "error; 'screen' is not installed/invokable on this system"
[ -n "$(getent group kvm)" ] || error 4 "error; 'kvm' group does not exist"

good_emu=
while [ -z "$good_emu" ]
do
	read -p "Enter command to invoke QEMU (without arguments): " qcmd
	if [ -n "$($qcmd --version 2>/dev/null)" ]
	then
		good_emu=1
	else
		echo "'$qcmd' could not be executed!"
	fi
done

# say '/var/vms'
mkdir -p "$install_dir"
cp -r images "$install_dir"
cp -r scripts "$install_dir"
cp -r profiles "$install_dir"
cp LICENSE README.md vm "$install_dir"

sed -e 's/^_emu_cmd=.*$/_emu_cmd='"$qcmd"'/' emufox.conf > "$install_dir"/emufox.conf

rm -f "$install_dir"/images/.gitignore

chown -R root:kvm "$install_dir"
chmod -R 770 "$install_dir"
chmod g+s "$install_dir" "$install_dir/images" "$install_dir/profiles" "$install_dir/scripts"

ln -s "$install_dir"/vm /usr/bin/vm

echo "successfully installed to '$install_dir'"

