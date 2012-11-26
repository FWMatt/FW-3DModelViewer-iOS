//
//  ViewController.m
//  ColourTest
//
//  Created by Tim Chilvers on 23/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "ViewController.h"

#define kColorOn 0.4f
#define kColorMod 1.3f

@interface ViewController ()

@property (nonatomic, retain) NSArray *colors;

@end

@implementation ViewController

- (void)loadView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.dataSource = self;
    self.view = tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.colors.count;
}

- (NSArray *)colors {
    if (!self->_colors) {
        self->_colors = @[
        [UIColor colorWithRed:kColorOn      green:0.0f          blue:0.0f           alpha:1.0f],
        [UIColor colorWithRed:kColorOn      green:kColorOn      blue:0.0f           alpha:1.0f],
        [UIColor colorWithRed:kColorOn      green:kColorOn      blue:kColorOn       alpha:1.0f],
        [UIColor colorWithRed:0.0f          green:kColorOn      blue:kColorOn       alpha:1.0f],
        [UIColor colorWithRed:0.0f          green:kColorOn      blue:0.0f           alpha:1.0f],
        [UIColor colorWithRed:0.0f          green:0.0f          blue:kColorOn       alpha:1.0f], //388bc0
        [UIColor colorWithRed:54.0f/255.0f green:140.0f/255.0f  blue:191.0f/255.0f  alpha:1.0f]
        ];
    }
    return self->_colors;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"colors"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"colors"];
    }
    UIColor *color = [self.colors objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = color;
    cell.textLabel.backgroundColor = color;
    cell.textLabel.text = @"Stuff";
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    cell.textLabel.textColor = [UIColor colorWithRed:red * kColorMod green:green * kColorMod blue:blue * kColorMod alpha:alpha];
    cell.textLabel.shadowColor = [UIColor darkGrayColor];
    return cell;
}

@end
