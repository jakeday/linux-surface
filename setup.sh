#!/bin/sh

LX_BASE=""
LX_VERSION=""

if [ -r /etc/os-release ]; then
    . /etc/os-release
	if [ $ID = arch ]; then
		LX_BASE=$ID
    elif [ $ID = ubuntu ]; then
		LX_BASE=$ID
		LX_VERSION=$VERSION_ID
	elif [ ! -z "$UBUNTU_CODENAME" ] ; then
		LX_BASE="ubuntu"
		LX_VERSION=$VERSION_ID
    else
		LX_BASE=$ID
		LX_VERSION=$VERSION
    fi
else
    echo "Could not identify your distro. Please open script and run commands manually."
	exit
fi

SUR_MODEL="$(dmidecode | grep "Product Name" -m 1 | xargs | sed -e 's/Product Name: //g')"
SUR_SKU="$(dmidecode | grep "SKU Number" -m 1 | xargs | sed -e 's/SKU Number: //g')"

echo -e "\nRunning ${LX_BASE^} version $LX_VERSION on a $SUR_MODEL."

read -rp "Press enter if this is correct, or CTRL-C to cancel. " cont;echo

echo -e "Continuing setup...\n"

echo -e "Copying the config files under root to where they belong..."
for dir in $(ls root/); do cp -Rb root/$dir/* /$dir/; done

echo -e "\nMaking /lib/systemd/system-sleep/sleep executable...\n"
chmod a+x /lib/systemd/system-sleep/sleep

echo -e "Suspend is recommended over hibernate. If you chose to use hibernate, please make sure you've setup your swap file per the instructions in the README.\n"
read -rp "Do you want to replace suspend with hibernate? (type yes or no) " usehibernate;echo

if [ "$usehibernate" = "yes" ]; then
	if [ "$LX_BASE" = "ubuntu" ] && [ 1 -eq "$(echo "${LX_VERSION} >= 17.10" | bc)" ]; then
		echo -e "Using Hibernate instead of Suspend...\n"
		ln -sfb /lib/systemd/system/hibernate.target /etc/systemd/system/suspend.target && sudo ln -sfb /lib/systemd/system/systemd-hibernate.service /etc/systemd/system/systemd-suspend.service
	else
		echo -e "Using Hibernate instead of Suspend...\n"
		ln -sfb /usr/lib/systemd/system/hibernate.target /etc/systemd/system/suspend.target && sudo ln -sfb /usr/lib/systemd/system/systemd-hibernate.service /etc/systemd/system/systemd-suspend.service
	fi
else
	echo -e "Not touching Suspend\n"
fi

if [ -x "$(command -v dpkg)" ]; then
	echo -e "Patched libwacom packages are available to better support the pen."
	
	echo -e "If you intend to use the pen, it's recommended that you install them!\n"

	read -rp "Do you want to install the patched libwacom packages through dpkg? (type yes or no) " uselibwacom;echo

	if [ "$uselibwacom" = "yes" ]; then
		echo -e "Installing patched libwacom packages..."
			dpkg -i packages/libwacom/*.deb
			apt-mark hold libwacom
	else
		echo -e "Not touching libwacom\n"
	fi
elif [ -x "$(command -v pacman)" ]; then
	echo -e "Patched libwacom packages are available to better support the pen."
	    
	echo -e "If you intend to use the pen, it's recommended that you install them!"
	    
	echo -e "You can install them through this AUR package: https://aur.archlinux.org/packages/libwacom-surface\n"
elif [ -x "$(command -v yum)" ]; then
	echo -e "Patched libwacom packages are available to better support the pen."
	
	echo -e "If you intend to use the pen, it's recommended that you install them!"
	
	echo -e "You can install them through this Fedora repository: https://github.com/StollD/fedora-linux-surface\n"
else
	echo -e "Patched libwacom packages are available to better support the pen."
	
	echo -e "If you intend to use the pen, it's recommended that you install them!"
	
	echo -e "You can install them through this Git repository: https://github.com/qzed/libwacom-surface\n"
fi

echo -e "This repo comes with an example xorg config. If you chose to keep it, be sure to rename it and uncomment out what you'd like to keep!\n"

read -rp "Do you want to remove the example intel xorg config? (type yes or no) " removexorg;echo

if [ "$removexorg" = "yes" ]; then
	echo -e "Removing the example intel xorg config...\n"
		rm /etc/X11/xorg.conf.d/20-intel_example.conf
else
	echo -e "Not touching example intel xorg config (/etc/X11/xorg.conf.d/20-intel_example.conf)\n"
fi

echo -e "This repo comes with an example pulse audio config. If you chose to keep it, be sure to rename it and uncomment out what you'd like to keep!\n"
read -rp "Do you want to remove the example pulse audio config files? (type yes or no) " removepulse;echo

if [ "$removepulse" = "yes" ]; then
	echo -e "Removing the example pulse audio config files..."
		rm /etc/pulse/daemon_example.conf
		rm /etc/pulse/default_example.pa
else
	echo -e "Not touching example pulse audio config files (/etc/pulse/*_example.*)"
fi

if [ "$SUR_MODEL" = "Surface Pro 3" ]; then
	echo -e "\nInstalling i915 firmware for Surface Pro 3...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_bxt.zip -d /lib/firmware/i915/

	echo -e "\nRemove unneeded udev rules for Surface Pro 3...\n"
	rm /etc/udev/rules.d/98-keyboardscovers.rules
fi

if [ "$SUR_MODEL" = "Surface Pro" ]; then
	echo -e "\nInstalling IPTS firmware for Surface Pro 2017...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v102.zip -d /lib/firmware/intel/ipts/

	echo -e "\nInstalling i915 firmware for Surface Pro 2017...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Pro 4" ]; then
	echo -e "\nInstalling IPTS firmware for Surface Pro 4...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v78.zip -d /lib/firmware/intel/ipts/

	echo -e "\nInstalling i915 firmware for Surface Pro 4...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_skl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Pro 2017" ]; then
	echo -e "\nInstalling IPTS firmware for Surface Pro 2017...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v102.zip -d /lib/firmware/intel/ipts/

	echo -e "\nInstalling i915 firmware for Surface Pro 2017...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Pro 6" ]; then
	echo -e "\nInstalling IPTS firmware for Surface Pro 6...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v102.zip -d /lib/firmware/intel/ipts/

	echo -e "\nInstalling i915 firmware for Surface Pro 6...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Studio" ]; then
	echo -e "\nInstalling IPTS firmware for Surface Studio...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v76.zip -d /lib/firmware/intel/ipts/

	echo -e "\nInstalling i915 firmware for Surface Studio...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_skl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Laptop" ]; then
	echo -e "\nInstalling IPTS firmware for Surface Laptop...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v79.zip -d /lib/firmware/intel/ipts/

	echo -e "\nInstalling i915 firmware for Surface Laptop...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Laptop 2" ]; then
	echo -e "\nInstalling IPTS firmware for Surface Laptop 2...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v79.zip -d /lib/firmware/intel/ipts/

	echo -e "\nInstalling i915 firmware for Surface Laptop 2...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Book" ]; then
	echo -e "\nInstalling IPTS firmware for Surface Book...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v76.zip -d /lib/firmware/intel/ipts/

	echo -e "\nInstalling i915 firmware for Surface Book...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_skl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Book 2" ]; then
	echo -e "\nInstalling IPTS firmware for Surface Book 2...\n"
	mkdir -p /lib/firmware/intel/ipts
	if [ "$SUR_SKU" = "Surface_Book_1793" ]; then
		unzip -o firmware/ipts_firmware_v101.zip -d /lib/firmware/intel/ipts/
	else
		unzip -o firmware/ipts_firmware_v137.zip -d /lib/firmware/intel/ipts/
	fi

	echo -e "\nInstalling i915 firmware for Surface Book 2...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/

	echo -e "\nInstalling nvidia firmware for Surface Book 2...\n"
	mkdir -p /lib/firmware/nvidia/gp108
	unzip -o firmware/nvidia_firmware_gp108.zip -d /lib/firmware/nvidia/gp108/
	mkdir -p /lib/firmware/nvidia/gv100
	unzip -o firmware/nvidia_firmware_gv100.zip -d /lib/firmware/nvidia/gv100/
fi

if [ "$SUR_MODEL" = "Surface Go" ]; then
	echo -e "\nInstalling ath10k firmware for Surface Go...\n"
	mkdir -p /lib/firmware/ath10k
	unzip -o firmware/ath10k_firmware.zip -d /lib/firmware/ath10k/

	if [ ! -f "/etc/init.d/surfacego-touchscreen" ]; then
		echo -e "\nPatching power control for Surface Go touchscreen...\n"
		echo -e "#!/bin/sh" >> /etc/init.d/surfacego-touchscreen
		echo -e "\n# chkconfig: 345 99 01" >> /etc/init.d/surfacego-touchscreen
		echo -e "\n# description: Surface Go Touchscreen Fix" >> /etc/init.d/surfacego-touchscreen
		echo -e "\necho \"on\" > /sys/devices/pci0000:00/0000:00:15.1/i2c_designware.1/power/control" >> /etc/init.d/surfacego-touchscreen
		chmod 755 /etc/init.d/surfacego-touchscreen
		if [ "$LX_BASE" = "ubuntu" ]; then
			update-rc.d surfacego-touchscreen defaults
		else
			systemctl enable surfacego-touchscreen
		fi
	fi
fi

echo -e "\nInstalling marvell firmware...\n"
mkdir -p /lib/firmware/mrvl/
unzip -o firmware/mrvl_firmware.zip -d /lib/firmware/mrvl/

echo -e "\nInstalling mwlwifi firmware...\n"
mkdir -p /lib/firmware/mwlwifi/
unzip -o firmware/mwlwifi_firmware.zip -d /lib/firmware/mwlwifi/

echo -e ""
read -rp "Do you want to set your clock to local time instead of UTC? This fixes issues when dual booting with Windows. (type yes or no) " uselocaltime;echo

if [ "$uselocaltime" = "yes" ]; then
	echo -e "Setting clock to local time...\n"

	timedatectl set-local-rtc 1
	hwclock --systohc --localtime
else
	echo -e "Not setting clock\n"
fi

if [ -x "$(command -v dpkg)" ]; then
	read -rp "Do you want this script to download and install the latest kernel for you? (type yes or no) " autoinstallkernel;echo

	if [ "$autoinstallkernel" = "yes" ]; then
		echo -e "Downloading latest kernel...\n"

		urls=$(curl --silent "https://api.github.com/repos/jakeday/linux-surface/releases/latest" | tr ',' '\n' | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/')

		resp=$(wget -P tmp $urls)

		echo -e "Installing latest kernel...\n"

		dpkg -i tmp/*.deb
		rm -rf tmp
	else
		echo -e "Not downloading latest kernel"
	fi
elif [ -x "$(command -v pacman)" ]; then
	echo -e "To make features like the touchscreen or battery stats work correctly, you have to install a patched kernel!"
	
	echo -e "For Arch-based distributions, the compiled versions can be found here: https://github.com/dmhacker/arch-linux-surface"
elif [ -x "$(command -v yum)" ]; then
	echo -e "To make features like the touchscreen or battery stats work correctly, you have to install a patched kernel!"
	
	echo -e "For Fedora, the compiled versions can be found here: https://github.com/StollD/fedora-linux-surface"
else
	echo -e "To make features like the touchscreen or battery stats work correctly, you have to install a patched kernel!"
	
	echo -e "However, there doesn't seem to be a known repository with prebuilt kernels for your distribution."
	
	echo -e "For instructions on how to compile from source, please refer to the README.md file."
fi

echo -e "\nAll done! Please reboot."
