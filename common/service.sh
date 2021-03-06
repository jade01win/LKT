#!/system/bin/sh
# ====================================================#
# Codename: LKT
# Author: korom42 @ XDA
# Device: Universal
# Version : 1.2.2
# Last Update: 08.DEC.2018
# ====================================================#
# THE BEST BATTERY MOD YOU CAN EVER USE
# JUST FLASH AND FORGET
# ====================================================#
# ##### Credits
#
# ** AKT contributors **
# @Alcolawl @soniCron @Asiier @Freak07 @Mostafa Wael 
# @Senthil360 @TotallyAnxious @RenderBroken @adanteon  
# @Kyuubi10 @ivicask @RogerF81 @joshuous @boyd95 
# @ZeroKool76 @ZeroInfinity
#
# ** Project WIPE contributors **
# @yc9559 @Fdss45 @yy688go (好像不见了) @Jouiz @lpc3123191239
# @小方叔叔 @星辰紫光 @ℳ๓叶落情殇 @屁屁痒 @发热不卡算我输# @予北
# @選擇遺忘 @想飞的小伙 @白而出清 @AshLight @微风阵阵 @半阳半
# @AhZHI @悲欢余生有人听 @YaomiHwang @花生味 @胡同口卖菜的
# @gce8980 @vesakam @q1006237211 @Runds @lmentor
# @萝莉控の胜利 @iMeaCore @Dfift半島鐵盒 @wenjiahong @星空未来
# @水瓶 @瓜瓜皮 @默认用户名8 @影灬无神 @橘猫520 @此用户名已存在
# @ピロちゃん @Jaceﮥ @黑白颠倒的年华0 @九日不能贱 @fineable
# @哑剧 @zokkkk @永恒的丶齿轮 @L风云 @Immature_H @揪你鸡儿
# @xujiyuan723 @Ace蒙奇 @ちぃ @木子茶i同学 @HEX_Stan
# @_暗香浮动月黄昏 @子喜 @ft1858336 @xxxxuanran @Scorpiring
# @猫见 @僞裝灬 @请叫我芦柑 @吃瓜子的小白 @HELISIGN @鹰雏
# @贫家boy有何贵干 @Yoooooo
#
# Give proper credits when using this in your work
# ====================================================#


# helper functions to allow Android init like script
function write() {
#if [ -e $1 ]; then
    echo -n $2 > $1
#fi
}

function copy() {
    cat $1 > $2
}

function round() {
  printf "%.${2}f" "${1}"
}

function trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}

function set_value() {
	if [ -f $2 ]; then
		# chown 0.0 $2
		chmod 0644 $2
		echo $1 > $2
		chmod 0444 $2
	fi
}


# $1:display-name $2:file path
function print_value() {
	if [ -f $2 ]; then
		echo $1
		cat $2
	fi
}

# $1:cpu0 $2:timer_rate $3:value
function set_param() {
	echo $3 > /sys/devices/system/cpu/$1/cpufreq/interactive/$2
}
function set_param_eas() {
	echo $3 > /sys/devices/system/cpu/$1/cpufreq/schedutil/$2
}


# $1:cpu0 $2:timer_rate
function print_param() {
	echo "$1: $2"
	cat /sys/devices/system/cpu/$1/cpufreq/interactive/$2
}

