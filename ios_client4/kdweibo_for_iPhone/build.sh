#!/bin/sh

#--------------------------------------------
# 功能：一键完成：为xcode工程打ipa包，生成在线安装页，拷贝ipa到测试环境，使用说明：
#     1. 导入测ipa说用的provision -> assets/keys/TestKdweiboClient_Development_Provisioning.mobileprovision
#     2. 打开终端，执行当前脚本
#     3. 如提示找不到 Xcode path,需执行: sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/
#     4. 如不需要发布到221测试环境，需屏蔽代码，见 script_copy2Server
# 作者：winters_huang
# E-mail:huanghuorong@gmail.com
# 创建日期：2013/07/30
# Usage:
#     1. 测试环境安装包 sh build.sh
#     2. 正式环境安装包 sh build.sh product
#--------------------------------------------

#Question:
#IF Build Error: xcrun: Error: could not stat active Xcode path '/Volumes/02_tools/Xcode.app/Contents/Developer'. (No such file or directory)
#THEN RUN CMD AT Terminal, Use following...
#sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/
#参数判断
#@huanghuorong 固定参数，将构建脚本放到项目根目录

#拷贝项目到构建临时目录
rm -rf ../buildtmp4iPhone
mkdir ../buildtmp4iPhone
cd ..
rsync -av --exclude ".svn" --exclude "build" kdweibo_xuntong buildtmp4iPhone/
rsync -av --exclude ".svn" --exclude "build" kdweibo_for_iPhone buildtmp4iPhone/
rsync -av --exclude ".svn" --exclude "build" kdweibo_common buildtmp4iPhone/
rsync -av --exclude ".svn" --exclude "build" MailCore buildtmp4iPhone/
rsync -av --exclude ".svn" --exclude "build" QREncoder buildtmp4iPhone/
#DTCoreText 项目需要连同 **build** 一起拷贝
rsync -av --exclude ".svn" --exclude "build" DTCoreText buildtmp4iPhone/


cd ./buildtmp4iPhone/kdweibo_for_iPhone/

#工程绝对路径
project_path=$(pwd)
#变量声明
CODE_SIGN_IDENTITY="iPhone Developer: YOU XINGWANG (568Q969HNG)"
if [ "$1" = "product" ] ; then
CODE_SIGN_IDENTITY="iPhone Developer: YOU XINGWANG (568Q969HNG)"
fi
if [ "$1" = "enterprise" ] ; then
CODE_SIGN_IDENTITY="iPhone Distribution: Kingdee Software (China) Co.,Ltd."
fi

#这里对应provision文件名，获取方法很多，均要先删除原provision，再导入新provison到系统
PROVISIONING_PROFILE="8746124D-4BE5-4C3A-9EE3-CDFD933A5324"
if [ "$1" = "product" ] ; then
PROVISIONING_PROFILE="0B5878CC-36B6-42F4-AFC2-93FD4B194F5A"
fi
if [ "$1" = "enterprise" ] ; then
PROVISIONING_PROFILE="5AF5665B-AFEA-414F-8317-143F6EC5BD53"
fi

#替换为测试环境安装包
if [ "$1" = "product" ] ; then
sed -i  '' 's/192.168.1.221/kdweibo.com/g' ./kdweibo_conf.plist
echo "product..."
else
if [ "$1" = "enterprise" ] ; then
echo "enterprise..."
sed -i  '' 's/192.168.1.221/kdweibo.com/g' ./kdweibo_conf.plist
sed -i '' 's/com.kdweibo.client/com.kdweibo.enterprise.tester/g' ./Info.plist
sed -i '' 's@\<string\>com.kingdee.kdweibo\<\/string\>@'\<string\>com.kingdee.enterprise.tester\<\/string\>'@g' ./Info.plist
sed -i '' 's@\<string\>kdweibo\<\/string\>@'\<string\>kdweiboenterprisetest\<\/string\>'@g' ./Info.plist
sed -i '' 's@\<string\>kdweiboavailable\<\/string\>@'\<string\>kdweiboavailableenterprisetest\<\/string\>'@g' ./Info.plist
cp -rf ./assets/InfoPlist.enterpriseEnv ./zh_CN.lproj/InfoPlist.strings
else
echo "test..."
sed -i  '' 's/kdweibo.com/192.168.1.221/g' ./kdweibo_conf.plist

sed -i '' 's/com.kdweibo.client/com.kdweibo.clienttest/g' ./Info.plist
sed -i '' 's@\<string\>com.kingdee.kdweibo\<\/string\>@'\<string\>com.kingdee.kdweibotest\<\/string\>'@g' ./Info.plist
sed -i '' 's@\<string\>kdweibo\<\/string\>@'\<string\>kdweibotest\<\/string\>'@g' ./Info.plist
sed -i '' 's@\<string\>kdweiboavailable\<\/string\>@'\<string\>kdweiboavailabletest\<\/string\>'@g' ./Info.plist
cp -rf ./assets/InfoPlist.testEnv ./zh_CN.lproj/InfoPlist.strings
fi
fi

#build文件夹路径
build_path=${project_path}/build

#工程配置文件路径
project_name=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')
echo "project_name: $project_name"

project_infoplist_path=${project_path}/Info.plist
echo "project_infoplist_path: $project_infoplist_path"

#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${project_infoplist_path})
echo "bundleVersion: $bundleVersion"

#编译工程
cd $project_path
#xcodebuild clean -configuration "Distribution" || exit

xcodebuild -configuration "Distribution" clean build  -arch "armv7s" -arch "armv7" -target "kdweibo" -sdk iphoneos CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${PROVISIONING_PROFILE}" GCC_VERSION="com.apple.compilers.llvm.clang.1_0" || exit
#TODO 构建子项目

#打包
cd $build_path
target_name=$(basename ./Distribution-iphoneos/*.app | awk -F. '{print $1}')

ipa_name="${target_name}_${bundleVersion}_build_$(date +"%m%d")_$1"


if [ -d ./ipa ]
then
rm -rf ipa
fi
mkdir -p ipa/Payload
cp -r ./Distribution-iphoneos/*.app ./ipa/Payload/
cd ipa
zip -r ${ipa_name}.ipa *
rm -rf Payload

ipa_root=$build_path/ipa
ipa_path=${ipa_root}/${ipa_name}.ipa
echo "*** Build and archiva ipa finish,output file at: $ipa_path"

#调用生成HTML,PLIST在线安装网页（TODO）
#script_makepage="subBuildTask02.sh"
#echo "*** Calling $script_makepage "

#cd $project_path
#chmod 777 $script_makepage
#./$script_makepage $ipa_root

#调用拷贝到测试服务器脚本，在线安装地址： http://192.168.1.221/res/client/beta
script_copy2Server="subBuildTask01.exp"
echo "*** Calling $script_copy2Server"

cd $project_path
chmod 777 $script_copy2Server

src_path=$ipa_path

dest_path=/kingdee/client/beta/kdweibo_beta_221.ipa
if [ "$1" = "product" ]  ; then
dest_path=/kingdee/client/beta/kdweibo_beta.ipa
fi
if [ "$1" = "enterprise" ]  ; then
dest_path=/kingdee/client/beta/kdweibo_enterprise.ipa
fi

./$script_copy2Server $src_path $dest_path

echo "Build finish."
echo "Online install goto http://192.168.1.221/res/client/beta"
echo ""







