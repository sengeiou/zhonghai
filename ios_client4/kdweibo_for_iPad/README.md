云之家 for iPad 项目描述
======================

把这玩意儿跑起来
--------------
首先，我们来把项目弄到你自己的xcode里并编译出来运行起来

1. 找个人要到彩程代码库金蝶项目访问权限，可以参考后面的联系人清单
1. `git clone git@git.mycolorway.com:KdWeiboIpad.git YOUR_LOCAL_PATH_OR_NULL`
1. `cd YOUR_LOCAL_PATH_OR_NULL`
1. `git submodule init`
1. `git submodule update`
1. 在XCode里打开KdWeiboIpad.xcodeproj
1. run

### trouble shooting
// TODO: fill this section


程序的大致结构
------------
### KWEngine
KWEngine的主要目的有:
* 为iOS程序提供一个尽可能简单的访问金蝶API的API (......)
* 提供封装金蝶API数据实体的容器类

这个文件夹里KWEngine是个简单的金蝶API客户端，entities文件夹里数据容器类，剩下的是些辅助类，在后面的模块清单里再详述。
因为期望这组类可以尽可能重用，我没有在这里做任何持久化工作，所以数据容器类都和core data没关系。

### KdWeiboIpad
项目自有的代码主要在这里，并且主要是views和controllers两个目录里的UI。misc里有一些工具类。Resources/img里是UI里用的图片。具体的每个类后面说。

### KWData
主管数据持久化。因为离线可用的要求并不高，所以现在只持久化了社区动态的timeline而已。考虑到如何处理持久化是针对应用的，所以KWData和KWEngine分离了，并且从属于KdWeiboIpad。其实我还是在想有没有可能把KWData独立出来供更大范围的重用。

### system/third party lib
这里只列出主要的库，而库里面类的描述，例如我有没有修改第三方代码，参见模块清单。

ASIHttpRequest
: https://github.com/pokeb/asi-http-request
  用来做网络请求。KWEngine用到。KdWeiboIpad里偶尔有用。

ASIHttpRequest+OAuth
: https://github.com/keybuk/asi-http-request-oauth
  基于ASI的OAuth库。KWEngine用到。

DTCoreText
: https://github.com/Cocoanetics/DTCoreText
  比系统默认TextView更强大的文字渲染，多处视图用到，以KWIStatusContent最为典型。

SBJSON
: https://github.com/stig/json-framework
  json解析。KWEngine有用，别的地方少数有用...吧。

SDWebImage
: https://github.com/rs/SDWebImage
  给一个UIImageView设置图片url。很多视图有用。

KTTextView
: https://github.com/kirbyt/KTTextView
  给textview加上placeholder, 用户反馈的视图用了。

EGOTableViewPullRefresh
: https://github.com/enormego/EGOTableViewPullRefresh/
  给TableView加上下来刷新支持，很多列表用了。 

iToast
: https://github.com/ecstasy2/toast-notifications-ios
  用来显示提示消息的库。

TBXML
: https://github.com/71squared/TBXML
  XML解析。访问雅虎和Google的天气API时候用了。

CoreLocation
: 取天气的时候用。

CoreText
: DTCoreText要用。

MapKit
: iOS4设备上取地理位置的时候要用。

Security
: OAuth要用


不完全模块清单
------------
### KWEngine

KWEngine
: 金蝶API的客户端。内含一个KWEngineDelegate protocel，但是因为block回调很方便，delegate已经大体弃用，只是留着万一遇到不方便用block的地方。

KWOAuthToken
: 封装一个OAuthToken

KWPaging
: 旨在更方便地设置API分页参数的类。

NSDate+KWDataExt, NSObject+KWDataExt
: 针对金蝶API数据格式的一些工具。

KWEntity及同目录下它的子类们
: KWEntity是所有金蝶API数据实体的抽象父类，提供了一般化的数据解析逻辑，使得其子类近似于只需要定义一下属性和API返回数据只见的对应关系就可以用xxxFromDict和xxxsFromDict这两个方法。

### KdWeiboIpad

KWIAppDelegate
: app delegate

KWIGlobal
: 一开始规划用来放伪全局常量的地方，后来几乎没有用

#### controllers/layout

KWIRootVCtrl
: 登陆后主界面的框架。

KWIMPanelVCtrl
: 主界面左侧面板的各种视图的抽象父类

KWIRPanelVCtrl
: 容纳主界面右侧各种卡片视图的栈

#### controllers/mpanel
主界面左侧面板的各种视图

KWIGroupLsVCtrl
: 小组列表，因为UI特殊所以没有继承KWIMPanelVCtrl
 
#### controllers/misc
KWIConversationVCtrl
: 一个会话的卡片

KWIRelationshipVCtrl, KWIFollowersVCtrl, KWIFolloweringsVCtrl
: KWIFollowersVCtrl和KWIFolloweringsVCtrl分别是用户profile卡片的关注的人列表和粉丝列表。它们的共同逻辑在父类KWIRelationshipVCtrl

KWIFullImgVCtrl
: 全屏查看图片

KWIGroupInfVCtrl
: 小组信息卡片

KWILoadMoreVCtrl
: 这是放在列表底部的加载更多控件

KWIMentionSelectorVCtrl
: 发新微博的时候选人@的控件

KWIPeopleStreamVCtrl
: 用户profile卡片里这个用户的微博视图

KWIPeopleVCtrl
: 用户profile卡片

