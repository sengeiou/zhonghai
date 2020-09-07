//
//  AuthDataModel.m
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "AuthDataModel.h"

@interface AuthDataModel ()
-(NSString *)checkURL:(NSString *)url;
@end

@implementation AuthDataModel
@synthesize welcome = _welcome_;
@synthesize url = _url_;
@synthesize security = _security_;
@synthesize customerName = _customerName_;
@synthesize authToken = _authToken_;
@synthesize params = _params_;
@synthesize appId = _appId_;
@synthesize loginUser = _loginUser_;
@synthesize instanceName = _instanceName_;
@synthesize xtOpen = _xtOpen;
- (id)init {
    self = [super init];
    if (self) {
        _welcome_ = [[NSString alloc] init];
        _url_ = [[NSString alloc] init];
        _security_ = SecurityLevelNone;
        _customerName_ = [[NSString alloc] init];
        _authToken_ = [[NSString alloc] init];
        _params_ = [[NSDictionary alloc] init];
        _appId_ = 0;
        _loginUser_ = [[NSString alloc] init];
        _instanceName_ = [[NSString alloc] init];
        _xtOpen=[[NSString alloc]init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id welcome = [dict objectForKey:@"welcome"];
        id url = [dict objectForKey:@"url"];
        id security = [dict objectForKey:@"security"];
        id customerName = [dict objectForKey:@"customerName"];
        id authToken = [dict objectForKey:@"authToken"];
        id params = [dict objectForKey:@"params"];
        id appId = [dict objectForKey:@"appId"];
        id loginUser = [dict objectForKey:@"loginUser"];
        id instanceName = [dict objectForKey:@"instanceName"];
        id xtOpen = [dict objectForKey:@"xtOpen"];
        if (![welcome isKindOfClass:[NSNull class]] && welcome) {
            self.welcome = welcome;
        }
        if (![url isKindOfClass:[NSNull class]] && url) {
            self.url = [self checkURL:url];
        }
        if (![security isKindOfClass:[NSNull class]] && security) {
            self.security = [security intValue];
        }
        if (![customerName isKindOfClass:[NSNull class]] && customerName) {
            self.customerName = customerName;
        }
        if (![authToken isKindOfClass:[NSNull class]] && authToken) {
            self.authToken = authToken;
        }
        if (![params isKindOfClass:[NSNull class]] && params && [params isKindOfClass:[NSDictionary class]]) {
            self.params = params;
        }
        if (![appId isKindOfClass:[NSNull class]] && appId) {
            self.appId = [appId intValue];
        }
        if (![loginUser isKindOfClass:[NSNull class]] && loginUser) {
            self.loginUser = loginUser;
        }
        if (![instanceName isKindOfClass:[NSNull class]] && instanceName) {
            self.instanceName = instanceName;
        }
        if (![xtOpen isKindOfClass:[NSNull class]] && xtOpen) {
            self.xtOpen = xtOpen;
        }
    }
    return self;
}

- (void)dealloc {
    //BOSRELEASE_welcome_);
    //BOSRELEASE_url_);
    //BOSRELEASE_customerName_);
    //BOSRELEASE_authToken_);
    //BOSRELEASE_params_);
    //BOSRELEASE_loginUser_);
    //BOSRELEASE_instanceName_);
    //BOSRELEASE_xtOpen);
    //[super dealloc];
}

-(NSString *)checkURL:(NSString *)url
{
    if ([[url lowercaseString] hasPrefix:@"http"]) {
        return url;
    }
    return [@"http://" stringByAppendingFormat:@"%@",url];
}

@end


@implementation AuthVersionLowDataModel
@synthesize iosURL = _iosURL_;

- (id)init {
    self = [super init];
    if (self) {
        _iosURL_ = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id iosURL = [dict objectForKey:@"iosURL"];
        
        if (![iosURL isKindOfClass:[NSNull class]] && iosURL) {
            self.iosURL = iosURL;
        }
    }
    return self;
}

- (void)dealloc {
    //BOSRELEASE_iosURL_);
    //[super dealloc];
}

@end

@implementation AuthDeviceUnauthorizedDataModel
@synthesize url = _url_;
@synthesize licencePolicy = _licencePolicy_;
@synthesize opToken = _opToken_;
@synthesize authTime = _authTime_;
@synthesize loginUser = _loginUser_;

- (id)init {
    self = [super init];
    if (self) {
        _url_ = [[NSString alloc] init];
        _licencePolicy_ = LicenceOpenPolicy;
        _opToken_ = [[NSString alloc] init];
        _authTime_ = [[NSString alloc] init];
        _loginUser_ = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id url = [dict objectForKey:@"url"];
        id licencePolicy = [dict objectForKey:@"licencePolicy"];
        id opToken = [dict objectForKey:@"opToken"];
        id authTime = [dict objectForKey:@"authTime"];
        id loginUser = [dict objectForKey:@"loginUser"];
        
        if (![url isKindOfClass:[NSNull class]] && url) {
            self.url = url;
        }
        if (![licencePolicy isKindOfClass:[NSNull class]] && licencePolicy) {
            self.licencePolicy = [licencePolicy intValue];
        }
        if (![opToken isKindOfClass:[NSNull class]] && opToken) {
            self.opToken = opToken;
        }
        if (![authTime isKindOfClass:[NSNull class]] && authTime) {
            self.authTime = authTime;
        }
        if (![loginUser isKindOfClass:[NSNull class]] && loginUser) {
            self.loginUser = loginUser;
        }
    }
    return self;
}

- (void)dealloc {
    //BOSRELEASE_url_);
    //BOSRELEASE_opToken_);
    //BOSRELEASE_authTime_);
    //BOSRELEASE_loginUser_);
    //[super dealloc];
}

@end

@implementation AuthTOSDataModel
@synthesize tosTag = _tosTag_;

- (id)init {
    self = [super init];
    if (self) {
        _tosTag_ = TOSSigned;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (self) {
        id tosTag = [dict objectForKey:@"signed"];
        
        if (![tosTag isKindOfClass:[NSNull class]] && tosTag) {
            self.tosTag = [tosTag intValue];
        }
    }
    return self;
}

- (void)dealloc {
    //[super dealloc];
}

@end
