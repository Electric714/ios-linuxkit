//
//  Logging.m
//  LinuxKit
//

#import "Logging.h"

static NSURL *LogFileURL(void) {
    static NSURL *url;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *docs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                              inDomains:NSUserDomainMask].firstObject;
        // Logs subfolder for cleanliness
        NSURL *logsDir = [docs URLByAppendingPathComponent:@"Logs" isDirectory:YES];
        [[NSFileManager defaultManager] createDirectoryAtURL:logsDir
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
        url = [logsDir URLByAppendingPathComponent:@"ios-linuxkit.log"];
    });
    return url;
}

static void WriteToLog(NSString *message) {
    NSString *timestamped = [NSString stringWithFormat:@"%@  %@\n",
                             [NSDate date], message];

    // Also print to Console.app when device is connected to Mac
    NSLog(@"%@", timestamped);

    NSURL *logURL = LogFileURL();
    NSData *data = [timestamped dataUsingEncoding:NSUTF8StringEncoding];

    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:logURL.path];
    if (handle) {
        [handle seekToEndOfFile];
        [handle writeData:data];
        [handle closeFile];
    } else {
        [data writeToURL:logURL atomically:YES];
    }
}

void Log(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    WriteToLog(msg);
}

void LogError(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    WriteToLog([@"[ERROR] " stringByAppendingString:msg]);
}