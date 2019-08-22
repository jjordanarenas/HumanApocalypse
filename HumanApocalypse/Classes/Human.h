#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCAnimation.h"

typedef enum {
    humanStateStill = 0,
    humanStateWalking,
    humanStateHitting,
    humanStateDamaged
} HumanStates;

typedef enum {
    grandma = 0,
    businessman
} HumanType;

typedef enum {
    humanDecisionStill = 0,
    humanDecisionWalk,
    humanStateRun
} HumanDecisions;

@class Human;
// Protocol to implement the human behavior
@protocol HumanDelegate <NSObject>
- (void) decideWalkToPosition:(CGPoint)position human:(Human *)human;
- (void) decideAttackToZombieHuman:(Human *)human;
- (void) decideStayStillHuman:(Human *)human;
@end

@interface Human : CCNode {
}

// Properties to store the sprite and life points
@property (readwrite, nonatomic) int lifePoints;
@property (readwrite, nonatomic) CCSprite *humanSprite;

// Properties for the state, type and decision
@property (readwrite, nonatomic) HumanStates *state;
@property (readwrite, nonatomic) HumanType *humanType;
@property (readwrite, nonatomic) HumanDecisions *decision;

// Properties for each human action
@property (readonly, nonatomic) CCActionAnimate *actionStill;
@property (readonly, nonatomic) CCActionRepeatForever *actionWalk;
@property (readonly, nonatomic) CCActionAnimate *actionHit;

// Declare init method
- (Human *) initHumanWithType:(HumanType)humanType;
// Declare custom method to set the position
- (void) setPosition:(CGPoint)position;

@end
