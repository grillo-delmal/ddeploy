/**
    Apple MobileDevice framework support
*/
module apple.mobiledevice;
import core.sys.darwin.mach.kern_return;
import core.sys.darwin.string;

struct cf_string_t;
alias CFStringRef = cf_string_t*;

struct cf_allocator_t;
alias CFAllocatorRef = cf_allocator_t*;

struct cf_dictionary_t;
alias CFDictionaryRef = cf_dictionary_t*;

struct cf_mutable_dictionary_t;
alias CFMutableDictionaryRef = cf_mutable_dictionary_t*;

struct cf_type_t;
alias CFTypeRef = cf_type_t*;

alias mach_error_t = kern_return_t;

/* Error codes */
enum err_system(uint x)             = (((x) & 0x3f) << 26);
enum err_sub(uint x)                = (((x) & 0xfff) << 14);

enum uint MDERR_APPLE_MOBILE        = (err_system!(0x3a));
enum uint MDERR_IPHONE              = (err_sub!(0));
enum uint ERR_MOBILE_DEVICE         = 0;

/* Apple Mobile (AM*) errors */
enum uint MDERR_OK = KERN_SUCCESS;
enum uint MDERR_SYSCALL = (ERR_MOBILE_DEVICE | 0x01);
enum uint MDERR_OUT_OF_MEMORY = (ERR_MOBILE_DEVICE | 0x03);
enum uint MDERR_QUERY_FAILED = (ERR_MOBILE_DEVICE | 0x04);
enum uint MDERR_INVALID_ARGUMENT = (ERR_MOBILE_DEVICE | 0x0b);
enum uint MDERR_DICT_NOT_LOADED = (ERR_MOBILE_DEVICE | 0x25);

/* Apple File Connection (AFC*) errors */
enum uint MDERR_AFC_OUT_OF_MEMORY = 0x03;

/* USBMux errors */
enum uint MDERR_USBMUX_ARG_NULL = 0x16;
enum uint MDERR_USBMUX_FAILED = 0xffffffff;

/* Messages passed to device notification callbacks: passed as part of
 * am_device_notification_callback_info. */
enum int ADNCI_MSG_CONNECTED = 1;
enum int ADNCI_MSG_DISCONNECTED = 2;
enum int ADNCI_MSG_UNKNOWN = 3;

enum uint AMD_IPHONE_PRODUCT_ID = 0x1290;
enum string AMD_IPHONE_SERIAL = "3391002d9c804d105e2c8c7d94fc35b6f3d214a3";

/* Services, found in /System/Library/Lockdown/Services.plist */
enum string AMSVC_AFC = "com.apple.afc";
enum string AMSVC_BACKUP = "com.apple.mobilebackup";
enum string AMSVC_CRASH_REPORT_COPY = "com.apple.crashreportcopy";
enum string AMSVC_DEBUG_IMAGE_MOUNT = "com.apple.mobile.debug_image_mount";
enum string AMSVC_NOTIFICATION_PROXY = "com.apple.mobile.notification_proxy";
enum string AMSVC_PURPLE_TEST = "com.apple.purpletestr";
enum string AMSVC_SOFTWARE_UPDATE = "com.apple.mobile.software_update";
enum string AMSVC_SYNC = "com.apple.mobilesync";
enum string AMSVC_SCREENSHOT = "com.apple.screenshotr";
enum string AMSVC_SYSLOG_RELAY = "com.apple.syslog_relay";
enum string AMSVC_SYSTEM_PROFILER = "com.apple.mobile.system_profiler";

alias afc_error_t = uint;
alias usbmux_error_t = uint;

struct service_conn_t {
    ubyte[0x10] unknown;
    int sockfd;
    void* sslContext;
    // ??
}

alias ServiceConnRef = service_conn_t*;

struct am_device_notification_callback_info_t {
    am_device_t* dev; /* 0    device */
    uint msg; /* 4    one of ADNCI_MSG_* */
}

/* The type of the device restore notification callback functions.
 * TODO: change to correct type. */
alias am_restore_device_notification_callback = void function(
    am_recovery_device_t * );

