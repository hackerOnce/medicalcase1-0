//
//  CoreDataSyncWithServer.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/6.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "CoreDataSyncWithServer.h"
#import "IHMsgSocket.h"
#import "MessageObject+DY.h"

@interface CoreDataSyncWithServer()
@property (nonatomic,strong) IHMsgSocket *socket;
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *privateContext;

@property (nonatomic,strong) CurrentDoctor *currentDoctor;
@end

@implementation CoreDataSyncWithServer
#pragma mask - core data

-(NSManagedObjectContext *)privateContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = self.coreDataStack.persistentStoreCoordinator;
    return context;
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}
-(CurrentDoctor *)currentDoctor
{
    if (!_currentDoctor) {
        _currentDoctor = [CurrentDoctor currentDoctor];
    }
    return _currentDoctor;
}
#pragma mask - sync dic

#pragma mask - init
-(instancetype)init
{
    self = [super init];
    if (self) {
        [self syncDataToCoreData];
        //[self saveDoctorToCoreDataWithDoctor:self.tempDoctor];
    }
    return self;
}
///save doctor  to managed object

//-(void)saveDoctorToCoreDataWithDoctor:(TempDoctor*)tempDoctor
//{
//    NSString *dept = tempDoctor.dept;
//    NSString *dID = tempDoctor.dID;
//    NSString *dName = tempDoctor.dName;
//    NSString *dProfessionalTitle = tempDoctor.dProfessionalTitle;
//    
//    [self.coreDataStack fetchDoctorWithDic:NSDictionaryOfVariableBindings(dept,dID,dName,dProfessionalTitle) successfulFetched:^(NSArray *resultArray) {
//        
//    } failedToFetched:^(NSError *error, NSString *errorInfo) {
//        abort();
//    }];
//}
//#pragma mask - property init
//
//-(TempDoctor *)tempDoctor
//{
//    if (!_tempDoctor) {
//        NSString *dID = @"88888";
//        NSString *dName = @"测试医生";
//        NSString *dProfessionalTitle = @"小医生";
//        NSString *dept = @"心内科";
//        NSString *medicalTeam = @"无";
//        _tempDoctor = [[TempDoctor alloc] initWithTempDoctorDic:NSDictionaryOfVariableBindings(dID,dName,dProfessionalTitle,dept,medicalTeam)];
//    }
//    return _tempDoctor;
//}
#pragma mask - socket
-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"didSyncFlag"];

        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
}
-(void)syncDataToCoreData
{
    [self.socket connectServerSucess:^(IHMsgSocket *socket) {
        NSLog(@"sucessfull ");
        
        
        BOOL didSyncFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"didSyncFlag"];
        
        if (didSyncFlag) {
            
            NSString *did = self.currentDoctor.dID;
            
            [MessageObject  messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:20000 dictionary:NSDictionaryOfVariableBindings(did) block:^(IHSockRequest *request) {

                NSArray *tempArray;
                if ([request.responseData isKindOfClass:[NSArray class]]) {
                    tempArray = (NSArray*)request.responseData;
                    
                    for (NSDictionary *tempDic in tempArray) {
                        if ([tempDic.allKeys containsObject:@"emrecord"]) {
                            id values = [tempDic objectForKey:@"emrecord"];
                            
                            if ([values isKindOfClass:[NSArray class]] ) {
                                NSArray *tempArray = (NSArray*)values;
                                for (NSDictionary *tempDic in tempArray) {
                                    NSDictionary *dic = [self parseCaseInfoWithDic:tempDic];
//                                    [self.coreDataStack syncServerMedicalCaseWithDataDic:dic inContext:self.privateContext failedToSync:^(NSError *error, NSString *errorInfo) {
//                                        
//                                        if ([self.delegate respondsToSelector:@selector(failureSync)]) {
//                                            [self.delegate failureSync];
//                                        }
//
//                                    } successfulSync:^{
//                                        
//                                    }];
//                                    
                                }
                            }
                        }
                        if ([tempDic.allKeys containsObject:@"emr"]) {
                            id values = [tempDic objectForKey:@"emr"];
                            
                            if ([values isKindOfClass:[NSArray class]]) {
                                
                                NSArray *tempArray = (NSArray*)values;
                                for (NSDictionary *tempDic in tempArray) {
                                    
                                }

                            }
                        }
                    }
                }
            } failConection:^(NSError *error) {
                if ([self.delegate respondsToSelector:@selector(failureSync)]) {
                    [self.delegate failureSync];
                }
            }];
            
            /// 保存到core data
//            [self.coreDataStack saveContext:self.privateContext failedToSync:^(NSError *error, NSString *errorInfo) {
//                
//                if ([self.delegate respondsToSelector:@selector(failureSync)]) {
//                    [self.delegate failureSync];
//                }
//
//                
//            } successfulSync:^{
//                if ([self.delegate respondsToSelector:@selector(successfulSync)]) {
//                    [self.delegate successfulSync];
//                }
//            }];
            
        }
        
    } failConection:^(NSError *error) {
        
        if ([self.delegate respondsToSelector:@selector(failureSync)]) {
            [self.delegate failureSync];
        }

    }];
}
-(NSDictionary*)parseTemplateWithDic:(NSDictionary*)dataDic
{
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];

    
    return tempDic;
}
-(NSDictionary*)parseCaseInfoWithDic:(NSDictionary*)dataDic
{
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    
    if ([dataDic.allKeys containsObject:@"_DOF"]) {
        [tempDic setObject:dataDic[@"_DOF"] forKey:@"archivedTime"];
    }
    if ([dataDic.allKeys containsObject:@"_created"]) {
        [tempDic setObject:dataDic[@"_created"] forKey:@"createdTime"];
    }
    if ([dataDic.allKeys containsObject:@"_id"]) {
        [tempDic setObject:dataDic[@"_id"] forKey:@"caseID"];
    }
    
    if ([dataDic.allKeys containsObject:@"_updated"]) {
        [tempDic setObject:dataDic[@"_updated"] forKey:@"updatedTime"];
    }
    if ([dataDic.allKeys containsObject:@"caseBaseInfo"]) {
        
        NSDictionary *dic = dataDic[@"caseBaseInfo"];
        
        if ([dic.allKeys containsObject:@"caseContent"]) {
            [tempDic setObject:dic[@"caseContent"]forKey:@"caseContent"];
        }
    }
    if ([dataDic.allKeys containsObject:@"caseState"]) {
        [tempDic setObject:dataDic[@"caseState"] forKey:@"caseState"];
    }
    if ([dataDic.allKeys containsObject:@"caseType"]) {
        [tempDic setObject:dataDic[@"caseType"] forKey:@"caseType"];
    }
    
    if ([dataDic.allKeys containsObject:@"doctor"]) {
        NSDictionary *doctor = dataDic[@"doctor"];
        if ([doctor.allKeys containsObject:@"attendingPhysicianDoctorID"]) {
            [tempDic setObject:doctor[@"attendingPhysicianDoctorID"] forKey:@"attendingPhysicianDoctorID"];
        }
        if ([doctor.allKeys containsObject:@"attendingPhysicianDoctorName"]) {
            [tempDic setObject:doctor[@"attendingPhysicianDoctorName"] forKey:@"attendingPhysicianDoctorName"];
        }
        
        if ([doctor.allKeys containsObject:@"chiefPhysicianDoctorID"]) {
            [tempDic setObject:doctor[@"chiefPhysicianDoctorID"] forKey:@"chiefPhysicianDoctorID"];
        }
        if ([doctor.allKeys containsObject:@"chiefPhysicianDoctorName"]) {
            [tempDic setObject:doctor[@"chiefPhysicianDoctorName"] forKey:@"chiefPhysicianDoctorName"];
        }

        if ([doctor.allKeys containsObject:@"residentDoctorID"]) {
            [tempDic setObject:doctor[@"residentDoctorID"] forKey:@"residentDoctorID"];
            [tempDic setObject:doctor[@"residentDoctorID"] forKey:@"dID"];
        }
        if ([doctor.allKeys containsObject:@"residentDoctorname"]) {
            [tempDic setObject:doctor[@"residentDoctorname"] forKey:@"residentDoctorname"];
            [tempDic setObject:doctor[@"residentDoctorname"] forKey:@"dName"];
        }

        if ([dataDic.allKeys containsObject:@"submitToDoctorName"]) {
            [tempDic setObject:doctor[@"submitToDoctorName"] forKey:@"submitToDoctorName"];
        }

        
    }
    if ([dataDic.allKeys containsObject:@"patient"]) {
        NSDictionary *patient = dataDic[@"patient"];
        
        if ([patient.allKeys containsObject:@"pAge"]) {
            [tempDic setObject:patient[@"pAge"] forKey:@"pAge"];
        }
        if ([patient.allKeys containsObject:@"pBedNum"]) {
            [tempDic setObject:patient[@"pBedNum"] forKey:@"pBedNum"];
        }
        if ([patient.allKeys containsObject:@"pCity"]) {
            [tempDic setObject:patient[@"pCity"] forKey:@"pCity"];
        }
        if ([patient.allKeys containsObject:@"pCountOfHospitalized"]) {
            [tempDic setObject:patient[@"pCountOfHospitalized"] forKey:@"pCountOfHospitalized"];
        }
        
        if ([patient.allKeys containsObject:@"pDept"]) {
            [tempDic setObject:patient[@"pDept"] forKey:@"pDept"];
        }
        if ([patient.allKeys containsObject:@"pDetailAddress"]) {
            [tempDic setObject:patient[@"pDetailAddress"] forKey:@"pDetailAddress"];
        }
        if ([patient.allKeys containsObject:@"pGender"]) {
            [tempDic setObject:patient[@"pGender"] forKey:@"pGender"];
        }
        if ([patient.allKeys containsObject:@"pID"]) {
            [tempDic setObject:patient[@"pID"] forKey:@"pID"];
        }
      
        if ([patient.allKeys containsObject:@"pLinkman"]) {
            [tempDic setObject:patient[@"pLinkman"] forKey:@"pLinkman"];
        }
        if ([patient.allKeys containsObject:@"pLinkmanMobileNum"]) {
            [tempDic setObject:patient[@"pLinkmanMobileNum"] forKey:@"pLinkmanMobileNum"];
        }
        if ([patient.allKeys containsObject:@"pMaritalStatus"]) {
            [tempDic setObject:patient[@"pMaritalStatus"] forKey:@"pMaritalStatus"];
        }
        
        if ([patient.allKeys containsObject:@"pMobileNum"]) {
            [tempDic setObject:patient[@"pMobileNum"] forKey:@"pMobileNum"];
        }
        if ([patient.allKeys containsObject:@"pName"]) {
            [tempDic setObject:patient[@"pName"] forKey:@"pName"];
        }
        if ([patient.allKeys containsObject:@"pNation"]) {
            [tempDic setObject:patient[@"pNation"] forKey:@"pNation"];
        }

        if ([patient.allKeys containsObject:@"pProfession"]) {
            [tempDic setObject:patient[@"pProfession"] forKey:@"pProfession"];
        }
        if ([patient.allKeys containsObject:@"pProvince"]) {
            [tempDic setObject:patient[@"pProvince"] forKey:@"pProvince"];
        }
        if ([patient.allKeys containsObject:@"patientState"]) {
            [tempDic setObject:patient[@"patientState"] forKey:@"patientState"];
        }

        if ([patient.allKeys containsObject:@"presenter"]) {
            [tempDic setObject:patient[@"presenter"] forKey:@"presenter"];
        }
        
    }

    return tempDic;
}
@end
