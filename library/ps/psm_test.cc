#include "library/ps/psm.h"

#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "library/ps/pes.h"
#include "library/utilities_gmock.h"

namespace {
// These test values are taken from the Widevine packager and live data.
const uint8_t kVideoStreamType = 0x1b;
const uint8_t kAudioStreamType = 0x0f;
const uint8_t kAudioOid[] = {
  0x1d, 0x34, 0x10, 0x01, 0x02, 0x80, 0x80, 0x2e,
  0x00, 0x4f, 0xff, 0xff, 0xfe, 0xfe, 0xff, 0x03,
  0x80, 0x80, 0x80, 0x22, 0x00, 0xc0, 0x00, 0x04,
  0x80, 0x80, 0x80, 0x14, 0x40, 0x15, 0x00, 0x18,
  0x00, 0x00, 0x01, 0xf4, 0x00, 0x00, 0x01, 0xf4,
  0x00, 0x05, 0x80, 0x80, 0x80, 0x02, 0x12, 0x10,
  0x06, 0x80, 0x80, 0x80, 0x01, 0x02};
const uint8_t kExpectedPsm[] = {
  0x00, 0x00, 0x01, 0xbc, 0x00, 0x4e, 0xe0, 0xff,
  0x00, 0x36, 0x1d, 0x34, 0x10, 0x01, 0x02, 0x80,
  0x80, 0x2e, 0x00, 0x4f, 0xff, 0xff, 0xfe, 0xfe,
  0xff, 0x03, 0x80, 0x80, 0x80, 0x22, 0x00, 0xc0,
  0x00, 0x04, 0x80, 0x80, 0x80, 0x14, 0x40, 0x15,
  0x00, 0x18, 0x00, 0x00, 0x01, 0xf4, 0x00, 0x00,
  0x01, 0xf4, 0x00, 0x05, 0x80, 0x80, 0x80, 0x02,
  0x12, 0x10, 0x06, 0x80, 0x80, 0x80, 0x01, 0x02,
  0x00, 0x0e, 0x1b, 0xe0, 0x00, 0x03, 0x06, 0x01,
  0x03, 0x0f, 0xc0, 0x00, 0x03, 0x06, 0x01, 0x01,
  0xad, 0xd0, 0x20, 0x1a};
}  // namespace

namespace dash2hls {

TEST(PSM, BuildExpected) {
  PSM psm;
  psm.set_current_next_indicator(true);
  psm.set_psm_version(0);
  psm.AddElementaryStream(PES::kVideoStreamId, kVideoStreamType);
  psm.AddElementaryStreamDescriptor(PES::kVideoStreamId,
                                    PSM::kVideoAlignmentDescriptor,
                                    sizeof(PSM::kVideoAlignmentDescriptor));
  psm.AddDescriptor(kAudioOid, sizeof(kAudioOid));

  psm.AddElementaryStream(PES::kAudioStreamId, kAudioStreamType);
  psm.AddElementaryStreamDescriptor(PES::kAudioStreamId,
                                    PSM::kAudioAlignmentDescriptor,
                                    sizeof(PSM::kAudioAlignmentDescriptor));

  ASSERT_EQ(sizeof(kExpectedPsm), psm.GetSize());
  uint8_t buffer[sizeof(kExpectedPsm)];
  EXPECT_EQ(sizeof(kExpectedPsm),
            psm.Write(buffer, sizeof(buffer)));
  EXPECT_THAT(std::make_pair(buffer, sizeof(buffer)),
              testing::MemEq(kExpectedPsm,
                             sizeof(kExpectedPsm)));
}
}  // namespace dash2hls
