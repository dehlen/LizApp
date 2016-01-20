//
//  HACategoryTableViewCell.m
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 13/08/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import "HACategoryTableViewCell.h"




@implementation HACategoryTableViewCell

-(void)awakeFromNib
{
    CGRect rect = self._progressView.frame;
    rect.size.height = 4.0;
    self._progressView.frame = rect;
    [self._buyButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
