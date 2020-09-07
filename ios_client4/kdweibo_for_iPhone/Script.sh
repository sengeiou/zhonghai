#!/bin/sh

#  Script.sh
#  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
#--------------------------------------------
# 功能：一键完成：为xcode工程打ipa包，生成在线安装页，拷贝ipa到测试环境，使用说明：

#--------------------------------------------

#----------------------定义固定参数----------------------
TARGETPATH=$1 #编辑工程路径


RESOUCE="Resource"            #应用程序图标
PROFILE="Profile"             #背景图标
TUTORIALS="Tutorials"         #新版介绍图标
#SET_AVATAR="Setavatar"        #移动签到图标
SIGNIN="SignIn"               #登录界面图标
IMAGE="ImageV2.3"             #轻应用默认图标
#-end----------------------------------------------------



#--------------------------------------------------替换图标--------------------------------------------------

cd $2 #替换文件路径
echo "Start Replace picture"

for file in `ls`
do
if [ -d $file ]

then
echo $file"是目录"
cd $file
if [ "$file" == "$RESOUCE" ]
then
for itemFile in `ls`
do
echo $itemFile
find $TARGETPATH/kdweibo_for_iPhone -name "$itemFile" -exec cp ./$itemFile {} \;
done
cd ..
elif [ "$file" == "$PROFILE" ]
then
for itemFile in `ls`
do
echo $itemFile
find $TARGETPATH/kdweibo_for_iPhone/Images/3.0/Profile -name "$itemFile" -exec cp ./$itemFile {} \;
done
cd ..
elif [ "$file" == "$TUTORIALS" ]
then
for itemFile in `ls`
do
echo $itemFile
find $TARGETPATH/kdweibo_for_iPhone/Images/3.0/Tutorials -name "$itemFile" -exec cp ./$itemFile {} \;
done
cd ..

elif [ "$file" == "$IMAGE" ]
then
for itemFile in `ls`
do
echo $itemFile
find $TARGETPATH/kdweibo_xuntong/xuntong_resource/image/imageV2.3 -name "$itemFile" -exec cp ./$itemFile {} \;
done
cd ..

elif [ "$file" == "$SIGNIN" ]
then
for itemFile in `ls`
do
echo $itemFile
find $TARGETPATH/kdweibo_for_iPhone/Images/3.0/signIn -name "$itemFile" -exec cp ./$itemFile {} \;
done
cd ..

else
for itemFile in `ls`
do
echo $itemFile
find $TARGETPATH/kdweibo_xuntong/xuntong_resource/image/imageV2.3 -name "$itemFile" -exec cp ./$itemFile {} \;
done
cd ..
echo "Replace piccture Done"
fi
elif [ "${file##*.}" == "mobileprovision" ]
then
TARGETMOBILEPROVISION=$file   #所需的mobileprovision文件名
echo $TARGETMOBILEPROVISION

elif [ "${file##*.}" == "p12" ]
then
P12=$file                        #所需的P12文件名
echo $P12

elif [ "$file" == "ios.properties" ]
then
#Update App Protocol
desc1=`sed '/^description=/!d;s/.*=//' ios.properties`
pwd
echo "Start replace update protocol"
sed -i '' "s/\"1.增加问题跟踪功能；\",//g" $TARGETPATH/kdweibo_for_iPhone/iphone.json
sed -i '' "s/2.微博功能优化；/$desc1/g" $TARGETPATH/kdweibo_for_iPhone/iphone.json
sed -i '' 's/|/\\n/g' $TARGETPATH/kdweibo_for_iPhone/iphone.json
#友盟key
Umengkey=`sed '/^umengkey=/!d;s/.*=//' ios.properties`
echo $Umengkey
#forcebuild 强制升级
forcebuild=`sed '/^forcebuild=/!d;s/.*=//' ios.properties`
sed -i '' "s/1000/$forcebuild/g" $TARGETPATH/kdweibo_for_iPhone/iphone.json
##高德地图key
mapKey=`sed '/^baidukey=/!d;s/.*=//' ios.properties`
if [ ! -n "$mapKey" ]; then
echo "mapKey is NULL"
else
pwd
echo "开始替换高德地图"
##sh ../map_gd.sh
sed -i '' "s/5f2af8e75444cfd42acd211fb90ef96c/$mapKey/g" $TARGETPATH/kdweibo_common/Classes/Common/KDCommon.h
echo "mapKey is $mapKey"
fi
elif [ "$file"  == "profile.properties" ]
then

