#!/bin/bash

function print() {
    case $1 in 
        -i)
            echo -e "[$(date +%Y-%m-%d\ %H:%M:%S) INFO]: $2"
            ;;
        -w)
            echo -e "[$(date +%Y-%m-%d\ %H:%M:%S) WARN]: $2"
            ;;
        -e)
            echo -e "[$(date +%Y-%m-%d\ %H:%M:%S) ERROR]: $2"
            ;;
        *)
            echo -e "[$(date +%Y-%m-%d\ %H:%M:%S) INFO]: "
            ;;
    esac
}

function init() {
    print -i "选择品牌"
    print -i "$(cat config.json | jq .name)"
    read -p "请输入品牌：" brand
    if [ "$brand" = "null" ]; then
        print -e "请输入正确的品牌"
        exit 1
    fi

    print -i "选择设备"
    print -i "$(cat config.json | jq .$brand.name)"
    read -p "请输入设备：" device
    if [ "$device" = "null" ]; then
        print -e "请输入正确的设备"
        exit 1
    fi

    print -i "是否更改软件源[y/n]"
    read -p "请输入：" change
    case $change in
        y|Y)
            print -i "选择软件源"
            print -i "1, 清华源: https://mirrors.tuna.tsinghua.edu.cn/"
            print -i "2, 北京源: https://mirrors.bfsu.edu.cn/"
            print -i "3, USTC源: https://mirrors.ustc.edu.cn/"
            print -i "4, 中科大源: https://mirrors.sjtug.sjtu.edu.cn/"
            print -i "5, 默认源"
            print -i "6, 自定义源"
            read -p "请输入[1~6]：" source
            case $source in 
                1)
                    jq '.source = "https://mirrors.tuna.tsinghua.edu.cn/"' build-config.json
                    print -i "已切换为清华源"
                    ;;
                2)
                    jq '.source = "https://mirrors.bfsu.edu.cn/"' build-config.json
                    print -i "已切换为北京源"
                    ;;
                3)
                    jq '.source = "https://mirrors.ustc.edu.cn/"' build-config.json
                    print -i "已切换为USTC源"
                    ;;
                4)
                    jq '.source = "https://mirrors.sjtug.sjtu.edu.cn/"' build-config.json
                    print -i "已切换为中科大源"
                    ;;
                5)
                    jq '.source = "https://repo.huaweicloud.com/repository/openeuler/"' build-config.json
                    print -i "已切换为默认源"
                    ;;
                6) 
                    print -i "请输入软件源"
                    read -p "请输入：" source
                    jq --arg source "$source" '.source = $source' build-config.json
                    print -i "已切换为自定义源"
                    ;;
                *)
                    print -e "请输入正确的软件源"
                    exit 1
                    ;;
            esac
            ;;
        n|N|*)
            print -i "已取消更改软件源"
            ;;
    esac

    print -i "设置设备名称"
    read -p "请输入：" name
    if [ "$name" = "" ]; then
        print -e "请输入正确的设备名称"
        exit 1
    fi

    jq --arg name "$name" '.hostname = $name' build-config.json

    print -i "设置设备用户"
    read -p "请输入：" user
    if [ "$user" = "" ]; then
        print -e "请输入正确的设备用户"
        exit 1
    fi
    jq --arg user "$user" '.username = $user' build-config.json

    print -i "设置设备密码"
    read -p "请输入：" password
    if [ "$password" = "" ]; then
        print -e "请输入正确的设备密码"
        exit 1
    fi

    jq --arg password "$password" '.password = $password' build-config.json

    print -i "是否需要预装软件包[y/n]"
    read -p "请输入：" preinstall
    case $preinstall in
        y|Y)
            print -i "请输入软件包名称如: vim git wget curl htop"
            read -p "请输入：" packages
            if [ "$packages" = "" ]; then
                print -e "请输入正确的软件包名称"
                exit 1
            fi
            jq --arg packages "$packages" '.packages = $packages' build-config.json
            ;;
        n|N|*)
            print -i "已取消预装软件包"
            ;;
    esac

    print -i "哪些服务需要自启动,如没有请直接回车"
    read -p "请输入：" enable-services
    if [ "$autostart" != "" ]; then
        jq --arg autostart "$autostart" '.autostart = $autostart' build-config.json
    fi

    print -i "是否安装Open-SSH[y/n]"
    read -p "请输入：" opssh
    case $opssh in
        y|Y)
            jq '.opssh = true' build-config.json
            print -i "已设置安装Open-SSH"
            ;;
        n|N|*)
            print -i "已取消安装Open-SSH"
            ;;
    esac
    print -i "选择一个桌面环境"
    print -i "1, KDE-Plasma"
    print -i "2, GNOME"
    print -i "3, Phosh"
    print -i "4, LXQT"
    print -i "5, 不安装"
    read -p "请输入[1~5]：" desktop
    case $desktop in
        1)
            jq '.desktop = "kubuntu-desktop"' build-config.json
            print -i "已选择KDE-Plasma"
            ;;
        2)
            jq '.desktop = "ubuntu-desktop"' build-config.json
            print -i "已选择GNOME"
            ;;
        3)
            jq '.desktop = "phosh"' build-config.json
            print -i "已选择Phosh"
            ;;
        4)
            jq '.desktop = "lxqt"' build-config.json
            print -i "已选择LXQT"
            ;;
        5)
            jq '.desktop = "none"' build-config.json
            print -i "已取消安装桌面环境"
            ;;
        *)
            print -e "请输入正确的桌面环境"
            exit 1
            ;;
    esac

    print -i "已完成Init"
}

