/**
 * Copyright (c) 2014-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */
@class YGLayout;

@protocol Yoga

/**
 The YGLayout that is attached to a view. It is lazily created.
 */
- (YGLayout *) yoga;

/**
 Indicates whether or not Yoga is enabled
 */
@property(nonatomic, readonly, assign) BOOL isYogaEnabled;

@end