#项目编号
Pro_code=`sed '/^Pro_code=/!d;s/.*=//' profile.properties`
#项目编号
Pro_name=`sed '/^Pro_name=/!d;s/.*=//' profile.properties`
echo $Pro_name
#微博域名
SNS_addr=`sed '/^SNS_addr=/!d;s/.*=//' profile.properties`
echo $SNS_addr
#消息域名
XT_addr=`sed '/^XT_addr=/!d;s/.*=//' profile.properties`
echo $XT_addr
echo SNS_SSL
SNS_ssl=`sed '/^ssl=/!d;s/.*=//' profile.properties`
echo $SNS_ssl
#微博端口
SNS_port=`sed '/^SNS_port=/!d;s/.*=//' profile.properties`
#消息端口
XT_port=`sed '/^XT_port=/!d;s/.*=//' profile.properties`
echo "SNS_port: $SNS_port,XT_port=$XT_port"
else

cat profile.properties|grep Pro_name|awk -F '=' '{print $2}'
fi
done
#-end-------------------------------------------------替换图标--------------------------------------------------




#-----------------------------------------------------替换名称--------------------------------------------------
TARGETPATH11="$TARGETPATH/kdweibo_common/Classes/Common"
TARGETPATH12="$TARGETPATH/kdweibo_xuntong/xuntong_common/net"
TARGETPATH13="$TARGETPATH/kdweibo_common/Classes/Util"

#-end----------------------------------------------------替换名称--------------------------------------------------

sed -i '' "s/云之家/$Pro_name/g" $TARGETPATH11/KDCommon.h

##sed -i '' "s/umeng_key/$Umengkey/g" $TARGETPATH13/KDEventAnalysis.m
sed -i '' "s/@\"\"/@\"$Umengkey\"/g" $TARGETPATH13/KDEventAnalysis.m

echo "helloworld"


#if [ ! -n "$mapKey" ]; then
#echo "mapKey is NULL"
#else
#sed -i '' "s/f4c85e8c23212cc5e7e5c7a254ec533b/$mapKey/g" $TARGETPATH11/KDCommon.h
#fi

#-----------------------------------------------------配置证书------------------------------------------------------------
PASSWORD=$5
mac_password="123456"
echo "##################################1###################################"

#import key-chain
security unlock-keychain -p $mac_password /Users/kingdee/Library/Keychains/login.keychain
security list-keychains -s /Users/kingdee/Library/Keychains/login.keychain
security import $2/$P12 -k /Users/kingdee/Library/Keychains/login.keychain -P $PASSWORD -T /usr/bin/codesign
security find-identity -p codesigning /Users/kingdee/Library/Keychains/login.keychain
echo "##################################2###################################"
# Provisioning Profile
PROFILE_DATA=$(security cms -D -i ${TARGETMOBILEPROVISION})
PROVISIONING_PROFILE_NAME=$(/usr/libexec/PlistBuddy -c 'Print :Name' /dev/stdin <<< $PROFILE_DATA)
UUID=$(/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $PROFILE_DATA)
APP_ID_PREFIX=$(/usr/libexec/PlistBuddy -c 'Print :ApplicationIdentifierPrefix:0' /dev/stdin <<< $PROFILE_DATA)
CODE_SIGN_IDENTITY=$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' /dev/stdin <<< $PROFILE_DATA)
echo "PROJECT_NAME: ${PROJECT_NAME}"
echo "PROVISIONING_PROFILE: ${PROFILE}"
echo "PROFILE_NAME: ${PROVISIONING_PROFILE_NAME}"
echo "UUID: ${UUID}"
echo "CODE_SIGN_IDENTITY: ${CODE_SIGN_IDENTITY}"
echo "APP_ID_PREFIX: ${APP_ID_PREFIX}"

# Copy 來源的 Provisioning Profile 至 OS
cp -rf $TARGETMOBILEPROVISION /Users/kingdee/Library/MobileDevice/Provisioning\ Profiles/$UUID.mobileprovision

