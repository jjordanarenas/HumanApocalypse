#import "GameScene.h"

// Number of human enemies
#define NUM_HUMANS 10

// Number of human types
#define NUM_HUMAN_TYPES 2

// Vertical margin
#define VERTICAL_MARGIN 12
// Speed value
#define HUMAN_SPEED 200

@implementation GameScene{
    // Declare global variable for screen size
    CGSize _screenSize;
    
    // Declare a variable for the zombie
    Zombie *_zombie;

    
    // Declare sprites for the background
    CCSprite *_background0;
    CCSprite *_background1;
    CCSprite *_background2;
    CCSprite *_background3;
    
    // Declare a variable for game pad
    GamePad *_gamePad;

    // Declare global batch node
    CCSpriteBatchNode *_batchNode;

    // Declare array of enemies
    NSMutableArray *_arrayOfHumans;
    // Declare array of killed humans
    NSMutableArray *_humansToDelete;
    
    // Collision flags
    BOOL _humanCollisionDetected;
    BOOL _zombieCollisionDetected;
    
    // Draw nodes to represent life bar
    CCDrawNode *_lifeBarYellow;
    CCDrawNode *_lifeBarRed;

}

+ (GameScene *)scene
{
    return [[self alloc] init];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Load texture atlas
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"humanApocalypse-hd.plist"];
    
    // Load batch node with texture atlas
    _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"humanApocalypse-hd.png"];
    
    // Add the batch node to the scene
    [self addChild:_batchNode];
    
    // Initialize array of enemies
    _arrayOfHumans = [NSMutableArray arrayWithCapacity:NUM_HUMANS];

    // Initialize array of deleted humans
    _humansToDelete = [NSMutableArray arrayWithCapacity:NUM_HUMANS];

    // Initializing the screen size variable
    _screenSize = [CCDirector sharedDirector].viewSize;
    
    // Adding the background images
    _background0.anchorPoint = CGPointMake(0.0, 0.0);
    _background0 = [CCSprite spriteWithImageNamed:@"background0.png"];
    _background0.position = CGPointMake(_background0.contentSize.width / 2, _screenSize.height / 2);
    
    _background1.anchorPoint = CGPointMake(0.0, 0.0);
    _background1 = [CCSprite spriteWithImageNamed:@"background1.png"];
    _background1.position = CGPointMake(_background0.contentSize.width / 2 + _background0.contentSize.width, _screenSize.height / 2);
    
    _background2.anchorPoint = CGPointMake(0.0, 0.0);
    _background2 = [CCSprite spriteWithImageNamed:@"background2.png"];
    _background2.position = CGPointMake(_background0.contentSize.width / 2 + _background0.contentSize.width + _background1.contentSize.width, _screenSize.height / 2);
    
    _background3.anchorPoint = CGPointMake(0.0, 0.0);
    _background3 = [CCSprite spriteWithImageNamed:@"background3.png"];
    _background3.position = CGPointMake(_background0.contentSize.width / 2 + _background0.contentSize.width + _background1.contentSize.width + _background2.contentSize.width, _screenSize.height / 2);
    
    [self addChild:_background0 z:-1];
    [self addChild:_background1 z:-1];
    [self addChild:_background2 z:-1];
    [self addChild:_background3 z:-1];

    // Initialize the main character
    _zombie = [[Zombie alloc] initZombie];
    _zombie.position = CGPointMake(2 * _zombie.contentSize.width, _zombie.contentSize.height);
    [self addChild:_zombie];
    
    // Set radius as the image width
    CGFloat radius = 192;
    CGFloat buttonRadius = 100;
    // Initialize game pad
    _gamePad = [[GamePad alloc] initWithPadRadius:radius buttonRadius:buttonRadius];
    
    // Add the game pad to the scene
    [self addChild:_gamePad];
    
    // Set GameScene as the GamePad delegate
    _gamePad.delegate = self;
    
    // Load enemies
    [self createEnemies];

    _humanCollisionDetected = FALSE;
    _zombieCollisionDetected = FALSE;
    
    _lifeBarYellow = [CCDrawNode node];
    _lifeBarRed = [CCDrawNode node];
    [self createLifeBars];

    return self;
}

