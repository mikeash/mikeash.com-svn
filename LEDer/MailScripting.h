/*
 * MailScripting.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class MailScriptingItem, MailScriptingApplication, MailScriptingColor, MailScriptingDocument, MailScriptingWindow, MailScriptingText, MailScriptingAttachment, MailScriptingParagraph, MailScriptingWord, MailScriptingCharacter, MailScriptingAttributeRun, MailScriptingOutgoingMessage, MailScriptingLdapServer, MailScriptingApplication, MailScriptingMessageViewer, MailScriptingSignature, MailScriptingMessage, MailScriptingAccount, MailScriptingImapAccount, MailScriptingMacAccount, MailScriptingPopAccount, MailScriptingSmtpServer, MailScriptingMailbox, MailScriptingRule, MailScriptingRuleCondition, MailScriptingRecipient, MailScriptingBccRecipient, MailScriptingCcRecipient, MailScriptingToRecipient, MailScriptingContainer, MailScriptingHeader, MailScriptingMailAttachment;

typedef enum {
	MailScriptingSavoYes = 'yes ' /* Save the file. */,
	MailScriptingSavoNo = 'no  ' /* Do not save the file. */,
	MailScriptingSavoAsk = 'ask ' /* Ask the user whether or not to save the file. */
} MailScriptingSavo;

typedef enum {
	MailScriptingEdmfPlainText = 'dmpt' /* Plain Text */,
	MailScriptingEdmfRichText = 'dmrt' /* Rich Text */
} MailScriptingEdmf;

typedef enum {
	MailScriptingHedeAll = 'hdal' /* All */,
	MailScriptingHedeCustom = 'hdcu' /* Custom */,
	MailScriptingHedeDefault = 'hdde' /* Default */,
	MailScriptingHedeNoHeaders = 'hdnn' /* No headers */
} MailScriptingHede;

typedef enum {
	MailScriptingLdasBase = 'lsba' /* LDAP scope of 'Base' */,
	MailScriptingLdasOneLevel = 'lsol' /* LDAP scope of 'One Level' */,
	MailScriptingLdasSubtree = 'lsst' /* LDAP scope of 'Subtree' */
} MailScriptingLdas;

typedef enum {
	MailScriptingQqclBlue = 'ccbl' /* Blue */,
	MailScriptingQqclGreen = 'ccgr' /* Green */,
	MailScriptingQqclOrange = 'ccor' /* Orange */,
	MailScriptingQqclOther = 'ccot' /* Other */,
	MailScriptingQqclPurple = 'ccpu' /* Purple */,
	MailScriptingQqclRed = 'ccre' /* Red */,
	MailScriptingQqclYellow = 'ccye' /* Yellow */
} MailScriptingQqcl;

typedef enum {
	MailScriptingMvclAttachmentsColumn = 'ecat' /* Column containing the number of attachments a message contains */,
	MailScriptingMvclBuddyAvailabilityColumn = 'ecba' /* Column indicating whether the sender of a message is online or not */,
	MailScriptingMvclMessageColor = 'eccl' /* Used to indicate sorting should be done by color */,
	MailScriptingMvclDateReceivedColumn = 'ecdr' /* Column containing the date a message was received */,
	MailScriptingMvclDateSentColumn = 'ecds' /* Column containing the date a message was sent */,
	MailScriptingMvclFlagsColumn = 'ecfl' /* Column containing the flags of a message */,
	MailScriptingMvclFromColumn = 'ecfr' /* Column containing the sender's name */,
	MailScriptingMvclMailboxColumn = 'ecmb' /* Column containing the name of the mailbox or account a message is in */,
	MailScriptingMvclMessageStatusColumn = 'ecms' /* Column indicating a messages status (read, unread, replied to, forwarded, etc) */,
	MailScriptingMvclNumberColumn = 'ecnm' /* Column containing the number of a message in a mailbox */,
	MailScriptingMvclSizeColumn = 'ecsz' /* Column containing the size of a message */,
	MailScriptingMvclSubjectColumn = 'ecsu' /* Column containing the subject of a message */,
	MailScriptingMvclToColumn = 'ecto' /* Column containing the recipients of a message */
} MailScriptingMvcl;

