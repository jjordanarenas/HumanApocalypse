#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    directionCenter = 0,
    directionRight,
    directionUpRight,
    directionUp,
    directionUpLeft,
    directionLeft,
    directionDownLeft,
    directionDown,
    directionDownRight
} GamePadDirections;

@class GamePad;

@protocol GamePadDelegate <NSObject>
- (void)gamePad:(GamePad *)gamePad
didChangeDirectionTo:(GamePadDirections)newDirection;
- (void)gamePad:(GamePad *)gamePad
isHoldingDirection:(GamePadDirections)holdingDirection;
- (void)gamePadTouchEnded:(GamePad *)gamePad;
- (void)gamePadPushButton:(GamePad *)gamePad;
@end

@interface GamePad : CCNode {
}

@property (weak, nonatomic) id <GamePadDelegate> delegate;
@property (assign, nonatomic) GamePadDirections direction;
@property (assign, nonatomic) GamePadDirections previousDirection;
@property (assign, nonatomic) BOOL isHeld;
@property (assign, nonatomic) CGFloat padRadius;
@property (assign, nonatomic) NSUInteger touchHash;
@property (assign, nonatomic) CGFloat buttonRadius;
@property (readwrite, nonatomic) CCSprite *padSprite;
@property (readwrite, nonatomic) CCSprite *buttonSprite;

// Declare init method
-	(GamePad *) initWithPadRadius:(CGFloat)padRadius buttonRadius:(CGFloat)buttonRadius;

@end