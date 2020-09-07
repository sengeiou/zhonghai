//
//  KDEvent.h
//  kdweibo_common
//
//  Created by Gil on 14-9-20.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

//add
//pubacc_subscribe
//[KDEventAnalysis event:pubacc_tab_count];
/*
 event:代表事件ID
 label:代表事件label的key，value则直接使用注释里的中文
 */
//登录时输入密码是否可见
static NSString *event_lpwd_visible           = @"pwd_visible";

//登录成功次数
static NSString *event_login_ok               = @"login_ok";
//登录失败次数
static NSString *event_fail_count               = @"login_fail_count";
//【设置】点击次数
static NSString *event_setting_click            = @"setting_click";
//〖抽屉导航〗-【退出登录】
static NSString *event_login_out                = @"login_out";
//〖抽屉导航〗-【推荐]
static NSString *event_recommend_count          = @"recommend_count";
//【消息】点击次数
static NSString *event_message_tab_count        = @"msg_tab_count";
//发起多人会话点击次数
static NSString *event_shortcut_new_session     = @"msg_send_shortcut";
//加号写微博点击次数
static NSString *event_shortcut_new_weibo       = @"weibo_send_shortcut";
//扫一扫打开次数
static NSString *event_shortcut_scan             = @"scan_shortcut";
//〖消息〗- 〖+〗-【发送到电脑
static NSString *event_sendto_computer_shortcut  = @"sendto_computer_shortcut";
//〖消息〗- 【标记
static NSString *event_mark_count                 = @"mark_count";
//〖消息〗- 〖标记〗-【提醒】
static NSString *event_mark_notify                = @"mark_notify";
//〖消息〗- 【待办通知]
static NSString *event_todo_tab_count             = @"todo_tab_count";
//〖消息〗-〖 待办通知〗-【搜索】
static NSString *event_todo_search                = @"todo_search";
//〖消息〗-〖 待办通知〗-【一键忽略所有未读消息】
static NSString *event_todo_ignore_all_count      = @"todo_ignore_all_count";
//〖消息〗-〖 待办通知〗-【过滤】
static NSString *event_todo_filter                = @"todo_filter";
//〖消息〗-〖 待办通知〗-【待办】
static NSString *event_todo_todo_tab               = @"todo_todo_tab";
//〖消息〗-〖 待办通知〗-【已办】
static NSString *event_todo_hasdone_tab            = @"todo_hasdone_tab";
//〖消息〗-〖 待办通知〗-【通知】
static NSString *event_todo_notify_tab              = @"todo_notify_tab";
//〖消息〗-【公共号】
static NSString *event_pubacc_tab_count             = @"pubacc_tab_count";
//〖消息〗-〖 公共号〗-【订阅】
static NSString *event_pubacc_subscribe             = @"pubacc_subscribe";
//〖消息〗-〖 群组聊天〗-【按住说话】
static NSString *event_dialog_hold_speak            = @"dialog_hold_speak";
//〖消息〗-〖 群组聊天〗-【群公告】
static NSString *event_dialog_group_announcement             = @"dialog_grp_notify";
//〖消息〗-〖 群组聊天〗-〖群公告〗-【快速创建】
static NSString *event_dialog_group_announcement_create  = @"dialog_grp_notify_create";
//〖消息〗-〖 群组聊天〗-【群组详情】
static NSString *event_dialog_group_detail            = @"dialog_grp_detail";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【群组二维码】
static NSString *event_dialog_group_qrcode            = @"dialog_grp_qrcode";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【群组二维码】-【扫描二维码】
static NSString *event_dialog_dialog_group_scan_qrcode    = @"dialog_group_scan_qrcode";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【群组二维码】-【转发】
static NSString *event_dialog_group_qrcode_forward            = @"dialog_grp_qrcode_forward";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【群组二维码】-【保存图片】
static NSString *event_dialog_group_qrcode_save            = @"dialog_grp_qrcode_save";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【修改群聊名称】
static NSString *event_dialog_group_name_modify            = @"dialog_grp_name_modify";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【文件】
static NSString *event_dialog_group_file            = @"dialog_grp_file";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【图片】
static NSString *event_dialog_group_pic            = @"dialog_grp_pic";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【搜索】
static NSString *event_dialog_group_search            = @"dialog_grp_search";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【消息免打扰】
static NSString *event_dialog_group_message_free          = @"dialog_grp_message_free";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【设为重要群组】
static NSString *event_dialog_group_set_important           = @"dialog_grp_set_important";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【清空聊天记录】
static NSString *event_dialog_group_clear_history            = @"dialog_grp_clear_history";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【退出群组】
static NSString *event_dialog_group_quit            = @"dialog_grp_quit";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【解散群组】
static NSString *event_dialog_group_disband           = @"dialog_grp_disband";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-【群管理】
static NSString *event_group_manage_count           = @"grp_manage_count";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-〖群管理〗 -【转让管理员】
static NSString *event_group_manage_transfer_admin            = @"transfer_admin";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-〖群管理〗 -【仅管理员添加成员】
static NSString *event_group_manage_admin_add_member            = @"admin_add_member";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-〖群管理〗 -【全员禁言】
static NSString *event_dialog_group_manage_nospeak          = @"all_nospeak";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-〖群管理〗 -【群组二维码】
static NSString *event_group_manage_qrcode            = @"grp_manage_qrcode";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-〖群公共〗 -【新建】
static NSString *event_group_manage_announcement_create            = @"grp_notice_create";
//〖消息〗-〖 群组聊天〗-〖群组详情〗-〖群公共〗 -【快速创建】
static NSString *event_group_manage_announcement_quick            = @"grp_notice_create_quick";
//〖消息〗-〖 群组聊天〗或-〖 单人聊天〗 - 【右下角+】
static NSString *event_dialog_plus_count    = @"dialog_plus_count";
//〖消息〗-〖 群组聊天〗或-〖 单人聊天〗 - 【右下角+】-【语音会议】
static NSString *event_dialog_plus_voice_conference           = @"dialog_voice_conf";
//〖消息〗-〖 群组聊天〗或-〖 单人聊天〗 - 【右下角+】-【无痕消息】
static NSString *event_dialog_plus_traceless_message            = @"dialog_traceless_message";
//【应用】
static NSString *event_application_tab_count           = @"app_tab_count";
//〖应用〗-〖添加应用〗-【搜索应用名称】
static NSString *event_application_add           = @"app_add";
//〖应用〗中具体应用的点击次数，包括，应用的名称和应用的ID
static NSString *event_applicatioin_click_count            = @"app_click_count";
//【发现】
static NSString *event_find_tab_count           = @"find_tab_count";
//〖发现〗-【动态】-【发布微博】
static NSString *event_tendency_release_weibo        = @"tendency_release_weibo";
//〖发现〗-【动态】-【搜索】
static NSString *event_tendency_search          = @"tendency_search";
//〖发现〗-【提及回复】
static NSString *event_find_mention_reply           = @"find_mention_reply";
//〖发现〗-【小组】
static NSString *event_find_group            = @"find_grp";
//〖发现〗-【话题】
static NSString *event_find_topic          = @"find_topic";

