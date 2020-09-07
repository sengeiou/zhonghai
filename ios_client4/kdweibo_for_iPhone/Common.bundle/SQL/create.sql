
CREATE TABLE statuses_v2 (
    id TEXT,
    user_id TEXT,
    content TEXT,
    source TEXT,
    
    forwarded_status_id TEXT,
    extend_status_id TEXT,
    extra_message_id TEXT,

    created_at DOUBLE,
    updated_at DOUBLE,

    favorited SMALLINT,
    truncated SMALLINT,
    liked     SMALLINT,

    latitude FLOAT,
    longitude FLOAT,
    address  TEXT,
    
   
    comments_count INTEGER,
    forwards_count INTEGER,
    liked_count  INTEGER,
    
    -- the values can be (0 - company activity, 1 - friend timeline, 2 - popular discussion)
    type SMALLINT,
    
    -- extra source mask
    mask INTEGER,
    group_id TEXT,
    group_name TEXT,
    
    -- use id and timeline type as unique primary key
	PRIMARY KEY(id, type)
);


CREATE INDEX statuses_v2_id_idx ON statuses_v2(id);
CREATE INDEX statuses_v2_type_idx ON statuses_v2(type);
CREATE INDEX statuses_v2_created_at_idx ON statuses_v2(created_at);


CREATE TABLE forwarded_statuses (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    content TEXT,
    source TEXT,
    
    forwarded_status_id TEXT,
    extend_status_id TEXT,
    extra_message_id TEXT,

    created_at DOUBLE,
    updated_at DOUBLE,
    
    favorited SMALLINT,
    truncated SMALLINT,
    liked     SMALLINT,

    latitude FLOAT,
    longitude FLOAT,
    address TEXT,
    
    comments_count INTEGER,
    forwards_count INTEGER,
    liked_count  INTEGER,
    
    -- extra source mask
    mask INTEGER
);

CREATE INDEX forwarded_statuses_id_idx ON forwarded_statuses(id);
CREATE INDEX forwarded_statuses_created_at_idx ON forwarded_statuses(created_at);


CREATE TABLE mention_me_statuses (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    content TEXT,
    source TEXT,
    
    forwarded_status_id TEXT,
    extend_status_id TEXT,
    extra_message_id TEXT,

    created_at DOUBLE,
    updated_at DOUBLE,
    
    favorited SMALLINT,
    truncated SMALLINT,
    liked     SMALLINT,

    latitude FLOAT,
    longitude FLOAT,
    address TEXT,
    
    comments_count INTEGER,
    forwards_count INTEGER,
    liked_count  INTEGER,
    
    -- extra source mask
    mask INTEGER,
    
    group_id TEXT,
    group_name TEXT
);

CREATE INDEX mention_me_statuses_created_at_idx ON mention_me_statuses(created_at);


CREATE TABLE comment_me_statuses (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    content TEXT,
    source TEXT,
    
    forwarded_status_id TEXT,
    extend_status_id TEXT,
    extra_message_id TEXT,

    created_at DOUBLE,
    updated_at DOUBLE,
    
    favorited SMALLINT,
    truncated SMALLINT,
    liked     SMALLINT,

    latitude FLOAT,
    longitude FLOAT,
    address   TEXT,
    
    comments_count INTEGER,
    forwards_count INTEGER,
    liked_count  INTEGER,
    
    -- extra source mask
    mask INTEGER,
    
    reply_status_id TEXT,
    reply_user_id TEXT,
    reply_screen_name TEXT,
    reply_status_text TEXT,
    reply_comment_text TEXT,
    
    group_id TEXT,
    group_name TEXT
);

CREATE INDEX comment_me_statuses_created_at_idx ON comment_me_statuses(created_at);


CREATE TABLE group_statuses_v2 (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    content TEXT,
    source TEXT,
    
    forwarded_status_id TEXT,
    extend_status_id TEXT,
    extra_message_id TEXT,

    created_at DOUBLE,
    updated_at DOUBLE,
    
    favorited SMALLINT,
    truncated SMALLINT,
    liked SMALLINT,

    latitude FLOAT,
    longitude FLOAT,
    address TEXT,
    
    comments_count INTEGER,
    forwards_count INTEGER,
    liked_count   INTEGER,
    
    -- extra source mask
    mask INTEGER,
    
    group_id TEXT
);

