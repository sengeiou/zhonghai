
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