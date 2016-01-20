//
//  HACustomLabel.m
//  QUIZ_APP
//
//  Created by Pavithra Satish on 09/02/15.
//  Copyright (c) 2015 Heaven Apps. All rights reserved.
//

#import "HACustomLabel.h"

@implementation HACustomLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [HAUtilities setAppTextColorForLabel:self];
    }
    return self;
}

-(void)awakeFromNib
{
    //    [super awakeFromNib];
    [HAUtilities setAppTextColorForLabel:self];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [HAUtilities setAppTextColorForLabel:self];
    }
    return self;
}
@end