/* This is a CoreFoundation object of class AMRecoveryModeDevice. */
struct am_recovery_device_t {
    ubyte[8] unknown0; /* 0 */
    am_restore_device_notification_callback callback; /* 8 */
    void* user_info; /* 12 */
    ubyte[12] unknown1; /* 16 */
    uint readwrite_pipe; /* 28 */
    ubyte read_pipe; /* 32 */
    ubyte write_ctrl_pipe; /* 33 */
    ubyte read_unknown_pipe; /* 34 */
    ubyte write_file_pipe; /* 35 */
    ubyte write_input_pipe; /* 36 */
}

/* A CoreFoundation object of class AMRestoreModeDevice. */
struct am_restore_device_t {
    ubyte[32] unknown;
    int port;
}

/* The type of the device notification callback function. */
alias am_device_notification_callback = void function(
    am_device_notification_callback_info_t*, void* arg);

/* The type of the _AMDDeviceAttached function.
 * TODO: change to correct type. */
alias amd_device_attached_callback = void function();

struct am_device_t {
    ubyte[16] unknown0; /* 0 - zero */
    uint device_id; /* 16 */
    uint product_id; /* 20 - set to AMD_IPHONE_PRODUCT_ID */
    char* serial; /* 24 - set to AMD_IPHONE_SERIAL */
    uint unknown1; /* 28 */
    ubyte[4] unknown2; /* 32 */
    uint lockdown_conn; /* 36 */
    ubyte[8] unknown3; /* 40 */
}

struct am_device_notification_t {
    uint unknown0; /* 0 */
    uint unknown1; /* 4 */
    uint unknown2; /* 8 */
    am_device_notification_callback callback; /* 12 */
    uint unknown3; /* 16 */
}

struct afc_connection_t {
    uint handle; /* 0 */
    uint unknown0; /* 4 */
    ubyte unknown1; /* 8 */
    ubyte[3] padding; /* 9 */
    uint unknown2; /* 12 */
    uint unknown3; /* 16 */
    uint unknown4; /* 20 */
    uint fs_block_size; /* 24 */
    uint sock_block_size; /* 28: always 0x3c */
    uint io_timeout; /* 32: from AFCConnectionOpen, usu. 0 */
    void* afc_lock; /* 36 */
    uint context; /* 40 */
}

alias AFCConnectionRef = afc_connection_t*;

struct afc_directory_t {
    ubyte[0] unknown; /* size unknown */
}

struct afc_dictionary_t {
    ubyte[0] unknown; /* size unknown */
}

alias afc_file_ref_t = ulong;

struct usbmux_listener_1_t { /* offset   value in iTunes */
    uint unknown0; /* 0        1 */
    ubyte* unknown1; /* 4        ptr, maybe device? */
    amd_device_attached_callback callback; /* 8        _AMDDeviceAttached */
    uint unknown3; /* 12 */
    uint unknown4; /* 16 */
    uint unknown5; /* 20 */
}

struct usbmux_listener_2_t {
    ubyte[4144] unknown0;
}

struct am_bootloader_control_packet_t {
    ubyte opcode; /* 0 */
    ubyte length; /* 1 */
    ubyte[2] magic; /* 2: 0x34, 0x12 */
    ubyte[0] payload; /* 4 */
}

/* ----------------------------------------------------------------------------
 *   Public routines
 * ------------------------------------------------------------------------- */

void AMDSetLogLevel(int level);

/*  Registers a notification with the current run loop. The callback gets
 *  copied into the notification struct, as well as being registered with the
 *  current run loop. dn_unknown3 gets copied into unknown3 in the same.
 *  (Maybe dn_unknown3 is a user info parameter that gets passed as an arg to
 *  the callback?) unused0 and unused1 are both 0 when iTunes calls this.
 *  In iTunes the callback is located from $3db78e-$3dbbaf.
 *
 *  Returns:
 *      MDERR_OK            if successful
 *      MDERR_SYSCALL       if CFRunLoopAddSource() failed
 *      MDERR_OUT_OF_MEMORY if we ran out of memory
 */

mach_error_t AMDeviceNotificationSubscribeWithOptions(
    am_device_notification_callback callback, uint unused0, uint unused1, void*  //uint
        dn_unknown3, am_device_notification_t** notification, CFDictionaryRef options);

/*  Connects to the iPhone. Pass in the am_device structure that the
 *  notification callback will give to you.
 *
 *  Returns:
 *      MDERR_OK                if successfully connected
 *      MDERR_SYSCALL           if setsockopt() failed
 *      MDERR_QUERY_FAILED      if the daemon query failed
 *      MDERR_INVALID_ARGUMENT  if USBMuxConnectByPort returned 0xffffffff
 */