typedef enum {
	MailScriptingExutPassword = 'axct' /* Clear text password */,
	MailScriptingExutApop = 'aapo' /* APOP */,
	MailScriptingExutKerberos5 = 'axk5' /* Kerberos 5 */,
	MailScriptingExutNtlm = 'axnt' /* NTLM */,
	MailScriptingExutMd5 = 'axmd' /* MD5 */,
	MailScriptingExutNone = 'ccno' /* None */
} MailScriptingExut;

typedef enum {
	MailScriptingCclrBlue = 'ccbl' /* Blue */,
	MailScriptingCclrGray = 'ccgy' /* Gray */,
	MailScriptingCclrGreen = 'ccgr' /* Green */,
	MailScriptingCclrNone = 'ccno' /* None */,
	MailScriptingCclrOrange = 'ccor' /* Orange */,
	MailScriptingCclrOther = 'ccot' /* Other */,
	MailScriptingCclrPurple = 'ccpu' /* Purple */,
	MailScriptingCclrRed = 'ccre' /* Red */,
	MailScriptingCclrYellow = 'ccye' /* Yellow */
} MailScriptingCclr;

typedef enum {
	MailScriptingE9xpAllMessagesAndTheirAttachments = 'x9al' /* All messages and their attachments */,
	MailScriptingE9xpAllMessagesButOmitAttachments = 'x9bo' /* All messages but omit attachments */,
	MailScriptingE9xpDoNotKeepCopiesOfAnyMessages = 'x9no' /* Do not keep copies of any messages */,
	MailScriptingE9xpOnlyMessagesIHaveRead = 'x9wr' /* Only messages I have read */
} MailScriptingE9xp;

typedef enum {
	MailScriptingEnrqBeginsWithValue = 'rqbw' /* Begins with value */,
	MailScriptingEnrqDoesContainValue = 'rqco' /* Does contain value */,
	MailScriptingEnrqDoesNotContainValue = 'rqdn' /* Does not contain value */,
	MailScriptingEnrqEndsWithValue = 'rqew' /* Ends with value */,
	MailScriptingEnrqEqualToValue = 'rqie' /* Equal to value */,
	MailScriptingEnrqLessThanValue = 'rqlt' /* Less than value */,
	MailScriptingEnrqGreaterThanValue = 'rqgt' /* Greater than value */,
	MailScriptingEnrqNone = 'rqno' /* Indicates no qualifier is applicable */
} MailScriptingEnrq;

typedef enum {
	MailScriptingErutAccount = 'tacc' /* Account */,
	MailScriptingErutAnyRecipient = 'tanr' /* Any recipient */,
	MailScriptingErutCcHeader = 'tccc' /* Cc header */,
	MailScriptingErutMatchesEveryMessage = 'tevm' /* Every message */,
	MailScriptingErutFromHeader = 'tfro' /* From header */,
	MailScriptingErutHeaderKey = 'thdk' /* An arbitrary header key */,
	MailScriptingErutMessageContent = 'tmec' /* Message content */,
	MailScriptingErutMessageIsJunkMail = 'tmij' /* Message is junk mail */,
	MailScriptingErutSenderIsInMyAddressBook = 'tsii' /* Sender is in my address book */,
	MailScriptingErutSenderIsMemberOfGroup = 'tsim' /* Sender is member of group */,
	MailScriptingErutSenderIsNotInMyAddressBook = 'tsin' /* Sender is not in my address book */,
	MailScriptingErutSenderIsNotMemberOfGroup = 'tsig' /* Sender is not member of group */,
	MailScriptingErutSubjectHeader = 'tsub' /* Subject header */,
	MailScriptingErutToHeader = 'ttoo' /* To header */,
	MailScriptingErutToOrCcHeader = 'ttoc' /* To or Cc header */
} MailScriptingErut;

typedef enum {
	MailScriptingEtocImap = 'etim' /* IMAP */,
	MailScriptingEtocPop = 'etpo' /* POP */,
	MailScriptingEtocSmtp = 'etsm' /* SMTP */,
	MailScriptingEtocMac = 'etit' /* .Mac */
} MailScriptingEtoc;



