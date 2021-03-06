    //
//  TabBarVCDemoViewController.m
//  PlutoLand
//
//  Created by xhan on 10-7-22.
//  Copyright 2010 ixHan.com. All rights reserved.
//

#import "TabBarVCDemoViewController.h"
#import "SegmentDemoViewController.h"

#import "UIViewAdditions.h"

/////////////////////////////////////////////////////////////////////////////////////


@interface DemoColorfulVC : UIViewController
{
	UIColor* bgColor;
}
@property(nonatomic,retain) UIColor* bgColor;

- (id)initWithColor:(UIColor*)color;

@end

@implementation DemoColorfulVC

@synthesize bgColor;

- (id)initWithColor:(UIColor*)color
{
	self =  [super init];
	self.bgColor = color;
	return self;
}

- (void)loadView
{
//	NSLog(@"load View");
	[super loadView];
	self.view.backgroundColor = self.bgColor;
//	self.title = [self.bgColor description];
	//self.tabBarItem.badgeValue = @"5";
//	self.tabBarItem.title = nil;
	self.navigationItem.title = [self.bgColor description];
}



@end

/////////////////////////////////////////////////////////////////////////////////////


@implementation TabBarVCDemoViewController


- (id)init
{
	NSMutableArray* vcArray = [NSMutableArray array];
	for (int i = 0; i <4; i++) {
		UIColor* color = [UIColor colorWithWhite:i*0.25 alpha:1];
		[vcArray addObject:[[[DemoColorfulVC alloc] initWithColor:color] autorelease]];
	} 
#ifdef USING_UITABBAR_CONTROLLER_SUBCLASS
	self = [super init];
	self.title = @"fixed tabBar";
	self.viewControllers = vcArray;
	self.tabBarView = [SegmentDemoViewController segmentDemo1TabBar];
	
#else	
	self = [super initWithTabBar:[SegmentDemoViewController segmentDemo1TabBar] viewControllers:vcArray];	
	self.title = @"origin tabBar";
	self.tabBarView.bottom = 480 - 44 - 20;
	self.selectedIndex = 1;
#endif
	return self;
}



- (void)dealloc {
    [super dealloc];
}


@end
