//
//  BaseDefine.h
//  AppFramework
//
//  Created by bjb on 2019/3/26.
//  Copyright © 2019 cheshikeji. All rights reserved.
//

#ifndef BaseDefine_h
#define BaseDefine_h

#ifdef DEBUG  // 开发阶段

#define BASELog(...) NSLog(__VA_ARGS__)

#else    // 发布阶段

#define BASELog(...)

#endif


#endif /* BaseDefine_h */