# $1:io-scheduler $2:block-path
function set_io() {
	if [ -f $2/queue/scheduler ]; then
		if [ `grep -c $1 $2/queue/scheduler` = 1 ]; then
			echo $1 > $2/queue/scheduler
			echo 2048 > $2/queue/read_ahead_kb
			set_value 0 $2/queue/iostats
			set_value 128 $2/queue/nr_requests
			set_value 0 $2/queue/iosched/slice_idle
			set_value 1 $2/queue/rq_affinity
			set_value 1 $2/queue/nomerges
			set_value 0 $2/queue/add_random
			set_value 0 $2/queue/rotational
			set_value 0 $2/bdi/min_ratio
			set_value 100 $2/bdi/max_ratio
  		fi
	fi
}

    # Sleep at boot
    # Do not decrease
    # Better late than never

    sleep 48

    #MOD Variable
    V="1.2.2"
    PROFILE=<PROFILE_MODE>
    LOG=/data/LKT.prop
    dt=$(date '+%d/%m/%Y %H:%M:%S');
    sbusybox=`busybox | awk 'NR==1{print $2}'` 
   
    # RAM variables
	TOTAL_RAM=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`; 
    memg=$(awk -v x=$TOTAL_RAM 'BEGIN{print x/1048576}')
    ROUND_memg=$(round ${memg} 0) 
    
	# CPU variables
    arch_type=`uname -m`
    gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)
    govn=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    bcl_soc_hotplug_mask=`cat /sys/devices/soc/soc:qcom,bcl/hotplug_soc_mask`
    bcl_hotplug_mask=`cat /sys/devices/soc/soc:qcom,bcl/hotplug_mask`
	
	# Device infos
    BATT_LEV=`dumpsys battery | grep level | awk '{print $2}'`    
    BATT_TECH=`dumpsys battery | grep technology | awk '{print $2}'`
    BATT_VOLT=`dumpsys battery | awk '/^ +voltage:/ && $NF!=0{print $NF}'`
    BATT_TEMP=`dumpsys battery | grep temperature | awk '{print $2}'`
    BATT_HLTH=`dumpsys battery | grep health | awk '{print $2}'`
    BATT_VOLT=$(awk -v x=$BATT_VOLT 'BEGIN{print x/1000}')
    BATT_TEMP=$(awk -v x=$BATT_TEMP 'BEGIN{print x/10}')
    VENDOR=`getprop ro.product.brand`
    ROM=`getprop ro.build.display.id`
    KERNEL="$(uname -r)"
    APP=`getprop ro.product.model`
    SOC=$(awk '/^Hardware/{print $NF}' /proc/cpuinfo | tr '[:upper:]' '[:lower:]')
    snapdragon=0

    if [ "$SOC" != "${SOC/msm/}" ]; then
    snapdragon=1
   elif [ "$SOC" != "${SOC/sdm/}" ]; then
    snapdragon=1
    else
    snapdragon=0
    fi

    if [ $BATT_HLTH -eq "2" ];then
    BATT_HLTH="Very Good"
    elif [ $BATT_HLTH -eq "3" ];then
    BATT_HLTH="Good"
    elif [ $BATT_HLTH -eq "4" ];then
    BATT_HLTH="Poor"
    elif [ $BATT_HLTH -eq "5" ];then
    BATT_HLTH="Sh*t"
    else
    BATT_HLTH="Unknown"
    fi
	
    cores=`grep -c ^processor /proc/cpuinfo`
    coresmax=$(cat /sys/devices/system/cpu/kernel_max)

    quad_core=4
    hexa_core=6
    octa_core=8
    deca_core=10
    bcores=4

    if [ $cores -eq $quad_core ];then
    bcores=2
    elif [ $cores -eq $hexa_core ];then
    bcores=4
    elif [ $cores -eq $octa_core ];then
    bcores=4
    elif [ $cores -eq $deca_core ];then
    bcores=4
    else
    bcores=4
    fi

    if [ -e /sys/devices/system/cpu/cpu0/cpufreq ]; then
    GOV_PATH_L=/sys/devices/system/cpu/cpu0/cpufreq
    fi
    if [ -e /sys/devices/system/cpu/cpu$bcores/cpufreq ]; then
    GOV_PATH_B=/sys/devices/system/cpu/cpu$bcores/cpufreq
    fi

    if [ -e /sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors ]; then
    SILVER=/sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors;
    fi
    if [ -e /sys/devices/system/cpu/cpufreq/policy0 ]; then
    SVD=/sys/devices/system/cpu/cpufreq/policy0
    fi
	
    if [ -e /sys/devices/system/cpu/cpufreq/policy$bcores/scaling_available_governors ]; then 
    GOLD=/sys/devices/system/cpu/cpufreq/policy$bcores/scaling_available_governors;
	elif [ -e /sys/devices/system/cpu/cpufreq/policy$bcores/scaling_available_governors ]; then 
    GOLD=/sys/devices/system/cpu/cpufreq/policy$bcores/scaling_available_governors;  
    fi
	 
    if [ -e /sys/devices/system/cpu/cpufreq/policy$bcores ]; then 
    GLD=/sys/devices/system/cpu/cpufreq/policy$bcores
    elif [ -e /sys/devices/system/cpu/cpufreq/policy$bcores ]; then 
    GLD=/sys/devices/system/cpu/cpufreq/policy$bcores
    fi

    function before_modify()
{
	chown 0.0 $GOV_PATH_L/interactive/*
	chown 0.0 $GOV_PATH_B/interactive/*
	chmod 0666 $GOV_PATH_L/interactive/*	
 chmod 0666 $GOV_PATH_B/interactive/*
}

    function after_modify()
{
	chmod 0444 $GOV_PATH_L/interactive/*	
  chmod 0444 $GOV_PATH_B/interactive/*
}

    function before_modify_eas()
{
	chown 0.0 $GOV_PATH_L/schedutil/*
	chown 0.0 $GOV_PATH_B/schedutil/*
	chmod 0666 $GOV_PATH_L/schedutil/*	
	chmod 0666 $GOV_PATH_B/schedutil/*
	chmod 0666 $SVD/schedutil/*
	chmod 0666 $GLD/schedutil/*
}

    function after_modify_eas()
{
	chmod 0444 $SVD/schedutil/*
	chmod 0444 $GLD/schedutil/*
	chmod 0444 $GOV_PATH_L/schedutil/*	
	chmod 0444 $GOV_PATH_B/schedutil/*
}

    function logdata() {
        echo $1 |  tee -a $LOG;
    }

    if [ -e $LOG ]; then
     rm $LOG;
    fi;


    if [ $PROFILE -eq 0 ];then
	PROFILE_M="Battery"
	elif [ $PROFILE -eq 1 ];then
	PROFILE_M="Balanced"
	else
	PROFILE_M="Balanced"
	fi

logdata "###### LKT™ $V" 
logdata "###### Profile : $PROFILE_M" 
logdata "" 
logdata "#  START : $(date +"%d-%m-%Y %r")" 
logdata "#  ==============================" 
logdata "#  Vendor : $VENDOR" 
logdata "#  Device : $APP" 
logdata "#  CPU : $SOC ($cores x cores)" 
logdata "#  RAM : $ROUND_memg GB" 
logdata "#  ==============================" 
logdata "#  ROM : $ROM" 
logdata "#  Android : $(getprop ro.build.version.release)" 
logdata "#  Kernel : $KERNEL" 
logdata "#  BusyBox  : $sbusybox" 
logdata "# ==============================" 


function enable_bcl() {

if [ $snapdragon -eq 1 ];then

    write /sys/module/msm_thermal/core_control/enabled "1"
    write /sys/devices/soc/soc:qcom,bcl/mode -n disable
    write /sys/devices/soc/soc:qcom,bcl/hotplug_mask $bcl_hotplug_mask
    write /sys/devices/soc/soc:qcom,bcl/hotplug_soc_mask $bcl_soc_hotplug_mask
    write /sys/devices/soc/soc:qcom,bcl/mode -n enable

else
	set_value 1 /sys/power/cpuhotplug/enabled
	set_value 1 /sys/devices/system/cpu/cpuhotplug/enabled
fi

}

function disable_swap() {
	swapp=`blkid | grep swap | awk '{print $1}'`;
        uuid=`blkid -s UUID -o value $swapp | awk '{print $1}'`; 


	if [ -f /system/bin/swapoff ] ; then
        swff="/system/bin/swapoff"
	else
	swff="swapoff"
	fi

        write /sys/class/zram-control/hot_remove $uuid

	for i in /sys/block/zram*; do
	set_value "1" $i/reset;
	set_value "0" $i/disksize
	done

	for j in /sys/block/vnswap*; do
	set_value "1" $j/reset;
	set_value "0" $j/disksize
	done

	for k in /sys/block/vnswap*; do
	set_value "1" $k/reset;
	set_value "0" $k/disksize
	done

	swff $swapp > /dev/null 2>&1;
        c=1
	for l in /dev/block*; do  
	while [ $c -lt 10 ]

        do
        if [ -e "$l/zram$c" ]; then
	swff $l/zram$c > /dev/null 2>&1;
        fi

        if [ -e "$l/swap$c" ]; then
	swff $l/swap$c > /dev/null 2>&1;
        fi

        if [ -e "$l/vnswap$c" ]; then
	swff $l/vnswap$c > /dev/null 2>&1;
        fi

	c=$(( $c + 1 ))

        done
	done

	resetprop -n vnswap.enabled false
	resetprop -n ro.config.zram false
	resetprop -n ro.config.zram.support false
	resetprop -n zram.disksize 0
	set_value 0 /proc/sys/vm/swappiness
	sysctl -w vm.swappiness=0
}

function disable_lmk() {
if [ -e "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" ]; then
 set_value 0 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
 set_value 0 /sys/module/process_reclaim/parameters/enable_process_reclaim
    resetprop -n lmk.autocalc false
 else
 	logdata '# *WARNING* Adaptive LMK is not present on your Kernel' 
fi;
}

function RAM_tuning() { 
    
    calculator=3
    if [ $PROFILE -eq 1 ];then
    prof="0.75"
    else
    prof="0.65"
    fi

    if [ $TOTAL_RAM -lt 2097152 ]; then
    calculator="2.70"
    disable_swap
    resetprop -n ro.config.low_ram true
    resetprop -n ro.board_ram_size low
    
    #Enable B service adj transition for 2GB or less memory
    resetprop -n ro.vendor.qti.sys.fw.bservice_enable true
    resetprop -n ro.vendor.qti.sys.fw.bservice_limit 5
    resetprop -n ro.vendor.qti.sys.fw.bservice_age 5000
    resetprop -n ro.sys.fw.bg_apps_limit 28

    #Enable Delay Service Restart
    setprop ro.vendor.qti.am.reschedule_service true
      
    elif [ $TOTAL_RAM -lt 3145728 ]; then
    calculator="2.75"
    disable_swap
    resetprop -n ro.sys.fw.bg_apps_limit 32
	
    elif [ $TOTAL_RAM -lt 4194304 ]; then
    calculator="2.85"
    disable_swap
    resetprop -n ro.sys.fw.bg_apps_limit 36
    fi
 
    if [ $TOTAL_RAM -gt 4194304 ]; then
    calculator="3.45"
    disable_swap
    resetprop -n ro.sys.fw.bg_apps_limit 48

    elif [ $TOTAL_RAM -gt 6291456 ]; then
    calculator="4.65"
    disable_swap
    #disable_lmk
    resetprop -n ro.sys.fw.bg_apps_limit 78
    fi

    resetprop -n sys.config.samp_spcm_enable false
    resetprop -n sys.config.samp_enable false
    resetprop -n ro.config.fha_enable true
    resetprop -n ro.sys.fw.use_trim_settings false

  # LMK Calculator
  # This is a Calculator for the Android Low Memory Killer 
  # It detects the Free RAM and set the LMK to right configuration
  # for more RAM but also better Multitasking 
  # Algorithms COPYRIGHT by PDesire and the THDR Alliance 
  # Code COPYRIGHT korom42


divisor=$(awk -v x=$TOTAL_RAM 'BEGIN{print x/256}')
var_one=$(awk -v x=$TOTAL_RAM -v y=2 'BEGIN{print sqrt(x)*sqrt(2)}')
var_two=$(awk -v x=$TOTAL_RAM -v p=3.14 'BEGIN{print x*sqrt(p)}')
var_three=$(awk -v x=$var_one -v y=$var_two -v z=$divisor 'BEGIN{print (x+y)/z}')
var_four=$(awk -v x=$var_three -v p=3.14 'BEGIN{print x/(sqrt(p)*2)}')
f_LMK=$(awk -v x=$var_four -v p=3.14 'BEGIN{print x/(p*2)}')
LMK=$(round ${f_LMK} 0)


 # Low Memory Killer Generator
 # Settings inspired by HTC stock firmware 
 # Tuned by korom42 for multi-tasking and saving CPU cycles

f_LMK1=$(awk -v x=$LMK -v y=$calculator 'BEGIN{print x*y*1024/4}') #Low Memory Killer 1
LMK1=$(round ${f_LMK1} 0)

f_LMK2=$(awk -v x=$LMK1 -v y=$calculator 'BEGIN{print x*1.25}') #Low Memory Killer 2
LMK2=$(round ${f_LMK2} 0)

f_LMK3=$(awk -v x=$LMK1 -v y=$calculator 'BEGIN{print x*1.75}') #Low Memory Killer 3
LMK3=$(round ${f_LMK3} 0)

f_LMK4=$(awk -v x=$LMK1 -v y=$calculator 'BEGIN{print x*2.25}') #Low Memory Killer 4
LMK4=$(round ${f_LMK4} 0)

f_LMK5=$(awk -v x=$LMK1 -v y=$calculator 'BEGIN{print x*3.33}') #Low Memory Killer 5
LMK5=$(round ${f_LMK5} 0)

f_LMK6=$(awk -v x=$LMK1 -v y=$calculator 'BEGIN{print x*4.25}') #Low Memory Killer 6
LMK6=$(round ${f_LMK6} 0)

LMK1=$((LMK1/2))
LMK1=$(round ${LMK1} 0)


if [ -e "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" ]; then
	set_value 1 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
else
	logdata "#  *WARNING* Adaptive LMK is not present on your Kernel" 
fi
 
if [ -e "/sys/module/lowmemorykiller/parameters/minfree" ]; then
   set_value "$LMK1,$LMK2,$LMK3,$LMK4,$LMK5,$LMK6" /sys/module/lowmemorykiller/parameters/minfree
   resetprop -n lmk.autocalc true
else
	logdata "#  *WARNING* LMK cannot currently be modified on your Kernel" 
fi


# =========
# Vitual Memory
# =========

chmod 0644 /proc/sys/*;
sysctl -e -w  vm.drop_caches=1 \
vm.oom_dump_tasks=1 \
vm.oom_kill_allocating_task=0 \
vm.dirty_background_ratio=1 \
vm.dirty_ratio=5 \
vm.vfs_cache_pressure=70 \
vm.overcommit_memory=50 \
vm.overcommit_ratio=0 \
vm.laptop_mode=0 \
vm.block_dump=0 \
vm.dirty_writeback_centisecs=0 \
vm.dirty_expire_centisecs=0 \
dir-notify-enable=0 \
fs.lease-break-time=20 \
fs.leases-enable=1 \
vm.compact_memory=1 \
vm.compact_unevictable_allowed=1 \
vm.page-cluster=0 \
vm.panic_on_oom=0 &> /dev/null
chmod 0444 /proc/sys/*;

# Disable KSM to save CPU cycles

set_value 1 /sys/kernel/mm/ksm/run


# =========
# Entropy 
# =========

# Anything more than 64/128 is stupid
# It won't increase your performance
# It will increase battery drain
# So leave it as it is

sysctl -w kernel.random.read_wakeup_threshold=64
sysctl -w kernel.random.write_wakeup_threshold=128

logdata "#  Virtual Memory Tuning .. DONE" 

sync;

}

function CPU_tuning() {

if [ $snapdragon -eq 1 ];then

logdata "#  Snapdragon SoC detected" 

    # disable thermal bcl hotplug to switch governor
    write /sys/module/msm_thermal/core_control/enabled "0"
    write /sys/module/msm_thermal/parameters/enabled "N"
	
 else
 	logdata "#  Non-Snapdragon SoC detected" 

 	# Linaro HMP, between 0 and 1024, maybe compare to the capacity of current cluster
	# PELT and period average smoothing sampling, so the parameter style differ from WALT by Qualcomm a lot.
	# https://lists.linaro.org/pipermail/linaro-dev/2012-November/014485.html
	# https://www.anandtech.com/show/9330/exynos-7420-deep-dive/6
	# set_value 60 /sys/kernel/hmp/load_avg_period_ms
	set_value 256 /sys/kernel/hmp/down_threshold
	set_value 640 /sys/kernel/hmp/up_threshold
	set_value 0 /sys/kernel/hmp/boost

	# Exynos hotplug
	set_value 0 /sys/power/cpuhotplug/enabled
	set_value 0 /sys/devices/system/cpu/cpuhotplug/enabled
	
fi


	if [ -e /sys/devices/soc/soc:qcom,bcl/mode ]; then
    chmod 644 /sys/devices/soc/soc:qcom,bcl/mode
    write /sys/devices/soc/soc:qcom,bcl/mode -n disable
    write /sys/devices/soc/soc:qcom,bcl/hotplug_mask 0
    write /sys/devices/soc/soc:qcom,bcl/hotplug_soc_mask 0
    write /sys/devices/soc/soc:qcom,bcl/mode -n enable
    fi
	
	# Perfd, nothing to worry about, if error the script will continue

	if [ -e /data/system/perfd ]; then
	stop perfd
	fi
	
	if [ -e /data/system/perfd/default_values ]; then
	rm /data/system/perfd/default_values
	fi
	 
	sleep 0.1
	 
	# A simple loop to bring all cores online that we counted earlier
	 
	num=0
	
	while [ $num -lt $cores ]
	
	do
	
	set_value 1 /sys/devices/system/cpu/cpu$num/online
	
	#num=`expr $num + 1`
	num=$(( $num + 1 ))
	
	sleep 0.1
	
	done

	write /sys/devices/system/cpu/online "0-$coresmax"

	if [ -d "/dev/stune" ]; then
	set_value 5 /dev/stune/foreground/schedtune.boost
	set_value 25 /dev/stune/top-app/schedtune.boost
	set_value 0 /dev/stune/system-background/schedtune.boost
	set_value "-100" /dev/stune/schedtune.boost
	set_value "-100" /dev/stune/background/schedtune.boost
	set_value 0 /dev/stune/background/schedtune.boost
	set_value 0 /dev/stune/foreground/schedtune.boost
	set_value 0 /dev/stune/schedtune.prefer_idle
	set_value 0 /dev/stune/background/schedtune.prefer_idle
	set_value 0 /dev/stune/foreground/schedtune.prefer_idle
	set_value 0 /dev/stune/top-app/schedtune.prefer_idle
	set_value 0 /dev/stune/foreground/schedtune.prefer_idle
	set_value 0 /dev/stune/top-app/schedtune.prefer_idle
	set_value 1 $SVD/schedutil/iowait_boost_enable
	set_value 1 $GLD/schedutil/iowait_boost_enable
	set_value 500 $SVD/schedutil/up_rate_limit_us
	set_value 8000 $SVD/schedutil/down_rate_limit_us
	set_value 500 $GLD/schedutil/up_rate_limit_us
	set_value 8000 $GLD/schedutil/down_rate_limit_us
	fi
	
	if [ -e "/proc/sys/kernel/sched_tunable_scaling" ]; then
	set_value 2 /proc/sys/kernel/sched_tunable_scaling
	fi
	if [ -e "/proc/sys/kernel/sched_child_runs_first" ]; then
	set_value 1 /proc/sys/kernel/sched_child_runs_first
	fi
	if [ -e "/proc/sys/kernel/sched_cfs_boost" ]; then
	set_value 0 /proc/sys/kernel/sched_cfs_boost
	fi
	if [ -e "/proc/sys/kernel/sched_latency_ns" ]; then
	set_value 100000 /proc/sys/kernel/sched_latency_ns
	fi
	if [ -e "/proc/sys/kernel/sched_autogroup_enabled" ]; then
	set_value 0 /proc/sys/kernel/sched_autogroup_enabled
	fi
	if [ -e "/proc/sys/kernel/sched_boost" ]; then
	set_value 0 /proc/sys/kernel/sched_boost
	fi
	if [ -e "/proc/sys/kernel/sched_cstate_aware" ]; then
	set_value 1 /proc/sys/kernel/sched_cstate_aware
	fi
	if [ -e "/proc/sys/kernel/sched_initial_task_util" ]; then
	set_value 0 /proc/sys/kernel/sched_initial_task_util
	fi
	if [ -e "/sys/module/msm_performance/parameters/touchboost/sched_boost_on_input" ]; then
	set_value N /sys/module/msm_performance/parameters/touchboost/sched_boost_on_input
	fi

	set_value 90 /proc/sys/kernel/sched_spill_load
	set_value 1 /proc/sys/kernel/sched_prefer_sync_wakee_to_waker
	set_value 3000000 /proc/sys/kernel/sched_freq_inc_notify

	if [ $coresmax -eq 3 ];then
	set_value 1 /dev/cpuset/background/cpus
	set_value 0-1 /dev/cpuset/system-background/cpus
	set_value 0-1,2-3 /dev/cpuset/foreground/cpus
	set_value 0-1,2-3 /dev/cpuset/top-app/cpus
	elif [ $coresmax -eq 5 ];then
	set_value 2-3 /dev/cpuset/background/cpus
	set_value 0-3 /dev/cpuset/system-background/cpus
	set_value 0-3,4-5 /dev/cpuset/foreground/cpus
	set_value 0-3,4-5 /dev/cpuset/top-app/cpus
	else
	set_value 2-3 /dev/cpuset/background/cpus
	set_value 0-3 /dev/cpuset/system-background/cpus
	set_value 0-3,4-7 /dev/cpuset/foreground/cpus
	set_value 0-3,4-7 /dev/cpuset/top-app/cpus
        fi

	# set_value 85 /proc/sys/kernel/sched_downmigrate
	# set_value 95 /proc/sys/kernel/sched_upmigrate

	set_value 0 /sys/module/msm_performance/parameters/touchboost

	available_governors=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`
	string1=/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors;
	string2=/sys/devices/system/cpu/cpu$bcores/cpufreq/scaling_available_governors;
	
