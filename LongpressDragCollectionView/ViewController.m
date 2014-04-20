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
    
    NSArray *_colors;
    
    __weak IBOutlet UIView *_targetView;
    __weak IBOutlet UIView *_panView;
    UIPanGestureRecognizer *_targetViewPanGestureRecognizer;
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
    
    // 操作用ターゲットを追加
    _targetViewPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(firePan:)];
    _targetViewPanGestureRecognizer.delegate = self;
    [_targetView addGestureRecognizer:_targetViewPanGestureRecognizer];
}

- (void) firePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    NSLog(@"firePan: call");
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint location = [_targetViewPanGestureRecognizer locationInView:_targetView];
            
            for( UIView *subview in _targetView.subviews ){
                if( CGRectContainsPoint(subview.frame, location) ){
                    _panView = subview;
                    break;
                }
            }
        }
            break;
        default:
            break;
    }
    
    
    CGPoint translation = [gestureRecognizer translationInView:_targetView];
    
    CGPoint center = CGPointMake(_panView.center.x + translation.x, _panView.center.y + translation.y);
    
    CGPoint oldCenter = _panView.center;
    _panView.center = center;
    [gestureRecognizer setTranslation:CGPointZero inView:self.view];
    
#define SAFETY_MARGINE_EDGE 25.0f
    CGPoint points[] = {
                         CGPointMake(CGRectGetMinX(_panView.frame) + SAFETY_MARGINE_EDGE,CGRectGetMinY(_panView.frame) + SAFETY_MARGINE_EDGE)
                        ,CGPointMake(CGRectGetMaxX(_panView.frame) - SAFETY_MARGINE_EDGE,CGRectGetMinY(_panView.frame) + SAFETY_MARGINE_EDGE)
                        ,CGPointMake(CGRectGetMaxX(_panView.frame) - SAFETY_MARGINE_EDGE,CGRectGetMaxY(_panView.frame) - SAFETY_MARGINE_EDGE)
                        ,CGPointMake(CGRectGetMinX(_panView.frame) + SAFETY_MARGINE_EDGE,CGRectGetMaxY(_panView.frame) - SAFETY_MARGINE_EDGE)
                        };
    
    CGRect hitTestRect = (CGRect){ CGPointZero , _targetView.frame.size};
    if( CGRectContainsPoint(hitTestRect, points[0]) != YES && CGRectContainsPoint(hitTestRect, points[01]) != YES && CGRectContainsPoint(hitTestRect, points[2]) != YES && CGRectContainsPoint(hitTestRect, points[3]) != YES){
        
        _panView.center = oldCenter;
        _targetViewPanGestureRecognizer.enabled = NO;
        _targetViewPanGestureRecognizer.enabled = YES;
    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            _panView = nil;
        }
            break;
        default:
            break;
    }
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
                                         appendView.alpha = 1.0f;
                                         appendView.transform = CGAffineTransformIdentity;
                                     }
                                     completion:^(BOOL finished) {

                                     }];
                }else{
                    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _currentView.alpha = .0f;
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
    
    if( [_targetViewPanGestureRecognizer isEqual:gestureRecognizer] ){
        CGPoint location = [_targetViewPanGestureRecognizer locationInView:_targetView];
        
        for( UIView *subview in _targetView.subviews ){
            if( CGRectContainsPoint(subview.frame, location) ){
                return YES;
            }
        }
        return NO;
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

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectionView: didSelectItemAtIndexPath: call");
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIView *itemView = [cell viewWithTag:100];
    
    CGRect frame = [self.view convertRect:itemView.frame fromView:cell];
    UIView* appendView = [[UIView alloc] initWithFrame:frame];
    appendView.backgroundColor = itemView.backgroundColor;
    appendView.center = CGPointMake(_targetView.frame.size.width * .5f, _targetView.frame.size.height * .5f);
    
    [_targetView addSubview:appendView];
    
    
}


@end