/*
 * Standard Suite
 */

// Abstract object provides a base class for scripting classes.  It is never used directly.
@interface MailScriptingItem : SBObject

@property (copy) NSDictionary *properties;  // All of the object's properties.

- (void) open;  // Open an object.
- (void) print;  // Print an object.
- (void) closeSaving:(MailScriptingSavo)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveIn:(NSString *)in_ as:(NSString *)as;  // Save an object.

@end

// An application's top level scripting object.
@interface MailScriptingApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the frontmost (active) application?
@property (copy, readonly) NSString *version;  // The version of the application.

- (void) quitSaving:(MailScriptingSavo)saving;  // Quit an application.
- (void) checkForNewMailFor:(MailScriptingAccount *)for_;  // Triggers a check for email.
- (NSString *) extractNameFrom:(NSString *)x;  // Command to get the full name out of a fully specified email address. E.g. Calling this with "John Doe <jdoe@example.com>" as the direct object would return "John Doe"
- (NSString *) extractAddressFrom:(NSString *)x;  // Command to get just the email address of a fully specified email address. E.g. Calling this with "John Doe <jdoe@example.com>" as the direct object would return "jdoe@example.com"
- (void) GetURL:(NSString *)x;  // Opens a mailto URL.
- (void) importMailMailboxAt:(NSString *)at;  // Imports a mailbox in Mail's mbox format.
- (void) mailto:(NSString *)x;  // Opens a mailto URL.
- (void) performMailActionWithMessages:(NSArray *)x inMailboxes:(MailScriptingMailbox *)inMailboxes forRule:(MailScriptingRule *)forRule;  // Script handler invoked by rules and menus that execute AppleScripts.  The direct parameter of this handler is a list of messages being acted upon.
- (void) synchronizeWith:(MailScriptingAccount *)with;  // Command to trigger synchronizing of an IMAP account with the server.

@end

// A color.
@interface MailScriptingColor : SBObject

- (void) open;  // Open an object.
- (void) print;  // Print an object.
- (void) closeSaving:(MailScriptingSavo)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveIn:(NSString *)in_ as:(NSString *)as;  // Save an object.

@end

// A document.
@interface MailScriptingDocument : SBObject

@property (copy) NSString *path;  // The document's path.
@property (readonly) BOOL modified;  // Has the document been modified since the last save?
@property (copy) NSString *name;  // The document's name.

- (void) open;  // Open an object.
- (void) print;  // Print an object.
- (void) closeSaving:(MailScriptingSavo)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveIn:(NSString *)in_ as:(NSString *)as;  // Save an object.

@end

// A window.
@interface MailScriptingWindow : SBObject

@property (copy) NSString *name;  // The full title of the window.
- (NSInteger) id;  // The unique identifier of the window.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Whether the window has a close box.
@property (readonly) BOOL titled;  // Whether the window has a title bar.
@property NSInteger index;  // The index of the window in the back-to-front window ordering.
@property (readonly) BOOL floating;  // Whether the window floats.
@property (readonly) BOOL miniaturizable;  // Whether the window can be miniaturized.
@property BOOL miniaturized;  // Whether the window is currently miniaturized.
@property (readonly) BOOL modal;  // Whether the window is the application's current modal window.
@property (readonly) BOOL resizable;  // Whether the window can be resized.
@property BOOL visible;  // Whether the window is currently visible.
@property (readonly) BOOL zoomable;  // Whether the window can be zoomed.
@property BOOL zoomed;  // Whether the window is currently zoomed.

- (void) open;  // Open an object.
- (void) print;  // Print an object.
- (void) closeSaving:(MailScriptingSavo)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveIn:(NSString *)in_ as:(NSString *)as;  // Save an object.

@end



/*
 * Text Suite
 */

// Rich (styled) text
@interface MailScriptingText : SBObject

- (SBElementArray *) paragraphs;
- (SBElementArray *) words;
- (SBElementArray *) characters;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) attachments;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property (copy) NSNumber *size;  // The size in points of the first character.

