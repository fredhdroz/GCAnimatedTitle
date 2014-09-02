//
//  ViewController.m
//  AnimatedTitle
//
//  Created by Guillaume CASTELLANA on 19/6/14.
//  Copyright (c) 2014 Guillaume CASTELLANA. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSMutableAttributedString *title1 = [[NSMutableAttributedString alloc] initWithString:@"Intercom"];
	[title1 addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,5)];
	
    [self.titleBar createLabelsFromTitles: @[title1, @"Inbox", @"Important", @"Upcomming"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didChangeSliderValue:(UISlider*)sender
{
    [self.titleBar scrollTo:sender.value];
}

@end