mach_error_t AMDeviceConnect(am_device_t* device);

/*  Calls PairingRecordPath() on the given device, than tests whether the path
 *  which that function returns exists. During the initial connect, the path
 *  returned by that function is '/', and so this returns 1.
 *
 *  Returns:
 *      0   if the path did not exist
 *      1   if it did
 */

int AMDeviceIsPaired(am_device_t* device);

/*  iTunes calls this function immediately after testing whether the device is
 *  paired. It creates a pairing file and establishes a Lockdown connection.
 *
 *  Returns:
 *      MDERR_OK                if successful
 *      MDERR_INVALID_ARGUMENT  if the supplied device is null
 *      MDERR_DICT_NOT_LOADED   if the load_dict() call failed
 */

mach_error_t AMDeviceValidatePairing(am_device_t* device);

/*  Creates a Lockdown session and adjusts the device structure appropriately
 *  to indicate that the session has been started. iTunes calls this function
 *  after validating pairing.
 *
 *  Returns:
 *      MDERR_OK                if successful
 *      MDERR_INVALID_ARGUMENT  if the Lockdown conn has not been established
 *      MDERR_DICT_NOT_LOADED   if the load_dict() call failed
 */

mach_error_t AMDeviceStartSession(am_device_t* device);

/* Starts a service and returns a handle that can be used in order to further
 * access the service. You should stop the session and disconnect before using
 * the service. iTunes calls this function after starting a session. It starts 
 * the service and the SSL connection. unknown may safely be
 * NULL (it is when iTunes calls this), but if it is not, then it will be
 * filled upon function exit. service_name should be one of the AMSVC_*
 * constants. If the service is AFC (AMSVC_AFC), then the handle is the handle
 * that will be used for further AFC* calls.
 *
 * Returns:
 *      MDERR_OK                if successful
 *      MDERR_SYSCALL           if the setsockopt() call failed
 *      MDERR_INVALID_ARGUMENT  if the Lockdown conn has not been established
 */

mach_error_t AMDeviceStartService(am_device_t* device, CFStringRef service_name, ServiceConnRef* handle, uint* unknown);

mach_error_t AMDeviceStartHouseArrestService(am_device_t* device, CFStringRef identifier, void* unknown, ServiceConnRef handle, uint* what);

/* Stops a session. You should do this before accessing services.
 *
 * Returns:
 *      MDERR_OK                if successful
 *      MDERR_INVALID_ARGUMENT  if the Lockdown conn has not been established
 */

mach_error_t AMDeviceStopSession(am_device_t* device);

/* Opens an Apple File Connection. You must start the appropriate service
 * first with AMDeviceStartService(). In iTunes, io_timeout is 0.
 *
 * Returns:
 *      MDERR_OK                if successful
 *      MDERR_AFC_OUT_OF_MEMORY if malloc() failed
 */

afc_error_t AFCConnectionOpen(ServiceConnRef handle, uint io_timeout,
    AFCConnectionRef* conn);

/* Pass in a pointer to an afc_device_info structure. It will be filled. */
afc_error_t AFCDeviceInfoOpen(AFCConnectionRef conn,
    afc_dictionary_t** info);

/* Turns debug mode on if the environment variable AFCDEBUG is set to a numeric
 * value, or if the file '/AFCDEBUG' is present and contains a value. */
void AFCPlatformInit();

/* Opens a directory on the iPhone. Pass in a pointer in dir to be filled in.
 * Note that this normally only accesses the iTunes sandbox/partition as the
 * root, which is /var/root/Media. Pathnames are specified with '/' delimiters
 * as in Unix style.
 *
 * Returns:
 *      MDERR_OK                if successful
 */

afc_error_t AFCDirectoryOpen(AFCConnectionRef conn, const(char)* path,
    afc_directory_t** dir);

/* Acquires the next entry in a directory previously opened with
 * AFCDirectoryOpen(). When dirent is filled with a NULL value, then the end
 * of the directory has been reached. '.' and '..' will be returned as the
 * first two entries in each directory except the root; you may want to skip
 * over them.
 *
 * Returns:
 *      MDERR_OK                if successful, even if no entries remain
 */

afc_error_t AFCDirectoryRead(AFCConnectionRef conn /*uint unused*/ , afc_directory_t* dir,
    char** dirent);