CREATE INDEX group_statuses_v2_created_at_idx ON group_statuses_v2(created_at);
CREATE INDEX group_statuses_v2_group_id_idx ON group_statuses_v2(group_id);


CREATE TABLE extend_statuses (
    id TEXT PRIMARY KEY,
    site TEXT,
    content TEXT,
    sender_name TEXT,
    fwd_sender_name TEXT,
    fwd_content TEXT,
    
    created_at INTEGER,
    forwarded_at INTEGER,
    mask INTEGER
);

CREATE TABLE status_extra_messages (
    id TEXT PRIMARY KEY,
    application_url TEXT,
    type TEXT,
    reference_id TEXT,
    tenant_id TEXT
);


CREATE TABLE dm_thread_messages (
    message_id TEXT NOT NULL PRIMARY KEY,
	thread_id TEXT,
    message TEXT,
    created_at DOUBLE,
    is_system_message SMALLINT,
    unread SMALLINT,
    
    latitude FLOAT,
    longitude FLOAT,
    address  TEXT,
    
    sender_id TEXT,
    recipient_id TEXT,
    mask INTEGER
);

CREATE INDEX dm_thread_messages_thread_id_idx ON dm_thread_messages (thread_id);
CREATE INDEX dm_thread_messages_created_at_idx ON dm_thread_messages (created_at);


CREATE TABLE dm_threads (
	-- direct message thread id
	thread_id TEXT NOT NULL PRIMARY KEY,
	
	-- the subject of this direct message thread
	subject TEXT,
    
    -- the thread avatar url
    thread_avatar_url TEXT,
	
	-- thread create time
	created_at DOUBLE,
	
	-- latest update time
	updated_at DOUBLE,
	
	-- the latest direct message id for this thread
	latest_dm_id TEXT,
    
    -- the latest direct message text of this thread
	latest_dm_text TEXT,
	
    -- the user id of latest direct message of this thread
	latest_dm_sender_id TEXT,
	
	-- total number of unread direct messages
	unread_count INTEGER,
	
    -- user id for all participants of this thread
    participant_ids TEXT,
    
	-- total participants for this thread
	participants_count INTEGER,
    
    -- participant avatar urls
    participant_urls TEXT,
	
	-- 1 means this thread opened for many people and many people did joined, otherwise is 0.
	public SMALLINT
);

CREATE INDEX dm_threads_updated_at_idx ON dm_threads (updated_at);



CREATE TABLE users (
    'user_id'                TEXT PRIMARY KEY,
    'name'                   TEXT,
    'screen_name'            TEXT,
    'email'					 TEXT,    
    'profile_image_url'      TEXT,
	'followees'              INTEGER,
	'fans'                   INTEGER,
	'following'              INTEGER,
	'latitude'               DOUBLE,
	'longitude'				 DOUBLE,
	'locationAddress'        TEXT,
	'description'             TEXT,
	'statuses_count'         INTEGER,
	'favorites_count'       INTEGER,
    'department'            TEXT,
    'job'                   TEXT,
    'topic'                     INTEGER,
    'company_name'                   TEXT,
    'is_team_user' SMALLINT,
    'is_public_user' SMALLINT
);  

CREATE TABLE Topic(
'topicid'                TEXT,
'topicName'              TEXT
);

CREATE INDEX users_name on users(name);
CREATE INDEX users_screen_name on users(screen_name);


CREATE TABLE attachments (
    id TEXT NOT NULL ,
    -- ID of object the attachment belongs to.
    object_id TEXT NOT NULL,
    name TEXT,
    content_type TEXT,
    url TEXT,
    file_size INTEGER,
    PRIMARY KEY(id,object_id)
);

CREATE TABLE unsend_messages (
    message_id TEXT NOT NULL PRIMARY KEY,
    thread_id TEXT,
    message TEXT,
    created_at DOUBLE,
    file_path TEXT,
    
    latitude FLOAT,
    longitude FLOAT,
    address  TEXT,

    mask INTEGER
);

CREATE INDEX attachments_idx_object_id_idx ON attachments(object_id);


CREATE TABLE drafts(
    id INTEGER PRIMARY KEY,
    type INTEGER,
    author_id TEXT,
    created_at DOUBLE,
    content TEXT,
    status_content TEXT,
    comment_on_status_id TEXT,
    comment_on_comment_id TEXT,
    group_id TEXT,
    group_name TEXT,
    image_data BLOB,
    mask INTEGER,
    latitude FLOAT,
    longitude FLOAT,
    address  TEXT

);