function build() { 
    print -i "开始构建"
    device=$(cat build-config.json | jq .device)
    mirror-source=$(cat build-config.json | jq .source)
    linux=$(cat build-config.json | jq .linux)
    firmware=$(cat build-config.json | jq .firmware)
    hostname=$(cat build-config.json | jq .hostname)
    username=$(cat build-config.json | jq .username)
    password=$(cat build-config.json | jq .password)
    prepackages=$(cat build-config.json | jq .pre-installed-packages)
    enable_services=$(cat build-config.json | jq .enable-services)
    openssh=$(cat build-config.json | jq .openssh-server)
    desktop=$(cat build-config.json | jq .desktop)

    mkdir dl
    print -i "下载Linux Kernel"
    curl -L "$linux" -o dl/linux.tar.gz
    if [ $? -ne 0 ]; then
        print -e "下载Linux Kernel失败"
        exit 1
    fi
    print -i "下载Firmware"
    curl -L "$firmware" -o dl/firmware.tar.gz
    if [ $? -ne 0 ]; then
        print -e "下载Firmware失败"
        exit 1
    fi
    print -i "下载Rootfs(Ubuntu 22.04.5 LTS)"
    curl -L "https://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/ubuntu-base-24.04.3-base-arm64.tar.gz" -o dl/rootfs.tar.gz
    if [ $? -ne 0 ]; then
        print -e "下载Rootfs失败"
        exit 1
    fi
    print -i "构建Linux Kernel 过程可能会比较长，请耐心等待"
    sleep 3
    mkdir -p build/linux
    tar -xvf dl/linux.tar.gz -C build/linux
    print -i "进入目录 build/linux"
    cd build/linux
    print -i "生成配置文件"
    sudo make ARCH=arm64 defconfig ${device}_defconfig
    print -i "开始编译"
    sudo make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
    if [ $? -ne 0 ]; then
        print -e "编译Linux Kernel失败"
        exit 1
    fi
    print -i "编译完成"

    print -i "进入目录 build"
    cd ../
    print -i "开始构建Android Boot"
    cat linux/arch/arm64/boot/Image.gz linux/arch/arm64/boot/dts/qcom/raphael.dtb > Image.gz-dtb
    bash device/raphael-mkbootimg.sh
}