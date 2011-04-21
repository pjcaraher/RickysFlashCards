//
//  VoiceEntity.m
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/26/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import "VoiceEntity.h"


@implementation VoiceEntity

@dynamic name;

- (BOOL)validateName:(NSString*)value error:(NSError **)saveError
{
	BOOL	okToSave = TRUE;
	NSError	*error = nil;
	NSArray	*sameNameVoices = nil;
	NSError	*fetchError;
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSString	*predictateString = [NSString stringWithFormat:@"name == '%@'", [self valueForKey:@"name"]];
	
	// See if a Voice already exists for this name.
	[fetchRequest setEntity:[self entity]]; 
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:predictateString]]; 
	
	sameNameVoices = [[self managedObjectContext] executeFetchRequest:fetchRequest 
															 error:&fetchError];

	// Note that the fetch should include this instance.
	// We want to see if there are any other instances with the same name.
	if ((nil != sameNameVoices) && ([sameNameVoices count] > 1)) {
		error = [[[NSError alloc] initWithDomain:VALIDATION_ERROR_DOMAIN
													 code:VALIDATION_ERROR_DUPLICATE_NAME
												 userInfo:nil] autorelease];
		*saveError = error;
		okToSave = FALSE;
	}

	return okToSave;
}

@end