if [[ "$available_governors" == *"schedutil"* ]] || [[ "$available_governors" == *"sched"* ]]; then
		
	logdata "#  EAS Kernel Detected .. Tuning $govn" 
	if [ -e $SVD ] && [ -e $GLD ]; then

	before_modify_eas

	if grep -w "sched" $string1 && grep -w "sched" $string2; then
	set_value "sched" $SVD/scaling_governor 
	set_value "sched" $GLD/scaling_governor
	else
	set_value "schedutil" $SVD/scaling_governor 
	set_value "schedutil" $GLD/scaling_governor
	fi
	
	if [ $PROFILE -eq 1 ];then

	set_value $(($bcores/2)) /sys/devices/system/cpu/cpu$bcores/core_ctl/min_cpus
	set_value $bcores /sys/devices/system/cpu/cpu$bcores/core_ctl/max_cpus

	if [ -e "/sys/module/cpu_boost" ]; then
	set_value "0:1080000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	fi

	set_value 80 /sys/module/cpu_boost/parameters/input_boost_ms
	
	if [ -e "/proc/sys/kernel/sched_use_walt_task_util" ]; then
		write /proc/sys/kernel/sched_use_walt_task_util 1
		write /proc/sys/kernel/sched_use_walt_cpu_util 1
		write /proc/sys/kernel/sched_walt_init_task_load_pct 10
		write /proc/sys/kernel/sched_walt_cpu_high_irqload 10000000
		write /proc/sys/kernel/sched_rt_runtime_us 980000
	fi

	write /sys/module/cpu_boost/parameters/dynamic_stune_boost 8
	write /proc/sys/kernel/sched_nr_migrate 64

	set_param_eas cpu0 hispeed_freq 1280000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu$bcores hispeed_freq 1280000
	set_param_eas cpu$bcores hispeed_load 90
	set_param_eas cpu$bcores pl 0

	else
	
	set_value 0 /sys/devices/system/cpu/cpu$bcores/core_ctl/min_cpus
	set_value $bcores /sys/devices/system/cpu/cpu$bcores/core_ctl/max_cpus
	
	if [ -e "/sys/module/cpu_boost" ]; then
	set_value "0:1080000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	fi
	
	set_value 80 /sys/module/cpu_boost/parameters/input_boost_ms
		
	if [ -e "/proc/sys/kernel/sched_use_walt_task_util" ]; then
		write /proc/sys/kernel/sched_use_walt_task_util 1
		write /proc/sys/kernel/sched_use_walt_cpu_util 1
		write /proc/sys/kernel/sched_walt_init_task_load_pct 0
		write /proc/sys/kernel/sched_walt_cpu_high_irqload 10000000
		write /proc/sys/kernel/sched_rt_runtime_us 980000
	fi

	write /sys/module/cpu_boost/parameters/dynamic_stune_boost 5
	write /proc/sys/kernel/sched_nr_migrate 48

	set_param_eas cpu0 hispeed_freq 1180000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu$bcores hispeed_freq 1080000
	set_param_eas cpu$bcores hispeed_load 90
	set_param_eas cpu$bcores pl 0

	fi

        after_modify_eas

	fi
	
	else
	#if grep -w 'interactive' $string1; then
	if [ -e $string1 ] && [ -e $string2 ]; then
	
	logdata "#  HMP Kernel Detected .. Tuning 'Interactive'" 

	set_value "interactive" /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	set_value "interactive" /sys/devices/system/cpu/cpu$bcores/cpufreq/scaling_governor
	
        before_modify

	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu$bcores timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu$bcores timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu$bcores boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu$bcores boostpulse_duration 0
	set_param cpu0 use_sched_load 1
	set_param cpu$bcores use_sched_load 1
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu$bcores ignore_hispeed_on_notif 0
	set_value 0 /sys/devices/system/cpu/cpu0/cpufreq/interactive/enable_prediction
	set_value 0 /sys/devices/system/cpu/cpu$bcores/cpufreq/interactive/enable_prediction
	
	# Input Boost
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq" ]; then
	if [ $coresmax -eq 1 ];then
	set_value "0:0 1:0" /sys/module/cpu_boost/parameters/input_boost_freq
	elif [ $coresmax -eq 3 ];then
	set_value "0:0 1:0 2:0 3:0" /sys/module/cpu_boost/parameters/input_boost_freq
	elif [ $coresmax -eq 5 ];then
	set_value "0:0 1:0 2:0 3:0 4:0 5:0" /sys/module/cpu_boost/parameters/input_boost_freq
	elif [ $coresmax -eq 7 ];then
	set_value "0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0" /sys/module/cpu_boost/parameters/input_boost_freq
	elif [ $coresmax -eq 9 ];then
	set_value "0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0 8:0 9:0" /sys/module/cpu_boost/parameters/input_boost_freq
	fi
	set_value 20 /sys/module/cpu_boost/parameters/input_boost_ms
	else
	logdata "#  *WARNING* Your Kernel does not support CPU BOOST  " 
	fi

	if [ -e "/sys/module/cpu_boost/parameters/boost_ms" ]; then
	set_value 0 /sys/module/cpu_boost/parameters/boost_ms
	fi

	#Disable TouchBoost
	if [ -e "/sys/module/msm_performance/parameters/touchboost" ]; then
	set_value 0 /sys/module/msm_performance/parameters/touchboost
	else
	logdata "#  *WARNING* Your Kernel does not support TOUCH BOOST  " 
	fi

    if [ $PROFILE -eq 1 ];then
    case "$SOC" in
    "msm8998" | "apq8098_latv") #sd835
        set_value "0:1680000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "18000 1580000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:30 480000:41 580000:29 680000:4 780000:60 1180000:88 1280000:70 1380000:78 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "18000 1380000:78000 1480000:18000 1580000:98000 1880000:138000"
	set_param cpu4 hispeed_freq 1280000
	set_param cpu4 go_hispeed_load 98
	set_param cpu4 target_loads "80 380000:39 580000:58 780000:63 980000:81 1080000:92 1180000:77 1280000:98 1380000:86 1580000:98"
	set_param cpu4 min_sample_time 18000

    ;;

    "msm8996") #sd820
        
	set_value 280000 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	set_value 280000 /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate
	set_value "0:1280000 2:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "58000 1280000:98000 1580000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:9 580000:36 780000:62 880000:71 980000:87 1080000:75 1180000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu2 above_hispeed_delay "38000 1480000:98000 1880000:138000"
	set_param cpu2 hispeed_freq 1380000
	set_param cpu2 go_hispeed_load 98
	set_param cpu2 target_loads "80 380000:39 480000:35 680000:29 780000:63 880000:71 1180000:91 1380000:83 1480000:98"
	set_param cpu2 min_sample_time 18000

    ;;

    "msm8994" | "msm8992") #sd810/808
	
	set_value 380000 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	set_value 380000 /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_value "0:1344000 4:1440000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value 1344000 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	set_value 1440000 /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
	set_value "0:1180000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 580000:59 680000:54 780000:63 880000:85 1180000:98 1280000:94"
	set_param cpu0 min_sample_time 38000
	set_param cpu4 above_hispeed_delay "18000 1180000:98000"
	set_param cpu4 hispeed_freq 880000
	set_param cpu4 go_hispeed_load 98
	set_param cpu4 target_loads "80 580000:64 680000:58 780000:19 880000:97"
	set_param cpu4 min_sample_time 78000
	
    ;;

    "msm8974" | "apq8084")  #sd800-801-805
	
	set_param cpu0 above_hispeed_delay "18000 1480000:78000 1780000:138000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 99
	set_param cpu0 boostpulse_duration 18000
	set_param cpu0 target_loads "80 580000:60 680000:81 880000:42 980000:90 1480000:80 1680000:99"
	set_param cpu0 min_sample_time 18000

    ;;

    "sdm660") #sd660

	set_value "0:1480000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "98000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:59 1080000:90 1380000:78 1480000:98"
	set_param cpu0 min_sample_time 38000
	set_param cpu4 above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu4 hispeed_freq 1080000
	set_param cpu4 go_hispeed_load 83
	set_param cpu4 target_loads "80 1380000:70 1680000:98"
	set_param cpu4 min_sample_time 18000
	
    ;;
    "msm8956" | "msm8976")  #sd652/650
	set_value 50 /sys/module/cpu_boost/parameters/input_boost_ms
	set_value "0:1380000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "98000 1380000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 680000:68 780000:60 980000:97 1180000:63 1280000:97 1380000:84"
	set_param cpu0 min_sample_time 58000
	set_param cpu4 above_hispeed_delay "18000 1580000:98000"
	set_param cpu4 hispeed_freq 1280000
	set_param cpu4 go_hispeed_load 98
	set_param cpu4 target_loads "80 880000:47 980000:68 1280000:74 1380000:92 1580000:98"
	set_param cpu4 min_sample_time 18000

    ;;

    "sdm636" ) #sd636
	set_value "0:1480000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "18000 1380000:78000 1480000:98000 1580000:78000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:62 1080000:94 1380000:75 1480000:96"
	set_param cpu0 min_sample_time 58000
	set_param cpu4 above_hispeed_delay "18000 1680000:98000"
	set_param cpu4 hispeed_freq 1080000
	set_param cpu4 go_hispeed_load 81
	set_param cpu4 target_loads "80 1380000:70 1680000:98"
	set_param cpu4 min_sample_time 18000
    
	;;


	"msm8953")  #sd625/626
	set_value 0 /proc/sys/kernel/sched_boost
	set_value "0:1680000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "98000 1880000:138000"
	set_param cpu0 hispeed_freq 1680000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:63 1380000:72 1680000:97"
	set_param cpu0 min_sample_time 18000
	;;


	"universal8895")  #EXYNOS8895 (S8)
	set_param cpu0 above_hispeed_delay "38000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:53 880000:70 980000:50 1180000:71 1380000:97 1680000:92"
	set_param cpu0 min_sample_time 58000
	set_param cpu4 above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu4 hispeed_freq 1380000
	set_param cpu4 go_hispeed_load 98
	set_param cpu4 target_loads "80 780000:40 880000:34 980000:66 1080000:31 1180000:72 1380000:86 1680000:98"
	set_param cpu4 min_sample_time 18000
	;;

	
	"universal8890")  #EXYNOS8890 (S7)
	set_param cpu0 above_hispeed_delay "18000 1280000:38000 1480000:98000 1580000:18000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 480000:49 680000:34 780000:61 880000:33 980000:63 1080000:69 1180000:77 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "18000 1580000:98000 1880000:138000"
	set_param cpu4 hispeed_freq 1380000
	set_param cpu4 go_hispeed_load 93
	set_param cpu4 target_loads "80 780000:33 880000:67 980000:42 1080000:75 1180000:65 1280000:74 1480000:97"
	set_param cpu4 min_sample_time 18000
    ;;

	"universal7420") #EXYNOS7420 (S6)
	set_param cpu0 above_hispeed_delay "58000 1280000:18000 1380000:98000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 480000:29 580000:12 680000:69 780000:22 880000:36 1080000:80 1180000:89 1480000:63"
	set_param cpu0 min_sample_time 38000
	set_param cpu4 above_hispeed_delay "18000 1480000:78000 1580000:98000 1880000:138000"
	set_param cpu4 hispeed_freq 1380000
	set_param cpu4 go_hispeed_load 96
	set_param cpu4 target_loads "80 880000:27 980000:44 1080000:71 1180000:32 1280000:64 1380000:78 1480000:87 1580000:98"
	set_param cpu4 min_sample_time 18000
    ;;

	
	"kirin970")  # Huawei Kirin 970
	set_param cpu0 above_hispeed_delay "18000 1480000:38000 1680000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:61 1180000:88 1380000:70 1480000:96"
	set_param cpu0 min_sample_time 38000
	set_param cpu4 above_hispeed_delay "18000 1580000:98000 1780000:138000"
	set_param cpu4 hispeed_freq 1280000
	set_param cpu4 go_hispeed_load 94
	set_param cpu4 target_loads "80 980000:72 1280000:77 1580000:98"
	set_param cpu4 min_sample_time 18000
    ;;
	
	"kirin960")  # Huawei Kirin 960
	set_param cpu0 above_hispeed_delay "38000 1680000:98000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:97 1380000:78 1680000:98"
	set_param cpu0 min_sample_time 78000
	set_param cpu4 above_hispeed_delay "18000 1380000:98000 1780000:138000"
	set_param cpu4 hispeed_freq 880000
	set_param cpu4 go_hispeed_load 95
	set_param cpu4 target_loads "80 1380000:59 1780000:98"
	set_param cpu4 min_sample_time 38000
    ;;

	"kirin950") # Huawei Kirin 950
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 780000:69 980000:76 1280000:80 1480000:96"
	set_param cpu0 min_sample_time 58000
	set_param cpu4 above_hispeed_delay "18000 1780000:138000"
	set_param cpu4 hispeed_freq 1180000
	set_param cpu4 go_hispeed_load 80
	set_param cpu4 target_loads "80 1180000:75 1480000:93 1780000:98"
	set_param cpu4 min_sample_time 38000
    ;;

	
	"mt6797t" | "mt6797") #Helio X25 / X20	 
	set_value 50 /proc/hps/down_threshold
	set_value 80 /proc/hps/up_threshold
	set_value "3 2 0" /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "18000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 93
	set_param cpu0 boostpulse_duration [balance_uni_boostpulse_duration]
	set_param cpu0 target_loads "80 380000:8 580000:14 680000:9 780000:41 880000:56 1080000:65 1180000:92 1380000:85 1480000:97"
	set_param cpu0 min_sample_time 18000
    ;;
	
	"mt6795") #Helio X10
	set_value 50 /proc/hps/down_threshold
	set_value 85 /proc/hps/up_threshold
	set_value 2 /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "18000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 boostpulse_duration 38000
	set_param cpu0 target_loads "85 780000:62 1180000:68 1280000:87 1480000:99"
	set_param cpu0 min_sample_time 18000
    ;;
	
	*)
	
	
	if [ "$SOC" = "moorefield" ] || [ "$SOC" = "msm8939" ] || [ "$SOC" = "msm8939v2" ]; then 
	echo "Intel chip detected"
	else
	logdata "# *ERROR* Governor tweaks failed .. Unrecognized chip : $SOC" 
	fi
	
    ;;

    esac

    case "$SOC" in
    "moorefield") # Intel Atom
    set_param cpu0 above_hispeed_delay "58000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 99
	set_param cpu0 boostpulse_duration 18000
	set_param cpu0 target_loads "85 580000:40 680000:89 780000:35 880000:40 980000:52 1080000:66 1180000:99 1280000:70 1380000:87 1480000:93 1580000:98"
	set_param cpu0 min_sample_time 18000
	;;
    esac
    case "$SOC" in
	"msm8939" | "msm8939v2")  #sd615/616
	set_value "0:980000" /sys/module/cpu_boost/parameters/input_boost_freq

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate

	set_value 2500 /sys/module/cpu_boost/parameters/input_boost_ms
	set_value 0 /sys/module/msm_performance/parameters/touchboost


	set_value 0 $GOV_PATH_L/interactive/ignore_hispeed_on_notif
	set_value 0 $GOV_PATH_L/interactive/enable_prediction

	set_value 0 $GOV_PATH_B/interactive/ignore_hispeed_on_notif
	set_value 0 $GOV_PATH_B/interactive/enable_prediction

	set_param cpu0 above_hispeed_delay "18000 1344000:98000 1459000:138000"
	set_param cpu0 hispeed_freq 1113000
	set_param cpu0 go_hispeed_load 94
	set_param cpu0 target_loads "80 980000:66 1113000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "18000 1344000:98000 1459000:138000"
	set_param cpu4 hispeed_freq 1344000
	set_param cpu4 go_hispeed_load 94
	set_param cpu4 target_loads "80 980000:66 1113000:96"
	set_param cpu4 min_sample_time 18000
	set_param cpu4 use_sched_load 1
	set_param cpu0 use_sched_load 1
    esac

    else

    case "$SOC" in
    "msm8998" | "apq8098_latv") #sd835

	# configure governor settings for little cluster
	set_value "0:1680000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "18000 1580000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:30 480000:41 580000:29 680000:4 780000:60 1180000:88 1280000:70 1380000:78 1480000:97"
	set_param cpu0 min_sample_time 18000

	# configure governor settings for big cluster
        set_param cpu4 above_hispeed_delay "18000 1380000:78000 1480000:18000 1580000:98000 1880000:138000"
	set_param cpu4 hispeed_freq 1280000
	set_param cpu4 go_hispeed_load 98
	set_param cpu4 target_loads "80 380000:39 580000:58 780000:63 980000:81 1080000:92 1180000:77 1280000:98 1380000:86 1580000:98"
	set_param cpu4 min_sample_time 18000

    ;;

    "msm8996")
        
	set_value 280000 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	set_value 280000 /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate
	set_value "0:1280000 2:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "98000 1580000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:15 480000:5 580000:62 780000:71 880000:96 980000:87 1080000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu2 above_hispeed_delay "18000 1280000:98000 1380000:58000 1480000:98000 1880000:138000"
	set_param cpu2 hispeed_freq 1180000
	set_param cpu2 go_hispeed_load 98
	set_param cpu2 target_loads "80 380000:22 580000:48 680000:72 880000:88 1180000:98 1280000:85 1480000:92 1580000:98"
	set_param cpu2 min_sample_time 18000

    ;;

    "msm8994" | "msm8992")
	
	set_value 380000 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	set_value 380000 /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_value "0:1344000 4:1440000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value 1344000 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	set_value 1440000 /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
	set_value "0:1180000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "98000 1280000:18000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 580000:46 680000:16 780000:63 880000:91 1180000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "18000 1180000:98000 1380000:78000"
	set_param cpu4 hispeed_freq 880000
	set_param cpu4 go_hispeed_load 97
	set_param cpu4 target_loads "80 580000:44 680000:58 780000:71 880000:96"
	set_param cpu4 min_sample_time 38000
	
    ;;

    "msm8974" | "apq8084")
	
	stop mpdecision
	setprop ro.qualcomm.perf.cores_online 2
	set_value 2500 /sys/module/cpu_boost/parameters/input_boost_ms
	set_value "380000" /sys/module/cpu_boost/parameters/input_boost_freq

	set_param cpu0 boostpulse_duration 0
	set_param cpu0 above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:6 580000:25 680000:43 880000:61 980000:86 1180000:97"
	set_param cpu0 min_sample_time 18000
	start mpdecision

    ;;

    "sdm660")

	set_value 50 /sys/module/cpu_boost/parameters/input_boost_ms
	set_value "0:1080000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "18000 1480000:58000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 91
	set_param cpu0 boostpulse_duration 38000
	set_param cpu0 target_loads "80 880000:63 1080000:81 1380000:75 1480000:99"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "58000 1380000:18000 1680000:58000 1780000:138000"
	set_param cpu4 hispeed_freq 1080000
	set_param cpu4 go_hispeed_load 83
	set_param cpu4 boostpulse_duration 38000
	set_param cpu4 target_loads "80 1680000:99"
	set_param cpu4 min_sample_time 18000
	
    ;;
    "msm8956" | "msm8976")
	set_value 50 /sys/module/cpu_boost/parameters/input_boost_ms
	set_value "0:980000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 boost 0
	set_param cpu4 boost 0
	set_param cpu0 above_hispeed_delay "18000 1180000:38000 1280000:58000 1380000:18000"
	set_param cpu0 hispeed_freq 980000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 boostpulse_duration 58000
	set_param cpu0 target_loads "80 680000:58 780000:98 980000:65 1180000:79"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "18000 1580000:58000"
	set_param cpu4 hispeed_freq 1280000
	set_param cpu4 go_hispeed_load 97
	set_param cpu4 boostpulse_duration 18000
	set_param cpu4 target_loads "80 880000:69 1080000:90 1280000:74 1380000:91 1580000:99"
	set_param cpu4 min_sample_time 18000

    ;;

    "sdm636" )
	set_value "0:1480000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "18000 1380000:78000 1480000:98000 1580000:38000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:62 1080000:98 1380000:84 1480000:97"
	set_param cpu0 min_sample_time 58000
	set_param cpu4 above_hispeed_delay "18000 1680000:98000"
	set_param cpu4 hispeed_freq 1080000
	set_param cpu4 go_hispeed_load 86
	set_param cpu4 target_loads "80 1380000:84 1680000:98"
	set_param cpu4 min_sample_time 18000
    
	;;

    "msm8953" )
	set_value 0 /proc/sys/kernel/sched_boost
	set_value "0:1680000 4:0" /sys/module/cpu_boost/parameters/input_boost_freq
	set_param cpu0 above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 94
	set_param cpu0 target_loads "80 980000:66 1380000:96"
	set_param cpu0 min_sample_time 18000
    ;;

	
	"universal8895")
	set_param cpu0 above_hispeed_delay "38000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 82
	set_param cpu0 target_loads "80 680000:27 780000:39 880000:61 980000:68 1380000:98 1680000:94"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu4 hispeed_freq 1380000
	set_param cpu4 go_hispeed_load 98
	set_param cpu4 target_loads "80 780000:73 880000:79 980000:55 1080000:69 1180000:84 1380000:98"
	set_param cpu4 min_sample_time 18000
    ;;

	
	"universal8890")
	set_param cpu0 above_hispeed_delay "38000 1280000:18000 1480000:98000 1580000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 96
	set_param cpu0 target_loads "80 480000:51 680000:28 780000:56 880000:63 1080000:71 1180000:75 1280000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "18000 1480000:98000 1880000:138000"
	set_param cpu4 hispeed_freq 1280000
	set_param cpu4 go_hispeed_load 98
	set_param cpu4 target_loads "80 780000:4 880000:77 980000:14 1080000:90 1180000:68 1280000:92 1480000:96"
	set_param cpu4 min_sample_time 18000
    ;;

	"universal7420")
    set_param cpu0 above_hispeed_delay "38000 1280000:78000 1380000:98000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 96
	set_param cpu0 target_loads "80 480000:28 580000:19 680000:37 780000:51 880000:61 1080000:83 1180000:66 1280000:91 1380000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "98000 1880000:138000"
	set_param cpu4 hispeed_freq 1480000
	set_param cpu4 go_hispeed_load 97
	set_param cpu4 target_loads "80 880000:74 980000:56 1080000:80 1180000:92 1380000:85 1480000:93 1580000:98"
	set_param cpu4 min_sample_time 18000
    ;;

	
	"kirin970")  # Huawei Kirin 970
	set_param cpu0 above_hispeed_delay "18000 1380000:38000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 980000:60 1180000:87 1380000:70 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "18000 1580000:98000 1780000:138000"
	set_param cpu4 hispeed_freq 1280000
	set_param cpu4 go_hispeed_load 98
	set_param cpu4 target_loads "80 1280000:98 1480000:91 1580000:98"
	set_param cpu4 min_sample_time 18000
	
    ;;
	
	"kirin960")  # Huawei Kirin 960
	set_param cpu0 above_hispeed_delay "38000 1680000:98000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:93 1380000:97"
	set_param cpu0 min_sample_time 58000
	set_param cpu4 above_hispeed_delay "18000 1780000:138000"
	set_param cpu4 hispeed_freq 880000
	set_param cpu4 go_hispeed_load 84
	set_param cpu4 target_loads "80 1380000:98"
	set_param cpu4 min_sample_time 38000
	
    ;;

	"kirin950") # Huawei Kirin 950
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:62 980000:71 1280000:77 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "18000 1480000:98000 1780000:138000"
	set_param cpu4 hispeed_freq 780000
	set_param cpu4 go_hispeed_load 80
	set_param cpu4 target_loads "80 1180000:89 1480000:98"
	set_param cpu4 min_sample_time 38000
	
    ;;

	
	"mt6797t" | "mt6797") #Helio X25 / X20	 
	set_value 60 /proc/hps/down_threshold
	set_param cpu0 io_is_busy 0
	
	set_value 95 /proc/hps/up_threshold
	set_value "2 2 0" /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "18000 1480000:58000"
	set_param cpu0 hispeed_freq 980000
	set_param cpu0 go_hispeed_load 99
	set_param cpu0 boostpulse_duration 38000
	set_param cpu0 target_loads "85 380000:32 480000:10 580000:22 680000:36 780000:61 880000:91 980000:76 1080000:80 1180000:99 1380000:68 1480000:99"
	set_param cpu0 min_sample_time 18000
	
    ;;

	
       "mt6795") #Helio X10
	
	set_value 60 /proc/hps/down_threshold
	set_param cpu0 io_is_busy 0
	
	set_value 95 /proc/hps/up_threshold
	set_value 1 /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "18000 1280000:38000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 boostpulse_duration 18000
	set_param cpu0 target_loads "85 780000:63 1180000:68 1280000:92 1480000:99"
	set_param cpu0 min_sample_time 18000
	
    ;;

	*)
	
	if [ "$SOC" = "moorefield" ] || [ "$SOC" = "msm8939" ] || [ "$SOC" = "msm8939v2" ]; then 
	echo "Intel chip detected"
	else
	logdata "# *ERROR* Governor tweaks failed .. Unrecognized chip : $SOC" 
	fi
		
    ;;

    esac

    case "$SOC" in
    "moorefield") # Intel ATOM
    set_param cpu0 above_hispeed_delay "58000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 99
	set_param cpu0 boostpulse_duration 18000
	set_param cpu0 target_loads "85 580000:38 680000:88 780000:43 980000:66 1080000:91 1180000:99 1280000:91 1380000:87 1480000:93 1580000:98"
	set_param cpu0 min_sample_time 18000
	;;
    esac

    case "$SOC" in
	"msm8939" | "msm8939v2")  #sd615/616
	set_value "0:980000" /sys/module/cpu_boost/parameters/input_boost_freq

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate

	set_value 2500 /sys/module/cpu_boost/parameters/input_boost_ms
	set_value 0 /sys/module/msm_performance/parameters/touchboost


	set_value 0 $GOV_PATH_L/interactive/ignore_hispeed_on_notif
	set_value 0 $GOV_PATH_L/interactive/enable_prediction

	set_value 0 $GOV_PATH_B/interactive/ignore_hispeed_on_notif
	set_value 0 $GOV_PATH_B/interactive/enable_prediction

	set_param cpu0 above_hispeed_delay "18000 1344000:98000 1459000:138000"
	set_param cpu0 hispeed_freq 1113000
	set_param cpu0 go_hispeed_load 94
	set_param cpu0 target_loads "80 980000:66 1113000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "18000 1344000:98000 1459000:138000"
	set_param cpu4 hispeed_freq 1344000
	set_param cpu4 go_hispeed_load 94
	set_param cpu4 target_loads "80 980000:66 1113000:96"
	set_param cpu4 min_sample_time 18000
	set_param cpu4 use_sched_load 1
	set_param cpu0 use_sched_load 1

	set_param cpu0 above_hispeed_delay "98000 1459000:138000"
	set_param cpu0 hispeed_freq 1113000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:63 1113000:72 1344000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu4 above_hispeed_delay "98000 1459000:138000"
	set_param cpu4 hispeed_freq 1344000
	set_param cpu4 go_hispeed_load 97
	set_param cpu4 target_loads "80 980000:63 1113000:72 1344000:97"
	set_param cpu4 min_sample_time 18000
    esac
    fi
   
