#!/usr/bin/env bash
#
# AGNI Kernel SELinux Injector
# GKI 5.10 + KernelSU / KernelSU Next
#
# Inject custom SELinux rules into KernelSU rules.c
#

set -e


SELINUX_RULES_C="drivers/kernelsu/selinux/rules.c"

MARKER="rcu_assign_pointer(selinux_state.policy, pol);"


# ==========================================================
# KernelSU Check
# ==========================================================

if [ ! -f "$SELINUX_RULES_C" ]; then

    echo "⚠️ KernelSU SELinux file not found:"
    echo "$SELINUX_RULES_C"

    echo "Skipping SELinux injection"

    exit 0

fi



echo "======================================"
echo " AGNI SELinux Injection"
echo "======================================"



# ==========================================================
# Injector Function
# ==========================================================

inject_selinux()
{

local NAME="$1"
local RULES="$2"


echo ""
echo "🔐 Injecting ${NAME} rules..."



python3 - "$SELINUX_RULES_C" "$MARKER" "$RULES" <<'PY'

import sys


file = sys.argv[1]
marker = sys.argv[2]
rules = sys.argv[3]


with open(file,"r") as f:
    data=f.read()



rules = rules.replace("\\n","\n")



if rules in data:

    print("⚠️ Already injected")

    sys.exit(0)



if marker not in data:

    print("❌ SELinux marker not found")

    sys.exit(1)



data = data.replace(

    marker,

    "/* AGNI SELinux Rules */\n"
    + rules
    + "\n\n"
    + marker,

    1

)



with open(file,"w") as f:

    f.write(data)



print("✅ Injected")

PY

}

# ==========================================================
# NTSYNC
# ==========================================================

inject_selinux "NTSYNC" \
'ksu_allow(db, "kernel", "device", "chr_file", "setattr");\n\
ksu_allow(db, "kernel", "device", "chr_file", "relabelfrom");\n\
ksu_allow(db, "kernel", "gpu_device", "chr_file", "relabelto");\n\
ksu_allow(db, "kernel", "gpu_device", "chr_file", "setattr");\n\
ksu_allow(db, "untrusted_app", "gpu_device", "chr_file", "read");\n\
ksu_allow(db, "untrusted_app", "gpu_device", "chr_file", "write");\n\
ksu_allow(db, "untrusted_app", "gpu_device", "chr_file", "open");\n\
ksu_allow(db, "untrusted_app", "gpu_device", "chr_file", "ioctl");'



# ==========================================================
# VINDICATOR
# ==========================================================

inject_selinux "Vindicator" \
'ksu_allow(db, "kernel", "sysfs", "dir", "search");\n\
ksu_allow(db, "kernel", "sysfs", "dir", "getattr");\n\
ksu_allow(db, "kernel", "sysfs", "file", "read");\n\
ksu_allow(db, "kernel", "sysfs", "file", "write");\n\
ksu_allow(db, "kernel", "sysfs", "file", "open");'



# ==========================================================
# NOCTURNE
# ==========================================================

inject_selinux "Nocturne" \
'ksu_allow(db, "kernel", "cgroup", "dir", "search");\n\
ksu_allow(db, "kernel", "cgroup", "file", "read");\n\
ksu_allow(db, "kernel", "cgroup", "file", "write");\n\
ksu_allow(db, "kernel", "sysfs_backlight", "file", "read");\n\
ksu_allow(db, "kernel", "sysfs_drm", "file", "read");'



# ==========================================================
# EQUILIBRIUM
# ==========================================================

inject_selinux "Equilibrium" \
'ksu_allow(db, "kernel", "proc", "file", "write");\n\
ksu_allow(db, "kernel", "proc", "file", "open");\n\
ksu_allow(db, "kernel", "proc", "file", "getattr");'



# ==========================================================
# HERALD / KAISEI
# ==========================================================

inject_selinux "Herald-Kaisei" \
'ksu_allow(db, "system_app", "sysfs_kernel", "dir", "search");\n\
ksu_allow(db, "system_app", "sysfs_kernel", "file", "read");\n\
ksu_allow(db, "init", "sysfs_kernel", "file", "write");\n\
ksu_allow(db, "shell", "sysfs_kernel", "file", "read");'



# ==========================================================
# IYASHI / KASUMI
# ==========================================================

inject_selinux "Iyashi-Kasumi" \
'ksu_allow(db, "kernel", "sysfs_therm", "dir", "search");\n\
ksu_allow(db, "kernel", "sysfs_therm", "file", "read");\n\
ksu_allow(db, "kernel", "sysfs_therm", "file", "write");'



# ==========================================================
# OTO
# ==========================================================

inject_selinux "Oto" \
'ksu_allow(db, "kernel", "kernel", "capability", "dac_override");\n\
ksu_allow(db, "kernel", "cgroup", "dir", "search");\n\
ksu_allow(db, "kernel", "cgroup", "file", "write");'



# ==========================================================
# KIRYUU
# ==========================================================

inject_selinux "Kiryuu" \
'ksu_allow(db, "kernel", KERNEL_SU_DOMAIN, "process", "transition");\n\
ksu_allow(db, "kernel", "shell_exec", "file", "execute");\n\
ksu_allow(db, "kernel", "shell_exec", "file", "execute_no_trans");\n\
ksu_allow(db, "kernel", "shell_exec", "file", "read");\n\
ksu_allow(db, "kernel", "shell_exec", "file", "open");\n\
ksu_allow(db, "kernel", "adb_data_file", "dir", "search");\n\
ksu_allow(db, "kernel", "adb_data_file", "file", "execute");\n\
ksu_allow(db, "kernel", "adb_data_file", "file", "read");'



# ==========================================================
# CPU TARGETS
# ==========================================================

inject_selinux "Vindicator Targets" \
'ksu_allow(db, "kernel", "sysfs_devices_system_cpu", "dir", "search");\n\
ksu_allow(db, "kernel", "sysfs_devices_system_cpu", "file", "read");\n\
ksu_allow(db, "kernel", "sysfs_devices_system_cpu", "file", "write");'



# ==========================================================
# Summary
# ==========================================================

echo ""
echo "======================================"
echo " AGNI SELINUX SUMMARY"
echo "======================================"


if grep -q "AGNI SELinux Rules" "$SELINUX_RULES_C"; then

    echo "✅ SELinux injection completed"

else

    echo "❌ SELinux injection failed"

    exit 1

fi


echo "File:"
echo "$SELINUX_RULES_C"

echo "======================================"
