//
//  ObjectListViewController.m
//  dwo
//
//  Created by Guntis Treulands on 16/11/13.
//  Copyright (c) 2013 Guntis Treulands. All rights reserved.
//

#import "ObjectListViewController.h"

#import "LInteractionViewController.h"

#import "AppDelegate.h"


@implementation ObjectListViewController

#pragma mark - view appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"3D Objects"];
    
    [self setUpTableView];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self deselectSelectedRow];
}

#pragma mark - set up elements

- (void)setUpTableView
{
    _tableView = [UITableView new];
    
    [_tableView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
    
    [_tableView setFrame:self.view.bounds];
    
    [_tableView setDelegate:self];
    
    [_tableView setDataSource:self];
    
    [_tableView setRowHeight:50];
    
    [[self view] addSubview:_tableView];
}

#pragma mark - tableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[_AppDelegate objectArray] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mObjectsCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mObjectsCell"];
        
        [self configureCell:cell atIndexPath:indexPath];                                
    }
    
    [self updateCell:cell atIndexPath:indexPath];     
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{   
    // Title label
    UILabel *mCellTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    [mCellTitleLabel setFont:[UIFont systemFontOfSize:15]];
    
    [mCellTitleLabel setTextAlignment:NSTextAlignmentLeft];
    
    [mCellTitleLabel setBackgroundColor:[UIColor clearColor]];
    
    [mCellTitleLabel setTextColor:[UIColor blackColor]];
    
    [mCellTitleLabel setHighlightedTextColor:[UIColor whiteColor]];
    
    [mCellTitleLabel setNumberOfLines:0];
    
    [mCellTitleLabel setTag:1];
    
    [[cell contentView] addSubview:mCellTitleLabel];
}               


- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{
	DLog();

    // Cell title
    UILabel *mCellTitleLabel = (UILabel *)[cell viewWithTag:1];
    
    [mCellTitleLabel setFrame:CGRectMake(15, 5, self.view.frame.size.width-30, 40)];
    
    [mCellTitleLabel setText:[[[_AppDelegate objectArray] objectAtIndex:[indexPath row]] objectAtIndex:0]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DLog();

    LInteractionViewController *mLInteractionViewController = [[LInteractionViewController alloc]
        initWithObjectIndex:[indexPath row]];
    
    [[self navigationController] presentViewController:mLInteractionViewController animated:YES completion:nil];
}


- (void)deselectSelectedRow
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}


@end