after_modify
 
# =========
# HMP Scheduler Tweaks
# =========

write /proc/sys/kernel/sched_select_prev_cpu_us 0
write /proc/sys/kernel/sched_spill_nr_run 5
write /proc/sys/kernel/sched_restrict_cluster_spill 1
write /proc/sys/kernel/sched_prefer_sync_wakee_to_waker 1
#write /proc/sys/kernel/sched_window_stats_policy 2
#write /proc/sys/kernel/sched_upmigrate 45
#write /proc/sys/kernel/sched_downmigrate 25
#write /proc/sys/kernel/sched_spill_nr_run 3
write /proc/sys/kernel/sched_spill_load 90
write /proc/sys/kernel/sched_init_task_load 40
#if [ -e "/proc/sys/kernel/sched_heavy_task" ]; then
#    write /proc/sys/kernel/sched_heavy_task 0
#fi
#write /proc/sys/kernel/sched_upmigrate_min_nice 15
#write /proc/sys/kernel/sched_ravg_hist_size 4
#if [ -e "/proc/sys/kernel/sched_small_wakee_task_load" ]; then
#write /proc/sys/kernel/sched_small_wakee_task_load 65
#fi
#if [ -e "/proc/sys/kernel/sched_wakeup_load_threshold" ]; then
#write /proc/sys/kernel/sched_wakeup_load_threshold 110
#fi
#if [ -e "/proc/sys/kernel/sched_small_task" ]; then
#write /proc/sys/kernel/sched_small_task 10
#fi
#if [ -e "/proc/sys/kernel/sched_big_waker_task_load" ]; then
#write /proc/sys/kernel/sched_big_waker_task_load 80
#fi
#if [ -e "/proc/sys/kernel/sched_rt_runtime_us" ]; then
#write /proc/sys/kernel/sched_rt_runtime_us 950000
#fi
#if [ -e "/proc/sys/kernel/sched_rt_period_us" ]; then
#write /proc/sys/kernel/sched_rt_period_us 1000000
#fi
#if [ -e "/proc/sys/kernel/sched_enable_thread_grouping" ]; then
#write /proc/sys/kernel/sched_enable_thread_grouping 1
#fi
#if [ -e "/proc/sys/kernel/sched_rr_timeslice_ms" ]; then
#write /proc/sys/kernel/sched_rr_timeslice_ms 20
#fi
#if [ -e "/proc/sys/kernel/sched_migration_fixup" ]; then
write /proc/sys/kernel/sched_migration_fixup 1
#fi
#if [ -e "/proc/sys/kernel/sched_freq_dec_notify" ]; then
write /proc/sys/kernel/sched_freq_dec_notify 400000
#fi
#if [ -e "/proc/sys/kernel/sched_freq_inc_notify" ]; then
write /proc/sys/kernel/sched_freq_inc_notify 3000000
#fi
#if [ -e "/proc/sys/kernel/sched_boost" ]; then
#write /proc/sys/kernel/sched_boost 0
#fi
#if [ -e "/proc/sys/kernel/sched_enable_power_aware" ]; then
#    write /proc/sys/kernel/sched_enable_power_aware 1
#fi

	else
	logdata "# *ERROR* Governor tweaks failed .. Unsupported governor '$govn'" 

	fi
	fi
	
	# Enable Thermal engine
	enable_bcl

        # Enable power efficient work_queue mode
	if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
	set_value "Y" /sys/module/workqueue/parameters/power_efficient 
	logdata "# Enabling power efficient work_queue mode .. DONE" 
	else
	logdata "# *WARNING* Your kernel doesn't support power efficient work_queue mode" 
	fi