KWIPostVCtrl
: 发微博卡片

KWIProfileTrendLsVCtrl
: 用户profile里的话题视图

KWISelectThreadParticipantVCtrl
: 新建短邮的选择收件人视图

KWISigninVCtrl
: 登录和注册视图

KWISimpleFollowingsVCtrl
: 用户关注的人列表，原来是新建短邮和@人的时候用的，现在已经没有用了

KWIStatusVCtrl
: 微博详情卡片

KWITrendStreamVCtrl
: 一个话题的timeline卡片

KWIWebVCtrl
: 应用内置web view，现已弃用

KWIWelcomeVCtrl
: 主界面右边没有卡片时显示的天气等等乱七八糟东西的面板

KWITutorialVCtrl
: 新手引导

#### controllers/misc
KWISettingsNavCtrl
: 设置视图的自定义navigation controller, 为了用自定义的标题栏背景

KWISettingsPgVCtrl
: 为了实现自定义标题栏背景，push进KWISettingsNavCtrl的每一个vctrl都要有的一些额外逻辑，放在这个抽象父类。

KWISettingsVCtrl
: 设置

KWIAboutVCtrl
: 关于

KWIFeedbackVCtrl
: 用户反馈

KWIRateVCtrl
: 评分，目前还没实现


#### views
KWIAvatarV
: 各种尺寸的头像，自带蒙板

KWIMessageCell
: 会话里的一条消息

KWIStatusCell
: hometimeline里的一条微博

KWITutorialNetworkV
: 选择社区的新手指引

KWICommentCell
: 微博详情卡片里的一条回复

KWINetworkBannerV
: 切换社区的社区列表里的一项

KWIStatusContent
: 微博或者回复的正文、图片、引用，在需要显示一条微博或者一个回复的地方都用了这个

KWIVoteOptionV
: 投票的一个选项

KWICommentMPCell
: 左侧面板的回复timeline中的一项

KWINewThreadParticipantCell
: 新建短邮选选择收件人的列表中的一项

KWIThreadCell
: 短邮列表的一项

KWIWelcomeElectionV
: welcome面板的一个投票

KWIElectionCell
: 微博详情卡片中的投票信息

KWIPeopleCell
: 各种用户列表中的一项

KWITrendCell
: 话题列表中的一项

KWIWelcomeTrendV
: welcome面板中的一个话题

KWIGroupCell
: 小组列表中的一项

KWITrendStatusCell
: 话题timeline中的一条微博

KWIGroupMemberCell
: 小组成员列表中的一项

KWISimpleStatusCell
: profile卡片的微博列表中的一项

KWITutorialCardV
: 使用卡片的新手引导的视图

#### misc
KWIStatusContentThumbV
: 为了确保KWIStatusContent里的缩略图能够水平居中而对UIImageView做的扩展

NSCharacterSet+Emoji
: iOS5的emoji的字符集

NSError+KWIExt
: 一些通用的面向用户的错误提示逻辑

UIViewController+KWIExt
: iOS有些情况下认为不应该在切换视图的时候切键盘，例如settings里的各个视图。这个扩展强制之。

UIDevice+KWIExt
: 存一些和设备有关的工具方法

### misc
KeychainItemWrapper
: 简化系统keychain的使用的工具。一开始KWEngine是用keychain来存access  token的，现在改用SCPLocalKVStorage了，所以这个类其实没有用。

POAPinyin
: 汉字转拼音，短邮选人控件建人名索引的时候要用

RCPMemCacheMgr
: 私人代码库里拿来的内存缓存

SCNavigationBar
: 支持自定义navication bar的，设置那用了

SCPLocalKVStorage
: 私人代码库里拿来的local key-value storage helper

UIImage+Resize
: 缩放图片的工具，依赖UIImage+Alpha和UIImage+RoundedCorner，发微博的时候用

UITextView+SizeUtils
: 算textview尺寸的，不记得哪儿用了

### EGORefreshTableHeaderView
EGORefreshTableHeaderView
: 硬编码在代码里的提示文字改成中文了

Resources
: 换了图片

### iToast
iToast
: 修改了`- (void) show:(iToastType) type`方法，改变外观，并且修复了一个bug https://github.com/ecstasy2/toast-notifications-ios/issues/7

### SDWebImage
UIImageView+WebCache.m
: line 27, 仅当placeholder不为nill时才使用。这是一个为了自己应用的业务逻辑简单粗暴修改第三方库的做法，不推荐这么做。

SDWebImageManager
: 添加了cancelAllDelegates方法，详见commit 0866c92cca4045050ce02d7d18f1fd2498d22db3


KWEngine API
-------------
// TODO: fill this section

常见缩写
-------
* vctrl: viewController
* ctn: content or container
* tpl: template
* misc: miscellaneous
* inf: information

我找谁去？
---------
Snow Hellsing
: 这些代码是这货写的，遇到问题，就算他不知道答案，大概也能告诉你找谁去。
  email / gtalk: snow.hellsing@gmail.com

沈学良
: 这个项目彩程方的负责人，对很多问题有决策权
  email: manfred@mycolorway.com

刘风扬
: 这个项目金蝶方的负责人，对很多问题有决策权，那些他没有决策权的问题，也得他去沟通
  QQ: 1276933297

郭志波
: API的负责人，API的问题可以找他
  QQ: 16903382

黄火荣
: 可以请教问题的人
  gtalk: huanghr.1@gmail.com

