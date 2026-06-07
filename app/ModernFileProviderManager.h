// ModernFileProviderManager.h
// Dedicated modern FileProvider manager for iOS 18+
// Extensive use of latest NSFileProvider APIs + heavy logging

#import <Foundation/Foundation.h>
#import <FileProvider/FileProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModernFileProviderManager : NSObject

+ (instancetype)sharedManager;

- (void)syncDomainsForRoots:(NSArray<NSString *> *)rootNames completion:(void (^)(NSError * _Nullable error))completion;
- (void)addDomainForRoot:(NSString *)rootName completion:(void (^)(NSError * _Nullable error))completion;
- (void)removeDomainForRoot:(NSString *)rootName completion:(void (^)(NSError * _Nullable error))completion;
- (void)removeAllStaleDomains:(void (^)(NSError * _Nullable error))completion;

// iOS 18+ ready methods
- (void)signalDomainsChanged:(void (^)(NSError * _Nullable error))completion;
- (void)getAllDomainsWithDetailedInfo:(void (^)(NSArray<NSFileProviderDomain *> *domains, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END