afc_error_t AFCDirectoryClose(AFCConnectionRef conn, afc_directory_t* dir);
afc_error_t AFCDirectoryCreate(AFCConnectionRef conn, const(char)* dirname);
afc_error_t AFCRemovePath(AFCConnectionRef conn, const(char)* dirname);
afc_error_t AFCRenamePath(AFCConnectionRef conn, const(char)* from, const(char)* to);
afc_error_t AFCLinkPath(AFCConnectionRef conn, long linktype, const(char)* target, const(char)* linkname);

/* Returns the context field of the given AFC connection. */
uint AFCConnectionGetContext(AFCConnectionRef conn);

/* Returns the fs_block_size field of the given AFC connection. */
uint AFCConnectionGetFSBlockSize(AFCConnectionRef conn);

/* Returns the io_timeout field of the given AFC connection. In iTunes this is
 * 0. */
uint AFCConnectionGetIOTimeout(AFCConnectionRef conn);

/* Returns the sock_block_size field of the given AFC connection. */
uint AFCConnectionGetSocketBlockSize(AFCConnectionRef conn);

/* Closes the given AFC connection. */
afc_error_t AFCConnectionClose(AFCConnectionRef conn);

/* Registers for device notifications related to the restore process. unknown0
 * is zero when iTunes calls this. In iTunes,
 * the callbacks are located at:
 *      1: $3ac68e-$3ac6b1, calls $3ac542(unknown1, arg, 0)
 *      2: $3ac66a-$3ac68d, calls $3ac542(unknown1, 0, arg)
 *      3: $3ac762-$3ac785, calls $3ac6b2(unknown1, arg, 0)
 *      4: $3ac73e-$3ac761, calls $3ac6b2(unknown1, 0, arg)
 */

uint AMRestoreRegisterForDeviceNotifications(
    am_restore_device_notification_callback dfu_connect_callback,
    am_restore_device_notification_callback recovery_connect_callback,
    am_restore_device_notification_callback dfu_disconnect_callback,
    am_restore_device_notification_callback recovery_disconnect_callback,
    uint unknown0,
    void* user_info);

/* Causes the restore functions to spit out (unhelpful) progress messages to
 * the file specified by the given path. iTunes always calls this right before
 * restoring with a path of
 * "$HOME/Library/Logs/iPhone Updater Logs/iPhoneUpdater X.log", where X is an
 * unused number.
 */

uint AMRestoreEnableFileLogging(char* path);

/* Initializes a new option dictionary to default values. Pass the constant
 * kCFAllocatorDefault as the allocator. The option dictionary looks as
 * follows:
 * {
 *      NORImageType => 'production',
 *      AutoBootDelay => 0,
 *      KernelCacheType => 'Release',
 *      UpdateBaseband => true,
 *      DFUFileType => 'RELEASE',
 *      SystemImageType => 'User',
 *      CreateFilesystemPartitions => true,
 *      FlashNOR => true,
 *      RestoreBootArgs => 'rd=md0 nand-enable-reformat=1 -progress'
 *      BootImageType => 'User'
 *  }
 *
 * Returns:
 *      the option dictionary   if successful
 *      NULL                    if out of memory
 */

CFMutableDictionaryRef AMRestoreCreateDefaultOptions(CFAllocatorRef allocator);

/* ----------------------------------------------------------------------------
 *   Less-documented public routines
 * ------------------------------------------------------------------------- */

/* mode 2 = read, mode 3 = write */
afc_error_t AFCFileRefOpen(AFCConnectionRef conn, const(char)* path,
    ulong mode, afc_file_ref_t* ref_);
afc_error_t AFCFileRefSeek(AFCConnectionRef conn, afc_file_ref_t ref_,
    ulong offset1, ulong offset2);
afc_error_t AFCFileRefRead(AFCConnectionRef conn, afc_file_ref_t ref_,
    void* buf, size_t* len);
afc_error_t AFCFileRefSetFileSize(AFCConnectionRef conn, afc_file_ref_t ref_,
    ulong offset);
afc_error_t AFCFileRefWrite(AFCConnectionRef conn, afc_file_ref_t ref_,
    const void* buf, size_t len);
afc_error_t AFCFileRefClose(AFCConnectionRef conn, afc_file_ref_t ref_);

afc_error_t AFCFileInfoOpen(AFCConnectionRef conn, const(char)* path,
    afc_dictionary_t *  * info);