- (void) open;  // Open an object.
- (void) print;  // Print an object.
- (void) closeSaving:(MailScriptingSavo)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveIn:(NSString *)in_ as:(NSString *)as;  // Save an object.
- (NSString *) extractNameFrom;  // Command to get the full name out of a fully specified email address. E.g. Calling this with "John Doe <jdoe@example.com>" as the direct object would return "John Doe"
- (NSString *) extractAddressFrom;  // Command to get just the email address of a fully specified email address. E.g. Calling this with "John Doe <jdoe@example.com>" as the direct object would return "jdoe@example.com"
- (void) GetURL;  // Opens a mailto URL.
- (void) mailto;  // Opens a mailto URL.

@end

// Represents an inline text attachment.  This class is used mainly for make commands.
@interface MailScriptingAttachment : MailScriptingText

@property (copy) NSString *fileName;  // The path to the file for the attachment


@end

// This subdivides the text into paragraphs.
@interface MailScriptingParagraph : MailScriptingText


@end

// This subdivides the text into words.
@interface MailScriptingWord : MailScriptingText


@end

// This subdivides the text into characters.
@interface MailScriptingCharacter : MailScriptingText


@end

// This subdivides the text into chunks that all have the same attributes.
@interface MailScriptingAttributeRun : MailScriptingText


@end



/*
 * Mail
 */

// A new email message
@interface MailScriptingOutgoingMessage : MailScriptingItem

- (SBElementArray *) bccRecipients;
- (SBElementArray *) ccRecipients;
- (SBElementArray *) recipients;
- (SBElementArray *) toRecipients;

@property (copy) NSString *sender;  // The sender of the message
@property (copy) NSString *subject;  // The subject of the message
@property (copy) MailScriptingText *content;  // The contents of the message
@property BOOL visible;  // Controls whether the message window is shown on the screen.  The default is false
@property (copy) MailScriptingSignature *messageSignature;  // The signature of the message
- (NSInteger) id;  // The unique identifier of the message

- (BOOL) send;  // Sends a message.

@end

// LDAP servers for use in type completion in Mail
@interface MailScriptingLdapServer : MailScriptingItem

@property BOOL enabled;  // Indicates whether this LDAP server will be used for type completion in Mail
@property (copy) NSString *name;  // Name of LDAP server configuration to be displayed in Composing preferences
@property NSInteger port;  // Port number for the LDAP server (default is 389)
@property MailScriptingLdas scope;  // Scope setting for the LDAP server
@property (copy) NSString *searchBase;  // Search base for this LDAP server (not required by all LDAP servers)
@property (copy) NSString *hostName;  // Internet address (myldapserver.company.com) for LDAP server


@end

// Mail's top level scripting object.
@interface MailScriptingApplication (Mail)

- (SBElementArray *) accounts;
- (SBElementArray *) outgoingMessages;
- (SBElementArray *) smtpServers;
- (SBElementArray *) MacAccounts;
- (SBElementArray *) imapAccounts;
- (SBElementArray *) ldapServers;
- (SBElementArray *) mailboxes;
- (SBElementArray *) messageViewers;
- (SBElementArray *) popAccounts;
- (SBElementArray *) rules;
- (SBElementArray *) signatures;