- (void)gamePad:(GamePad *)gamePad didChangeDirectionTo:(GamePadDirections)newDirection {
    CGPoint nextPosition = [self calculateNextPosition:newDirection isHeld:FALSE];
	// If zombie is still, running, or hitting
    if ((int)_zombie.state == stateStill || (int)_zombie.state == stateRunning || (int)_zombie.state == stateHitting) {
        
        // Stop actions and init walk action
        [_zombie.zombieSprite stopAllActions];
        _zombie.state = stateWalking;
        [_zombie.zombieSprite runAction:_zombie.actionWalk];
        
    } else if ((int)_zombie.state == stateWalking) {
        // Keep walking
        [self moveWithDirection:nextPosition];
    }

}

- (void)gamePad:(GamePad *)gamePad isHoldingDirection:(GamePadDirections)holdingDirection {
    CGPoint nextPosition = [self calculateNextPosition:holdingDirection isHeld:TRUE];
    // If zombie is still or walking
    if ((int)_zombie.state == stateStill || (int)_zombie.state == stateWalking) {
        
        // Init run action
        _zombie.state = stateRunning;
        [_zombie.zombieSprite runAction:_zombie.actionRun];
        
    } else if ((int)_zombie.state == stateRunning) {
        // Kepp running
        [self moveWithDirection:nextPosition];
    }
}

- (void)gamePadTouchEnded:(GamePad *)gamePad {
    // Stop actions and init still action
    [_zombie.zombieSprite stopAllActions];
    _zombie.state = stateStill;
    [_zombie.zombieSprite runAction:_zombie.actionStill];
}

- (void)gamePadPushButton:(GamePad *)gamePad {
    // I zombie is not hitting
    if ((int)_zombie.state != stateHitting) {
        _zombie.state = stateHitting;
    }
    // Stop actions and init hitting action
    [_zombie.zombieSprite stopAllActions];
    [_zombie.zombieSprite runAction:_zombie.actionHit];
    
    // Detect collision
    for (Human *human in _arrayOfHumans){
        // Detect collision
        if (CGRectIntersectsRect(_zombie.boundingBox, human.humanSprite.boundingBox) && !_humanCollisionDetected
            && _zombie.position.y <= (human.humanSprite.position.y + 12)
            && _zombie.position.y >= (human.humanSprite.position.y - 12)) { // anchorpoint
            _humanCollisionDetected = TRUE;
            
            // Managing collisions
            [self manageCollisionForHuman:human];
            
            break;
        }
    }

}

- (void)moveWithDirection:(CGPoint)nextPosition {
    float nextXPosition;
    float nextYPosition;
    // Total background width
    float backgroundWidth = _background0.contentSize.width + _background1.contentSize.width + _background2.contentSize.width + _background3.contentSize.width;
    
    // Avoinding going out of screen
    if ((_zombie.position.x + nextPosition.x) < (_zombie.contentSize.width / 2) || (_zombie.position.x + nextPosition.x) > (backgroundWidth - _zombie.contentSize.width / 2)) {
        nextXPosition = _zombie.position.x;
    } else {
        nextXPosition = _zombie.position.x + nextPosition.x;
    }
    if ((_zombie.position.y + nextPosition.y) < (_zombie.contentSize.height / 2) || (_zombie.position.y + nextPosition.y) > (_screenSize.height / 2)) {
        nextYPosition = _zombie.position.y;
    } else {
        nextYPosition = _zombie.position.y + nextPosition.y;
    }
    
    _zombie.position = CGPointMake(nextXPosition, nextYPosition);
}

- (CGPoint) calculateNextPosition:(GamePadDirections)zombieDirection isHeld:(BOOL)isHeld{
    CGFloat incrX;
    CGFloat incrY;
    if (isHeld) {
        incrX = 1.5;
        incrY = 1.125;
    } else {
        incrX = 1.0;
        incrY = 0.75;
    }
    switch (zombieDirection) {
        case directionCenter:
            return CGPointZero;
            break;
        case directionUp:
            return CGPointMake(0.0, incrY);
            break;
        case directionUpRight:
            return CGPointMake(incrX, incrY);
            break;
        case directionRight:
            return CGPointMake(incrX, 0.0);
            break;
        case directionDownRight:
            return CGPointMake(incrX, -incrY);
            break;
        case directionDown:
            return CGPointMake(0.0, -incrY);
            break;
        case directionDownLeft:
            return CGPointMake(-incrX, -incrY);
            break;
        case directionLeft:
            return CGPointMake(-incrX, 0.0);
            break;
        case directionUpLeft:
            return CGPointMake(-incrX, incrY);
            break;
        default:
            return CGPointZero;
            break;
    }
}