#从provision中获取BundleIdentifier
BUNDLEIDENTIFIER=${CODE_SIGN_IDENTITY#*.}
echo "#####################################################################"
echo $BUNDLEIDENTIFIER
#-end--------------------------------------------------配置证书------------------------------------------------------------

cd $1/kdweibo_for_iPhone/

#工程绝对路径
project_path=$(pwd)
#---------------------------------------------------修改plist文件------------------------------------------------------------
sed -i '' "s/xt[a-z]*.msbu.kingdee.com/$XT_addr:$XT_port/g" $TARGETPATH12/URL+MCloud.h                                          #替换讯通消息url
echo $SNS_ssl
if [ $SNS_ssl -eq 0 ];then
/usr/libexec/PlistBuddy -c "Set :kdweibo.pref.serverBaseURL http://$SNS_addr:$SNS_port" ./kdweibo_conf.plist #替换微博url
/usr/libexec/PlistBuddy -c "Set :kdweibo.pref.restBaseURL   http://$SNS_addr:$SNS_port/snsapi" ./kdweibo_conf.plist            #替换微博url
else
/usr/libexec/PlistBuddy -c "Set :kdweibo.pref.serverBaseURL https://$SNS_addr:$SNS_port" ./kdweibo_conf.plist
/usr/libexec/PlistBuddy -c "Set :kdweibo.pref.restBaseURL   https://$SNS_addr:$SNS_port/snsapi" ./kdweibo_conf.plist
fi


sed -i '' 's/com.kingdee.yzjyfw/$BUNDLEIDENTIFIER/g' ./Info.plist
if [ "$4" = "zsgroup" ];then
sed -i '' "s/emp10200/ezsgroup/g" ./Info.plist
else
sed -i '' "s/emp10200/$4/g" ./Info.plist
fi
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLEIDENTIFIER" ./Info.plist                                  #替换bundleIdentifier
#Bundle display name
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $Pro_name" ./Info.plist
echo $3
echo "BuildNo:$3"
sed -i '' 's/999/$BUNDLEIDENTIFIER/g' ./Info.plist
/usr/libexec/PlistBuddy -c "Set :BuildNo $3" ./Info.plist                                                             #替换BuildNo

##sed -i  '' "s/MSBU/$Pro_name/g"  ./zh_CN.lproj/InfoPlist.strings                                             #替换DisplayName
##/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $Pro_name" ./Info.plist
touch InfoPlist.strings
echo \"CFBundleDisplayName\" = \"$Pro_name\"\; >> InfoPlist.strings
mv InfoPlist.strings ./zh_CN.lproj/InfoPlist.strings
echo "替换InfoPlist.strings"

#-end--------------------------------------------------修改plist文件----------------------------------------------------------



#-----------------------------------------------------build 并打包--------------------------------------------------

#build文件夹路径
build_path=${project_path}/build

#工程配置文件路径
project_name=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')
echo "project_name: $project_name"

project_infoplist_path=${project_path}/Info.plist
echo "project_infoplist_path: $project_infoplist_path"

#取build值
#bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${project_infoplist_path})
#echo "bundleVersion: $bundleVersion"

cd $project_path
#clean工程
xcodebuild clean -configuration "Release" || exit
xcodebuild -target $project_name clean

#编译工程
xcodebuild -configuration "Release" -target $project_name -sdk iphoneos PROVISIONING_PROFILE="$UUID" CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" || exit

#进入build路径
cd $build_path

#创建ipa-build文件夹
if [ -d ./ipa-build ];then
rm -rf ipa-build
fi
mkdir ipa-build

#IPA名称
ipa_name="${project_name}_$(date +"%Y%m%d")"
echo $ipa_name

appdirname="Release-iphoneos"
#xcrun打包

xcrun -sdk iphoneos PackageApplication -v ./$appdirname/*.app -o ${build_path}/ipa-build/${ipa_name}.ipa || exit

if [ "$output_path" != "" ];then
cp ${build_path}/ipa-build/${ipa_name}.ipa $output_path/${ipa_name}.ipa
echo "Copy ipa file successfully to the path $output_path/${ipa_name}.ipa"
fi



