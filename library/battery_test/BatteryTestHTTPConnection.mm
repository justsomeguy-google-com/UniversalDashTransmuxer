// This is Sample code.  It does not have a lot of error checking for
// simplicity.  In practice error codes should be checked and handled.
// author: justsomeguy@

#import "BatteryTestHTTPConnection.h"

#import "AppDelegate.h"
#include <openssl/aes.h>
#import <Responses/HTTPDataResponse.h>
#include <vector>

#include "include/DashToHlsApi.h"
#include "library/mac_test_files.h"
#include "library/player/DashParserInfo.h"
#import "ViewController.h"

static NSString* kVariantPlaylist = @"#EXTM3U\n#EXT-X-MEDIA:URI=\"http://"
    @"localhost:12345/audio.m3u8\",TYPE=AUDIO,GROUP-ID=\"audio\",NAME=\""
    @"audio\",DEFAULT=YES,AUTOSELECT=YES\n#EXT-X-STREAM-INF:BANDWIDTH=340992,"
    @"CODECS=\"avc1.4d4015,mp4a.40.5\",RESOLUTION=426x240,AUDIO=\"audio\"\n"
    @"http://localhost:12345/video.m3u8";

static NSString* kPlaylist = @"#EXTM3U\n#EXT-X-VERSION:3\n"
    @"#EXT-X-PLAYLIST-TYPE:VOD\n#EXT-X-TARGETDURATION:%f\n%@#EXT-X-ENDLIST";

static NSString* kVideoSegmentFormat = @"#EXTINF:%0.06f,\nhttp://localhost:"
    @"12345/video%d.ts\n";
static NSString* kAudioSegmentFormat = @"#EXTINF:%0.06f,\nhttp://localhost:"
    @"12345/audio%d.ts\n";

//static const uint8_t video_key[] = {0x6f, 0xc9, 0x6f, 0xe6, 0x28, 0xa2, 0x65, 0xb1,
//  0x3a, 0xed, 0xde, 0xc0, 0xbc, 0x42, 0x1f, 0x4d};
static const uint8_t video_key[] = {0x99, 0x70, 0xD1, 0xFA, 0x60, 0x28, 0xB7, 0x19, 0x6B, 0xD5, 0x47, 0x50, 0x58, 0x46, 0x52, 0x4D};
static const uint8_t audio_key[] = {0x5C, 0x46, 0x78, 0xB8, 0xF2, 0x95, 0x97, 0xB9, 0x58, 0x3E, 0xD0, 0xBD, 0x66, 0xFB, 0xDB, 0x06};
//static const uint8_t audio_key[] = {0xab, 0x88, 0xf8, 0xd3, 0xe9, 0xea, 0x83, 0x5a,
//  0x74, 0x50, 0x53, 0xd7, 0xf4, 0x4d, 0x14, 0x3d};

// CTR is symetrical.  There is no decrypt call, you just use encrypt.
DashToHlsStatus BatteryTestVideoDecryptionHandler(void* context,
                                                  const uint8_t* encrypted,
                                                  uint8_t* clear,
                                                  size_t length,
                                                  uint8_t* iv,
                                                  size_t iv_length,
                                                  struct SampleEntry*,
                                                  size_t sampleEntrySize) {
  AES_KEY aes_key;
  AES_set_encrypt_key(video_key, AES_BLOCK_SIZE * 8, &aes_key);
  uint8_t ecount_buf[AES_BLOCK_SIZE];
  memset(ecount_buf, 0, AES_BLOCK_SIZE);
  unsigned int block_offset_cur = 0;
  AES_ctr128_encrypt(encrypted, clear, length, &aes_key, iv, ecount_buf,
                     &block_offset_cur);
  return kDashToHlsStatus_OK;
}

DashToHlsStatus BatteryTestAudioDecryptionHandler(void* context,
                                                  const uint8_t* encrypted,
                                                  uint8_t* clear,
                                                  size_t length,
                                                  uint8_t* iv,
                                                  size_t iv_length,
                                                  struct SampleEntry*,
                                                  size_t sampleEntrySize) {
  AES_KEY aes_key;
  AES_set_encrypt_key(audio_key, AES_BLOCK_SIZE * 8, &aes_key);
  uint8_t ecount_buf[AES_BLOCK_SIZE];
  memset(ecount_buf, 0, AES_BLOCK_SIZE);
  unsigned int block_offset_cur = 0;
  AES_ctr128_encrypt(encrypted, clear, length, &aes_key, iv, ecount_buf,
                     &block_offset_cur);
  return kDashToHlsStatus_OK;
}

DashToHlsStatus BatteryTestPsshHandler(void* context,
                                       const uint8_t* pssh,
                                       size_t pssh_length) {
  return kDashToHlsStatus_OK;
}


// One session with one audio and one video track.
// Required ParseVideo and ParseAudio to be called before any Convert methods.
//
// In theory the constructor could just do that but this is an example and
// shows how to handle getting the m3u8.
class BatteryTestDashParserInfo : public DashParserInfo {
public:
  BatteryTestDashParserInfo()
      : DashParserInfo(Dash2HLS_BatteryTestVideoFileName(),
                       BatteryTestPsshHandler,
                       BatteryTestVideoDecryptionHandler,
                       Dash2HLS_BatteryTestAudioFileName(),
                       BatteryTestPsshHandler,
                       BatteryTestAudioDecryptionHandler) {
  }
};

@implementation BatteryTestHTTPConnection

- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket
            configuration:(HTTPConfig *)aConfig {
  if (!DashParserInfo::s_info) {
    DashParserInfo::s_info = new BatteryTestDashParserInfo;
  }
  self = [super initWithAsyncSocket:newSocket configuration:aConfig];
  return self;
}

- (void)incrementVideoSegmentCount {
  [((AppDelegate*)[[UIApplication sharedApplication] delegate]).viewController incrementCounter];
}


@end
