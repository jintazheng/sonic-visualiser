/*
    iTunes connection for
    Sonic Visualiser
    An audio file viewer and annotation editor.
    Centre for Digital Music, Queen Mary, University of London.
    This file copyright 2010 Dan Stowell and QMUL.
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of the
    License, or (at your option) any later version.  See the file
    COPYING included with this distribution for more information.
*/

#include "svitunes.h"

#include <Foundation/NSAppleScript.h>

#import <Foundation/Foundation.h>

QString qt_mac_NSStringToQString(const NSString *nsstr)
{
    NSRange range;
    range.location = 0;
    range.length = [nsstr length];
     
    unichar *chars = new unichar[range.length + 1];
    chars[range.length] = 0;
    [nsstr getCharacters:chars range:range];
    QString result = QString::fromUtf16(chars, range.length);
    delete chars;
    return result;
}

QStringList iTunesNowPlaying(){
    NSDictionary *errorDict;
    NSAppleScript *scriptObject = [[NSAppleScript alloc]    initWithSource:@" \
tell application \"System Events\" to set iTunesIsRunning to (name of processes) contains \"iTunes\" \n\
if iTunesIsRunning is false then return \"\" \n\
\
tell application \"iTunes\" \n\
    if player state is not stopped then \n\
        set aTrack to current track \n\
    else \n\
        set sel to selection \n\
        if sel is not {} then --and (length of sel) is 1 then \n\
            set aTrack to item 1 of sel \n\
        else \n\
            return \"\" \n\
        end if \n\
    end if \n\
    \
    return the POSIX path of (location of aTrack as text) & \"\n\" & (genre of aTrack) \n\
end tell \n\
"
    ];
    
    NSLog([scriptObject source]);
    
    [scriptObject compileAndReturnError: &errorDict];
    
    if(![scriptObject isCompiled]){
        NSLog(@"SV ERROR: applescript object not compiled");
        NSLog([errorDict description]);
    }
    
    NSAppleEventDescriptor *eventDesc = [scriptObject executeAndReturnError: &errorDict];
    NSString *nsResultString = [eventDesc stringValue];
    
    NSLog(@"iTunesNowPlayingPath: ");
    NSLog(nsResultString);
    
    QString resultString = qt_mac_NSStringToQString(nsResultString);
    
    [scriptObject release];
    return resultString.split(QChar('\n'));
}
