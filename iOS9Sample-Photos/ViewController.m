//
//  ViewController.m
//  iOS9Sample-Photos
//
//  Created by MJ Lee on 15/9/24.
//  Copyright © 2015年 小码哥（http://www.520it.com）. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>

/** 相册名字 */
static NSString * const XMGCollectionName = @"小码哥-Photos";

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    NSMutableArray *photoArr;
    UICollectionView *photoCollectionView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    photoArr = [NSMutableArray new];

    
    UICollectionViewFlowLayout *flowLayou=[[UICollectionViewFlowLayout alloc] init];
    [flowLayou setItemSize:CGSizeMake((self.view.frame.size.width-20)/2, (self.view.frame.size.width-20)/2)];
    [flowLayou setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayou setSectionInset:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    photoCollectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.height-150) collectionViewLayout:flowLayou];
    
    photoCollectionView.dataSource=self;
    photoCollectionView.delegate=self;
    
    [photoCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"mycell"];
    [photoCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"myhead"];
    photoCollectionView.backgroundColor=[UIColor whiteColor];
    
    [self.view addSubview:photoCollectionView];
    
    
    
   // [self searchAllImages];
}

#pragma mark - 查询相册中的图片
/**
 * 查询所有的图片
 */
/*
 PHAssetCollectionType的枚举值:
 
 PHAssetCollectionTypeAlbum : 相册 - 依次获取每个相册
 PHAssetCollectionTypeSmartAlbum : 智能相册 - 符合PHAssetCollectionSubtype的筛选相册
 PHAssetCollectionTypeMoment : 时刻 - 按照时间顺序
 
 PHAssetCollectionSubtype枚举类型:
 常规的子类型
 PHAssetCollectionSubtypeAlbumRegular        常规的
 PHAssetCollectionSubtypeAlbumSyncedEvent    使用 iTunes 同步操作过来的相册
 PHAssetCollectionSubtypeAlbumSyncedFaces    使用 iTuens 同步操作过来的人物相册
 PHAssetCollectionSubtypeAlbumSyncedAlbum    使用iTunes  同步的所有相册
 PHAssetCollectionSubtypeAlbumImported       从外界导入的相册
 
 经分享的子类型
 PHAssetCollectionSubtypeAlbumMyPhotoStream   从相册分享得到
 PHAssetCollectionSubtypeAlbumCloudShared     从 cloud 分享得到
 
 智能相册子类型
 PHAssetCollectionSubtypeSmartAlbumGeneric    通用的
 PHAssetCollectionSubtypeSmartAlbumPanoramas  全景
 PHAssetCollectionSubtypeSmartAlbumVideos     视屏
 PHAssetCollectionSubtypeSmartAlbumFavorites  收藏 (点击照片下面的❤️按钮,就代表已收藏)
 PHAssetCollectionSubtypeSmartAlbumTimelapses 延时视屏,也会在PHAssetCollectionSubtypeSmartAlbumVideos在出现
 PHAssetCollectionSubtypeSmartAlbumAllHidden  隐藏的
 PHAssetCollectionSubtypeSmartAlbumRecentlyAdded 最近添加
 PHAssetCollectionSubtypeSmartAlbumBursts    连拍
 PHAssetCollectionSubtypeSmartAlbumSlomoVideos Slomo是slow motion的缩写,高速摄影慢动作解析
 PHAssetCollectionSubtypeSmartAlbumUserLibrary 用户所有的资源
 PHAssetCollectionSubtypeSmartAlbumSelfPortraits 所有前置摄像头拍的照片和视屏
 PHAssetCollectionSubtypeSmartAlbumScreenshots 所有的截屏图

 PHAssetCollectionSubtypeAny = NSIntegerMax  不关心子类型时的全部资源
 
 */
- (IBAction)searchAllImages {
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 遍历所有的自定义相册
            PHFetchResult<PHAssetCollection *> *collectionResult0 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
            NSLog(@"collectionResult0 = %@",collectionResult0);
            for (PHAssetCollection *collection in collectionResult0) {
                //[self searchAllImagesInCollection:collection];
            }
            
            // 获得相机胶卷的图片
            PHFetchResult<PHAssetCollection *> *collectionResult1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            for (PHAssetCollection *collection in collectionResult1) {
                if (![collection.localizedTitle isEqualToString:@"Camera Roll"]) continue;
                [self searchAllImagesInCollection:collection];
                break;
            }
        });
    }];
}

/**
 * 查询某个相册里面的所有图片
 */
- (void)searchAllImagesInCollection:(PHAssetCollection *)collection
{
    // 采取同步获取图片（只获得一次图片）
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    
    NSLog(@"相册名字：%@", collection.localizedTitle);
    
    // 遍历这个相册中的所有图片
    PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
   
    for (PHAsset *asset in assetResult) {
        // 过滤非图片
        //if (asset.mediaType != PHAssetMediaTypeImage) continue;
        
        // 图片原尺寸
        CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        // 请求图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            NSLog(@"图片：%@ info :%@", result,info);
            
            if (result) {
                [photoArr addObject:result];
            }
            
        }];
    }
    
    _photoNumbers.text = [NSString stringWithFormat:@"照片数: %ld",photoArr.count];
    [photoCollectionView reloadData];
}

#pragma mark - 保存图片到自定义相册
/**
 * 获得自定义的相册对象
 */
- (PHAssetCollection *)collection
{
    // 先从已存在相册中找到自定义相册对象
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:XMGCollectionName]) {
            return collection;
        }
    }
    
    // 新建自定义相册
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:XMGCollectionName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) {
        NSLog(@"获取相册【%@】失败", XMGCollectionName);
        return nil;
    }
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}

/**
 * 保存图片到相册
 */
- (IBAction)saveImage {
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
    
            // 保存相片到相机胶卷
            __block PHObjectPlaceholder *createdAsset = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                createdAsset = [PHAssetCreationRequest creationRequestForAssetFromImage:[UIImage imageNamed:@"logo"]].placeholderForCreatedAsset;
            } error:&error];
            
            if (error) {
                NSLog(@"保存失败：%@", error);
                return;
            }
            
            // 拿到自定义的相册对象
            PHAssetCollection *collection = [self collection];
            if (collection == nil) return;
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
            } error:&error];
            
            if (error) {
                NSLog(@"保存失败：%@", error);
            } else {
                NSLog(@"保存成功");
            }
        });
    }];
}

- (IBAction)clearPhotoAlbum:(id)sender {
    
    [photoArr removeAllObjects];
    [photoCollectionView  reloadData];
}

#pragma mark ---- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return photoArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *mycell=[collectionView dequeueReusableCellWithReuseIdentifier:@"mycell" forIndexPath:indexPath];
    
    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mycell.frame.size.width, mycell.frame.size.height)];
    imageView.image  = [photoArr objectAtIndex:indexPath.row];
    [mycell addSubview:imageView];
    mycell.backgroundColor = [UIColor redColor];
    
    return mycell;
}


@end
