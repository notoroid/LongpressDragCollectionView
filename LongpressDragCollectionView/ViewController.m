//
//  ViewController.m
//  SimplePanGesture
//
//  Created by 能登 要 on 2014/04/18.
//  Copyright (c) 2014年 purchase.and.advertising. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate>
{
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    UIPanGestureRecognizer *_panGestureRecognizer;
    NSIndexPath *_selectedItemIndexPath;
    __weak IBOutlet UICollectionView *_collectionView;
    UIView *_currentView;
    CGPoint _panTranslationInCollectionView;
    __weak IBOutlet UIView *_targetView;
    
    NSArray *_colors;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    _longPressGestureRecognizer.delegate = self;
    
    // Links the default long press gesture recognizer to the custom long press gesture recognizer we are creating now
    // by enforcing failure dependency so that they doesn't clash.
    for (UIGestureRecognizer *gestureRecognizer in _collectionView.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gestureRecognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
        }
    }
    
    [_collectionView addGestureRecognizer:_longPressGestureRecognizer];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handlePanGesture:)];
    _panGestureRecognizer.delegate = self;
    [_collectionView addGestureRecognizer:_panGestureRecognizer];
    
    _colors = @[ [UIColor redColor],[UIColor blueColor],[UIColor greenColor],[UIColor yellowColor]
                ,[UIColor cyanColor],[UIColor magentaColor],[UIColor brownColor]
                ,[UIColor purpleColor]
                , [UIColor redColor],[UIColor blueColor],[UIColor greenColor],[UIColor yellowColor]
                ,[UIColor cyanColor],[UIColor magentaColor],[UIColor brownColor]
                ,[UIColor purpleColor]
                ];
    
    
    [_collectionView reloadData];
    
    // Useful in multiple scenarios: one common scenario being when the Notification Center drawer is pulled down
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActive:) name: UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - Notifications

- (void)handleApplicationWillResignActive:(NSNotification *)notification {
    _panGestureRecognizer.enabled = NO;
    _panGestureRecognizer.enabled = YES;
}


- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    NSLog(@"handleLongPressGesture: call");
    
    switch(gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *currentIndexPath = [_collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:_collectionView]];
            
            _selectedItemIndexPath = currentIndexPath;
            
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:_selectedItemIndexPath];
            UIView *itemView = [cell viewWithTag:100];
            
            CGRect frame = [self.view convertRect:itemView.frame fromView:cell];
            _currentView = [[UIView alloc] initWithFrame:frame];
            _currentView.backgroundColor = itemView.backgroundColor;
            _currentView.alpha = .8;
            
            _currentView.transform = CGAffineTransformMakeScale(1.1f,1.1f);
            
            [self.view addSubview:_currentView];
            
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            NSIndexPath *currentIndexPath = _selectedItemIndexPath;
            
            if (currentIndexPath) {
                _selectedItemIndexPath = nil;
                
                if( CGRectContainsPoint(_targetView.frame,_currentView.center) ){
                    UIView* appendView = _currentView;
                    _currentView = nil;
                    
                    
                    CGPoint center = [_targetView convertPoint:appendView.center fromView:self.view];
                    [appendView removeFromSuperview];
                    appendView.center = center;
                    [_targetView addSubview:appendView];
                    
                    
                    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState
                                     animations:^{
                                         appendView.transform = CGAffineTransformIdentity;
                                     }
                                     completion:^(BOOL finished) {

                                     }];
                }else{
                    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _currentView.alpha = .01;
                         }
                     completion:^(BOOL finished) {
                         [_currentView removeFromSuperview];
                         _currentView = nil;
                     }];
                }
            }
        } break;
            
        default: break;
    }
    
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self.view];
    
    CGPoint center = CGPointMake(_currentView.center.x + translation.x, _currentView.center.y + translation.y);
    _currentView.center = center;
    [gestureRecognizer setTranslation:CGPointZero inView:self.view];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([_panGestureRecognizer isEqual:gestureRecognizer]) {
        return (_selectedItemIndexPath != nil);
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([_longPressGestureRecognizer isEqual:gestureRecognizer]) {
        return [_panGestureRecognizer isEqual:otherGestureRecognizer];
    }
    
    if ([_panGestureRecognizer isEqual:gestureRecognizer]) {
        return [_longPressGestureRecognizer isEqual:otherGestureRecognizer];
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellItem" forIndexPath:indexPath];
    
    UIView *itemView = [cell viewWithTag:100];
    itemView.backgroundColor = _colors[indexPath.row];
    
    return cell;
}

@end
