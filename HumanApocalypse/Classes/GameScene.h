#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GamePad.h"
#import "Zombie.h"
#import "Human.h"

@interface GameScene : CCScene <GamePadDelegate, HumanDelegate>{
}

+ (GameScene *)scene;
- (id)init;

@end