CREATE INDEX drafts_created_at_idx ON drafts (created_at);



CREATE TABLE groups (
    id TEXT PRIMARY KEY,
    name TEXT,
    profile_image_url TEXT,
    summary TEXT,
    bulletin TEXT,
    type INTEGER,
    sorting_index INTEGER
);

CREATE INDEX groups_sorting_index_idx ON groups (sorting_index);

CREATE TABLE votes(
    vote_id TEXT PRIMARY KEY,
    name TEXT,
    author_id TEXT,
    max_vote_item_count INTEGER,
    participant_count INTEGER,
    created_time DOUBLE,
    closed_time DOUBLE,
    is_ended BOOL,
    selected_option_ids TEXT,
    state SMALLINT
); 

CREATE TABLE vote_options(
    vote_id TEXT,
    option_id TEXT,
    name TEXT,
    count INTEGER,
    PRIMARY KEY(vote_id, option_id)
);

CREATE INDEX vote_options_vote_id_idx ON vote_options (vote_id);
CREATE INDEX vote_options_option_id_idx ON vote_options (option_id);

 
CREATE TABLE IF NOT EXISTS downloads (
      'id'                      TEXT NOT NULL PRIMARY KEY ,
      'name'                    TEXT NOT NULL,   
      'entity_id'               TEXT NOT NULL,      --statusId, directMessageId
      'entity_type'             INTEGER  NOT NULL DEFAULT -1,   --0: status 1: message 
      'start_at'                DOUBLE,
      'end_at'                  DOUBLE,
      'url'                     TEXT NOT NULL,
      'path'                    TEXT,
      'temp_path'               TEXT,
      'downdload_state'         INTEGER   NOT NULL DEFAULT 0 , --0: not  1:  success  2:failed
      'current_byte'            INTEGER NOT NULL DEFAULT 0,
      'max_byte'                INTEGER NOT NULL DEFAULT -1,
      'mime_type'               TEXT
);


CREATE TABLE images_source (
	-- entity id (status id, direct message id)
    file_id  TEXT NOT NULL,
    entity_id TEXT NOT NULL,

    file_name TEXT,
    file_type TEXT,
	-- thumbnail url
	thumbnail TEXT,
    
    -- middle url
    middle TEXT,
	
	-- original
	original TEXT,

    is_upload BOOL,
    
    PRIMARY KEY(file_id, entity_id)
);

CREATE INDEX images_source_entity_id_idx ON images_source (entity_id);


CREATE TABLE ab_persons (
	pid TEXT NOT NULL,
    user_id TEXT NOT NULL,
	name TEXT,
    job_title TEXT,
	department TEXT,
    
    emails TEXT,
    phones TEXT,
    mobiles TEXT,

    profile_image_url TEXT,
    network_id TEXT,

    favorited SMALLINT,

    -- (1 - recently contacts, 2 - all, 3 - favorited)
    type SMALLINT,
    
    sorting_time INTEGER,
    
    PRIMARY KEY(pid, type)
);

CREATE INDEX ab_person_p_id_idx ON ab_persons (pid);
CREATE INDEX ab_person_type_idx ON ab_persons (type);

CREATE TABLE inbox (
	refId TEXT NOT NULL,
    content TEXT,
	unReadCount INTEGER,
    groupId TEXT,
	groupName TEXT,
    
    isNew BOOL,
    isUpdate BOOL,
    refUserId TEXT,

    createTime DATE,
    userId TEXT,

    isDelete BOOL,

    type TEXT,
    
    refUserName TEXT,
    
    isUnRead BOOL,
    networkId TEXT,
    latestFeed TEXT,
    updateTime DATE,
    participants_photo TEXT,
    
    PRIMARY KEY(refId, type)
);
CREATE TABLE todo (
	fromId TEXT NOT NULL,
    fromType TEXT,
	networkId TEXT,
    actName TEXT,
	createDate DATE,
    
    contentHead TEXT,
    title TEXT,
    toUserId TEXT,

    fromUserId TEXT,
    connectType TEXT,

    updateDate DATE,

    actDate DATE,
    
    status TEXT,
    
    content TEXT,
    
    PRIMARY KEY(fromId)
);