#	if [ -e "/sys/devices/system/cpu/cpu0/cpufreq/interactive/screen_off_maxfreq" ]; then
#		set_param cpu0 screen_off_maxfreq 307200
#	fi
	if [ -e "/sys/devices/system/cpu/cpu0/cpufreq/interactive/powersave_bias" ]; then
		set_param cpu0 powersave_bias 1
	fi

}

# =========
# CPU Governor Tuning
# =========

CPU_tuning
 
# =========
# GPU Tweaks
# =========

 logdata "#  Governor Tuning  .. DONE" 

 set GPU default power level to 6 instead of 4 or 5
 set_value /sys/class/kgsl/kgsl-3d0/default_pwrlevel 6
	
 if [ -e "/sys/module/adreno_idler" ]; then
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "10000"
 logdata "# Enabling Adreno Idler (GPU) .. DONE" 
 else
 logdata "#  *WARNING* Your Kernel does not support Adreno Idler" 
 fi

# =========
# RAM TWEAKS
# =========

RAM_tuning

# =========
# REDUCE DEBUGGING
# =========

write "/sys/module/binder/parameters/debug_mask" "0"
write "/sys/module/bluetooth/parameters/disable_ertm" "Y"
write "/sys/module/bluetooth/parameters/disable_esco" "Y"
write "/sys/module/debug/parameters/enable_event_log" "0"
write "/sys/module/dwc3/parameters/ep_addr_rxdbg_mask" "0" 
write "/sys/module/dwc3/parameters/ep_addr_txdbg_mask" "0"
write "/sys/module/edac_core/parameters/edac_mc_log_ce" "0"
write "/sys/module/edac_core/parameters/edac_mc_log_ue" "0"
write "/sys/module/glink/parameters/debug_mask" "0"
write "/sys/module/hid_apple/parameters/fnmode" "0"
write "/sys/module/hid_magicmouse/parameters/emulate_3button" "N"
write "/sys/module/hid_magicmouse/parameters/emulate_scroll_wheel" "N"
write "/sys/module/ip6_tunnel/parameters/log_ecn_error" "N"
write "/sys/module/lowmemorykiller/parameters/debug_level" "0"
write "/sys/module/mdss_fb/parameters/backlight_dimmer " "N"
write "/sys/module/msm_show_resume_irq/parameters/debug_mask" "0"
write "/sys/module/msm_smd/parameters/debug_mask" "0"
write "/sys/module/msm_smem/parameters/debug_mask" "0" 
write "/sys/module/otg_wakelock/parameters/enabled" "N" 
write "/sys/module/service_locator/parameters/enable" "0" 
write "/sys/module/sit/parameters/log_ecn_error" "N"
write "/sys/module/smem_log/parameters/log_enable" "0"
write "/sys/module/smp2p/parameters/debug_mask" "0"
write "/sys/module/sync/parameters/fsync_enabled" "N"
write "/sys/module/touch_core_base/parameters/debug_mask" "0"
write "/sys/module/usb_bam/parameters/enable_event_log" "0"
write "/sys/module/printk/parameters/console_suspend" "Y"