//[KDEventAnalysis event:event_contacts_tab_count];
//〖通讯录〗
static NSString *event_contacts_tab_count          = @"contacts_tab_count";
//〖通讯录〗-【搜索】
static NSString *event_contacts_search            = @"contacts_search";
//〖通讯录〗-【组织架构】
static NSString *event_contacts_org_structure           = @"contacts_org_structure";
//〖通讯录〗-【商务伙伴】
static NSString *event_contacts_business_partner         = @"contacts_busi_partner";
//〖通讯录〗-【重要群组】
static NSString *event_contacts_important_group            = @"contacts_important_grp";
//〖通讯录〗-【公共号】
static NSString *event_contact_pubacc_count           = @"contacts_pubacc_count";
//〖通讯录〗-  点击任意人员
static NSString *event_personal_info_count          = @"personal_info_count";
//〖通讯录〗-〖个人名片〗-【加关注】
static NSString *event_personal_add_tofollow           = @"personal_add_tofollow";
//〖通讯录〗-〖个人名片〗-【保存到本地通讯录】
static NSString *event_personal_save_local         = @"personal_save_local";
//〖通讯录〗-〖个人名片〗-【发送名片】
static NSString *event_personal_send_card      = @"personal_send_card";
//〖通讯录〗-〖个人名片〗-【头像】
static NSString *event_personal_profile_photo          = @"personal_profile_photo";
//〖通讯录〗-〖个人名片〗-【收藏】
static NSString *event_personal_favorite          = @"personal_favorite";
//〖通讯录〗-〖个人名片〗-【关注】
static NSString *event_personal_tofollow           = @"personal_add_tofollow";
//〖通讯录〗-〖个人名片〗-【发消息】
static NSString *event_personal_send_message          = @"personal_send_message";
//〖通讯录〗-〖个人名片〗-【打电话】
static NSString *event_personal_call_phone          = @"personal_call_phone";



