#import "Zombie.h"

// Number of walk animation frames
#define NUM_WALK_FRAMES 6

// Number of hit animation frames
#define NUM_HIT_FRAMES 5

@implementation Zombie

- (Zombie *) initZombie {
    self = [super init];
    if (!self) return(nil);
    
    // Initialize zombie sprite
    _zombieSprite = [[CCSprite alloc ] initWithImageNamed:@"HumanApocalypseAtlas/zombie.png"];
    _zombieSprite.anchorPoint = CGPointMake(0.5, 0.5);
    
    // Set content size
    self.contentSize = CGSizeMake(_zombieSprite.contentSize.width, _zombieSprite.contentSize.height);
    
    // Set initial state
    _state = stateStill;
    
    // Initialize life points
    _lifePoints = 15;
    
    // Add sprite to zombie
    [self addChild:_zombieSprite];
    
    // Initialize an array of frames
    NSMutableArray *zombieWalkFrames = [NSMutableArray arrayWithCapacity: NUM_WALK_FRAMES];
    
    for (int i = 0; i < NUM_WALK_FRAMES; i++) {
        // Create a sprite frame
        CCSpriteFrame *zombieWalkFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"HumanApocalypseAtlas/zombie_walk_%i.png", i]];
        
        // Add sprite frame to the array
        [zombieWalkFrames addObject:zombieWalkFrame];
    }
    
    // Create an animation with the array of frames
    CCAnimation *zombieWalkAnimation = [CCAnimation animationWithSpriteFrames:zombieWalkFrames delay:0.2];
    
    // Create an animate action with the animation
    CCActionAnimate *zombieWalkAction = [CCActionAnimate actionWithAnimation:zombieWalkAnimation];
    
    // Create walk action
    _actionWalk = [CCActionRepeatForever actionWithAction:zombieWalkAction];
    
    // Create walk action
    _actionRun = [CCActionRepeatForever actionWithAction:zombieWalkAction];
    
    // Initialize an array of frames
    NSMutableArray *zombieHitFrames = [NSMutableArray arrayWithCapacity: NUM_HIT_FRAMES];
    
    for (int i = 0; i < NUM_HIT_FRAMES; i++) {
        // Create a sprite frame
        CCSpriteFrame *zombieHitFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"HumanApocalypseAtlas/zombie_hit_%i.png", i]];
        
        // Add sprite frame to the array
        [zombieHitFrames addObject:zombieHitFrame];
    }
    
    // Create an animation with the array of frames
    CCAnimation *zombieHitAnimation = [CCAnimation animationWithSpriteFrames:zombieHitFrames delay:0.1];
    
    // Create an animate action with the animation
    _actionHit = [CCActionAnimate actionWithAnimation:zombieHitAnimation];
    
    // Initialize an array of frames
    NSMutableArray *zombieStillFrames = [NSMutableArray arrayWithCapacity: 1];
    
    // Create a sprite frame
    CCSpriteFrame *zombieStillFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"HumanApocalypseAtlas/zombie.png"];
    
    // Add sprite frame to the array
    [zombieStillFrames addObject:zombieStillFrame];
    
    // Create an animation with the array of frames
    CCAnimation *zombieStillAnimation = [CCAnimation animationWithSpriteFrames:zombieStillFrames delay:0.1];
    
    // Create an animate action with the animation
    _actionStill = [CCActionAnimate actionWithAnimation:zombieStillAnimation];

    return self;
}

@end