set_value 0 "/sys/module/wakelock/parameters/debug_mask"
set_value 0 "/sys/module/userwakelock/parameters/debug_mask"
set_value 0 "/sys/module/earlysuspend/parameters/debug_mask"
set_value 0 "/sys/module/alarm/parameters/debug_mask"
set_value 0 "/sys/module/alarm_dev/parameters/debug_mask"
set_value 0 "/sys/module/binder/parameters/debug_mask"
set_value 0 "/sys/devices/system/edac/cpu/log_ce"
set_value 0 "/sys/devices/system/edac/cpu/log_ue"

sysctl -w kernel.panic_on_oops=0
sysctl -w kernel.panic=0

for i in $( find /sys/ -name debug_mask); do
 write $i 0;
done;

if [ -e /sys/module/logger/parameters/log_mode ]; then
 write /sys/module/logger/parameters/log_mode 2
fi;

logdata "#  Limit Logging & Debugging .. DONE" 

sleep 0.1

# =========
# I/O TWEAKS
# =========

sch=$(</sys/block/mmcblk0/queue/scheduler);


if [[ $sch == *"maple"* ]]
then
	set_io maple /sys/block/mmcblk0
	set_io maple /sys/block/sda
elif [[ $sch == *"row"* ]]
then
	set_io row /sys/block/mmcblk0
	set_io row /sys/block/sda
