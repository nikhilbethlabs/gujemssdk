//
//  MASTAccelerometer.m
//

#import "MASTAccelerometer.h"
#import "MASTUtils.h"

@interface MASTAccelerometer()
{
    BOOL isShakeDetected,isTiltDetected;
    CMAcceleration lastAcceleration;
}
@property CMAcceleration lastAcceleration;
@end

@implementation MASTAccelerometer


@synthesize lastAcceleration;

static MASTAccelerometer* sharedInstance = nil;
static CMMotionManager* sharedMotionManagerInstance = nil;
static CMMotionManager *motionManager;
static CGFloat kDefaultMaxThreshold = 1.0;
static CGFloat kDefaultMinThreshold = 0.3;

static BOOL accelerationIsShaking(CMAcceleration last, CMAcceleration current, double threshold) {
    double
    deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);
    
    return
    (deltaX > threshold && deltaY > threshold) ||
    (deltaX > threshold && deltaZ > threshold) ||
    (deltaY > threshold && deltaZ > threshold);
}

static BOOL accelerationIsTilting(CMAcceleration last, CMAcceleration current, double max_threshold, double min_threshold) {
    
    double
    deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);
    
    //check again to make sure that it is not shaking
    bool isShaking = accelerationIsShaking(last,current,max_threshold);
    
        
    //check to make sure if acceleration is titled
    bool isTilted = 
    ( deltaX > min_threshold && deltaX < max_threshold ) ||
    ( deltaY > min_threshold && deltaY < max_threshold ) ||
    ( deltaZ > min_threshold && deltaZ < max_threshold );
    
    
    //if not shaking and tilted,
    return !isShaking && isTilted;
}



- (id) init {
    self = [super init];
    
    if (self) {
        
        motionManager = [MASTAccelerometer sharedMotionManagerInstance];
        motionManager.accelerometerUpdateInterval = 0.3;
        
    }
    
    return self;
}


- (void)handleDeviceMotion:(CMAccelerometerData*)accel
{   
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self, kOrmmaKeySender, accel, kOrmmaKeyObject, nil];
    
    if (self.lastAcceleration.x == 0 &&
        self.lastAcceleration.y == 0 &&
        self.lastAcceleration.z == 0)
    {
        self.lastAcceleration = accel.acceleration;
    }
    
    if (self.lastAcceleration.x != 0 &&
        self.lastAcceleration.y != 0 &&
        self.lastAcceleration.z != 0) 
    {
        
        if (!isShakeDetected && accelerationIsShaking(self.lastAcceleration, accel.acceleration, kDefaultMaxThreshold)) {
            
            isShakeDetected = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kOrmmaShake object:dic];
            
        } else if (isShakeDetected && !accelerationIsShaking(self.lastAcceleration, accel.acceleration, kDefaultMinThreshold)) {
            
            isShakeDetected = NO;
        }
        
        if (!isShakeDetected)
        {   
            if (!isTiltDetected && accelerationIsTilting(self.lastAcceleration,accel.acceleration,kDefaultMaxThreshold,kDefaultMinThreshold))
            {
                isTiltDetected = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kOrmmaTiltUpdated object:dic];
                
            } else if (isTiltDetected && !accelerationIsTilting(self.lastAcceleration,accel.acceleration,kDefaultMaxThreshold,kDefaultMinThreshold))
            {
                isTiltDetected = NO;
            }
            
        }
        self.lastAcceleration = accel.acceleration;
        
    }    
}


- (void)registerMASTNotificationDeviceMotion
{
    if (motionManager.deviceMotionAvailable) {
        
        NSLog(@"Device Motion Available");
        
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] 
                                            withHandler:^(CMAccelerometerData *accel, NSError *error){
                                                
                                                [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:accel waitUntilDone:YES];
                                                
                                            }];             
    }
    
}


+ (id)sharedInstance {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [[self alloc] init];
		}
	}
	return sharedInstance;
}

+ (CMMotionManager *)sharedMotionManagerInstance {
	@synchronized(self) {
		if (nil == sharedMotionManagerInstance) {
			sharedMotionManagerInstance = [[CMMotionManager alloc] init];
		}
	}
	return sharedMotionManagerInstance;
}

- (oneway void)superRelease {
	[super release];
}

+ (void)releaseSharedInstance {
	@synchronized(self) {
        [self stopMotionManagerUpdates];
		[sharedInstance superRelease];
		sharedInstance = nil;
	}
}

+ (id)allocWithZone:(NSZone*)zone {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [super allocWithZone:zone];
		}
	}
	
	return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
	return sharedInstance;
}

- (id)retain {
	return sharedInstance;
}

- (unsigned)retainCount {
	return NSUIntegerMax;
}

- (oneway void)release {
	// Do nothing.
}

- (id)autorelease {
	return sharedInstance;
}


+ (void)stopMotionManagerUpdates
{
    [motionManager stopAccelerometerUpdates];
    [motionManager release];
    motionManager = nil;
}

@end