@property (copy, readonly) NSString *version;  // The version of the application.
@property BOOL alwaysBccMyself;  // Indicates whether you will be included in the Bcc: field of messages which you are composing
@property BOOL alwaysCcMyself;  // Indicates whether you will be included in the Cc: field of messages which you are composing
@property (copy, readonly) NSArray *selection;  // List of messages that the user has selected
@property (copy, readonly) NSString *applicationVersion;  // The build number for the Mail application bundle
@property NSInteger fetchInterval;  // The interval (in minutes) between automatic fetches of new mail
@property (readonly) NSInteger backgroundActivityCount;  // Number of background activities currently running in Mail, according to the Activity Viewer
@property BOOL chooseSignatureWhenComposing;  // Indicates whether user can choose a signature directly in a new compose window
@property BOOL colorQuotedText;  // Indicates whether quoted text should be colored
@property MailScriptingEdmf defaultMessageFormat;  // Default format for messages being composed or message replies
@property BOOL downloadHtmlAttachments;  // Indicates whether images and attachments in HTML messages should be downloaded and displayed
@property (copy, readonly) MailScriptingMailbox *draftsMailbox;  // The top level Drafts mailbox
@property BOOL expandGroupAddresses;  // Indicates whether group addresses will be expanded when entered into the address fields of a new compose message
@property (copy) NSString *fixedWidthFont;  // Font for plain text messages, only used if 'use fixed width font' is set to true
@property double fixedWidthFontSize;  // Font size for plain text messages, only used if 'use fixed width font' is set to true
@property (copy, readonly) NSString *frameworkVersion;  // The build number for the Message framework, used by Mail
@property MailScriptingHede headerDetail;  // The level of detail shown for headers on incoming messages
@property (copy, readonly) MailScriptingMailbox *inbox;  // The top level In mailbox
@property BOOL includeAllOriginalMessageText;  // Indicates whether all of the original message will be quoted or only the text you have selected (if any)
@property BOOL quoteOriginalMessage;  // Indicates whether the text of the original message will be included in replies
@property BOOL checkSpellingWhileTyping;  // Indicates whether spelling will be checked automatically in messages being composed
@property (copy, readonly) MailScriptingMailbox *junkMailbox;  // The top level Junk mailbox
@property MailScriptingQqcl levelOneQuotingColor;  // Color for quoted text with one level of indentation
@property MailScriptingQqcl levelTwoQuotingColor;  // Color for quoted text with two levels of indentation
@property MailScriptingQqcl levelThreeQuotingColor;  // Color for quoted text with three levels of indentation
@property (copy) NSString *messageFont;  // Font for messages (proportional font)
@property double messageFontSize;  // Font size for messages (proportional font)
@property (copy) NSString *messageListFont;  // Font for message list
@property double messageListFontSize;  // Font size for message list
@property (copy) NSString *newMailSound;  // Name of new mail sound or 'None' if no sound is selected
@property (copy, readonly) MailScriptingMailbox *outbox;  // The top level Out mailbox
@property BOOL shouldPlayOtherMailSounds;  // Indicates whether sounds will be played for various things such as when a messages is sent or if no mail is found when manually checking for new mail or if there is a fetch error
@property BOOL sameReplyFormat;  // Indicates whether replies will be in the same text format as the message to which you are replying
@property (copy) NSString *selectedSignature;  // Name of current selected signature (or 'randomly', 'sequentially', or 'none')
@property (copy, readonly) MailScriptingMailbox *sentMailbox;  // The top level Sent mailbox
@property BOOL fetchesAutomatically;  // Indicates whether mail will automatically be fetched at a specific interval
@property BOOL highlightSelectedThread;  // Indicates whether threads should be highlighted in the Mail viewer window
@property BOOL showOnlineBuddyStatus;  // Indicates whether Mail will show online buddy status
@property (copy, readonly) MailScriptingMailbox *trashMailbox;  // The top level Trash mailbox
@property BOOL useAddressCompletion;  // Indicates whether network directories (LDAP) and Address Book will be used for address completion
@property BOOL useFixedWidthFont;  // Should fixed-width font be used for plain text messages?
@property (copy, readonly) NSString *primaryEmail;  // The user's primary email address

@end

// Represents the object responsible for managing a viewer window
@interface MailScriptingMessageViewer : MailScriptingItem

- (SBElementArray *) messages;