- (void)createEnemies {
    Human *human;
    int humanType;
    int randomXPosition;
    int randomYPosition;
    
    for (int i = 0; i < NUM_HUMANS; i++) {
        
        // Create a new human sprite with a random type
        humanType = arc4random_uniform(NUM_HUMAN_TYPES);
        human = [[Human alloc] initHumanWithType:humanType];
        
        // Get random positions
        randomXPosition = arc4random_uniform(_screenSize.width + 1500);
        randomYPosition = arc4random_uniform(300);
        
        // Stablish positions out of screen
        if (randomXPosition <= _screenSize.width) {
            randomXPosition = randomXPosition + _screenSize.width;
        }
        // Keep the enemies inside the screen height
        if (randomYPosition <= human.contentSize.height / 2) {
            randomYPosition = randomYPosition + human.contentSize.height / 2;
        }
        
        // Set initial position
        [human setPosition:CGPointMake(randomXPosition, randomYPosition)];
        
        // Add the human to the batchand the array
        [_batchNode addChild:human.humanSprite];
        [_arrayOfHumans addObject:human];
    }
}

- (void)update:(NSTimeInterval)delta {
    // Check game over or stage cleared
    if (_zombie.lifePoints <= 0){
        [self gameOverWithSuccess:FALSE];
    } else if (_arrayOfHumans.count == 0) {
        [self gameOverWithSuccess:TRUE];
    }

    // Keep the zombie on view
    [self setZombieOnView:_zombie.position];
    
    // Take decisions
    for (Human *human in _arrayOfHumans) {
        // If the human is doing nothing
        if ((int)human.state == humanStateStill) {
            [self takeDecisionWithHuman:human];
        }
        
        // If some human enemy hits the zombie
        if((int)human.state == humanStateHitting && CGRectIntersectsRect(_zombie.boundingBox, human.humanSprite.boundingBox) && !_zombieCollisionDetected
           && _zombie.position.y <= (human.humanSprite.position.y + VERTICAL_MARGIN)
           && _zombie.position.y > (human.humanSprite.position.y - VERTICAL_MARGIN)) {
            _zombieCollisionDetected = TRUE;
            // Manage collisions
            [self manageCollisionForZombieWithHuman:human];
        }
    }
}

- (void)setZombieOnView:(CGPoint)position {
    // Stablish the maximum positions in screen
    NSInteger positionX = MAX(position.x, _screenSize.width / 2);
    NSInteger positionY = MAX(position.y, _screenSize.height / 2);
    
    // Calculate the limits in both axis
    float backgroundWidth = _background0.contentSize.width + _background1.contentSize.width + _background2.contentSize.width + _background3.contentSize.width;
    positionX = MIN(positionX, backgroundWidth - (_screenSize.width / 2));
    positionY = MIN(positionY, _screenSize.height / 2);
    
    // Initialize current position
    CGPoint currentPosition = CGPointMake(positionX, positionY);
    
    // Set view point
    CGPoint cameraPosition = CGPointMake((_screenSize.width / 2) - currentPosition.x, (_screenSize.height / 2) - currentPosition.y);
    
    // Set the scene position
    self.position = cameraPosition;
    
    // Update game pad sprite's position
    _gamePad.padSprite.position = CGPointMake(ABS(cameraPosition.x) + _gamePad.padSprite.contentSize.width / 2, _gamePad.padSprite.position.y);
    _gamePad.buttonSprite.position = CGPointMake(ABS(cameraPosition.x) + _screenSize.width - _gamePad.buttonSprite.contentSize.width / 2, _gamePad.buttonSprite.position.y);
    
    // Update life bar positions
    _lifeBarRed.position = CGPointMake(ABS(cameraPosition.x) + _lifeBarRed.contentSize.width / 2, _lifeBarRed.position.y);
    _lifeBarYellow.position = CGPointMake(ABS(cameraPosition.x) + _lifeBarYellow.contentSize.width / 2, _lifeBarYellow.position.y);

}