//〖消息〗- 〖标记〗-〖提醒〗-【今天晚些】
static NSString *event_mark_notify_today          = @"mark_notify_today";
//〖消息〗- 〖标记〗-〖提醒〗-【选择日期和时间】
static NSString *event_mark_notify_someday         = @"mark_notify_someday";

#pragma mark - 登录login
//手机号登录成功次数
//static NSString *event_login_mobile_ok        = @"login_mobile_ok";
//账号（邮箱）密码方式登录成功次数
//static NSString *event_login_email_ok         = @"login_email_ok";
//登录成功次数
//static NSString *event_login_ok               = @"login_ok";
static NSString *label_login_ok_type          = @"type";
static NSString *label_login_ok_type_phone    = @"手机号";
static NSString *label_login_ok_type_email    = @"KDAuthViewController_email";





//重置密码成功次数
static NSString *event_login_resetpassword_ok = @"login_resetpassword_ok";


#pragma mark - 注册register
/*
 手机号注册成功
 注册类型：受邀注册、自主注册
 */
static NSString *event_register_mobile_ok                         = @"register_mobile_ok";
static NSString *label_register_mobile_ok_registerType            = @"registerType";
static NSString *label_register_mobile_ok_registerType_passive    = @"受邀注册";
static NSString *label_register_mobile_ok_registerType_initiative = @"自主注册";


#pragma mark - 工作圈band
//切换工作圈点击次数、成功次数
static NSString *event_band_switch_open                  = @"band_switch_open";
static NSString *event_band_switch_ok                    = @"band_switch_ok";
/*
 创建工作圈打开次数
 创建类型：首个工作圈、其他工作圈
 */
static NSString *event_band_create_open                  = @"band_create_open";
static NSString *label_band_create_open_createType       = @"createType";
static NSString *label_band_create_open_createType_first = @"首个工作圈";
static NSString *label_band_create_open_createType_other = @"其他工作圈";
//创建工作圈成功次数
static NSString *event_band_create_ok                    = @"band_create_ok";

#pragma mark - 邀请invite
/*
 邀请功能打开次数
 1、邀请人身份：管理员、普通用户
 2、邀请状态：不需要审核、需要审核
 3、来源位置：加号、侧边栏、自动（第一次登录后自动弹出）
 4、邀请类型：手机号、通讯录、微信、链接、面对面
 */