@property (copy, readonly) MailScriptingMailbox *draftsMailbox;  // The top level Drafts mailbox
@property (copy, readonly) MailScriptingMailbox *inbox;  // The top level In mailbox
@property (copy, readonly) MailScriptingMailbox *junkMailbox;  // The top level Junk mailbox
@property (copy, readonly) MailScriptingMailbox *outbox;  // The top level Out mailbox
@property (copy, readonly) MailScriptingMailbox *sentMailbox;  // The top level Sent mailbox
@property (copy, readonly) MailScriptingMailbox *trashMailbox;  // The top level Trash mailbox
@property MailScriptingMvcl sortColumn;  // The column that is currently sorted in the viewer
@property BOOL sortedAscending;  // Whether the viewer is sorted ascending or not
@property BOOL mailboxListVisible;  // Controls whether the list of mailboxes is visible or not
@property BOOL previewPaneIsVisible;  // Controls whether the preview pane of the message viewer window is visible or not
@property MailScriptingMvcl visibleColumns;  // List of columns that are visible.  The subject column and the message status column will always be visible
- (NSInteger) id;  // The unique identifier of the message viewer
@property (copy) NSArray *visibleMessages;  // List of messages currently being displayed in the viewer
@property (copy) NSArray *selectedMessages;  // List of messages currently selected
@property (copy) NSArray *selectedMailboxes;  // List of mailboxes currently selected in the list of mailboxes
@property (copy) MailScriptingWindow *window;  // The window for the message viewer


@end

// Email signatures
@interface MailScriptingSignature : MailScriptingItem

@property (copy) NSString *content;  // Contents of email signature. If there is a version with fonts and/or styles, that will be returned over the plain text version
@property (copy) NSString *name;  // Name of the signature


@end



/*
 * Message
 */

// An email message
@interface MailScriptingMessage : MailScriptingItem

- (SBElementArray *) bccRecipients;
- (SBElementArray *) ccRecipients;
- (SBElementArray *) recipients;
- (SBElementArray *) toRecipients;
- (SBElementArray *) headers;
- (SBElementArray *) mailAttachments;

- (NSInteger) id;  // The unique identifier of the message.
@property (copy, readonly) NSString *allHeaders;  // All the headers of the message
@property MailScriptingCclr backgroundColor;  // The background color of the message
@property (copy) MailScriptingMailbox *mailbox;  // The mailbox in which this message is filed
@property (copy) MailScriptingText *content;  // Contents of an email message
@property (copy, readonly) NSDate *dateReceived;  // The date a message was received
@property (copy, readonly) NSDate *dateSent;  // The date a message was sent
@property BOOL deletedStatus;  // Indicates whether the message is deleted or not
@property BOOL flaggedStatus;  // Indicates whether the message is flagged or not
@property BOOL junkMailStatus;  // Indicates whether the message has been marked junk or evaluated to be junk by the junk mail filter.
@property BOOL readStatus;  // Indicates whether the message is read or not
@property (copy, readonly) NSString *messageId;  // The unique message ID string
@property (copy, readonly) NSString *source;  // Raw source of the message
@property (copy) NSString *replyTo;  // The address that replies should be sent to
@property NSInteger messageSize;  // The size (in bytes) of a message
@property (copy) NSString *sender;  // The sender of the message
@property (copy) NSString *subject;  // The subject of the message
@property BOOL wasForwarded;  // Indicates whether the message was forwarded or not
@property BOOL wasRedirected;  // Indicates whether the message was redirected or not
@property BOOL wasRepliedTo;  // Indicates whether the message was replied to or not

- (void) bounce;  // Bounces a message back to the sender.
- (void) delete;  // Delete a message.
- (void) duplicateTo:(MailScriptingMailbox *)to;  // Copy message(s) and put the copies in the specified mailbox.
- (MailScriptingOutgoingMessage *) forwardOpeningWindow:(BOOL)openingWindow;  // Creates a forwarded message.
- (void) moveTo:(MailScriptingMailbox *)to;  // Move message(s) to a new mailbox.
- (MailScriptingOutgoingMessage *) redirectOpeningWindow:(BOOL)openingWindow;  // Creates a redirected message.
- (MailScriptingOutgoingMessage *) replyOpeningWindow:(BOOL)openingWindow replyToAll:(BOOL)replyToAll;  // Creates a reply message.

@end

// A Mail account for receiving messages (IMAP/POP/.Mac). To create a new receiving account, use the 'pop account', 'imap account', and 'Mac account' objects
@interface MailScriptingAccount : MailScriptingItem

- (SBElementArray *) mailboxes;