elif [[ $sch == *"zen"* ]]
then
	set_io zen /sys/block/mmcblk0
	set_io zen /sys/block/sda
else
	set_io cfq /sys/block/mmcblk0
	set_io cfq /sys/block/sda
fi


for i in /sys/block/loop*; do
	write $i/queue/add_random 0
	write $i/queue/iostats 0
   	write $i/queue/nomerges 1
   	write $i/queue/rotational 0
   	write $i/queue/rq_affinity 1
done

for j in /sys/block/ram*; do
	write $j/queue/add_random 0
	write $j/queue/iostats 0
	write $j/queue/nomerges 1
	write $j/queue/rotational 0
   	write $j/queue/rq_affinity 1
done

for k in /sys/block/sd*; do
	write $k/queue/add_random 0
	write $k/queue/iostats 0
done


logdata "#  Storage I/O Tuning  .. DONE" 

# =========
# TCP TWEAKS
# =========

algos=$(</proc/sys/net/ipv4/tcp_available_congestion_control);
if [[ $algos == *"westwood"* ]]
then
write /proc/sys/net/ipv4/tcp_congestion_control "westwood"
logdata "#  (TCP) Enabling westwood algorithm  .. DONE" 
elif [[ $algos == *"reno"* ]]
then
write /proc/sys/net/ipv4/tcp_congestion_control "reno"
logdata "#  (TCP) Enabling reno algorithm .. DONE" 
else
write /proc/sys/net/ipv4/tcp_congestion_control "cubic"
logdata "#  (TCP) Enabling cubic algorithm .. DONE" 
fi

