#!/bin/sh

#--------------------------------------------
# 功能：为xcode工程打ipa包
# 作者：winters_huang
# E-mail:huanghuorong@gmail.com
# 创建日期：2013/07/30
#--------------------------------------------

cd $1

cat << EOF > install.html <!DOCTYPE HTML> <html>   <head>     <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />     <title>安装此软件</title>   </head>   <body>     <ul>       <li>安装此软件:<a href="itms-services://?action=download-manifest&url=http%3A%2F%2Fwww.yourdomain.com%2Fynote.plist">$FILE_NAME</a></li>     </ul>     </div>   </body> </html> EOF 

cat << EOF > ynote.plist <?xml version="1.0" encoding="UTF-8"?> <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> <plist version="1.0"> <dict>    <key>items</key>    <array>        <dict>            <key>assets</key>            <array>                <dict>                    <key>kind</key>                    <string>software-package</string>                    <key>url</key>                    <string>http://www.yourdomain.com/$FILE_NAME</string>                </dict>                <dict>                    <key>kind</key>                    <string>display-image</string>                    <key>needs-shine</key>                    <true/>                    <key>url</key>                    <string>http://www.yourdomain.com/icon.png</string>                </dict>            <dict>                    <key>kind</key>                    <string>full-size-image</string>                    <key>needs-shine</key>                    <true/>                    <key>url</key>                    <string>http://www.yourdomain.com/icon.png</string>                </dict>            </array><key>metadata</key>            <dict>                <key>bundle-identifier</key>                <string>com.yourdomain.productname</string>                <key>bundle-version</key>                <string>1.0.0</string>                <key>kind</key>                <string>software</string>                <key>subtitle</key>                <string>ProductName</string>                <key>title</key>                <string>ProductName</string>            </dict>        </dict>    </array> </dict> </plist>   EOF 