@property (copy) MailScriptingSmtpServer *deliveryAccount;  // The delivery account used when sending mail from this account
@property (copy) NSString *name;  // The name of an account
@property (copy) NSString *password;  // Password for this account. Can be set, but not read via scripting
@property MailScriptingExut authentication;  // Preferred authentication scheme for account
@property (readonly) MailScriptingEtoc accountType;  // The type of an account
@property (copy) NSArray *emailAddresses;  // The list of email addresses configured for an account
@property (copy) NSString *fullName;  // The users full name configured for an account
@property NSInteger emptyJunkMessagesFrequency;  // Number of days before junk messages are deleted (0 = delete on quit, -1 = never delete)
@property NSInteger emptySentMessagesFrequency;  // Number of days before archived sent messages are deleted (0 = delete on quit, -1 = never delete)
@property NSInteger emptyTrashFrequency;  // Number of days before messages in the trash are permanently deleted (0 = delete on quit, -1 = never delete)
@property BOOL emptyJunkMessagesOnQuit;  // Indicates whether the messages in the junk messages mailboxes will be deleted on quit
@property BOOL emptySentMessagesOnQuit;  // Indicates whether the messages in the sent messages mailboxes will be deleted on quit
@property BOOL emptyTrashOnQuit;  // Indicates whether the messages in deleted messages mailboxes will be permanently deleted on quit
@property BOOL enabled;  // Indicates whether the account is enabled or not
@property (copy) NSString *userName;  // The user name used to connect to an account
@property (copy, readonly) NSURL *accountDirectory;  // The directory where the account stores things on disk
@property NSInteger port;  // The port used to connect to an account
@property (copy) NSString *serverName;  // The host name used to connect to an account
@property BOOL includeWhenGettingNewMail;  // Indicates whether the account will be included when getting new mail
@property BOOL moveDeletedMessagesToTrash;  // Indicates whether messages that are deleted will be moved to the trash mailbox
@property BOOL usesSsl;  // Indicates whether SSL is enabled for this receiving account


@end

// An IMAP email account
@interface MailScriptingImapAccount : MailScriptingAccount

@property BOOL compactMailboxesWhenClosing;  // Indicates whether an IMAP mailbox is automatically compacted when you quit Mail or switch to another mailbox
@property MailScriptingE9xp messageCaching;  // Message caching setting for this account
@property BOOL storeDraftsOnServer;  // Indicates whether drafts will be stored on the IMAP server
@property BOOL storeJunkMailOnServer;  // Indicates whether junk mail will be stored on the IMAP server
@property BOOL storeSentMessagesOnServer;  // Indicates whether sent messages will be stored on the IMAP server
@property BOOL storeDeletedMessagesOnServer;  // Indicates whether deleted messages will be stored on the IMAP server


@end

// A .Mac email account
@interface MailScriptingMacAccount : MailScriptingImapAccount


@end

// A POP email account
@interface MailScriptingPopAccount : MailScriptingAccount

@property NSInteger bigMessageWarningSize;  // If message size (in bytes) is over this amount, Mail will prompt you asking whether you want to download the message (-1 = do not prompt)
@property NSInteger delayedMessageDeletionInterval;  // Number of days before messages that have been downloaded will be deleted from the server (0 = delete immediately after downloading)
@property BOOL deleteMailOnServer;  // Indicates whether POP account deletes messages on the server after downloading
@property BOOL deleteMessagesWhenMovedFromInbox;  // Indicates whether messages will be deleted from the server when moved from your POP inbox


@end

// An SMTP account (for sending email)
@interface MailScriptingSmtpServer : MailScriptingItem

@property (copy, readonly) NSString *name;  // The name of an account
@property (copy) NSString *password;  // Password for this account. Can be set, but not read via scripting
@property (readonly) MailScriptingEtoc accountType;  // The type of an account
@property MailScriptingExut authentication;  // Preferred authentication scheme for account
@property BOOL enabled;  // Indicates whether the account is enabled or not
@property (copy) NSString *userName;  // The user name used to connect to an account
@property NSInteger port;  // The port used to connect to an account
@property (copy) NSString *serverName;  // The host name used to connect to an account
@property BOOL usesSsl;  // Indicates whether SSL is enabled for this receiving account


@end

