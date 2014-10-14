/*
Copyright 2014 Google Inc. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// This is Sample code.  It does not have a lot of error checking for
// simplicity.  In practice error codes should be checked and handled.

#import "DashHTTPConnection.h"

#include <openssl/aes.h>
#import <Responses/HTTPDataResponse.h>
#include <vector>

#include "include/DashToHlsApi.h"
#include "library/mac_test_files.h"
#include "library/player/DashParserInfo.h"

static NSString* kVariantPlaylist = @"#EXTM3U\n#EXT-X-MEDIA:URI=\"http://"
    @"localhost:12345/audio.m3u8\",TYPE=AUDIO,GROUP-ID=\"audio\",NAME=\""
    @"audio\",DEFAULT=YES,AUTOSELECT=YES\n#EXT-X-STREAM-INF:BANDWIDTH=340992,"
    @"CODECS=\"avc1.4d4015,mp4a.40.5\",RESOLUTION=426x240,AUDIO=\"audio\"\n"
    @"http://localhost:12345/video.m3u8";

static NSString* kPlaylist = @"#EXTM3U\n#EXT-X-VERSION:3\n"
    @"#EXT-X-MEDIA-SEQUENCE:0\n#EXT-X-PLAYLIST-TYPE:VOD\n#EXT-X-TARGETDURATION:%d\n%@#EXT-X-ENDLIST\n";

static NSString* kVideoSegmentFormat = @"#EXTINF:%0.06f,\nhttp://localhost:"
    @"12345/video%d.ts\n";
static NSString* kAudioSegmentFormat = @"#EXTINF:%0.06f,\nhttp://localhost:"
    @"12345/audio%d.ts\n";

static size_t kDashHeaderRead = 10000;  // Enough to get the sidx.
static float k90KRatio = 90000.0;
static const uint8_t video_key[] = {0x6f, 0xc9, 0x6f, 0xe6, 0x28, 0xa2, 0x65, 0xb1,
  0x3a, 0xed, 0xde, 0xc0, 0xbc, 0x42, 0x1f, 0x4d};
static const uint8_t audio_key[] = {0xab, 0x88, 0xf8, 0xd3, 0xe9, 0xea, 0x83, 0x5a,
  0x74, 0x50, 0x53, 0xd7, 0xf4, 0x4d, 0x14, 0x3d};

// CTR is symetrical.  There is no decrypt call, you just use encrypt.
>>>> ORIGINAL //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#3
DashToHlsStatus VideoDecryptionHandler(const uint8_t* encrypted,
==== THEIRS //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#4
DashToHlsStatus VideoDecryptionHandler(void* context,
                                       const uint8_t* encrypted,
==== YOURS //justsomeguy-desktop-dash-bagpipe/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm
DashToHlsStatus VideoDecryptionHandler(void *,
                                       const uint8_t* encrypted,
<<<<
                                       uint8_t* clear,
                                       size_t length,
                                       uint8_t* iv,
>>>> ORIGINAL //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#3
                                       size_t iv_length) {
==== THEIRS //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#4
                                       size_t iv_length,
                                       const uint8_t* key_id,
                                       struct SampleEntry*,
                                       size_t sampleEntrySize) {
==== YOURS //justsomeguy-desktop-dash-bagpipe/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm
                                       size_t iv_length,
                                       struct SampleEntry *,
                                       size_t) {
<<<<
  AES_KEY aes_key;
  AES_set_encrypt_key(video_key, AES_BLOCK_SIZE * 8, &aes_key);
  uint8_t ecount_buf[AES_BLOCK_SIZE];
  memset(ecount_buf, 0, AES_BLOCK_SIZE);
  unsigned int block_offset_cur = 0;
  AES_ctr128_encrypt(encrypted, clear, length, &aes_key, iv, ecount_buf,
                     &block_offset_cur);
  return kDashToHlsStatus_OK;
}

>>>> ORIGINAL //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#3
DashToHlsStatus AudioDecryptionHandler(const uint8_t* encrypted,
==== THEIRS //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#4
DashToHlsStatus AudioDecryptionHandler(void* context,
                                       const uint8_t* encrypted,
==== YOURS //justsomeguy-desktop-dash-bagpipe/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm
DashToHlsStatus AudioDecryptionHandler(void *,
                                       const uint8_t* encrypted,
<<<<
                                       uint8_t* clear,
                                       size_t length,
                                       uint8_t* iv,
>>>> ORIGINAL //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#3
                                       size_t iv_length) {
==== THEIRS //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#4
                                       size_t iv_length,
                                       const uint8_t* key_id,
                                       struct SampleEntry*,
                                       size_t sampleEntrySize) {
==== YOURS //justsomeguy-desktop-dash-bagpipe/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm
                                       size_t iv_length,
                                       struct SampleEntry *,
                                       size_t) {
<<<<
  AES_KEY aes_key;
  AES_set_encrypt_key(audio_key, AES_BLOCK_SIZE * 8, &aes_key);
  uint8_t ecount_buf[AES_BLOCK_SIZE];
  memset(ecount_buf, 0, AES_BLOCK_SIZE);
  unsigned int block_offset_cur = 0;
  AES_ctr128_encrypt(encrypted, clear, length, &aes_key, iv, ecount_buf,
                     &block_offset_cur);
  return kDashToHlsStatus_OK;
}

>>>> ORIGINAL //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#3
DashToHlsStatus PsshHandler(const uint8_t* pssh,
==== THEIRS //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#4
DashToHlsStatus PsshHandler(void* context,
                            const uint8_t* pssh,
==== YOURS //justsomeguy-desktop-dash-bagpipe/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm
DashToHlsStatus PsshHandler(void *,
                            const uint8_t* pssh,
<<<<
                            size_t pssh_length) {
  return kDashToHlsStatus_OK;
}

class PlayerDashParserInfo : public DashParserInfo {
public:
>>>> ORIGINAL //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#3
  DashParserInfo() : video_index_(nil), audio_index_(nil){
    DashToHls_CreateSession(&video_);
    DashToHls_CreateSession(&audio_);
    DashToHls_SetCenc_PsshHandler(video_, PsshHandler);
    DashToHls_SetCenc_DecryptSample(audio_, AudioDecryptionHandler);
    DashToHls_SetCenc_PsshHandler(audio_, PsshHandler);
    DashToHls_SetCenc_DecryptSample(video_, VideoDecryptionHandler);
    video_file_ = Dash2HLS_GetTestCencVideoFile();
    fseek(video_file_, 0, SEEK_END);
    video_file_size_ = ftell(video_file_);
    fseek(video_file_, 0, SEEK_SET);
    audio_file_ = Dash2HLS_GetTestCencAudioFile();
    fseek(audio_file_, 0, SEEK_END);
    audio_file_size_ = ftell(audio_file_);
    fseek(audio_file_, 0, SEEK_SET);
==== THEIRS //depot/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm#4
  DashParserInfo() : video_index_(nil), audio_index_(nil){
    DashToHls_CreateSession(&video_);
    DashToHls_CreateSession(&audio_);
    DashToHls_SetCenc_PsshHandler(video_, nullptr, PsshHandler);
    DashToHls_SetCenc_DecryptSample(audio_, nullptr, AudioDecryptionHandler,
                                    false);
    DashToHls_SetCenc_PsshHandler(audio_, nullptr, PsshHandler);
    DashToHls_SetCenc_DecryptSample(video_, nullptr, VideoDecryptionHandler,
                                    false);
    video_file_ = Dash2HLS_GetTestCencVideoFile();
    fseek(video_file_, 0, SEEK_END);
    video_file_size_ = ftell(video_file_);
    fseek(video_file_, 0, SEEK_SET);
    audio_file_ = Dash2HLS_GetTestCencAudioFile();
    fseek(audio_file_, 0, SEEK_END);
    audio_file_size_ = ftell(audio_file_);
    fseek(audio_file_, 0, SEEK_SET);
==== YOURS //justsomeguy-desktop-dash-bagpipe/googlemac/ThirdParty/Widevine/OpenSource/DashToHls/library/player/DashHTTPConnection.mm
  PlayerDashParserInfo() : DashParserInfo(Dash2HLS_GetTestCencVideoFileName(),
                       PsshHandler,
                       VideoDecryptionHandler,
                       Dash2HLS_GetTestCencAudioFileName(),
                       PsshHandler,
                       AudioDecryptionHandler) {
<<<<
  }
};

@implementation DashHTTPConnection

- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket
            configuration:(HTTPConfig *)aConfig {
  self = [super initWithAsyncSocket:newSocket configuration:aConfig];
  if (!DashParserInfo::s_info) {
    DashParserInfo::s_info = new PlayerDashParserInfo;
  }
  return self;
}

- (void)incrementVideoSegmentCount {
}

// Build a simple playlist for either the video or audio.
- (NSString*)buildManifest:(BOOL)is_video {
  if (is_video) {
    if (DashParserInfo::s_info->get_video_index() == nil) {
      DashParserInfo::s_info->ParseVideo();
    }
  } else {
    if (DashParserInfo::s_info->get_audio_index() == nil) {
      DashParserInfo::s_info->ParseAudio();
    }
  }

  NSMutableString* segments = [NSMutableString string];
  const DashToHlsIndex* index = NULL;
  if (is_video) {
    index = DashParserInfo::s_info->get_video_index();
  } else {
    index = DashParserInfo::s_info->get_audio_index();
  }
  uint32_t max_duration = 0;
  // The sample used here is truncated.  iOS will not play a truncated
  // asset.  It just silently fails.
  size_t file_size = is_video ? DashParserInfo::s_info->get_video_file_size() :
      DashParserInfo::s_info->get_audio_file_size();
  for (size_t loop = 0; loop < 100; ++loop) {
    for (size_t count = 100; count < 200; ++count) {
      if (index->segments[count].location + index->segments[count].length >
          file_size) {
        break;
      }
      if (index->segments[count].duration > max_duration) {
        max_duration = index->segments[count].duration;
      }
      [segments appendFormat:is_video ? kVideoSegmentFormat:kAudioSegmentFormat,
       static_cast<float>(index->segments[count].duration) /
           static_cast<float>(index->segments[count].timescale),
       loop * 100 + count, NULL];
    }
  }
  return [NSString stringWithFormat:kPlaylist,
          static_cast<UInt32>(max_duration/index->segments[0].timescale)+1,
          segments, NULL];
}

// Handle the requests from the client.  The manifest is written to be as
// easy to parse as possible.
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method
                                              URI:(NSString *)path {
  NSLog(@"called with %@ %@", method, path);
  NSData* page_data = NULL;
  if ([path isEqualToString:@"/movie.m3u8"]) {
    page_data = [kVariantPlaylist dataUsingEncoding:NSUTF8StringEncoding];
  } else if ([path isEqualToString:@"/video.m3u8"]) {
    page_data = [[self buildManifest:YES]
                 dataUsingEncoding:NSUTF8StringEncoding];
  } else if ([path isEqualToString:@"/audio.m3u8"]) {
    page_data= [[self buildManifest:NO]
        dataUsingEncoding:NSUTF8StringEncoding];
  } else {
    NSScanner* scanner = [NSScanner scannerWithString:path];
    if ([scanner scanString:@"/video" intoString:NULL]) {
      int segment;
      if ([scanner scanInt:&segment]) {
        NSLog(@"Found video segment %d", segment);
      } else {
        NSLog(@"found video tag, no segment scanned");
      }
      page_data = DashParserInfo::s_info->ConvertVideoSegment(segment % 100 + 100);
      [self incrementVideoSegmentCount];
    } else if ([scanner scanString:@"/audio" intoString:NULL]) {
      int segment;
      if ([scanner scanInt:&segment]) {
        NSLog(@"Found audio segment %d", segment);
      } else {
        NSLog(@"found audio tag, no segment scanned");
      }
      page_data = DashParserInfo::s_info->ConvertAudioSegment(segment);
    }
  }
  if (page_data) {
    return [[HTTPDataResponse alloc] initWithData:page_data];
  }
  return nil;
}

@end
