#import "TableStatus.h"
#import "SPTableData.h"
#import "SPStringAdditions.h"

@implementation TableStatus

- (void)awakeFromNib
{
	// TODO: implement awake code.
}

- (void)setConnection:(CMMCPConnection *)theConnection
{
	mySQLConnection = theConnection;
	[mySQLConnection retain];
}

- (NSString*)formatValueWithKey:(NSString *)aKey inDictionary:(NSDictionary*)statusDict withLabel:(NSString*)label
{
	NSString *value = [statusDict objectForKey:aKey];
	
	if ([value isKindOfClass:[NSNull class]]) {
		value = @"--";
	} 
	else {
		// Format size strings
		if ([aKey isEqualToString:@"Data_length"]     || 
			[aKey isEqualToString:@"Max_data_length"] || 
			[aKey isEqualToString:@"Index_length"]    || 
			[aKey isEqualToString:@"Data_free"]) {
			
			value = [NSString stringForByteSize:[value intValue]];
		}
		// Format date strings to the user's long date format
		else if ([aKey isEqualToString:@"Create_time"] ||
				 [aKey isEqualToString:@"Update_time"]) {
								
			// Create date formatter
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			
			// Set the date format returned by MySQL
			[dateFormatter setDateFormat:@"%Y-%m-%d %H:%M:%S"];
			
			// Get the date instance
			NSDate *date = [dateFormatter dateFromString:value];
			
			// This behaviour should be set after the above date string is parsed to a date object so we can
			// use the below style methods.
			[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
						
			[dateFormatter setDateStyle:NSDateFormatterLongStyle];
			[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
						
			value = [dateFormatter stringFromDate:date];
		}
	}
	
	NSString* labelVal = [NSString stringWithFormat:@"%@: %@", label, value];
	
	return labelVal;
}

- (void)loadTable:(NSString *)aTable
{
	// Store the table name away for future use...
	selectedTable = aTable;
	
	// No table selected
	if([aTable isEqualToString:@""] || !aTable) {
		[tableName setStringValue:@"Name: --"];
		[tableType setStringValue:@"Type: --"];
		[tableCreatedAt setStringValue:@"Created At: --"];
		[tableUpdatedAt setStringValue:@"Updated At: --"];

		// Assign the row values...
		[rowsNumber setStringValue:@"Number Of: --"];
		[rowsFormat setStringValue:@"Format: --"];	
		[rowsAvgLength setStringValue:@"Avg. Length: --"];
		[rowsAutoIncrement setStringValue:@"Auto Increment: --"];

		// Assign the size values...
		[sizeData setStringValue:@"Data: --"]; 
		[sizeMaxData setStringValue:@"Max Data: --"];	
		[sizeIndex setStringValue:@"Index: --"]; 
		[sizeFree setStringValue:@"Free: --"];

		// Finally, set the value of the comments box
		[commentsBox setStringValue:@"--"];

		return;
	}

	// Retrieve the table status information via the table data cache
	statusFields = [tableDataInstance statusValues];

	// Assign the table values...
	[tableName setStringValue:[NSString stringWithFormat:@"Name: %@",selectedTable]];
	[tableType setStringValue:[self formatValueWithKey:@"Engine" inDictionary:statusFields withLabel:@"Type"]];
	[tableCreatedAt setStringValue:[self formatValueWithKey:@"Create_time" inDictionary:statusFields withLabel:@"Created At"]];
	[tableUpdatedAt setStringValue:[self formatValueWithKey:@"Update_time" inDictionary:statusFields withLabel:@"Updated At"]];

	// Assign the row values...
	[rowsNumber setStringValue:[self formatValueWithKey:@"Rows" inDictionary:statusFields withLabel:@"Approx. Number"]];
	[rowsFormat setStringValue:[self formatValueWithKey:@"Row_format" inDictionary:statusFields withLabel:@"Format"]];	
	[rowsAvgLength setStringValue:[self formatValueWithKey:@"Avg_row_length" inDictionary:statusFields withLabel:@"Avg. Length"]];
	[rowsAutoIncrement setStringValue:[self formatValueWithKey:@"Auto_increment" inDictionary:statusFields withLabel:@"Auto Increment"]];

	// Assign the size values...
	[sizeData setStringValue:[self formatValueWithKey:@"Data_length" inDictionary:statusFields withLabel:@"Data"]]; 
	[sizeMaxData setStringValue:[self formatValueWithKey:@"Max_data_length" inDictionary:statusFields withLabel:@"Max Data"]];	
	[sizeIndex setStringValue:[self formatValueWithKey:@"Index_length" inDictionary:statusFields withLabel:@"Index"]]; 
	[sizeFree setStringValue:[self formatValueWithKey:@"Data_free" inDictionary:statusFields withLabel:@"Free"]];	 

	// Finally, assign the comments...
	[commentsBox setStringValue:[statusFields objectForKey:@"Comment"]];

	return;
}

- (IBAction)reloadTable:(id)sender
{
	[tableDataInstance resetStatusData];
	[self loadTable:selectedTable];
}

- (id)init
{
	self = [super init];
	
	return self;
}
@end
