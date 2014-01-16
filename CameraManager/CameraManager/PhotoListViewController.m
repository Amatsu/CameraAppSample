//
//  PhotoListViewController.m
//  CameraManager
//
//  Created by Amatsu on 2014/01/04.
//  Copyright (c) 2014年 Amatsu. All rights reserved.
//

#import "PhotoListViewController.h"
#import "ViewController.h"


@interface PhotoListViewController ()

@end

@implementation PhotoListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //タブバーのデリゲート処理を設定
    self.menuTabBar.delegate = self;
    
    //ALAssetLibraryのインスタンスを作成
    _library = [[ALAssetsLibrary alloc] init];
    _AlbumName = @"TestAppPhoto";
    _AlAssetsArr = [NSMutableArray array];
    
    //TableViewに関連付け
    self.photoListTableView.delegate = self;
    self.photoListTableView.dataSource = self;
    
    //アルバムを取得
    [_library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                            usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                //ALAssetsLibraryのすべてのアルバムが列挙される
                                if (group) {
                                    //アルバム名が「_AlbumName」と同一だった時の処理
                                    if ([_AlbumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                        //assetsEnumerationBlock
                                        ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                            if (result) {
                                                //asset をNSMutableArraryに格納
                                                [_AlAssetsArr addObject:result];
                                            }else{
                                                //データ取得後の処理
                                                [self.photoListTableView reloadData];
                                            }
                                        };
                                        //アルバム(group)からALAssetの取得       
                                        [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                                    }           
                                }
                            } failureBlock:nil];
}

//TalbeViewに写真一覧を表示
- (void)showPhotoTableView {
    
}

//テーブルに含まれるセクションの数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//セクションに含まれる行の数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_AlAssetsArr count];
}

//行に表示するデータの生成
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PhotoCell";
    PhotoListCell *cell = [self.photoListTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //ALAssetからサムネール画像を取得してUIImageに変換
    UIImage *image = [UIImage imageWithCGImage:[[_AlAssetsArr objectAtIndex:indexPath.row] thumbnail]];
    cell.photoImg.image = image;
    
    ALAssetRepresentation *representation = [(ALAsset*)[_AlAssetsArr objectAtIndex:indexPath.row] defaultRepresentation];
    NSDictionary *metadataDict = [representation metadata] ;
    cell.lblComment.text = [[metadataDict objectForKey:(NSString*)kCGImagePropertyExifDictionary] objectForKey:(NSString*)kCGImagePropertyExifUserComment];

    NSLog(@"%@", [[metadataDict objectForKey:(NSString*)kCGImagePropertyExifDictionary] objectForKey:(NSString*)kCGImagePropertyExifUserComment]);
    
    return cell;
    
}

//Viewが表示される直前に実行される
- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath* selection = [self.photoListTableView indexPathForSelectedRow];
    if(selection){
        [self.photoListTableView deselectRowAtIndexPath:selection animated:YES];
    }
    [self.photoListTableView reloadData];
}

//Viewが表示された直後に実行される
- (void)viewDidAppear:(BOOL)animated {
    [self.photoListTableView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - メニューバー
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == 1) {
        //カメラ画面呼び出し
        ViewController *cameraView = [[self storyboard] instantiateViewControllerWithIdentifier:@"MainViewController"];
        [self presentViewController:cameraView animated:YES completion:nil];
    }
}

@end