-(void) takeDecisionWithHuman:(Human *)human {
    float distance = ABS(human.humanSprite.position.x - _zombie.position.x);
    
    if ((distance > (human.contentSize.width / 2) && distance < _screenSize.width
         && !((int)human.state == humanStateWalking)) && !((int)human.state == humanStateDamaged)) {
        [self decideWalkToPosition:_zombie.position human:human];
    } else if (distance <= human.contentSize.width / 2 && !((int)human.state == humanStateHitting) && !((int)human.state == humanStateDamaged)) {
        [self decideAttackToZombieHuman:human];
    } else if (!((int)human.state == humanStateStill) && !((int)human.state == humanStateWalking) && !((int)human.state == humanStateDamaged)){
        [self decideStayStillHuman:human];
    }
}

- (void) decideWalkToPosition:(CGPoint)position human:(Human *)human {
    // Stop all actions
    [human.humanSprite stopAllActions];
    human.state = humanStateWalking;
    
    CCActionMoveTo *actionMove;
    float distance;
    float duration;
    
    if (human.humanSprite.position.y > position.y + VERTICAL_MARGIN  || human.humanSprite.position.y < position.y - VERTICAL_MARGIN) {
        // Calculate distance
        distance = ABS(human.humanSprite.position.y - position.y);
        // Calculate duration of the movement
        duration = distance / HUMAN_SPEED;
        // Create a movement action
        actionMove = [CCActionMoveTo actionWithDuration:duration position:CGPointMake(human.humanSprite.position.x, position.y)];
    } else if (human.humanSprite.position.x > position.x + human.contentSize.width / 2 || human.humanSprite.position.x < position.x + human.contentSize.width / 2) {
        // Calculate distance
        distance = ABS(human.humanSprite.position.x - position.x) + human.contentSize.width / 2;
        // Calculate duration of the movement
        duration = distance / HUMAN_SPEED;
        // Create a movement action
        actionMove = [CCActionMoveTo actionWithDuration:duration position:CGPointMake(position.x + (human.contentSize.width / 2), human.humanSprite.position.y)];
    } else {
        // Calculate distance
        distance = ABS(human.humanSprite.position.x - human.humanSprite.position.x);
        // Calculate duration of the movement
        duration = distance / HUMAN_SPEED;
        // Create a movement action
        actionMove = [CCActionMoveTo actionWithDuration:duration position:CGPointMake(human.humanSprite.position.x, human.humanSprite.position.y)];
    }
    
    CCActionCallBlock *callDidMove = [CCActionCallBlock actionWithBlock:^{
        // Stop all actions
        [human.humanSprite stopAllActions];
        // Set new state
        human.state = humanStateStill;
        // Run still action
        [human.humanSprite runAction:human.actionStill];
    }];
    
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[actionMove, callDidMove]];
    
    // Run human actions
    [human.humanSprite runAction:human.actionWalk];
    [human.humanSprite runAction:sequence];
}

- (void) decideAttackToZombieHuman:(Human *)human {
    // Stop all actions
    [human.humanSprite stopAllActions];
    human.state = humanStateHitting;
    
    CCActionCallBlock *callDidMove = [CCActionCallBlock actionWithBlock:^{
        [human.humanSprite stopAllActions];
        human.state = humanStateStill;
        _zombieCollisionDetected = FALSE;
        
    }];
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[human.actionHit, callDidMove]];
    
    // Run human action
    [human.humanSprite runAction:sequence];
}

- (void) decideStayStillHuman:(Human *)human {
    // Stop all actions
    [human.humanSprite stopAllActions];
    human.state = humanStateStill;
    
    // Run human action
    [human.humanSprite runAction:human.actionStill];
}

-(void) manageCollisionForZombieWithHuman:(Human *)human {
    if((int)human.state == humanStateHitting && _zombieCollisionDetected) {
        _zombie.lifePoints--;
        [self updateLifeBarWithPoints:_zombie.lifePoints];
    }
}

