#include "library/player/DashParserInfo.h"

static size_t kDashHeaderRead = 10000;  // Enough to get the sidx.

DashParserInfo* DashParserInfo::s_info = NULL;

DashParserInfo::DashParserInfo(NSString* video_file_path,
                               CENC_PsshHandler video_pssh_handler,
                               CENC_DecryptionHandler video_decryptor,
                               NSString* audio_file_path,
                               CENC_PsshHandler audio_pssh_handler,
                               CENC_DecryptionHandler audio_decryptor) :
video_index_(nil), audio_index_(nil) {
  DashToHls_CreateSession(&video_);
  DashToHls_SetCenc_PsshHandler(video_, nil, video_pssh_handler);
  DashToHls_SetCenc_DecryptSample(video_, nil, video_decryptor, false);
  video_file_ = [NSFileHandle fileHandleForReadingAtPath:video_file_path];
  video_file_size_ = [video_file_ seekToEndOfFile];
  [video_file_ seekToFileOffset:0];
  
  DashToHls_CreateSession(&audio_);
  DashToHls_SetCenc_DecryptSample(audio_, nil, audio_decryptor, false);
  DashToHls_SetCenc_PsshHandler(audio_, nil, audio_pssh_handler);
  audio_file_ = [NSFileHandle fileHandleForReadingAtPath:audio_file_path];
  audio_file_size_ = [audio_file_ seekToEndOfFile];
  [audio_file_ seekToFileOffset:0];
}

DashParserInfo::~DashParserInfo() {
  DashToHls_ReleaseSession(video_);
  DashToHls_ReleaseSession(audio_);
  [video_file_ closeFile];
  [audio_file_ closeFile];
}

// The client has asked for the video manifest, "download" the file and
// parse enough of the dash to get the sidx.
void DashParserInfo::ParseVideo() {
  [video_file_ seekToFileOffset:0];
  NSData* buffer = [video_file_ readDataOfLength:kDashHeaderRead];
  DashToHls_ParseDash(video_, reinterpret_cast<const UInt8*>([buffer bytes]),
                      [buffer length], &video_index_);
}

// The client has asked for the audio manifest, "download" the file and
// parse enough of the dash to get the sidx.
void DashParserInfo::ParseAudio() {
  [audio_file_ seekToFileOffset:0];
  NSData* buffer = [audio_file_ readDataOfLength:kDashHeaderRead];
  DashToHls_ParseDash(audio_, reinterpret_cast<const UInt8*>([buffer bytes]),
                      [buffer length], &audio_index_);
}

// The client has asked for a video segment.  "download" it, convert it
// to HLS.
NSData* DashParserInfo::ConvertVideoSegment(uint32_t segment) {
  size_t dash_buffer_size = video_index_->segments[segment].length;
  [video_file_ seekToFileOffset:video_index_->segments[segment].location];
  NSData* buffer = [video_file_ readDataOfLength:dash_buffer_size];
  if ([buffer length] != dash_buffer_size) {
    return nil;
  }
  const uint8_t* hls_segment;
  size_t hls_size;
  DashToHlsStatus status = kDashToHlsStatus_OK;
  status = DashToHls_ConvertDashSegment(video_, segment,
      reinterpret_cast<const UInt8*>([buffer bytes]),
      [buffer length], &hls_segment, &hls_size);

  if (status == kDashToHlsStatus_OK) {
    NSData* data = [NSData dataWithBytes:hls_segment length:hls_size];
    DashToHls_ReleaseHlsSegment(video_, segment);
    return data;
  }
  return nil;
}

// The client has asked for an audio segment.  "download" it, convert it
// to HLS.
NSData* DashParserInfo::ConvertAudioSegment(uint32_t segment) {
  size_t dash_buffer_size = audio_index_->segments[segment].length;
  [audio_file_ seekToFileOffset:audio_index_->segments[segment].location];
  NSData* buffer = [audio_file_ readDataOfLength:dash_buffer_size];
  if ([buffer length] != dash_buffer_size) {
    return nil;
  }
  const uint8_t* hls_segment;
  size_t hls_size;
  DashToHlsStatus status = kDashToHlsStatus_OK;
  status = DashToHls_ConvertDashSegment(audio_, segment,
      reinterpret_cast<const UInt8*>([buffer bytes]),
      [buffer length], &hls_segment, &hls_size);

  if (status == kDashToHlsStatus_OK) {
    NSData* data = [NSData dataWithBytes:hls_segment length:hls_size];
    DashToHls_ReleaseHlsSegment(audio_, segment);
    return data;
  }
  return nil;
}
