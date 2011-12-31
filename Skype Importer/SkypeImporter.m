//
//  SkypeImporter.m
//  Chatter
//
//  Created by Jones Curtis on 2011.07.09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SkypeImporter.h"
#import "ServiceStuff.h"
#import <stdlib.h>
#import <stdio.h>
#import <unistd.h>
#import <stdint.h>
#import <string.h>
#import <ctype.h>
#import <time.h>
#import <sys/mman.h>
#import <sys/types.h>
#import <sys/stat.h>
#import <fcntl.h>

typedef struct stat mystat;
typedef uint8_t byte;
typedef uint64_t offset;

int FileIn=0;
byte *Memory=NULL;
offset MemorySize=0;
offset Index=0;

char Divider='|';
int BlankFlag=0;

static NSString * getString (offset);
static uint64_t Bytes2Val	(int);
static uint64_t ReadNumber ();
static offset SkypeFindRecord ();
static void SkypeOpenFile (char*);
static void SkypeCloseFile ();

/**
 *
 *
 */
static void
SkypeCloseFile ()
{
  if (Memory)
		munmap(Memory,MemorySize);
	
  MemorySize=0;
	
  if (FileIn) 
		close(FileIn);
}

/**
 *
 *
 */
static void
SkypeOpenFile (char *Filename)
{
  mystat Stat;
	
  /* block re-opens */
  SkypeCloseFile();
	
  /* Open file */
  if (-1 == (FileIn = open(Filename,O_RDONLY))) {
    fprintf(stderr,"ERROR: Unable to open file (%s)\n",Filename);
    exit(-1);
	}
	
  if (fstat(FileIn,&Stat) == -1) {
    fprintf(stderr,"ERROR: Unable to stat file (%s)\n",Filename);
    close(FileIn);
    exit(-1);
	}
	
  MemorySize = Stat.st_size;
	
  if (MemorySize > 0) {
    Memory=mmap(0,MemorySize,PROT_READ,MAP_PRIVATE,FileIn,0);
    if (Memory == MAP_FAILED) {
      fprintf(stderr,"ERROR: Unable to mmap file (%s)\n",Filename);
      close(FileIn);
      exit(-1);
		}
	}
}

/**
 *
 *
 */
static offset
SkypeFindRecord ()
{
  if (memcmp(Memory+Index,"l33l",4) == 0) {
		Index += 4;
		return Index;
	}
	
  for (; Index+4 < MemorySize; Index++) {
    if (memcmp(Memory+Index,"l33l",4) == 0) {
      Index+=4;
      return(Index);
		}
	}
	
  return -1;
}

/**
 *
 *
 */
static uint64_t
ReadNumber ()
{
  int Shift=0;
  uint64_t Num=0;
	
  while ((Index < MemorySize) && (Memory[Index] & 0x80)) {
    Num = Num | ((Memory[Index] & 0x7f) << Shift);
    Shift += 7;
    Index++;
	}
	
  if (Index < MemorySize) {
    Num = Num | ((Memory[Index] & 0x7f) << Shift);
    Index++;
	}
	
  return Num;
}

/**
 *
 *
 */
static uint64_t
Bytes2Val	(int Len)
{
  uint64_t Val=0;
  int Shift=0;
	
  if (Index+Len >= MemorySize) {
		fprintf(stderr,"ERROR: Fractional Skype record.\n");
		return(0);
	}
  
  Len--;
  Shift=0;
  while(Len >= 0) {
    Val |= (Memory[Index] << Shift);
    Shift+=8;
    Len--;
    Index++;
	}
	
  return(Val);
}

/**
 *
 *
 */
static NSString *
getString (offset RecordEnd)
{
	offset tmpIndex = Index;
	byte *tmpMemory = NULL;
	int stringLength=0, stringIndex=0;
	
	while ((tmpIndex < RecordEnd) && (Memory[tmpIndex] > 0x03)) {
		if (isprint(Memory[tmpIndex]))
			stringLength += 1;
		tmpIndex += 1;
	}
	
	if (NULL == (tmpMemory = malloc(stringLength+1)))
		return nil;
	
	tmpIndex = Index;
	
	while ((tmpIndex < RecordEnd) && (Memory[tmpIndex] > 0x03)) {
		if (isprint(Memory[tmpIndex]))
			tmpMemory[stringIndex++] = Memory[tmpIndex];
		tmpIndex += 1;
	}
	
	tmpMemory[stringLength] = '\0';
	
	Index = tmpIndex;
	
	NSString *string =  [NSString stringWithCString:(char *)tmpMemory encoding:NSUTF8StringEncoding];
	
	free(tmpMemory);
	
	return string;
}










@interface SkypeImporter (PrivateMethods)
- (void)skypeMain:(NSArray *)files;
@end

@implementation SkypeImporter

#pragma mark - Structors

/**
 *
 *
 */
