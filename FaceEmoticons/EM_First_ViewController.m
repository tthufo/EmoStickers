//
//  EM_First_ViewController.m
//  Emoticon
//
//  Created by thanhhaitran on 2/5/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "EM_First_ViewController.h"

#import "EM_Second_ViewController.h"

#import "TFHpple.h"

#import "XMLReader.h"

#import "DropButton.h"

#define ratio 0.5

#define sideRatio 0.2

@interface EM_First_ViewController ()<UITableViewDataSource, UITableViewDelegate>

{
    NSMutableArray * dataList, * menuList, * sideMenuList, * multiImages, * uri;
    
    int count;
    
    IBOutlet UICollectionView * collectionView;
    
    NSString * url, * tempIndexPath;
    
    UIView * menu, * sideMenu;
    
    IBOutlet UIView * buttonView;
    
    IBOutlet UIButton * cover;
    
    UIImage * tempImage;
    
    UIImageView * preview;
    
    CGRect start;
    
    ASIFormDataRequest * request;
    
    BOOL isShow;
}

@end

@implementation EM_First_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    count = 1;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[AVHexColor colorWithHexString:@"#FFFFFF"]}];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7)
    {
        self.navigationController.navigationBar.barTintColor = [AVHexColor colorWithHexString:kColor];
        self.navigationController.navigationBar.translucent = NO;
    }
    else
    {
        self.navigationController.navigationBar.tintColor = [AVHexColor colorWithHexString:kColor];
    }
    
    UIBarButtonItem * menuB = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(didPressMenu)];
    self.navigationItem.leftBarButtonItem = menuB;
    
    UIBarButtonItem * share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(didPressShare)];
    self.navigationItem.rightBarButtonItem = share;
    
    [collectionView registerNib:[UINib nibWithNibName:@"EM_Cells" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
    
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    dataList = [NSMutableArray new];
    
    multiImages = [NSMutableArray new];
    
    uri = [NSMutableArray new];

    sideMenuList = [[NSMutableArray alloc] initWithArray:@[@"Save",@"Copy",@"Share",@"Close"]];
    
    menu = [self returnView];
    
    sideMenu = [self returnSideMenu];
    
    [self didPrepareData:NO];
    
    self.title = @"";
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":@"https://dl.dropboxusercontent.com/s/e8leve4263d42zj/EmoSticker.plist",@"overrideError":@(1),@"overrideLoading":@(1),@"host":self} withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSError *error, BOOL isValidated) {
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError * er = nil;
        NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                     options:XMLReaderOptionsProcessNamespaces
                                                       error:&er];
        
        NSMutableDictionary * option = [[XMLReader recursionRemoveTextNode:dict] mutableCopy];
        
        isShow = [option[@"plist"][@"dict"][@"key"] boolValue];
        
        [self didPrepareData:[option[@"plist"][@"dict"][@"key"] boolValue]];
        
        [self didPrepareButtonView];
        
        [self didSelectMultiMode];
        
        [self didRequestData];
        
        if(!isShow)
        {
            __block  EM_First_ViewController * weakSelf = self;
            
            [collectionView addFooterWithBlock:^{
                
                [weakSelf didLoadMore];
                
            }];
        }
        
    }];
    
    cover.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    preview = [self returnImage:CGRectMake(15, (screenHeight - (screenWidth - (screenWidth * sideRatio)) - 30) / 2 - 15 , (screenWidth - (screenWidth * sideRatio)) - 30 , (screenWidth - (screenWidth * sideRatio)) - 30)];
    
    [preview withBorder:@{}];
    
    preview.contentMode = UIViewContentModeScaleAspectFill;
        
    if([[self infoPlist][@"showAds"] boolValue])
    {
        [[StartAds sharedInstance] didShowBannerAdsWithInfor:@{@"host":self,@"Y":@(screenHeight - 64 - 50)} andCompletion:^(BannerEvent event, NSError *error, id bannerAd) {
            switch (event)
            {
                case AdsDone:
                {
                    
                }
                    break;
                case AdsFailed:
                {
                    
                }
                    break;
                case AdsWillPresent:
                {
                    
                }
                    break;
                case AdsWillLeave:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)didSelectMultiMode
{
    if(buttonView.frame.origin.y == screenHeight && ![[System getValue:@"s_option"] boolValue])
        return;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = buttonView.frame;
        
        rect.origin.y += ![[System getValue:@"s_option"] boolValue] ? 94 + 64 : - 94 - 64;
        
        buttonView.frame = rect;
        
        collectionView.contentInset = UIEdgeInsetsMake(0, 0,![[System getValue:@"s_option"] boolValue] ? 50 : 100, 0);
        
    }];
    
    [self showToast:[[System getValue:@"s_option"] boolValue] ? @"Multi selection" : @"Single selection" andPos:0];
}

- (void)didPrepareButtonView
{
    buttonView.frame = CGRectMake(0, screenHeight , screenWidth, 44);
    
    UIButton * save = [UIButton buttonWithType:UIButtonTypeCustom];
    save.tag = 1;
    [save setTitle:@"Save" forState:UIControlStateNormal];
    save.font = [UIFont boldSystemFontOfSize:17];
    save.backgroundColor = [AVHexColor colorWithHexString:kColor];
    [save withBorder:@{@"Bcorner":@(0),@"Bwidth": @(1),@"Bhex": @"#FFFFFF"}];
    save.frame = CGRectMake(0, 0, screenWidth / 2 - 1, buttonView.frame.size.height);
    [save addTarget:self action:@selector(didPressButtonView:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:save];
    
    UIButton * copy = [UIButton buttonWithType:UIButtonTypeCustom];
    copy.tag = 2;
    [copy setTitle:@"Copy" forState:UIControlStateNormal];
    copy.font = [UIFont boldSystemFontOfSize:17];
    copy.backgroundColor = [AVHexColor colorWithHexString:kColor];
    [copy withBorder:@{@"Bcorner":@(0),@"Bwidth": @(1),@"Bhex": @"#FFFFFF"}];
    copy.frame = CGRectMake(screenWidth / 2 + 1, 0, screenWidth / 2 - 1, buttonView.frame.size.height);
    [copy addTarget:self action:@selector(didPressButtonView:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:copy];
    
    [self.view addSubview:buttonView];
}

- (void)didPressButtonView:(UIButton*)sender
{
    NSMutableArray * index = [NSMutableArray new];
    
    [uri removeAllObjects];
    
    for(NSDictionary * dict in dataList)
    {
        if([dict[@"isSelected"] boolValue])
        {
            NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:dict[@"image"]]];
            
            UIImage *lastPreviousCachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
            
            [index addObject:lastPreviousCachedImage];
            
            [uri addObject:dict[@"image"]];
        }
    }
    if(sender.tag == 1)
    {
        if(index.count == 0)
        {
            [self showToast:@"You did not select any photo" andPos:0];
            
            return;
        }
        
        [multiImages removeAllObjects];
        
        [multiImages addObjectsFromArray:index];
        
        [self saveNextWallpaper];
        
        [self showSVHUD:@"Saving" andOption:0];
        
        if(![self getValue:@"save"])
        {
            [self addValue:@"1" andKey:@"save"];
        }
        else
        {
            int k = [[self getValue:@"save"] intValue] + 1 ;
            
            [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"save"];
        }
        
        if([[self getValue:@"save"] intValue] % 3 == 0)
        {
            [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
        }
    }
    else
    {
        UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
        
        appPasteBoard.persistent = YES;
        
        [appPasteBoard setImages:index];
        
        NSArray * total = [dataList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isSelected = 1"]];
       
        [self showToast:[NSString stringWithFormat:@"%lu photo(s) copied",(unsigned long)total.count] andPos:0];
        
        if(![self getValue:@"copy"])
        {
            [self addValue:@"1" andKey:@"copy"];
        }
        else
        {
            int k = [[self getValue:@"copy"] intValue] + 1 ;
            
            [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"copy"];
        }
        
        if([[self getValue:@"copy"] intValue] % 5 == 0)
        {
            [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
        }
    }
}

- (void)saveNextWallpaper
{
    if (multiImages && multiImages.count > 0)
    {
        UIImageWriteToSavedPhotosAlbum([multiImages lastObject], self, @selector(image:didFinishSavingImagesWithError:contextInfo:), (__bridge void * _Nullable)([uri lastObject]));
        [multiImages removeLastObject];
        [uri removeLastObject];
    }
}

- (void)image:(UIImage *)image didFinishSavingImagesWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        [self showSVHUD:@"Photo(s) not saved, please check for Gallery permission in Settings" andOption:2];
    }
    else
    {
        [System addValue:(__bridge NSString*)contextInfo andKey:(__bridge NSString*)contextInfo];
        
        [collectionView reloadData];
        
        if (multiImages)
        {
            [self saveNextWallpaper];
            
            if (multiImages.count == 0)
            {
                [self hideSVHUD];
                
                NSArray * total = [dataList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isSelected = 1"]];
                
                [self showToast:[NSString stringWithFormat:@"%i photo(s) saved",total.count] andPos:0];
            }
        }
    }
}

- (void)didPrepareData:(BOOL)isShow
{
    if(![System getValue:@"s_option"])
    {
        [System addValue:@(0) andKey:@"s_option"];
    }
    
    self.title = [NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"][0][@"title"];

    url = [NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"][0][@"cat"];
    
    menuList = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"]];
}

- (void)didPressShare
{
    DropButton * sender = [DropButton shareInstance];
    
    sender.pList = @"options";
    
    [sender didDropDownWithData:@[@{@"title":@"Emoji mode"},@{@"title":[[System getValue:@"s_option"] boolValue] ? @"Single selection" : @"Multi Selection"},@{@"title":@"Tell your friend"}] andInfo:@{@"rect":[NSValue valueWithCGRect:CGRectMake(screenWidth - 150, -34, 150, 100)]} andCompletion:^(id object) {
        
        switch ([object[@"index"] intValue]) {
    
            case 1:
            {
                [System addValue:[[System getValue:@"s_option"] boolValue] ? @(0) : @(1) andKey:@"s_option"];
                if(dataList.count != 0 && [[System getValue:@"s_option"] boolValue])
                {
                    for(NSMutableDictionary * dict in dataList)
                    {
                        if(![dict responseForKey:@"isSelected"])
                            dict[@"isSelected"] = @(0);
                    }
                }
                
                [self didSelectMultiMode];
                
                [collectionView reloadData];
            }
                break;
                
            case 2:
            {
                [[FB shareInstance] startShareWithInfo:@[@"Plenty of emotion stickers for your message and chatting, have fun!",@"https://itunes.apple.com/us/developer/thanh-hai-tran/id1073174100",[UIImage imageNamed:@"emostick"]] andBase:nil andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
                    
                }];
            }
                break;
            case 0:
            {
                [self.navigationController pushViewController:[EM_Second_ViewController new] animated:NO];
            }
                break;
            default:
                break;
        }
        
    }];
}

- (IBAction)didPressCover:(id)sender
{
    if([self.view.subviews containsObject:sideMenu])
    {
        [self didPressSideMenu];
    }
    else
    {
        [self didPressMenu];
    }
}

- (UIView*)returnView
{
    UIView * mem = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][0];
    
    ((UITableView *)[self withView:mem tag:11]).delegate = self;
    
    ((UITableView *)[self withView:mem tag:11]).dataSource = self;

    return mem;
}

- (UIView*)returnSideMenu
{
    UIView * mem = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][3];
    
    ((UITableView *)[self withView:mem tag:12]).delegate = self;
    
    ((UITableView *)[self withView:mem tag:12]).dataSource = self;
    
    return mem;
}

- (UIImageView*)returnImage:(CGRect)frame
{
    UIImageView * mem = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][4];

    mem.frame = frame;

    return mem;
}

- (void)didPressSideMenu
{
    BOOL isMenu = [self.view.subviews containsObject:sideMenu];
    
    if(!isMenu)
    {
        sideMenu.frame = CGRectMake(screenWidth, (screenHeight - 200) / 2 - 44, screenWidth * sideRatio, 200);
        
        [self.view addSubview:sideMenu];
    }

    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = sideMenu.frame;
        
        rect.origin.x += isMenu ? screenWidth * sideRatio : - screenWidth * sideRatio;
        
        sideMenu.frame = rect;
        
        collectionView.userInteractionEnabled = isMenu;
        
    } completion:^(BOOL finished) {
        
        if (finished && isMenu && sideMenu.frame.origin.x != screenWidth * sideRatio)
        {
            [sideMenu removeFromSuperview];
            [cover removeFromSuperview];
            [self didChangeImagePosition:start isBack:NO];
        }
        else
        {
            [self.view insertSubview:cover belowSubview:sideMenu];
        }
        
    }];
}

