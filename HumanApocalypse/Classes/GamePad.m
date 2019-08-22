#import "GamePad.h"

@implementation GamePad

- (GamePad *) initWithPadRadius:(CGFloat)padRadius buttonRadius:(CGFloat)buttonRadius {
    self = [super init];
    if (!self) return(nil);
    
    // Initialize properties
    _padRadius = padRadius;
    _buttonRadius = buttonRadius;
    
    _direction = directionCenter;
    _isHeld = FALSE;
    
    // Initialize pad sprite
    _padSprite = [[CCSprite alloc ] initWithImageNamed:@"HumanApocalypseAtlas/gamepad.png"];
    _padSprite.anchorPoint = CGPointMake(0.5, 0.5);
    _padSprite.position = CGPointMake(_padSprite.contentSize.width / 2, _padSprite.contentSize.height / 2);
    
    // Initialize button sprite
    _buttonSprite = [[CCSprite alloc ] initWithImageNamed:@"HumanApocalypseAtlas/button.png"];
    _buttonSprite.anchorPoint = CGPointMake(0.5, 0.5);
    _buttonSprite.position = CGPointMake([CCDirector sharedDirector].viewSize.width - (_buttonSprite.contentSize.width / 2), _buttonSprite.contentSize.height / 2);
    
    // Set content size
    self.contentSize = CGSizeMake(16000, _padSprite.contentSize.height);
    
    // Add pad sprite to game pad
    [self addChild:_padSprite];
    
    // Add button sprite to game pad
    [self addChild:_buttonSprite];
    
    // Enable user interaction
    self.userInteractionEnabled = TRUE;
    
    // Enable multi touch interaction
    self.multipleTouchEnabled = TRUE;
    
    return self;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Get the touch location
    CGPoint touchLocation = [touch locationInNode:self.parent];
    
    // If the touch is inside the pad
    if (CGRectContainsPoint(_padSprite.boundingBox, touchLocation)) {
        
        // Store current touch hash
        _touchHash = touch.hash;
        
        // Update direction
        [self updateDirectionForTouchLocation:touchLocation];
        
        // It's been held
        _isHeld = TRUE;
        
    } else if (CGRectContainsPoint(_buttonSprite.boundingBox, touchLocation)) {
        [_delegate gamePadPushButton:self];
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    // If it's the same touch as stored
    if (touch.hash == _touchHash) {
        // Get the touch location
        CGPoint touchLocation = [touch locationInNode:self.parent];
        // Update direction
        [self updateDirectionForTouchLocation:touchLocation];
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // Reset direction
    _direction = directionCenter;
    
    // Is no more held
    _isHeld = FALSE;
    
    // If it's the same touch as stored
    if (touch.hash == _touchHash)
    {
        // Call delegate touch end method
        [_delegate gamePadTouchEnded:self];
        // Reset hash value
        _touchHash = 0;
    }
}

- (void)update:(NSTimeInterval)delta
{
    // If is being held
    if (_isHeld) {
        // Call delegate holding method
        [_delegate gamePad:self
        isHoldingDirection:_direction];
    }
}

- (void)updateDirectionForTouchLocation:(CGPoint)touchLocation {
    
    // Get the difference between the touched location and the pad center
    CGPoint point = CGPointMake(touchLocation.x - _padSprite.position.x, touchLocation.y - _padSprite.position.y);
    // Convert point to radians
    CGFloat radians = ccpToAngle(point);
    // Calculate degrees
    CGFloat degrees = CC_RADIANS_TO_DEGREES(radians);
    
    // Update previous direction
    _previousDirection = _direction;
    
    // Calculate direction
    if (degrees <= 22.5 && degrees >= -22.5) {
        _direction = directionRight;
    } else if (degrees > 22.5 && degrees < 67.5) {
        _direction = directionUpRight;
    } else if (degrees >= 67.5 && degrees <= 112.5) {
        _direction = directionUp;
    } else if (degrees > 112.5 && degrees < 157.5) {
        _direction = directionUpLeft;
    } else if (degrees >= 157.5 || degrees <= -157.5) {
        _direction = directionLeft;
    } else if (degrees < -112.5 && degrees > -157.5) {
        _direction = directionDownLeft;
    } else if (degrees <= -67.5 && degrees >= -112.5) {
        _direction = directionDown;
    } else if (degrees < -22.5 && degrees > -67.5) {
        _direction = directionDownRight;
    }
    
    if (_isHeld) {
        if (_previousDirection != _direction) {
            [_delegate gamePad:self
          didChangeDirectionTo:_direction];
        }
    } else {
        [_delegate gamePad:self
      didChangeDirectionTo:_direction];
    }
}

@end
