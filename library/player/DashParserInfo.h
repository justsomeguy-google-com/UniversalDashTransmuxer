#ifndef DASH2HLS_PLAYER_DASHPARSERINFO_H_
#define DASH2HLS_PLAYER_DASHPARSERINFO_H_
// One session with one audio and one video track.
// Required ParseVideo and ParseAudio to be called before any Convert methods.
//
// In theory the constructor could just do that but this is an example and
// shows how to handle getting the m3u8.

#import <Foundation/Foundation.h>

#include "include/DashToHlsApi.h"

class DashParserInfo {
public:
  DashParserInfo(NSString* video_file_path,
                 CENC_PsshHandler video_pssh_handler,
                 CENC_DecryptionHandler video_decryptor,
                 NSString* audio_file_path,
                 CENC_PsshHandler audio_pssh_handler,
                 CENC_DecryptionHandler audio_decryptor);
  ~DashParserInfo();
  void ParseVideo();
  void ParseAudio();
  NSData* ConvertVideoSegment(uint32_t segment);
  NSData* ConvertAudioSegment(uint32_t segment);
  const DashToHlsSession* get_video() const {return video_;}
  const DashToHlsIndex* get_video_index() const {return video_index_;}
  const DashToHlsSession* get_audio() const {return video_;}
  const DashToHlsIndex* get_audio_index() const {return audio_index_;}
  size_t get_video_file_size() {return video_file_size_;}
  size_t get_audio_file_size() {return audio_file_size_;}

  static DashParserInfo* s_info;

private:
  DashToHlsSession* video_;
  DashToHlsIndex* video_index_;
  NSFileHandle* __strong video_file_;
  size_t video_file_size_;
  DashToHlsSession* audio_;
  DashToHlsIndex* audio_index_;
  NSFileHandle* __strong audio_file_;
  size_t audio_file_size_;
};

#endif  // DASH2HLS_PLAYER_DASHPARSERINFO_H_