- (void)didPressMenu
{
    BOOL isMenu = [self.view.subviews containsObject:menu];

    if(!isMenu)
    {
        menu.frame = CGRectMake( - screenWidth * ratio, (screenHeight - 200) / 2 - 44, screenWidth * ratio, 200);
        
        [self.view addSubview:menu];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = menu.frame;
        
        rect.origin.x += isMenu ? - screenWidth * ratio : screenWidth * ratio;
        
        menu.frame = rect;
        
        collectionView.userInteractionEnabled = isMenu;
        
    } completion:^(BOOL finished) {
        
        if (finished && isMenu && menu.frame.origin.x != 0)
        {
            [menu removeFromSuperview];
            [cover removeFromSuperview];
        }
        else
        {
            [self.view insertSubview:cover belowSubview:menu];
        }

    }];
    
    if(![self getValue:@"menu"])
    {
        [self addValue:@"1" andKey:@"menu"];
    }
    else
    {
        int k = [[self getValue:@"menu"] intValue] + 1 ;
        
        [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"menu"];
    }
    
    if([[self getValue:@"menu"] intValue] % 8 == 0)
    {
        [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
    }
}

- (void)didLoadMore
{
    count ++;
    
    [self didRequestData];
}

- (void)didReceiveData:(NSString*)data andIsReset:(BOOL)isReset
{
    if(count == 1)
        [dataList removeAllObjects];
    
    TFHpple *parser = [TFHpple hppleWithHTMLData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *pathQuery = isShow ?  @"//div[@class='sticker-single']" : @"//div[@class='mdCMN05Img']/img";

    NSArray *nodes = [parser searchWithXPathQuery:pathQuery];
    
    for (TFHppleElement *element in nodes)
    {        
        if(!isShow)
        {
            [dataList addObject:[@{@"image":[element objectForKey:@"src"]} mutableCopy]];
            continue;
        }
        
        for(TFHppleElement *child in element.children)
        {
            if([child objectForKey:@"src"] && ![[child objectForKey:@"src"] myContainsString:@"send.png"])
            {
                [dataList addObject:[@{@"image":[child objectForKey:@"src"]} mutableCopy]];
            }
        }

    }
    
    [collectionView reloadData];

    [collectionView footerEndRefreshing];
    
    if(isReset)
        [collectionView setContentOffset:CGPointZero animated:NO];
}

- (void)didRequestData
{
    NSString * requestUrl = [NSString stringWithFormat:url, count];
    
    if(isShow)
    {
       request = [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":url,@"overrideError":@(1),@"host":self} withCache:^(NSString *cacheString) {
            
            [self didReceiveData:cacheString andIsReset:YES];
            
        } andCompletion:^(NSString *responseString, NSError *error, BOOL isValidated) {
            
            if(!error)
                
                [self didReceiveData:responseString andIsReset:NO];
        }];
    }
    else
    {
        [[LTRequest sharedInstance] didInitWithUrl:@{@"absoluteLink":requestUrl/*,@"overrideError":@(1)*/,@"host":self} withCache:^(NSString *cacheString) {
            
            [self didReceiveData:cacheString andIsReset:YES];
            
        } andCompletion:^(NSString *responseString, NSError *error, BOOL isValidated) {
            
            if(!error)
            
                [self didReceiveData:responseString andIsReset:NO];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableView.tag == 11 ? menuList.count : sideMenuList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"menu"];
    
    if(!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][1];
    }
    
    if(_tableView.tag == 11)
    {
        ((UILabel*)[self withView:cell tag:11]).text = menuList[indexPath.row][@"title"];
        
        ((UILabel*)[self withView:cell tag:11]).textColor = [AVHexColor colorWithHexString:@"#4BABE4"];

        [((UIView*)[self withView:cell tag:12]) withBorder:@{@"Bcorner":@(0),@"Bwidth": @(1.5) ,@"Bhex":@"#4BABE4"}];
        
        if([menuList[indexPath.row][@"title"] isEqualToString:self.title])
        {
            ((UILabel*)[self withView:cell tag:11]).textColor = [AVHexColor colorWithHexString:@"#D6544E"];
            
            ((UILabel*)[self withView:cell tag:11]).alpha = 0.3;
            
            [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
                
                ((UILabel*)[self withView:cell tag:11]).alpha = 1;
                
            } completion:nil];
        }
    }
    else
    {
        ((UILabel*)[self withView:cell tag:11]).text = sideMenuList[indexPath.row];
        
        ((UILabel*)[self withView:cell tag:11]).textAlignment = NSTextAlignmentCenter;
        
        ((UILabel*)[self withView:cell tag:11]).textColor = [AVHexColor colorWithHexString:@"#4BABE4"];
    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(_tableView.tag == 11)
    {
        [request cancel];
        
        [request clearDelegatesAndCancel];
        
        if([menuList[indexPath.row][@"title"] isEqualToString:self.title])
        {
            [self didPressMenu];
            
             return;
        }
        
        count = 1;
        
        self.title = menuList[indexPath.row][@"title"];
        
        [_tableView reloadData];
        
        url = menuList[indexPath.row][@"cat"];
        
        [self didRequestData];
        
        [self didPressMenu];
    }
    else
    {
        switch(indexPath.row)
        {
            case 0:
            {
                UIImageWriteToSavedPhotosAlbum(tempImage,self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void * _Nullable)(dataList[[tempIndexPath intValue]][@"image"]));
            }
                break;
            case 1:
            {
                UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
                appPasteBoard.persistent = YES;
                [appPasteBoard setImage:tempImage];
            }
                break;
            case 2:
            {
                [[FB shareInstance] startShareWithInfo:@[@"Plenty of emotion stickers for your message and chatting, have fun!", @"https://itunes.apple.com/us/developer/thanh-hai-tran/id1073174100", tempImage] andBase:nil andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {

                    }];
            }
                break;
                case 3:
            {
                
            }
                break;
            default:
                break;
        }
        
        if(indexPath.row != 3)
        {
            if(![self getValue:@"detail"])
            {
                [self addValue:@"1" andKey:@"detail"];
            }
            else
            {
                int k = [[self getValue:@"detail"] intValue] + 1 ;

                [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"detail"];
            }

            if([[self getValue:@"detail"] intValue] % 4 == 0)
            {
                [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
            }
        }
        
        [self didPressCover:nil];
    }
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return dataList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    [((UIImageView*)[self withView:cell tag:11]) sd_setImageWithURL:[NSURL URLWithString:[((NSString*)dataList[indexPath.item][@"image"]) encodeUrl]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) return;
        if (image && cacheType == SDImageCacheTypeNone)
        {
            [UIView transitionWithView:((UIImageView*)[self withView:cell tag:11])
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [((UIImageView*)[self withView:cell tag:11]) setImage:image];
                            } completion:NULL];
        }
    }];
    
    ((UIView*)[self withView:cell tag:16]).hidden = ![[System getValue:@"s_option"] boolValue];
    
    ((UIView*)[self withView:cell tag:16]).alpha = [dataList[indexPath.item][@"isSelected"] boolValue] ? 0 : 0.5 ;
    
    [((UIImageView*)[self withView:cell tag:11]) withBorder:@{@"Bcorner":@(0),@"Bwidth": @(1),@"Bhex": @"#FFFFFF"}];
    
    NSArray * data = [System getFormat:@"key=%@" argument:@[dataList[indexPath.item][@"image"]]];
    
    ((UIImageView*)[self withView:cell tag:12]).alpha = data.count == 0 ? 0 : 1.0;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(screenWidth / 2 - 0.0, screenWidth / 2 - 0.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([[System getValue:@"s_option"] boolValue])
    {
        dataList[indexPath.item][@"isSelected"] = [dataList[indexPath.item][@"isSelected"] boolValue] ? @(0) : @(1);
        
        [collectionView reloadData];
        
        return;
    }
    
    UICollectionViewCell * cell = [_collectionView cellForItemAtIndexPath:indexPath];
    
    NSURL *imageURL = [NSURL URLWithString:dataList[indexPath.item][@"image"]];
    
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    tempImage = [LTRequest sharedInstance].isConnectionAvailable ? image : ((UIImageView*)[self withView:cell tag:11]).image;
    
    tempIndexPath = [NSString stringWithFormat:@"%li",(long)indexPath.item];
    
    [self didPressSideMenu];
    
    CGRect windowRect = [cell convertRect:cell.bounds toView:nil];
    
    windowRect.origin.y -= 64;
    
    start = windowRect;
    
    [self didChangeImagePosition:windowRect isBack:YES];
}