static NSString *event_invite_open                            = @"invite_open";
static NSString *label_invite_open_inviterIdentity            = @"inviterIdentity";
static NSString *label_invite_open_inviterIdentity_admin      = @"管理员";
static NSString *label_invite_open_inviterIdentity_user       = @"普通用户";
static NSString *label_invite_open_inviteStatus               = @"inviteStatus";
static NSString *label_invite_open_inviteStatus_notNeedReview = @"不需要审核";
static NSString *label_invite_open_inviteStatus_needReview    = @"需要审核";
static NSString *label_invite_open_inviteSource               = @"inviteSource";
static NSString *label_invite_open_inviteSource_shortcut      = @"加号";
static NSString *label_invite_open_inviteSource_sidebar       = @"侧边栏";
static NSString *label_invite_open_inviteSource_contact       = @"通讯录";
static NSString *label_invite_open_inviteType                 = @"inviteType";
static NSString *label_invite_open_inviteType_phone           = @"手机号";
static NSString *label_invite_open_inviteType_contact         = @"通讯录";
static NSString *label_invite_open_inviteType_weixin          = @"微信";
static NSString *label_invite_open_inviteType_link            = @"链接";
static NSString *label_invite_open_inviteType_facetoface      = @"面对面";
static NSString *label_invite_open_inviteType_firstToDo       = @"首条代办";
////微信邀请打开次数、成功次数
//static NSString *event_invite_weixin_open          = @"invite_weixin_open";
//static NSString *event_invite_weixin_ok            = @"invite_weixin_ok";
////手机号邀请打开次数、成功次数
//static NSString *event_invite_mobile_open          = @"invite_mobile_open";
//static NSString *event_invite_mobile_ok            = @"invite_mobile_ok";
////通讯录邀请打开次数、成功次数
//static NSString *event_invite_contact_open         = @"invite_contact_open";
//static NSString *event_invite_contact_ok           = @"invite_contact_ok";
////链接邀请打开次数、链接邀请QQ分享次数、链接邀请微信分享次数、链接邀请微博分享次数、链接邀请短信分享次数
//static NSString *event_invite_link_open            = @"invite_link_open";
//static NSString *event_invite_link_qq              = @"invite_link_qq";
//static NSString *event_invite_link_weixin          = @"invite_link_weixin";
//static NSString *event_invite_link_weibo           = @"invite_link_weibo";
//static NSString *event_invite_link_message         = @"invite_link_message";
////面对面邀请打开次数、面对面邀请QQ分享次数、面对面邀请微信分享次数、面对面邀请微博分享次数
//static NSString *event_invite_facebyface_open      = @"invite_facebyface_open";
//static NSString *event_invite_facebyface_qq        = @"invite_facebyface_qq";
//static NSString *event_invite_facebyface_weixin    = @"invite_facebyface_weixin";
//static NSString *event_invite_facebyface_weibo     = @"invite_facebyface_weibo";
/*
 成功发出邀请次数
 1、邀请类型：手机号、通讯录、微信
 */
static NSString *event_invite_send                               = @"invite_send";
static NSString *label_invite_send_inviteType                    = @"inviteType";
static NSString *label_invite_send_inviteType_phone              = @"手机号";
static NSString *label_invite_send_inviteType_contact            = @"通讯录";
static NSString *label_invite_send_inviteType_weixin             = @"微信";
static NSString *label_invite_send_inviteType_Link               = @"链接";
static NSString *label_invite_send_inviteType_facetoface         = @"面对面";
/*
 链接邀请分享次数
 1、分享类型：QQ、微信、微博、短信
 */
static NSString *event_invite_link_share                         = @"invite_link_share";
static NSString *label_invite_link_share_inviteType              = @"inviteType";
static NSString *label_invite_link_share_inviteType_qq           = @"QQ";
static NSString *label_invite_link_share_inviteType_weixin       = @"微信";
static NSString *label_invite_link_share_inviteType_weibo        = @"微博";
static NSString *label_invite_link_share_inviteType_sms          = @"短信";
/*
 面对面邀请分享次数
 1、分享类型：QQ、微信、微博
 */
static NSString *event_invite_facebyface_share                   = @"invite_facebyface_share";
static NSString *label_invite_facebyface_share_inviteType        = @"inviteType";
static NSString *label_invite_facebyface_share_inviteType_qq     = @"QQ";
static NSString *label_invite_facebyface_share_inviteType_weixin = @"微信";
static NSString *label_invite_facebyface_share_inviteType_weibo  = @"微博";
static NSString *event_session_open_todo               = @"session_open_todo";
static NSString *event_session_open_select             = @"session_open_select";
#pragma mark - 意见反馈feedback
//意见反馈打开次数
static NSString *event_feedback_open   = @"feedback_open";
//提交反馈次数
static NSString *event_feedback_submit = @"feedback_submit";

#pragma mark - 个人设置settings
/*
 个人设置页面打开次数
 打开方式：侧边栏、菜单(设置-个人设置)
 */