write /proc/sys/net/ipv4/tcp_ecn 2
write /proc/sys/net/ipv4/tcp_dsack 1
write /proc/sys/net/ipv4/tcp_low_latency 1
write /proc/sys/net/ipv4/tcp_timestamps 1
write /proc/sys/net/ipv4/tcp_sack 1
write /proc/sys/net/ipv4/tcp_window_scaling 1

# Increase WI-FI scan delay
# sqlite=/system/xbin/sqlite3 wifi_idle_wait=36000 

# =========
# Minor Tweaks
# =========

# Disable experimental features

strings=(
NO_GENTLE_FAIR_SLEEPERS
START_DEBIT
NO_NEXT_BUDDY
LAST_BUDDY
CACHE_HOT_BUDDY
WAKEUP_PREEMPTION
NO_HRTICK
NO_DOUBLE_TICK
NO_LB_BIAS
NO_NONTASK_CAPACITY
NO_TTWU_QUEUE
NO_SIS_AVG_CPU
NO_RT_PUSH_IPI
NO_FORCE_SD_OVERLAP
NO_RT_RUNTIME_SHARE
RT_RUNTIME_GREED 
NO_LB_MIN
ATTACH_AGE_LOAD
ENERGY_AWARE
NO_MIN_CAPACITY_CAPPING
NO_FBT_STRICT_ORDER
NO_EAS_USE_NEED_IDLE
)


mount -t debugfs debugfs /sys/kernel/debug
for i in "${strings[@]}"; do
write /sys/kernel/debug/sched_features $i
done
umount /sys/kernel/debug


logdata "#  Enabling Misc Tweaks .. DONE" 

# =========
# Blocking Wakelocks
# =========

if [ -e "/sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker" ]; then
write /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;[timerfd];hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;"
logdata "#  Enabling Boeffla wake-locks blocker .. DONE" 
fi


if [ -e "/sys/module/wakeup/parameters" ]; then
if [ -e "/sys/module/bcmdhd/parameters/wlrx_divide" ]; then
set_value /sys/module/bcmdhd/parameters/wlrx_divide 8
fi
if [ -e "/sys/module/bcmdhd/parameters/wlctrl_divide" ]; then
set_value /sys/module/bcmdhd/parameters/wlctrl_divide 8
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluetooth_timer" ]; then
set_value /sys/module/wakeup/parameters/enable_bluetooth_timer Y
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ipa_ws" ]; then
set_value /sys/module/wakeup/parameters/enable_wlan_ipa_ws N
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_pno_wl_ws N" ]; then
set_value /sys/module/wakeup/parameters/enable_wlan_pno_wl_ws N
fi
if [ -e "/sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws N" ]; then
set_value /sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws N
fi
if [ -e "/sys/module/wakeup/parameters/wlan_wake" ]; then
set_value N /sys/module/wakeup/parameters/wlan_wake
fi
if [ -e "/sys/module/wakeup/parameters/wlan_ctrl_wake" ]; then
set_value N /sys/module/wakeup/parameters/wlan_ctrl_wake
fi
if [ -e "/sys/module/wakeup/parameters/wlan_rx_wake" ]; then
set_value N /sys/module/wakeup/parameters/wlan_rx_wake
fi
if [ -e "/sys/module/wakeup/parameters/enable_msm_hsic_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_msm_hsic_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_si_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_si_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluedroid_timer_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_bluedroid_timer_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_ipa_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_ipa_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_netlink_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_netlink_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_netmgr_wl_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_netmgr_wl_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_timerfd_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_timerfd_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_rx_wake_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_rx_wake_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wake_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_wake_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wow_wl_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws
fi
logdata "# Enabling kernel Wake-locks Blocking .. DONE" 
else
logdata "# *WARNING* Your kernel doesn't support wake-lock Blocking" 
fi

# =========
# Google Services Drain fix
# =========

sleep 0.1
su -c "pm enable com.google.android.gms"
sleep 0.1
su -c "pm enable com.google.android.gsf"
sleep 0.1
su -c "pm enable com.google.android.gms/.update.SystemUpdateActivity"
sleep 0.1
su -c "pm enable com.google.android.gms/.update.SystemUpdateService"
sleep 0.1
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver"
sleep 0.1
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$Receiver"
sleep 0.1
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver"
sleep 0.1
su -c "pm enable com.google.android.gsf/.update.SystemUpdateActivity"
sleep 0.1
su -c "pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity"
sleep 0.1
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService"
sleep 0.1
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver"
sleep 0.1
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver"


# =========
# CLEAN UP
# =========

# Search all subdirectories

for f in $(find /cache -name '*.apk' -or -name '*.tmp' -or -name '*.temp' -or -name '*.log' -or -name '*.txt' -or -name '*.0'); do sleep "0.001" && rm $f; done
for f in $(find /data -name '*.tmp' -or -name '*.temp' -or -name '*.log' -or -name '*.0'); do sleep "0.001" && rm $f; done
for f in $(find /sdcard -name '*.tmp' -or -name '*.temp' -or -name '*.log' -or -name '*.0'); do sleep "0.001" && rm $f; done


logdata "#  Clean-up .. DONE" 

# FS-TRIM

fstrim -v /cache
fstrim -v /data
fstrim -v /system

logdata "#  FS-TRIM .. DONE" 

start perfd

# =========
# Battery Check
# =========

logdata "# ==============================" 
logdata "#  Battery Technology: $BATT_TECH"
logdata "#  Battery Health: $BATT_HLTH"
logdata "#  Battery Temp: $BATT_TEMP °C"
logdata "#  Battery Voltage: $BATT_VOLT Volts "
logdata "#  Battery Level: $BATT_LEV % "
logdata "# ==============================" 
logdata "#  Finished : $(date +"%d-%m-%Y %r")" 

exit 0
