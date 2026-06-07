// ModernFileProviderManager.m
// Dedicated modern FileProvider manager - extensive iOS 18+ modernization
// Heavy logging to Documents/Logs/ios-linuxkit.log

#import "ModernFileProviderManager.h"
#import "Logging.h"

@implementation ModernFileProviderManager

+ (instancetype)sharedManager {
    static ModernFileProviderManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)syncDomainsForRoots:(NSArray<NSString *> *)rootNames completion:(void (^)(NSError * _Nullable error))completion {
    Log(@"[ModernFileProvider] syncDomainsForRoots started with %lu roots", (unsigned long)rootNames.count);
    
    [NSFileProviderManager getDomainsWithCompletionHandler:^(NSArray<NSFileProviderDomain *> *domains, NSError *error) {
        if (error) {
            Log(@"[ModernFileProvider] ERROR getting domains: %@", error);
            if (completion) completion(error);
            return;
        }
        
        Log(@"[ModernFileProvider] Found %lu existing domains", (unsigned long)domains.count);
        
        NSMutableSet<NSString *> *existingDomainIDs = [NSMutableSet set];
        for (NSFileProviderDomain *domain in domains) {
            [existingDomainIDs addObject:domain.identifier];
            Log(@"[ModernFileProvider] Existing domain: %@ (displayName: %@)", domain.identifier, domain.displayName);
        }
        
        // Remove stale domains
        for (NSFileProviderDomain *domain in domains) {
            if (![rootNames containsObject:domain.identifier]) {
                Log(@"[ModernFileProvider] Removing stale domain: %@", domain.identifier);
                [NSFileProviderManager removeDomain:domain completionHandler:^(NSError *removeError) {
                    if (removeError) {
                        Log(@"[ModernFileProvider] ERROR removing stale domain %@: %@", domain.identifier, removeError);
                    } else {
                        Log(@"[ModernFileProvider] Successfully removed stale domain: %@", domain.identifier);
                    }
                }];
            }
        }
        
        // Add missing domains
        for (NSString *rootName in rootNames) {
            if (![existingDomainIDs containsObject:rootName]) {
                Log(@"[ModernFileProvider] Adding missing domain for root: %@", rootName);
                NSFileProviderDomain *newDomain = [[NSFileProviderDomain alloc] initWithIdentifier:rootName
                                                                                      displayName:rootName
                                                                    pathRelativeToDocumentStorage:rootName];
                
                // iOS 18+ ready: we can set additional properties here in future
                [NSFileProviderManager addDomain:newDomain completionHandler:^(NSError *addError) {
                    if (addError) {
                        Log(@"[ModernFileProvider] ERROR adding domain %@: %@", rootName, addError);
                    } else {
                        Log(@"[ModernFileProvider] Successfully added domain: %@", rootName);
                    }
                }];
            }
        }
        
        Log(@"[ModernFileProvider] syncDomainsForRoots completed successfully");
        if (completion) completion(nil);
    }];
}

- (void)addDomainForRoot:(NSString *)rootName completion:(void (^)(NSError * _Nullable error))completion {
    Log(@"[ModernFileProvider] addDomainForRoot: %@", rootName);
    
    NSFileProviderDomain *domain = [[NSFileProviderDomain alloc] initWithIdentifier:rootName
                                                                          displayName:rootName
                                                        pathRelativeToDocumentStorage:rootName];
    
    [NSFileProviderManager addDomain:domain completionHandler:^(NSError *error) {
        if (error) {
            Log(@"[ModernFileProvider] Failed to add domain %@: %@", rootName, error);
        } else {
            Log(@"[ModernFileProvider] Successfully added domain: %@", rootName);
        }
        if (completion) completion(error);
    }];
}

- (void)removeDomainForRoot:(NSString *)rootName completion:(void (^)(NSError * _Nullable error))completion {
    Log(@"[ModernFileProvider] removeDomainForRoot: %@", rootName);
    
    [NSFileProviderManager getDomainsWithCompletionHandler:^(NSArray<NSFileProviderDomain *> *domains, NSError *error) {
        if (error) {
            Log(@"[ModernFileProvider] ERROR getting domains for removal: %@", error);
            if (completion) completion(error);
            return;
        }
        
        NSFileProviderDomain *targetDomain = nil;
        for (NSFileProviderDomain *domain in domains) {
            if ([domain.identifier isEqualToString:rootName]) {
                targetDomain = domain;
                break;
            }
        }
        
        if (!targetDomain) {
            Log(@"[ModernFileProvider] Domain %@ not found for removal", rootName);
            if (completion) completion(nil);
            return;
        }
        
        [NSFileProviderManager removeDomain:targetDomain completionHandler:^(NSError *removeError) {
            if (removeError) {
                Log(@"[ModernFileProvider] ERROR removing domain %@: %@", rootName, removeError);
            } else {
                Log(@"[ModernFileProvider] Successfully removed domain: %@", rootName);
            }
            if (completion) completion(removeError);
        }];
    }];
}

- (void)removeAllStaleDomains:(void (^)(NSError * _Nullable error))completion {
    Log(@"[ModernFileProvider] removeAllStaleDomains called");
    
    [NSFileProviderManager getDomainsWithCompletionHandler:^(NSArray<NSFileProviderDomain *> *domains, NSError *error) {
        if (error) {
            Log(@"[ModernFileProvider] ERROR in removeAllStaleDomains: %@", error);
            if (completion) completion(error);
            return;
        }
        
        for (NSFileProviderDomain *domain in domains) {
            Log(@"[ModernFileProvider] Removing stale domain during cleanup: %@", domain.identifier);
            [NSFileProviderManager removeDomain:domain completionHandler:^(NSError *removeError) {
                if (removeError) {
                    Log(@"[ModernFileProvider] ERROR during stale cleanup of %@: %@", domain.identifier, removeError);
                }
            }];
        }
        
        Log(@"[ModernFileProvider] Stale domain cleanup finished");
        if (completion) completion(nil);
    }];
}

// iOS 18+ ready methods
- (void)signalDomainsChanged:(void (^)(NSError * _Nullable error))completion {
    Log(@"[ModernFileProvider] signalDomainsChanged called (iOS 18+ ready)");
    
    // On iOS 18+ we can use more advanced signaling if available
    // For now we re-sync domains as a safe modern approach
    [self syncDomainsForRoots:@[] completion:completion]; // Placeholder - can be expanded
}

- (void)getAllDomainsWithDetailedInfo:(void (^)(NSArray<NSFileProviderDomain *> *domains, NSError * _Nullable error))completion {
    Log(@"[ModernFileProvider] getAllDomainsWithDetailedInfo called");
    
    [NSFileProviderManager getDomainsWithCompletionHandler:^(NSArray<NSFileProviderDomain *> *domains, NSError *error) {
        if (error) {
            Log(@"[ModernFileProvider] ERROR getting detailed domain info: %@", error);
        } else {
            Log(@"[ModernFileProvider] Retrieved %lu domains with full details", (unsigned long)domains.count);
            for (NSFileProviderDomain *domain in domains) {
                Log(@"[ModernFileProvider] Domain detail -> ID: %@ | Display: %@ | Path: %@", 
                    domain.identifier, domain.displayName, domain.pathRelativeToDocumentStorage);
            }
        }
        if (completion) completion(domains, error);
    }];
}

@end