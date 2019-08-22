//
//  HomeCategoryTableViewCell.m
//  TheMiss
//
//  Created by lion on 6/20/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "HomeCategoryTableViewCell.h"
#import "Utils.h"
#import "Constants.h"

@implementation HomeCategoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self updateRemainTime];
    
    //display current month
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
    _monthLabel.text = [[Utils getMonthName:components.month] uppercaseString];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void) displayRemainTime:(NSString *)time{
//    _remainTimeLabel.text = @"kgs";
//}

- (void) selectButton:(int) category{
    
    [self initCategoryButtons];
    
    switch (category) {
        case SELECT_HOME_LASTPICTURES:
            _lastPicturesButton.backgroundColor = UIColorFromRGB(MAIN_RED_COLOR);
            [_lastPicturesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _missOfMonthButton.backgroundColor = [UIColor whiteColor];
            [_missOfMonthButton setTitleColor:UIColorFromRGB(MAIN_RED_COLOR) forState:UIControlStateNormal];
            _theWinnersButton.backgroundColor = [UIColor whiteColor];
            [_theWinnersButton setTitleColor:UIColorFromRGB(MAIN_RED_COLOR) forState:UIControlStateNormal];

            _timeView.hidden = FALSE;
            _displayModeView.hidden = FALSE;
            
            break;
            
        case SELECT_HOME_MISSOFMONTH:
            _lastPicturesButton.backgroundColor = [UIColor whiteColor];
            [_lastPicturesButton setTitleColor:UIColorFromRGB(MAIN_RED_COLOR) forState:UIControlStateNormal];
            _missOfMonthButton.backgroundColor = UIColorFromRGB(MAIN_RED_COLOR);
            [_missOfMonthButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _theWinnersButton.backgroundColor = [UIColor whiteColor];
            [_theWinnersButton setTitleColor:UIColorFromRGB(MAIN_RED_COLOR) forState:UIControlStateNormal];
            
            _timeView.hidden = FALSE;
            _displayModeView.hidden = FALSE;
            
            break;
            
        case SELECT_HOME_WINNERS:
            _lastPicturesButton.backgroundColor = [UIColor whiteColor];
            [_lastPicturesButton setTitleColor:UIColorFromRGB(MAIN_RED_COLOR) forState:UIControlStateNormal];
            _missOfMonthButton.backgroundColor = [UIColor whiteColor];
            [_missOfMonthButton setTitleColor:UIColorFromRGB(MAIN_RED_COLOR) forState:UIControlStateNormal];
            _theWinnersButton.backgroundColor = UIColorFromRGB(MAIN_RED_COLOR);
            [_theWinnersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            _timeView.hidden = TRUE;
            _displayModeView.hidden = TRUE;
            
            break;
            
        default:
            break;
    }
    
}

- (void) selectMode:(int) mode{
    
    switch (mode) {
        case LIST_MODE:
            [_listModeButton setBackgroundImage:nil forState:UIControlStateNormal];
            [_gridModeButton setBackgroundImage:[UIImage imageNamed:@"home_mode_bg"] forState:UIControlStateNormal];
            break;
            
        case GRID_MODE:
            [_listModeButton setBackgroundImage:[UIImage imageNamed:@"home_mode_bg"] forState:UIControlStateNormal];
            [_gridModeButton setBackgroundImage:nil forState:UIControlStateNormal];
            break;
    }
}

- (void) initCategoryButtons{
    _lastPicturesButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _lastPicturesButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_lastPicturesButton setTitle:LocalizedString(@"home_last_pictures") forState:UIControlStateNormal];
    
    _missOfMonthButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _missOfMonthButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_missOfMonthButton setTitle:LocalizedString(@"home_miss_of_month") forState:UIControlStateNormal];
    
    _theWinnersButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _theWinnersButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_theWinnersButton setTitle:LocalizedString(@"home_the_winners") forState:UIControlStateNormal];
}

- (void) updateRemainTime{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date] toDate:[Utils getLastDayOfMonth] options:0];
         
    _remainTimeLabel.text = [NSString stringWithFormat:@"%02i:%02i:%02i:%02i", components.day, components.hour, components.minute, components.second];
    
    [self performSelector:@selector(updateRemainTime) withObject:self afterDelay:1.0f];
}

@end
