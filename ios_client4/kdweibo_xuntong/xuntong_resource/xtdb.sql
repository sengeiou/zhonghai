//讯通不同企业的数据采用分组表实现，使用下面的表名+企业ID实现，比如"group_10109"。
//所以建表和查询语句都是动态生成，建表逻辑必须在登录拿到企业ID之后进行。

//消息组
CREATE TABLE 'Group' (
  	'groupId' VARCHAR PRIMARY KEY NOT NULL, 
  	'groupType' INTEGER NOT NULL DEFAULT 1, 
  	'groupName' VARCHAR, 
	'unreadCount' INTEGER NOT NULL DEFAULT 0, 
	'lastMsgId' VARCHAR, 
	'lastMsgSendTime' VARCHAR, 
	'status' INTEGER NOT NULL DEFAULT 3, 
	'updateTime' VARCHAR, 
	'tag' VARCHAR, 
	'subTag' VARCHAR, 
	'menu' VARCHAR
)

//意见反馈消息组（设置界面）
CREATE TABLE 'PublicGroup' (
	'groupId' VARCHAR PRIMARY KEY NOT NULL,
	'publicId' VARCHAR NOT NULL,
	'groupType' INTEGER NOT NULL  DEFAULT (1),
	'groupName' VARCHAR,
	'unreadCount' INTEGER NOT NULL  DEFAULT (0),
	'lastMsgId' VARCHAR,
	'lastMsgSendTime' VARCHAR,
	'status' INTEGER NOT NULL  DEFAULT (3),
	'updateTime' VARCHAR
)

//组参与人表
CREATE TABLE 'Participant' (
	'groupId' VARCHAR NOT NULL ,
	'personId' VARCHAR NOT NULL
)

//人员信息表
CREATE TABLE 'T9Person' (
	'id' INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT NULL, 
	'personId' VARCHAR DEFAULT NULL, 
	'personName' VARCHAR, 
	'defaultPhone' VARCHAR, 
	'department' VARCHAR, 
	'fullPinyin' VARCHAR, 
	'photoId' VARCHAR, 
	'photoUrl' VARCHAR, 
	'status' INTEGER DEFAULT 0, 
	'jobTitle' VARCHAR, 
	'lastContactTime' VARCHAR, 
	'note' VARCHAR, 
	'reply' VARCHAR, 
	'subscribe' VARCHAR, 
	'canUnsubscribe' VARCHAR, 
	'menu' VARCHAR
)

//人员联系信息表
CREATE TABLE 'Contact' (
	'personId' VARCHAR NOT NULL DEFAULT '' ,
	'text' VARCHAR,
	'value' VARCHAR,
	'type' INTEGER NOT NULL  DEFAULT 0
)

//公共号（虚拟人）表
CREATE TABLE 'PublicPerson' (
	'id' integer PRIMARY KEY AUTOINCREMENT DEFAULT NULL, 
	'personId' varchar DEFAULT NULL, 
	'personName' varchar, 
	'defaultPhone' varchar, 
	'department' varchar, 
	'fullPinyin' varchar, 
	'photoId' varchar, 
	'photoUrl' varchar, 
	'status' integer DEFAULT 0, 
	'jobTitle' varchar, 
	'lastContactTime' varchar, 
	'note' varchar, 
	'reply' varchar, 
	'subscribe' varchar, 
	'canUnsubscribe' varchar, 
	'menu' varchar
)

//消息表
CREATE TABLE Message (
	'msgId' VARCHAR PRIMARY KEY  NOT NULL,
	'fromUserId' VARCHAR,
	'sendTime' VARCHAR,
	'msgType' INTEGER NOT NULL  DEFAULT (0),
	'msgLen' INTEGER NOT NULL  DEFAULT (0),
	'content' VARCHAR,
	'status' INTEGER NOT NULL  DEFAULT (1),
	'direction' INTEGER DEFAULT (1),
	'fromUserNickName' VARCHAR,
	'groupId' VARCHAR,
	'toUserId' VARCHAR,
	'requestType' INTEGER NOT NULL  DEFAULT (0),
	'param' VARCHAR
)

//应用信息表
CREATE TABLE PersonalApp (
	'appClientId' VARCHAR PRIMARY KEY NOT NULL, 
	'appType' VARCHAR, 
	'appName' VARCHAR, 
	'appLogo' VARCHAR, 
	'appClientSchema' VARCHAR, 
	'appWebURL' VARCHAR, 
	'appDldURL' VARCHAR
)