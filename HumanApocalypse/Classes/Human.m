#import "Human.h"

@implementation Human

// Number of walk animation frames
#define NUM_WALK_FRAMES 6

// Number of hit animation frames
#define NUM_HIT_FRAMES 5

- (Human *) initHumanWithType:(HumanType)humanType {
    self = [super init];
    if (!self) return(nil);
    
    NSString *prefix;
    switch (humanType) {
        case grandma:
            // Assign textureName and numHits values
            prefix = @"grandma";
            _lifePoints = 7;
            break;
        case businessman:
            // Assign textureName and numHits values
            prefix = @"businessman";
            _lifePoints = 5;
            break;
        default:
            break;
    }
    
    // Initialize human sprite
    _humanSprite = [[CCSprite alloc ] initWithImageNamed:[NSString stringWithFormat:@"HumanApocalypseAtlas/%@.png", prefix]];
    _humanSprite.anchorPoint = CGPointMake(0.5, 0.5);
    
    // Set content size
    _contentSize = CGSizeMake(_humanSprite.contentSize.width, _humanSprite.contentSize.height);
    
    // Set initial state type and decision
    _state = humanStateStill;
    _humanType = humanType;
    _decision = humanDecisionStill;
    
    // Initialize an array of frames
    NSMutableArray *humanWalkFrames = [NSMutableArray arrayWithCapacity: NUM_WALK_FRAMES];
    
    for (int i = 0; i < NUM_WALK_FRAMES; i++) {
        // Create a sprite frame
        CCSpriteFrame *humanWalkFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"HumanApocalypseAtlas/%@_walk_%i.png", prefix, i]];
        
        // Add sprite frame to the array
        [humanWalkFrames addObject:humanWalkFrame];
    }
    
    // Create an animation with the array of frames
    CCAnimation *humanWalkAnimation = [CCAnimation animationWithSpriteFrames:humanWalkFrames delay:0.2];
    
    // Create an animate action with the animation
    CCActionAnimate *humanWalkAction = [CCActionAnimate actionWithAnimation:humanWalkAnimation];
    
    // Create walk action
    _actionWalk = [CCActionRepeatForever actionWithAction:humanWalkAction];
    // Initialize an array of frames
    NSMutableArray *humanHitFrames = [NSMutableArray arrayWithCapacity: NUM_HIT_FRAMES];
    
    for (int i = 0; i < NUM_HIT_FRAMES; i++) {
        // Create a sprite frame
        CCSpriteFrame *humanHitFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"HumanApocalypseAtlas/%@_hit_%i.png", prefix, i]];
        
        // Add sprite frame to the array
        [humanHitFrames addObject:humanHitFrame];
    }
    
    // Create an animation with the array of frames
    CCAnimation *humanHitAnimation = [CCAnimation animationWithSpriteFrames:humanHitFrames delay:0.1];
    
    // Create an animate action with the animation
    _actionHit = [CCActionAnimate actionWithAnimation:humanHitAnimation];
    
    // Initialize an array of frames
    NSMutableArray *humanStillFrames = [NSMutableArray arrayWithCapacity: 1];
    
    // Create a sprite frame
    CCSpriteFrame *humanStillFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"HumanApocalypseAtlas/%@.png", prefix]];
    
    // Add sprite frame to the array
    [humanStillFrames addObject:humanStillFrame];
    
    // Create an animation with the array of frames
    CCAnimation *humanStillAnimation = [CCAnimation animationWithSpriteFrames:humanStillFrames delay:0.1];
    
    // Create an animate action with the animation
    _actionStill = [CCActionAnimate actionWithAnimation:humanStillAnimation];

    return self;
}

- (void) setPosition:(CGPoint)position {
    _humanSprite.position = position;
    [super setPosition:position];
}

@end