afc_error_t AFCKeyValueRead(afc_dictionary_t** dict, char** key, char** val);
afc_error_t AFCKeyValueClose(afc_dictionary_t** dict);

uint AMRestorePerformRecoveryModeRestore(am_recovery_device_t* rdev, CFDictionaryRef opts, void* callback, void* user_info);
uint AMRestorePerformRestoreModeRestore(am_restore_device_t* rdev, CFDictionaryRef opts, void* callback, void* user_info);

am_restore_device_t * AMRestoreModeDeviceCreate(uint unknown0,
    uint connection_id, uint unknown1);

uint AMRestoreCreatePathsForBundle(CFStringRef restore_bundle_path,
    CFStringRef kernel_cache_type, CFStringRef boot_image_type, uint unknown0, CFStringRef* firmware_dir_path, CFStringRef* kernelcache_restore_path, uint unknown1, CFStringRef* ramdisk_path);

uint AMDeviceGetConnectionID(am_device_t* device);
mach_error_t AMDeviceEnterRecovery(am_device_t* device);
mach_error_t AMDeviceDisconnect(am_device_t* device);
mach_error_t AMDeviceRetain(am_device_t* device);
mach_error_t AMDeviceRelease(am_device_t* device);
CFTypeRef AMDeviceCopyValue(am_device_t* device, void*, CFStringRef cfstring);
CFStringRef AMDeviceCopyDeviceIdentifier(am_device_t* device);

alias notify_callback = void function(CFStringRef notification, void* data);

mach_error_t AMDPostNotification(service_conn_t socket, CFStringRef notification, CFStringRef userinfo);
mach_error_t AMDObserveNotification(void* socket, CFStringRef notification);
mach_error_t AMDListenForNotifications(void* socket, notify_callback cb, void* data);
mach_error_t AMDShutdownNotificationProxy(void* socket);

/*edits by geohot*/
mach_error_t AMDeviceDeactivate(am_device_t* device);
mach_error_t AMDeviceActivate(am_device_t* device, CFMutableDictionaryRef);
/*end*/

void* AMDeviceSerialize(am_device_t* device);
void AMDAddLogFileDescriptor(int fd);
//kern_return_t AMDeviceSendMessage(service_conn_t socket, void *unused, CFPropertyListRef plist);
//kern_return_t AMDeviceReceiveMessage(service_conn_t socket, CFDictionaryRef options, CFPropertyListRef * result);

alias am_device_install_application_callback = int function(CFDictionaryRef, int);

mach_error_t AMDeviceInstallApplication(service_conn_t socket, CFStringRef path, CFDictionaryRef options, am_device_install_application_callback callback, void* user);
mach_error_t AMDeviceTransferApplication(service_conn_t socket, CFStringRef path, CFDictionaryRef options, am_device_install_application_callback callbackj, void* user);

int AMDeviceSecureUninstallApplication(int unknown0, am_device_t* device, CFStringRef bundle_id, int unknown1, void* callback, int callback_arg);

/* ----------------------------------------------------------------------------
 *   Semi-private routines
 * ------------------------------------------------------------------------- */

/*  Pass in a usbmux_listener_1 structure and a usbmux_listener_2 structure
 *  pointer, which will be filled with the resulting usbmux_listener_2.
 *
 *  Returns:
 *      MDERR_OK                if completed successfully
 *      MDERR_USBMUX_ARG_NULL   if one of the arguments was NULL
 *      MDERR_USBMUX_FAILED     if the listener was not created successfully
 */

usbmux_error_t USBMuxListenerCreate(usbmux_listener_1_t* esi_fp8,
    usbmux_listener_2_t** eax_fp12);

/* ----------------------------------------------------------------------------
 *   Less-documented semi-private routines
 * ------------------------------------------------------------------------- */

usbmux_error_t USBMuxListenerHandleData(void*);

/* ----------------------------------------------------------------------------
 *   Private routines - here be dragons
 * ------------------------------------------------------------------------- */

/* AMRestorePerformRestoreModeRestore() calls this function with a dictionary
 * in order to perform certain special restore operations
 * (RESTORED_OPERATION_*). It is thought that this function might enable
 * significant access to the phone. */

alias t_performOperation = uint function(am_restore_device_t * rdev,
    CFDictionaryRef op); // __attribute__ ((regparm(2)));