- (void)showAds
{
    if([[self infoPlist][@"showAds"] boolValue])
    {
        [[StartAds sharedInstance] didShowFullAdsWithInfor:@{} andCompletion:^(BannerEvent event, NSError *error, id bannerAd) {
            switch (event)
            {
                case AdsDone:
                {
                    
                }
                    break;
                case AdsFailed:
                {
                    
                }
                    break;
                case AdsWillPresent:
                {
                    
                }
                    break;
                case AdsWillLeave:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        [self showSVHUD:@"Photo not saved, please check for Gallery permission in Settings" andOption:2];
    }
    else
    {
        [self showSVHUD:@"Photo saved" andOption:1];
        
        [System addValue:(__bridge NSString*)contextInfo andKey:(__bridge NSString*)contextInfo];
        
        [collectionView reloadData];
    }
}

-(void)didChangeImagePosition:(CGRect)rect isBack:(BOOL)back
{
    UIImageView * temp = [[UIImageView alloc] initWithFrame:rect];
    [temp withBorder:@{}];
    temp.contentMode = UIViewContentModeScaleAspectFill;
    temp.backgroundColor = [self.title isEqualToString:@"Meme"] ? [AVHexColor colorWithHexString:@"#DDEFFA"] : [UIColor clearColor];
    temp.image = tempImage;
    
    if(back)
    {
        [self.view addSubview:preview];
        [self.view addSubview:temp];
    }
    
    CGRect destination = [preview convertRect:preview.bounds toView:nil];
    
    destination.origin.y -= 64;
    
    [UIView animateWithDuration:0.3 animations:^{
        if(back)
        {
            temp.transform = [self translatedAndScaledTransformUsingViewRect:back ? destination : rect fromRect: back ? rect : destination];
        }
        else
        {
            preview.transform = [self translatedAndScaledTransformUsingViewRect:back ? destination : rect fromRect: back ? rect : destination];
        }
    }
                     completion:^(BOOL finished){
                         if(back)
                         {
                             [temp removeFromSuperview];
                             preview.image = tempImage;
                             [preview withBorder:@{}];
                             preview.backgroundColor = [self.title isEqualToString:@"Meme"] ? [AVHexColor colorWithHexString:@"#DDEFFA"] : [UIColor clearColor];
                         }
                         else
                         {
                             [preview removeFromSuperview];
                             preview = [self returnImage:CGRectMake(15, (screenHeight - (screenWidth - (screenWidth * sideRatio)) - 30) / 2 - 15 , (screenWidth - (screenWidth * sideRatio)) - 30 , (screenWidth - (screenWidth * sideRatio)) - 30)];
                         }
                         self.navigationItem.leftBarButtonItem.enabled = !back;
                         self.navigationItem.rightBarButtonItem.enabled = !back;

                     }];
}

- (CGAffineTransform)translatedAndScaledTransformUsingViewRect:(CGRect)viewRect fromRect:(CGRect)fromRect
{
    CGSize scales = CGSizeMake(viewRect.size.width/fromRect.size.width, viewRect.size.height/fromRect.size.height);
    CGPoint offset = CGPointMake(CGRectGetMidX(viewRect) - CGRectGetMidX(fromRect), CGRectGetMidY(viewRect) - CGRectGetMidY(fromRect));
    return CGAffineTransformMake(scales.width, 0, 0, scales.height, offset.x, offset.y);
}

- (void)pulse:(UIView*)view toSize: (float) value withDuration:(float) duration
{
    [UIView animateWithDuration:duration
                     animations:^{
                         CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                         pulseAnimation.duration = duration;
                         pulseAnimation.toValue = [NSNumber numberWithFloat:value];;
                         pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                         pulseAnimation.autoreverses = YES;
                         pulseAnimation.repeatCount = 1;
                         [view.layer addAnimation:pulseAnimation forKey:nil];
                     }
                     completion:^(BOOL finished)
     {
     }];
}

- (NSString *)uuidString
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end


