#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCAnimation.h"

typedef enum {
    stateStill = 0,
    stateWalking,
    stateRunning,
    stateHitting
} ZombieStates;

@interface Zombie : CCNode {
}

@property (readwrite, nonatomic) int lifePoints;
@property (readwrite, nonatomic) ZombieStates *state;
@property (readwrite, nonatomic) CCSprite *zombieSprite;
@property (readonly, nonatomic) CCActionAnimate *actionStill;
@property (readonly, nonatomic) CCActionRepeatForever *actionWalk;
@property (readonly, nonatomic) CCActionRepeatForever *actionRun;
@property (readonly, nonatomic) CCActionAnimate *actionHit;

// Declare init method
- (Zombie *) initZombie;
@end