- (id)init
{
	self = [super init];
	
	if (self) {
		mMessage = [[NSMutableString alloc] init];
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[mMessage release];
	[super dealloc];
}





#pragma mark - ServiceImporter

/**
 *
 *
 */
+ (BOOL)canHandleFilePath:(NSString *)filePath
{
	BOOL retval=FALSE, isDir;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (FALSE == [fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir)
		goto done_fail;
	
	if ([[filePath lastPathComponent] hasPrefix:@"chatmsg"] && [filePath hasSuffix:@".dbb"])
		goto done_good;
	
	// skype database files start with 'l33l' (0x63 33 33 6C)
	{
		char buf[4] = { 0 };
		int fd = open([filePath cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
		
		if (fd == -1) {
			NSLog(@"%s.. failed to open(), %s", __PRETTY_FUNCTION__, strerror(errno));
			goto done_fail;
		}
		
		ssize_t bytes = read(fd, buf, 4);
		
		close(fd);
		
		if (bytes != 4)
			goto done_fail;
		
		if (buf[0] != 0x6C || buf[1] != 0x33 || buf[2] != 0x33 || buf[3] != 0x6C)
			goto done_fail;
	}
	
done_good:
	retval = TRUE;
	
done_fail:
	[fileManager release];
	return retval;
}

+ (NSString *)name
{
	return @"Skype";
}

+ (NSArray *)supportedContentTypes
{
	return nil;
}

+ (NSArray *)supportedTypeCodes
{
	return nil;
}

+ (NSArray *)supportedKinds
{
	return nil;
}

+ (NSArray *)supportedFileExtensions
{
	return [NSArray arrayWithObjects:@"dbb", nil];
}

+ (NSArray *)supportedSearchPaths
{
	return [NSArray arrayWithObjects:@"~/Library/Application Support/Skype", nil];
}





#pragma mark - Accessors

/**
 *
 *
 */
- (BOOL)importFileAtPath:(NSString *)filePath withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	long RecordNum=0;
	long RecordLen=0;
	offset RecordEnd=0;
	time_t Time;
	uint64_t SequenceNum;
	uint64_t Number;
	int First=0;
	int PrintString=0;
	char *Label;
	
	NSString *tmpMessage = nil;
	
	SkypeOpenFile((char *)[filePath UTF8String]);
	Index=0;
	
	while ((Index < MemorySize) && (SkypeFindRecord() != (offset)(-1)))
	{
		RecordNum++;
		RecordLen = Bytes2Val(4);
		RecordEnd = Index + RecordLen;
		
		if (Index+RecordLen > MemorySize)
			RecordLen = MemorySize - Index;
		
		SequenceNum = Bytes2Val(4);
		
		/* Process the record */
		First = 0; /* no output yet (first entry not seen) */
		Time=0;
		while(Index < RecordEnd)
		{
			/* Skip until we hit 0x03 */
			while ((Index < RecordEnd) && (Memory[Index] != 0x03))
			{
				Index++;
			}
			
			/* Check if we found the start */
			while ((Index < RecordEnd) && (Memory[Index] == 0x03))
			{
				Number=0;
				/* Skip multiple 0x03 */
				while (Memory[Index] == 0x03) Index++;
				Number = ReadNumber();
				BOOL handled = FALSE;
				
				PrintString=1;
				Label=NULL;
				switch(Number)
				{
					case 15: Label="VoicemailFile"; break;
					case 16: Label="Call"; break;
					case 20: Label="Summary"; break;
					case 36: Label="Language"; break;
					case 40: Label="Country"; break;
					case 48: Label="City"; break;
					case 51: Label="File"; break;
					case 55: Label="Peek"; break;
					case 64: Label="Email"; break;
					case 68: Label="URL"; break;
					case 72: Label="Description"; break;
					case 116: Label="Country"; break;
					case 184: Label="Phone"; break;
					case 296: Label="Type"; break;
					case 404: Label="User"; break;
					case 408: Label="User"; break;
					case 440: Label="Session"; handled=TRUE; [mSession release]; mSession = [getString(RecordEnd) retain]; break;
					case 456: Label="Members"; break; /* username */
					case 460: Label="Members"; break;
					case 468: Label="User"; break;
					case 472: Label="Name"; break;
					case 480: Label="Session"; handled=TRUE; [mSession release]; mSession = [getString(RecordEnd) retain]; break;
					case 488: Label="Sender"; handled=TRUE; [mSender release]; mSender = [getString(RecordEnd) retain]; break;
					case 492: Label="Sender"; break; /* screenname */
					case 500: Label="Recipient"; break;
					case 508: Label="Message"; handled=TRUE; tmpMessage = (NSString *)CFXMLCreateStringByUnescapingEntities(NULL, (CFStringRef)getString(RecordEnd), NULL); if (tmpMessage) [mMessage appendString:tmpMessage]; break;
					case 584: Label="Session"; handled=TRUE; [mSession release]; mSession = [getString(RecordEnd) retain]; break;
					case 588: Label="Member"; break;
					case 828: Label="User"; break;
					case 840: Label="User"; break;
					case 868: Label="Number"; break;
					case 920: Label="Screenname"; break;
					case 924: Label="Fullname"; break;
					case 3160: Label="LogBy"; break; /* username */
					default:
						PrintString=0;
						if (!mTimestamp /*!Time*/ && (Number > 1000000000))
						{
							[mTimestamp release];
							mTimestamp = [[NSDate dateWithTimeIntervalSince1970:Number] retain];
						}
						break;
				}
				
				if (!handled) {
					while((Index < RecordEnd) && (Memory[Index] > 0x03))
						Index++;
				}
			}
		}
		
		if (mTimestamp && mSender && mSession && [mMessage length]) {
			id<ServiceImporterMessage> message = [[(Class)messageClass alloc] init];
			BOOL stop = FALSE;
			
			[message setScreenname:mSender];
			[message setTimestamp:mTimestamp];
			[message setSessionName:mSession];
			[message setMessage:[NSString stringWithString:mMessage]];
			
			handler(message, &stop);
			
			if (stop)
				break;
			
			[message release];
		}
		
		[mSession release];
		mSession = nil;
		
		[mSender release];
		mSender = nil;
		
		[mMessage setString:@""];
		
		[mTimestamp release];
		mTimestamp = nil;
	}
	
	SkypeCloseFile();
	
	return TRUE;
}

@end
