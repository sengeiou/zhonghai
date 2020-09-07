/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXEANManufacturerOrgSupport.h"
#import "ZXEANManufacturerOrgSupportTest.h"

@implementation ZXEANManufacturerOrgSupportTest

- (void)testEncode {
  ZXEANManufacturerOrgSupport *support = [[ZXEANManufacturerOrgSupport alloc] init];
  XCTAssertNil([support lookupCountryIdentifier:@"472000"]);
  XCTAssertEqualObjects(@"US/CA", [support lookupCountryIdentifier:@"000000"]);
  XCTAssertEqualObjects(@"MO", [support lookupCountryIdentifier:@"958000"]);
  XCTAssertEqualObjects(@"GB", [support lookupCountryIdentifier:@"500000"]);
  XCTAssertEqualObjects(@"GB", [support lookupCountryIdentifier:@"509000"]);
}

@end
