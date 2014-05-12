//
//  CCDataSourceManager.m
//  CCDataSourceManager
//
//  Created by Michael Berg on 12.05.14.
//  Copyright (c) 2014 Couchfunk GmbH. All rights reserved.
//

#import "CCDataSourceManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CCDataSourceManager () <UITableViewDataSource, UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView    *collectionView;
@property (nonatomic, strong) NSMutableDictionary *reuseIdentifiers;
@property (nonatomic, strong) NSMutableDictionary *setupBlocks;
@property (nonatomic, weak) UITableView         *tableView;

@end


@implementation CCDataSourceManager


+ (instancetype)managerForTableView:(UITableView *)tableView {
    CCDataSourceManager *manager = [[CCDataSourceManager alloc] init];
    
    manager.tableView       = tableView;
    tableView.dataSource    = manager;
    
    return manager;
}

+ (instancetype)managerForCollectionView:(UICollectionView *)collectionView {
    CCDataSourceManager *manager = [[CCDataSourceManager alloc] init];
    
    manager.collectionView      = collectionView;
    collectionView.dataSource   = manager;
    
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.shouldAutoReloadOnDataSourceChange = TRUE;
        self.editable                           = FALSE;
        self.setupBlocks                        = [NSMutableDictionary dictionary];
        self.reuseIdentifiers                   = [NSMutableDictionary dictionary];
        
        __weak CCDataSourceManager *weakSelf = self;
        [RACObserve(self, data) subscribeNext:^(NSArray *data) {
            if (![data isKindOfClass:[NSArray class]]) {
                weakSelf.data = @[];
                return;
            }
            
            if (weakSelf.shouldAutoReloadOnDataSourceChange) {
                [weakSelf.tableView reloadData];
                [weakSelf.collectionView reloadData];
            }
        }];
    }
    return self;
}

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)reuseIdentifier forDataObject:(Class)classType setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock {
    [self registerNib:nib forCellReuseIdentifier:reuseIdentifier forDataObjects:@[classType] setupBlock:setupBlock];
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)reuseIdentifier forDataObject:(Class)classType setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock {
    [self registerClass:cellClass forCellReuseIdentifier:reuseIdentifier forDataObjects:@[classType] setupBlock:setupBlock];
}

- (void)registerCellReuseIdentifier:(NSString *)reuseIdentifier forDataObject:(Class)classType setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock {
    NSString *classString = NSStringFromClass(classType);
    [self.reuseIdentifiers  setObject:reuseIdentifier   forKey:classString];
    [self.setupBlocks       setObject:[setupBlock copy] forKey:classString];
}

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)reuseIdentifier forDataObjects:(NSArray *)classes setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock{
    [self.tableView      registerNib:nib forCellReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
    
    [self registerCellReuseIdentifier:reuseIdentifier forDataObjects:classes setupBlock:setupBlock];
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)reuseIdentifier forDataObjects:(NSArray *)classes setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock {
    [self.tableView registerClass:cellClass forCellReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:reuseIdentifier];
    
    [self registerCellReuseIdentifier:reuseIdentifier forDataObjects:classes setupBlock:setupBlock];
}

- (void)registerCellReuseIdentifier:(NSString *)reuseIdentifier forDataObjects:(NSArray *)classes setupBlock:(CCDataSourceManagerCellSetupBlock)setupBlock {
    for (Class class in classes) {
        [self registerCellReuseIdentifier:reuseIdentifier forDataObject:class setupBlock:setupBlock];
    }
}


#pragma mark - Data Accessor

- (id)dataForIndexPath:(NSIndexPath *)indexPath {
    return [self.data[indexPath.section] objectAtIndex:indexPath.row];
}


#pragma mark - Table View DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *data          = [self dataForIndexPath:indexPath];
    NSString *classString   = NSStringFromClass(data.class);
    
    NSString *reuseIdentifier   = [self.reuseIdentifiers objectForKey:classString];
    NSAssert(reuseIdentifier, @"No Cell registered for class with Name: %@",classString);
    
    UITableViewCell *cell       = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    CCDataSourceManagerCellSetupBlock setupBlock = [self.setupBlocks objectForKey:classString];
    
    if (setupBlock) {
        setupBlock(cell,data,indexPath);
    }
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *sectionData = self.data[indexPath.section];
    
    return self.editable && [sectionData isKindOfClass:[NSMutableArray class]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *sectionData = self.data[indexPath.section];
    if (
        editingStyle == UITableViewCellEditingStyleDelete &&
        [sectionData isKindOfClass:[NSMutableArray class]]
        ) {
        id item = [sectionData objectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        
        [sectionData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView endUpdates];
        
        [self.delegate dataSourceManager:self didDeleteItem:item atIndexPath:indexPath];
    }
}


#pragma mark - Collection View DataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.data.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.data[section] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSObject *data          = [self dataForIndexPath:indexPath];
    NSString *classString   = NSStringFromClass(data.class);
    
    NSString *reuseIdentifier   = [self.reuseIdentifiers objectForKey:classString];
    NSAssert(reuseIdentifier, @"No Cell registered for class with Name: %@",classString);
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    CCDataSourceManagerCellSetupBlock setupBlock = [self.setupBlocks objectForKey:classString];
    
    if (setupBlock) {
        setupBlock(cell,data,indexPath);
    }
    
    return cell;
}

@end



#pragma mark - Categories

//Categories
#import <objc/runtime.h>
static char DataSource_MANAGER_KEY;

@implementation UITableView (CCDataSourceManager)

-(CCDataSourceManager *)dataSourceManager{
    CCDataSourceManager *manager = objc_getAssociatedObject(self, &DataSource_MANAGER_KEY);
    
    if (!manager) {
        manager = [CCDataSourceManager managerForTableView:self];
        objc_setAssociatedObject(self, &DataSource_MANAGER_KEY, manager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return manager;
}

-(BOOL)isDataSourceInstantiated {
    CCDataSourceManager *manager = objc_getAssociatedObject(self, &DataSource_MANAGER_KEY);
    
    return (manager != nil);
}

- (void)removeDataSourceManager {
    objc_setAssociatedObject(self, &DataSource_MANAGER_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.dataSource = nil;
}

@end

@implementation UICollectionView (CCDataSourceManager)

-(CCDataSourceManager *)dataSourceManager{
    CCDataSourceManager *manager = objc_getAssociatedObject(self, &DataSource_MANAGER_KEY);
    
    if (!manager) {
        manager = [CCDataSourceManager managerForCollectionView:self];
        objc_setAssociatedObject(self, &DataSource_MANAGER_KEY, manager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return manager;
}

-(BOOL)isDataSourceInstantiated {
    CCDataSourceManager *manager = objc_getAssociatedObject(self, &DataSource_MANAGER_KEY);
    
    return (manager != nil);
}

- (void)removeDataSourceManager {
    objc_setAssociatedObject(self, &DataSource_MANAGER_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.dataSource = nil;
}

@end