// A mailbox that holds messages
@interface MailScriptingMailbox : MailScriptingItem

- (SBElementArray *) mailboxes;
- (SBElementArray *) messages;

@property (copy) NSString *name;  // The name of a mailbox
@property (readonly) NSInteger unreadCount;  // The number of unread messages in the mailbox
@property (copy, readonly) MailScriptingAccount *account;
@property (copy, readonly) MailScriptingMailbox *container;


@end

// Class for message rules
@interface MailScriptingRule : MailScriptingItem

- (SBElementArray *) ruleConditions;

@property MailScriptingCclr colorMessage;  // If rule matches, apply this color
@property BOOL deleteMessage;  // If rule matches, delete message
@property (copy) NSString *forwardText;  // If rule matches, prepend this text to the forwarded message. Set to empty string to include no prepended text
@property (copy) NSString *forwardMessage;  // If rule matches, forward message to this address, or multiple addresses, separated by commas. Set to empty string to disable this action
@property BOOL markFlagged;  // If rule matches, mark message as flagged
@property BOOL markRead;  // If rule matches, mark message as read
@property (copy) NSString *playSound;  // If rule matches, play this sound (specify name of sound or path to sound)
@property (copy) NSArray *redirectMessage;  // If rule matches, redirect message to this address or multiple addresses, separate by commas. Set to empty string to disable this action
@property (copy) NSString *replyText;  // If rule matches, reply to message and prepend with this text. Set to empty string to disable this action
@property (copy) NSURL *runScript;  // If rule matches, run this AppleScript.  Set to POSIX path of compiled AppleScript file.  Set to empty string to disable this action
@property BOOL allConditionsMustBeMet;  // Indicates whether all conditions must be met for rule to execute
@property (copy) MailScriptingMailbox *copyMessage;  // If rule matches, copy to this mailbox
@property (copy) MailScriptingMailbox *moveMessage;  // If rule matches, move to this mailbox
@property BOOL highlightTextUsingColor;  // Indicates whether the color will be used to highlight the text or background of a message in the message list
@property BOOL enabled;  // Indicates whether the rule is enabled
@property (copy) NSString *name;  // Name of rule
@property BOOL shouldCopyMessage;  // Indicates whether the rule has a copy action
@property BOOL shouldMoveMessage;  // Indicates whether the rule has a transfer action
@property BOOL stopEvaluatingRules;  // If rule matches, stop rule evaluation for this message


@end

// Class for conditions that can be attached to a single rule
@interface MailScriptingRuleCondition : MailScriptingItem

@property (copy) NSString *expression;  // Rule expression field
@property (copy) NSString *header;  // Rule header key
@property MailScriptingEnrq qualifier;  // Rule qualifier
@property MailScriptingErut ruleType;  // Rule type


@end

// An email recipient
@interface MailScriptingRecipient : MailScriptingItem

@property (copy) NSString *address;  // The recipients email address
@property (copy) NSString *name;  // The name used for display


@end

// An email recipient in the Bcc: field
@interface MailScriptingBccRecipient : MailScriptingRecipient


@end

// An email recipient in the Cc: field
@interface MailScriptingCcRecipient : MailScriptingRecipient


@end

// An email recipient in the To: field
@interface MailScriptingToRecipient : MailScriptingRecipient


@end

// A mailbox that contains other mailboxes.
@interface MailScriptingContainer : MailScriptingMailbox


@end

// A header value for a message.  E.g. To, Subject, From.
@interface MailScriptingHeader : MailScriptingItem

@property (copy) NSString *content;  // Contents of the header
@property (copy) NSString *name;  // Name of the header value


@end

// A file attached to a received message.
@interface MailScriptingMailAttachment : MailScriptingItem

@property (copy, readonly) NSString *name;  // Name of the attachment
@property (copy, readonly) NSString *MIMEType;  // MIME type of the attachment E.g. text/plain.
@property (readonly) NSInteger fileSize;  // Approximate size in bytes.
@property (readonly) BOOL downloaded;  // Indicates whether the attachment has been downloaded.
- (NSString *) id;  // The unique identifier of the attachment.


@end

