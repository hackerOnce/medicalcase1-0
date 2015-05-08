//
//  WLKCase.m
//  MedCase
//
//  Created by ihefe36 on 14/12/31.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import "WLKCase.h"
#import "WLKPatient.h"

@implementation WLKCase
- (void)setPatient:(WLKPatient *)patient
{
    if (patient) {
        _patient = patient;
        [_patient addCase:self];
    }
}
@end