static NSString *event_settings_personal_open                = @"settings_personal_open";
static NSString *label_settings_personal_open_source         = @"source";
static NSString *label_settings_personal_open_source_sidebar = @"侧边栏";
static NSString *label_settings_personal_open_source_menu    = @"菜单";
//设置头像打开次数
static NSString *event_settings_personal_headpicture         = @"settings_personal_headpicture";
//用户名修改次数
static NSString *event_settings_personal_name                = @"settings_personal_name";
//更换手机号功能打开次数、成功次数
static NSString *event_settings_personal_mobile_open         = @"settings_personal_mobile_open";
static NSString *event_settings_personal_mobile_ok           = @"settings_personal_mobile_ok";
//绑定邮箱账号功能打开次数、成功次数
static NSString *event_settings_personal_email_open          = @"settings_personal_email_open";
static NSString *event_settings_personal_email_ok            = @"settings_personal_email_ok";
//修改部门打开次数、成功次数
static NSString *event_settings_personal_department_open     = @"settings_personal_department_open";
static NSString *event_settings_personal_department_ok       = @"settings_personal_department_ok";
/*
 手势密码设置次数
 设置状态：启用、禁用
 */
static NSString *event_settings_gesturepassword              = @"settings_gesturepassword";
static NSString *label_settings_gesturepassword_status       = @"status";
static NSString *label_settings_gesturepassword_status_off   = @"禁用";
static NSString *label_settings_gesturepassword_status_on    = @"启用";
//清除缓存使用次数
static NSString *event_settings_wipecache                    = @"settings_wipecache";
//更新人员索引使用次数
//static NSString *event_settings_upgradeindex                 = @"settings_upgradeindex";
//新版介绍打开次数
static NSString *event_settings_newversionintroduction_open  = @"settings_newversionintroduction_open";
//退出工作圈打开次数、成功次数
static NSString *event_settings_quitband_open                = @"settings_quitband_open";
static NSString *event_settings_quitband_ok                  = @"settings_quitband_ok";
//关于打开次数
static NSString *event_settings_about_open                   = @"settings_about_open";
//检查新版本次数
static NSString *event_settings_about_checknewversion        = @"settings_about_checknewversion";
//退出登录次数
static NSString *event_settings_logout_ok                    = @"settings_logout_ok";

#pragma mark - 推荐recommend
//推荐打开次数
static NSString *event_recommend_open                        = @"recommend_open";
//短信推荐发送次数
static NSString *event_recommend_sendmessage                 = @"recommend_sendmessage";

#pragma mark - 页签bottombar
//消息页签点击次数
static NSString *event_bottombar_session  = @"bottombar_session";
//应用页签点击次数
static NSString *event_bottombar_app      = @"bottombar_app";
//发现页签点击次数
static NSString *event_bottombar_discover = @"bottombar_discover";
//通讯录页签点击次数
static NSString *event_bottombar_contact  = @"bottombar_contact";
// 聊天页面+号面板点击次数
static NSString *event_session_chat_plus_menu_click    = @"event_session_chat_plus_menu_click";

#pragma mark - 加号shortcut
//加号点击次数
static NSString *event_shortcut_open                        = @"shortcut_open";

//发起多人会话从组织架构选人次数
//static NSString *event_shortcut_new_session_organization           = @"shortcut_new_session_organization";
////发起多人会话从我的部门选人次数
//static NSString *event_shortcut_new_session_mydepartment           = @"shortcut_new_session_mydepartment";
////发起多人会话从收藏选人次数
//static NSString *event_shortcut_new_session_favorites              = @"shortcut_new_session_favorites";
////发起多人会话从已有会话选人次数
//static NSString *event_shortcut_new_session_existing_multisession  = @"shortcut_new_session_existing_multisession";
////发起多人会话从最近联系人选人次数
//static NSString *event_shortcut_new_session_existing_singlesession = @"shortcut_new_session_existing_singlesession";

/*
 会话添加人次
 添加方式：组织架构、我的部门、收藏、已有会话、最近联系人、搜索
 */
static NSString *event_session_adduser                      = @"session_adduser";
static NSString *label_session_adduser_type                 = @"type";
static NSString *label_session_adduser_type_organization    = @"组织架构";
static NSString *label_session_adduser_type_mydepartment    = @"我的部门";
static NSString *label_session_adduser_type_favorites       = @"KDABActionTabBar_tips_1";
static NSString *label_session_adduser_type_existingsession = @"已有会话";
static NSString *label_session_adduser_type_recently        = @"最近联系人";
static NSString *label_session_adduser_type_search          = @"搜索";
static NSString *label_session_adduser_type_list            = @"列表选择";

