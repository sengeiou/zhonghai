//
//  XTSelectPersonsView.h
//  XT
//
//  Created by Gil on 13-7-22.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XTSelectPersonsViewDelegate,XTSelectPersonsViewDataSource;
@class PersonSimpleDataModel;
@interface XTSelectPersonsView : UIView

@property (nonatomic, strong, readonly) NSMutableArray *persons;
@property (nonatomic, weak) id<XTSelectPersonsViewDelegate> delegate;
@property (nonatomic, weak) id<XTSelectPersonsViewDataSource> dataSource;
@property (assign, nonatomic) NSInteger minCount;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) BOOL isStopRefresh;

@property (nonatomic,assign) BOOL isMult; //增加新属性，用来判断是否多选，默认为多选
@property (nonatomic, assign) BOOL isFromTask;



- (void)addPerson:(PersonSimpleDataModel *)person;
- (void)deletePerson:(PersonSimpleDataModel *)person;

-(void)deleteAllPerson;
-(void)updateType;

- (void)addDataSource:(id<XTSelectPersonsViewDataSource>)dsToAdd;
- (void)removeDataSource:(id<XTSelectPersonsViewDataSource>)dsToRemove;
@end

@protocol XTSelectPersonsViewDelegate <NSObject>

- (void)selectPersonViewDidConfirm:(NSMutableArray *)persons;

@end

@protocol XTSelectPersonsViewDataSource <NSObject>

- (void)selectPersonViewDidAddPerson:(PersonSimpleDataModel *)person;
- (void)selectPersonsViewDidDeletePerson:(PersonSimpleDataModel *)person;

@end
