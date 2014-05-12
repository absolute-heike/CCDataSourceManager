//
//  CCDataSourceManager.h
//  CCDataSourceManager
//
//  Created by Michael Berg on 12.05.14.
//  Copyright (c) 2014 Couchfunk GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void (^CCDataSourceManagerCellSetupBlock)(id cell, id data, NSIndexPath *indexPath);

@protocol CCDataSourceManagerDelegate;

@interface CCDataSourceManager : NSObject

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, weak) id<CCDataSourceManagerDelegate> delegate;
@property BOOL editable;
@property BOOL shouldAutoReloadOnDataSourceChange;


+ (instancetype)managerForTableView:(UITableView *)tableView;
+ (instancetype)managerForCollectionView:(UICollectionView *)collectionView;

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)reuseIdentifier forDataObject:(Class)classType setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock;
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)reuseIdentifier forDataObject:(Class)classType setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock;
- (void)registerCellReuseIdentifier:(NSString *)reuseIdentifier forDataObject:(Class)classType setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock;

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)reuseIdentifier forDataObjects:(NSArray *)classes setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock;
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)reuseIdentifier forDataObjects:(NSArray *)classes setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock;
- (void)registerCellReuseIdentifier:(NSString *)reuseIdentifier forDataObjects:(NSArray *)classes setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock;

- (id)dataForIndexPath:(NSIndexPath *)indexPath;

@end


@interface UITableView (CCDataSourceManager)

@property (nonatomic, readonly) CCDataSourceManager *dataSourceManager;
@property (nonatomic, readonly) BOOL                isDataSourceInstantiated;

- (void)removeDataSourceManager;

@end

@interface UICollectionView (CCDataSourceManager)

@property (nonatomic, readonly) CCDataSourceManager *dataSourceManager;
@property (nonatomic, readonly) BOOL                isDataSourceInstantiated;

- (void)removeDataSourceManager;

@end


@protocol CCDataSourceManagerDelegate

- (void)dataSourceManager:(CCDataSourceManager *)manager didDeleteItem:(id)item atIndexPath:(NSIndexPath *)indexPath;

@end