//扫一扫打开次数
static NSString *event_scan_open                                   = @"scan_open";
static NSString *label_scan_open                                   = @"source";
static NSString *label_scan_open_shortcut                          = @"加号";
static NSString *label_scan_open_application                       = @"应用";

#pragma mark - 会话session
//会话打开次数
static NSString *event_session_open                    = @"session_open";
static NSString *label_session_open_type               = @"type";
static NSString *label_session_open_type_single        = @"单人消息";
static NSString *label_session_open_type_multi         = @"多人消息";
static NSString *label_session_open_type_pubacc        = @"公共号";
//会话添加人员次数、会话减少人员次数
static NSString *event_session_settings_adduser        = @"session_settings_adduser";
static NSString *event_session_settings_deleteuser     = @"session_settings_deleteuser";
//消息发送次数
static NSString *event_msg_send                        = @"msg_send";
static NSString *label_msg_send_messageType            = @"msgType";
static NSString *label_msg_send_messageType_text       = @"文本";
static NSString *label_msg_send_messageType_speech     = @"语音";
static NSString *label_msg_send_messageType_picture    = @"图片";
static NSString *label_msg_send_messageType_file       = @"文件";
static NSString *label_msg_send_messageType_expression = @"表情";
//删除消息次数
static NSString *event_msg_del                         = @"msg_del";
//复制消息次数
static NSString *event_msg_copy                        = @"msg_copy";
//转发次数
static NSString *event_msg_forward                     = @"msg_forward";
//分享到动态次数
static NSString *event_msg_sharetoweibo                = @"msg_sharetoweibo";
//收藏
static NSString *event_msg_collect                     = @"msg_collect";
//重发成功次数
static NSString *event_msg_resend                      = @"msg_resend";

//收藏
static NSString *event_msg_cancel                     = @"msg_cancel";

//回复
static NSString *event_msg_reply                      = @"msg_reply";
/*
 *  转任务打开次数
 *  来源：长按消息、关键字点击
 *
 */
static NSString *event_msg_totask                      = @"msg_totask";
static NSString *label_msg_totask_source               = @"source";
static NSString *label_msg_totask_source_longpress     = @"长按消息";
static NSString *label_msg_totask_source_keyclick      = @"关键字点击";
//多人会话名称修改成功次数
static NSString *event_session_settings_namemodify_ok  = @"session_settings_namemodify_ok";
//新消息提醒设置次数
//设置状态：开、关
static NSString *event_session_settings_alert          = @"session_settings_alert";
static NSString *label_session_settings_alert          = @"status";
static NSString *label_session_settings_alert_on       = @"开";
static NSString *label_session_settings_alert_off      = @"关";
//多人会话收藏次数
//设置状态：开、关
static NSString *event_session_settings_favorite       = @"session_settings_favorite";
static NSString *label_session_settings_favorite       = @"status";
static NSString *label_session_settings_favorite_on    = @"开";
static NSString *label_session_settings_favorite_off   = @"关";
//标记已读次数
static NSString *event_session_settings_markread       = @"session_settings_markreads";
//清空聊天记录次数
static NSString *event_session_settings_clear          = @"session_settings_clear";
//退出多人聊天次数
static NSString *event_session_settings_quit           = @"session_settings_quit";
//消息过滤次数
static NSString *event_session_filter                  = @"session_filter";
static NSString *label_session_filter                  = @"filterType";
static NSString *label_session_filter_picture          = @"图片";
static NSString *label_session_filter_file             = @"文件";
static NSString *label_session_filter_search           = @"搜索";

#pragma mark - 应用页签app
//签到打开次数
static NSString *event_app_signin_open               = @"app_signin_open";
//文档助手打开次数
static NSString *event_app_dochelper_open            = @"app_dochelper_open";
//任务打开次数
static NSString *event_app_tasks_open                = @"app_tasks_open";
//一呼百应打开次数
static NSString *event_app_mass_response_open        = @"app_mass_response_open";
//添加应用次数
//来源：搜索、列表、推荐
static NSString *event_app_add                       = @"app_add";
static NSString *label_event_app_add_source          = @"source";
static NSString *label_event_app_add_source_search   = @"搜索";
static NSString *label_event_app_add_source_list     = @"列表";
static NSString *label_event_app_add_source_recommend = @"推荐";

