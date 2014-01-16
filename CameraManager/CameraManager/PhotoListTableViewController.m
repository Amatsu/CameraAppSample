//
//  PhotoListTableViewController.m
//  CameraManager
//
//  Created by Amatsu on 2014/01/16.
//  Copyright (c) 2014年 Amatsu. All rights reserved.
//

#import "PhotoListTableViewController.h"

@interface PhotoListTableViewController ()

@end

@implementation PhotoListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //ALAssetLibraryのインスタンスを作成
    _library = [[ALAssetsLibrary alloc] init];
    _AlbumName = @"TestAppPhoto";
    _AlAssetsArr = [NSMutableArray array];
    
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
                                                [self.tableView reloadData];
                                            }
                                        };
                                        //アルバム(group)からALAssetの取得
                                        [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                                    }
                                }
                            } failureBlock:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return  [_AlAssetsArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"PhotoCell";
    PhotoListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //ALAssetからサムネール画像を取得してUIImageに変換
    UIImage *image = [UIImage imageWithCGImage:[[_AlAssetsArr objectAtIndex:indexPath.row] thumbnail]];
    cell.photoImg.image = image;
    
    ALAssetRepresentation *representation = [(ALAsset*)[_AlAssetsArr objectAtIndex:indexPath.row] defaultRepresentation];
    NSDictionary *metadataDict = [representation metadata] ;
    cell.lblComment.text = [[metadataDict objectForKey:(NSString*)kCGImagePropertyExifDictionary] objectForKey:(NSString*)kCGImagePropertyExifUserComment];
    
    //画像URLを取得
    NSString *assetURL = [[[_AlAssetsArr objectAtIndex:indexPath.row] valueForProperty:ALAssetPropertyURLs] objectForKey:[[[_AlAssetsArr objectAtIndex:indexPath.row] defaultRepresentation] UTI]];
    cell.imageURL = (NSURL*)assetURL;
    
    NSLog(@"%@",cell.imageURL);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    PhotoListCell* photoCell =  (PhotoListCell*)cell;
    NSLog(@"%@",photoCell.lblComment.text);
    
    PhotoViewController *photoView = [[self storyboard] instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    photoView.imageURL = photoCell.imageURL;
    [photoView showPhoto];

    //画面遷移
    [self.navigationController pushViewController:photoView animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