- (void) createLifeBars {
    float rectHeight = 70.0;
    float rectWidth = _zombie.lifePoints * 40;
    float positionX = 20;
    float positionY = [CCDirector sharedDirector].viewSize.height - rectHeight - 20;
    
    // Creating array of vertices
    CGPoint vertices[4];
    
    vertices[0] = CGPointMake(positionX, positionY); //bottom-left
    vertices[1] = CGPointMake(positionX, positionY + rectHeight); //top-left
    vertices[2] = CGPointMake(positionX + rectWidth, positionY + rectHeight); //top-right
    vertices[3] = CGPointMake(positionX + rectWidth, positionY); //bottom-right
    
    // Draw a polygon by specifying its vertices
    _lifeBarRed.anchorPoint = CGPointMake(0.0, 0.0);
    [_lifeBarRed drawPolyWithVerts:vertices count:4 fillColor:[CCColor redColor] borderWidth:0.0 borderColor:[CCColor blackColor]];
    _lifeBarYellow.anchorPoint = CGPointMake(0.0, 0.0);
    [_lifeBarYellow drawPolyWithVerts:vertices count:4 fillColor:[CCColor yellowColor] borderWidth:0.0 borderColor:[CCColor blackColor]];
    
    // Add rectangle to scene
    [self addChild:_lifeBarRed z:2];
    [self addChild:_lifeBarYellow z:2];
}

- (void) updateLifeBarWithPoints:(int)lifePoints {
    
    if(_lifeBarYellow.parent) {
        [_lifeBarYellow removeFromParent];
    }
    
    float rectHeight = 70.0;
    float rectWidth = lifePoints * 40;
    float positionX = 20;
    float positionY = [CCDirector sharedDirector].viewSize.height - rectHeight - 20;
    
    // Creating array of vertices
    CGPoint vertices[4];
    
    vertices[0] = CGPointMake(positionX, positionY); //bottom-left
    vertices[1] = CGPointMake(positionX, positionY + rectHeight); //top-left
    vertices[2] = CGPointMake(positionX + rectWidth, positionY + rectHeight); //top-right
    vertices[3] = CGPointMake(positionX + rectWidth, positionY); //bottom-right
    
    // Draw a polygon by specifying its vertices
    _lifeBarYellow = [CCDrawNode node];
    _lifeBarYellow.anchorPoint = CGPointMake(0.0, 0.0);
    [_lifeBarYellow drawPolyWithVerts:vertices count:4 fillColor:[CCColor yellowColor] borderWidth:0.0 borderColor:[CCColor blackColor]];
    
    // Add rectangle to scene
    [self addChild:_lifeBarYellow z:2];
}

-(void) manageCollisionForHuman:(Human *)human {
    // Stop actions
    [human.humanSprite stopAllActions];
    // Update human state
    human.state = humanStateDamaged;
    // Update human action
    [human.humanSprite runAction:human.actionStill];
    
    _zombieCollisionDetected = FALSE;
    
    // Create movement action
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:0.5 position:CGPointMake(human.humanSprite.position.x + (human.humanSprite.contentSize.width / 2), human.humanSprite.position.y)];
    
    // Block to be executed at the endof the movement
    CCActionCallBlock *callDidMove = [CCActionCallBlock actionWithBlock:^{
        // Stop actions
        [human.humanSprite stopAllActions];
        
        // Update flag
        _humanCollisionDetected = FALSE;
        
        // Update position
        [human setPosition:human.humanSprite.position];
        
        // Update state
        human.state = humanStateStill;
        
        // Update human life points
        human.lifePoints--;
        
        // If human is killed
        if (human.lifePoints == 0) {
            if (_humansToDelete.count > 0) {
                [_humansToDelete replaceObjectAtIndex:0 withObject:human];
            } else {
                [_humansToDelete addObject:human];
            }
            // Remove human from batch node
            [_batchNode removeChild:human.humanSprite];
            if (_humansToDelete.count > 0) {
                [_arrayOfHumans removeObjectsInArray:_humansToDelete];
            }
        }
        
    }];
    
    // Declare and run sequence
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[actionMove, callDidMove]];
    [human.humanSprite runAction:sequence];
}

-(void) gameOverWithSuccess:(BOOL)success{
    
    // Initializing the label
    CCLabelTTF *label;
    // Stop interaction and running actions
    self.paused = TRUE;
    _gamePad.userInteractionEnabled = FALSE;
    
    if (!success) {
        // Create the game over label
        label = [CCLabelTTF labelWithString:@"GAME OVER" fontName:@"Verdana-Bold" fontSize:40];
        label.color = [CCColor redColor];
    } else {
        // Create the stage cleared label
        label = [CCLabelTTF labelWithString:@"STAGE CLEARED!" fontName:@"Verdana-Bold" fontSize:40];
        label.color = [CCColor greenColor];
    }
    
    // Place and add the label to the scene
    label.position = CGPointMake(ABS(self.position.x) + _screenSize.width / 2, _screenSize.height / 2);
    [self addChild:label];
}

@end