//所有应用打开次数
static NSString *event_app_open                      = @"app_open";
//推荐位应用点击次数
static NSString *event_app_recommend_open            = @"app_recommend_open";

#pragma mark - 发现页签discover
//动态点击次数
static NSString *event_discover_status               = @"discover_status";
//提及回复点击次数
static NSString *event_discover_inbox                = @"discover_inbox";
//小组点击次数
static NSString *event_discover_group                = @"discover_group";
//话题点击次数
static NSString *event_discover_topic                = @"discover_topic";
//老板开讲点击次数
static NSString *event_discover_bosstalk             = @"discover_bosstalk";
//运动频道点击次数
static NSString *event_discover_sport                = @"discover_sport";
//智慧雷达点击次数
static NSString *event_discover_smartradar           = @"discover_smartradar";

#pragma mark - 通讯录页签contact
//搜索打开次数
static NSString *event_contact_search                = @"contact_search";
/*
 搜索次数（离开搜索界面时统计）
 1.搜索类型：中文、拼音、手机号
 2.搜索键盘：全键盘、T9键盘
 */
static NSString *event_contact_search_type              = @"contact_search_type";
static NSString *label_contact_search_type_type         = @"type";
static NSString *label_contact_search_type_type_chinese = @"中文";
static NSString *label_contact_search_type_type_pinyin  = @"拼音";
static NSString *label_contact_search_type_type_number  = @"手机号";


//消息页签搜索打开次数
//static NSString *event_session_search

//输入中文搜索次数
//static NSString *event_contact_searchby_cn           = @"contact_searchby_cn";
//输入拼音搜索次数
//static NSString *event_contact_searchby_en           = @"contact_searchby_en";
//输入手机号搜索次数
//static NSString *event_contact_searchby_number       = @"contact_searchby_number";
//组织架构打开次数
static NSString *event_contact_org_open              = @"contact_org_open";
//多人会话打开次数
static NSString *event_contact_muiltsession_open     = @"contact_muiltsession_open";
//通讯录公共号打开次数
static NSString *event_contact_pubacc_open           = @"contact_pubacc_open";
//公共号信息刷新次数
static NSString *event_contact_pubacc_refresh        = @"contact_pubacc_refresh";
//收藏联系人打开次数
static NSString *event_contact_favorites_open        = @"contact_favorites_open";
//最近联系人点击次数
static NSString *event_contact_existing_session_open = @"contact_existing_session_open";
//联系人详情发消息次数
static NSString *event_contact_info_sendmsg          = @"contact_info_sendmsg";
//联系人详情查看部门次数
static NSString *event_contact_info_department       = @"contact_info_department";
//联系人详情收藏次数
static NSString *event_contact_info_favorite         = @"contact_info_favorite";
//联系人详情拨打电话次数
static NSString *event_contact_info_phone            = @"contact_info_phone";
//联系人详情发送短信次数
static NSString *event_contact_info_message          = @"contact_info_message";
//联系人详情发送邮件次数
static NSString *event_contact_info_email            = @"contact_info_email";
//联系人详情发送名片次数
static NSString *event_contact_info_card             = @"contact_info_card";

#pragma mark - 公共号pubacc
//公共号消息查看次数
//static NSString *event_msg_pubacc                    = @"msg_pubacc";
//公共号关注次数
static NSString *event_pubacc_favorite_on            = @"pubacc_favorite_on";
//公共号取消关注次数
static NSString *event_pubacc_favorite_off           = @"pubacc_favorite_off";

#pragma mark - 文件file
//我的文件点击次数
static NSString *event_app_myfile          = @"app_myfile";
//传输文件到电脑的点击次数
static NSString *event_myfile_extrans      = @"myfile_extrans";
//我上传的点击次数
static NSString *event_myfile_upload       = @"myfile_upload";
//我下载的点击次数
static NSString *event_myfile_download     = @"myfile_download";
//我收藏的点击次数
static NSString *event_myfile_favorite     = @"myfile_favorite";
//收藏按钮的点击次数
static NSString *event_filedetail_favorite = @"filedetail_favorite";
//转发按钮的点击次数
static NSString *event_filedetail_trans    = @"filedetail_trans";
//分享按钮的点击次数
static NSString *event_filedetail_share    = @"filedetail_share";

#pragma mark - 签到signin
//签到查看全部记录的点击次数
static NSString *event_signin_myrecord     = @"signin_myrecord";


#pragma mark - wifi自动签到 拍照签到
//新手引导（管理员）设置签到点
static NSString *event_signin_guide_set      = @"signin_guide_set";
//外勤签到时拍照次数
static NSString *event_signin_photo          = @"signin_photo";
//定位失败用户点击拍照签到的次数
static NSString *event_signin_nol_photo      = @"signin_nol_photo";
//管理员点击签到点管理菜单的次数
static NSString *event_signin_set            = @"signin_set";
//设置页面用户点击wifi自动签到的次数
static NSString *event_signin_wifiset        = @"signin_wifiset";
//点击签到记录分享icon的次数
static NSString *event_signin_record_share   = @"signin_record_share";
//点击签到记录里面删除icon的次数
static NSString *event_signin_record_delete   = @"signin_record_delete";
//点击签到记录里面设置签到点的次数
static NSString *event_signin_record_set      = @"signin_record_set";

//签到点管理的点击次数
static NSString *event_signin_set_signpoint   =@"signin_set_signpoint";
//离线状态的拍照签到
static NSString *event_signin_offl_photo      =@"signin_offl_photo";
//离线状态的取消操作
static NSString *event_signin_offl_cancel     =@"signin_offl_cancel";
//定位失败状态下再试一次
static NSString *event_signin_nol_again       =@"signin_nol_again";
//定位失败状态下的取消
static NSString *event_signin_nol_cancel      =@"signin_nol_cancel";
//点击感叹号的次数
static NSString *event_signin_record_syn      =@"signin_record_syn";
//签到点击分享到微信
static NSString *event_signin_record_sharewx  =@"signin_record_sharewx";
//签到取消微信分享
static NSString *event_signin_record_noshare  =@"signin_record_noshare";

//直接发起语音会议
static NSString *event_Voicon_first                        =@"Voicon_first";
//预约会议
static NSString *event_Voicon_book                         =@"Voicon_book";
//语音会议启动次数
static NSString *event_Voicon_start                       =@"Voicon_start";
//结束会议点击次数
static NSString *event_Voicon_end                         =@"Voicon_end";
//离开会议点击次数
static NSString *event_Voicon_leave                       =@"Voicon_leave";
//静音点击次数
static NSString *event_Voicon_silence                     =@"Voicon_silence";
//扬声点击次数
static NSString *event_Voicon_aloud                       =@"Voicon_aloud";
//隐藏点击次数
static NSString *event_Voicon_hid                         =@"Voicon_hid";
//蓝条点击事件
static NSString *event_Voicon_join                        =@"Voicon_join";

//点击签到按钮
static NSString *event_signin_clickbtn = @"signin_clickbtn";

//通讯录考核指标
static NSString *event_contact_kpi                   = @"kpi_contact";
static NSString *label_contact_kpi_source            = @"source";
static NSString *label_contact_kpi_source_contact    = @"通讯录";
static NSString *label_contact_kpi_source_search     = @"搜索";
static NSString *label_contact_kpi_source_org        = @"组织架构";
static NSString *label_contact_kpi_source_phone      = @"电话";
static NSString *label_contact_kpi_source_personInfo = @"用户详情";
static NSString *label_contact_kpi_source_newsession = @"发起会话";
static NSString *label_contact_kpi_source_adduser    = @"会话加人";
static NSString *label_contact_kpi_source_selectuser = @"发起会话选人";


//消息页签搜索打开次数
static NSString *event_session_search                  = @"session_search";

// 会话取消置顶
static NSString *event_session_top_cancel = @"session_top_cancel";

// 会话置顶
static NSString *event_session_top_set = @"session_top_set";

// 会话标为已读
static NSString *event_session_mark_read = @"session_mark_read";


// 选择原图
static NSString *event_image_original      = @"image_original";

// 快捷发图片次数
static NSString *event_session_send_image_by_shortcut  = @"event_session_send_image_by_shortcut";
