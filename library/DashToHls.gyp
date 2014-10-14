# Library targets for DashToHls. These minimize external dependencies (such
# as OpenSSL) so other projects can depend on them without bringing in
# unnecessary dependencies.
{
  'target_defaults': {
    'xcode_settings': {
      'CLANG_ENABLE_OBJC_ARC': [ 'YES' ],
    },
  },
  'conditions': [
    ['OS=="mac"', {
      'target_defaults': {
        'xcode_settings': {
          'ARCHS[sdk=macosx*]': 'x86_64',
        },
      },
      'targets': [{
          'target_name': 'DashToHlsTools',
          'type': 'executable',
            'xcode_settings': {
              'GCC_PREFIX_HEADER': 'DashToHls_osx.pch',
              'INFOPLIST_FILE': 'tools/OSX/tools-Info.plist',
            },
            'mac_bundle': 1,
            'mac_bundle_resources': [
              'tools/OSX/Base.lproj/MainMenu.xib',
              'tools/OSX/tools-Info.plist',
              'tools/OSX/en.lproj/InfoPlist.strings',
            ],
            'sources': [
              'tools/OSX/ToolsAppDelegate.h',
              'tools/OSX/ToolsAppDelegate.mm',
              'tools/OSX/ToolsMpdParser.h',
              'tools/OSX/ToolsMpdParser.mm',
              'tools/OSX/main.m',
            ],
            'include_dirs': [
            ],
            'dependencies': [
              'DashToHlsLibrary',
            ],
          }],
        },
      ]],
  'conditions': [
    ['OS=="mac"', {
      'targets': [{
        'target_name': 'DashToHlsTools',
        'type': 'executable',
          'xcode_settings': {
            'GCC_PREFIX_HEADER': 'DashToHls_osx.pch',
            'INFOPLIST_FILE': 'tools/OSX/tools-Info.plist',
          },
          'mac_bundle': 1,
          'mac_bundle_resources': [
            'tools/OSX/Base.lproj/MainMenu.xib',
            'tools/OSX/tools-Info.plist',
            'tools/OSX/en.lproj/InfoPlist.strings',
          ],
          'sources': [
            'tools/OSX/ToolsAppDelegate.h',
            'tools/OSX/ToolsAppDelegate.mm',
            'tools/OSX/ToolsMpdParser.h',
            'tools/OSX/ToolsMpdParser.mm',
            'tools/OSX/main.m',
          ],
          'include_dirs': [
          ],
          'dependencies': [
            'DashToHlsLibrary',
          ],
        }],
      }],
    ['OS=="ios"', {
      'targets': [{
        'target_name': 'BatteryTest',
        'type': 'executable',
        'xcode_settings': {
          'GCC_PREFIX_HEADER': 'DashToHls_ios.pch',
          'INFOPLIST_FILE': 'battery_test/iOS/player-Info.plist',
        },
        'mac_bundle': 1,
        'mac_bundle_resources': [
          'battery_test/iOS/Base.lproj/Main_iPad.storyboard',
          'battery_test/iOS/Base.lproj/Main_iPhone.storyboard',
          'battery_test/iOS/en.lproj/InfoPlist.strings',
        ],
        'sources': [
          'battery_test/BatteryTestHTTPConnection.h',
          'battery_test/BatteryTestHTTPConnection.mm',
          'battery_test/iOS/AppDelegate.h',
          'battery_test/iOS/AppDelegate.mm',
          'battery_test/iOS/ViewController.h',
          'battery_test/iOS/ViewController.mm',
          'battery_test/iOS/main.m',
          'mac_test_files.h',
          'mac_test_files.mm',
          'player/DashHTTPConnection.h',
          'player/DashHTTPConnection.mm',
          'player/DashParserInfo.h',
          'player/DashParserInfo.mm',
        ],
        'dependencies': [
          'DashToHlsLibrary',
        ],
        'libraries': [
          '$(SDKROOT)/System/Library/Frameworks/MediaPlayer.framework',
          '$(SDKROOT)/System/Library/Frameworks/AVFoundation.framework',
        ],
        'include_dirs': [
        ],
      }],
    }]
  ],
<<<<
  'targets': [
    {
      'target_name': 'DashToHlsLibrary',
      'type': 'static_library',
      'xcode_settings': {
        'GCC_PREFIX_HEADER': 'DashToHls_osx.pch',
        'CLANG_CXX_LIBRARY': 'libc++',
      },
      'direct_dependent_settings': {
        'include_dirs': [
         '../include',
         '..',
        ]
      },
      'include_dirs': [
        '..',
      ],
      'sources': [
        'dash_to_hls_api.cc',
        'utilities.cc',
        'utilities.h',
      ],
      'dependencies': [
        'DashToHlsDash',
        'DashToHlsDefaultDiagnosticCallback',
        'DashToHlsPs',
        'DashToHlsTs',
      ],
    },
    {
      'target_name': 'DashToHlsDash',
      'type': 'static_library',
      'xcode_settings': {
        'GCC_PREFIX_HEADER': 'DashToHls_osx.pch',
        'CLANG_CXX_LIBRARY': 'libc++',
      },
      'include_dirs': [
        '..',
      ],
      'direct_dependent_settings': {
        'include_dirs': [
          '..',
        ],
      },
      'sources': [
        'utilities.h',
        'utilities.cc',
        '<!@(find dash -type f -name "*.h")',
        '<!@(find dash -type f -name "*.cc" ! -name "*_test.cc")',
      ],
    },
    {
      'target_name': 'DashToHlsPs',
      'type': 'static_library',
      'xcode_settings': {
        'GCC_PREFIX_HEADER': 'DashToHls_osx.pch',
        'CLANG_CXX_LIBRARY': 'libc++',
      },
      'include_dirs': [
        '..',
      ],
      'sources': [
        'utilities.h',
        'utilities.cc',
        '<!@(find ps -type f -name "*.h")',
        '<!@(find ps -type f -name "*.cc" ! -name "*_test.cc")',
        'player/DashParserInfo.h',
        'player/DashParserInfo.mm',
      ],
    },
    {
      'target_name': 'DashToHlsTs',
      'type': 'static_library',
      'xcode_settings': {
        'GCC_PREFIX_HEADER': 'DashToHls_osx.pch',
        'CLANG_CXX_LIBRARY': 'libc++',
      },
      'include_dirs': [
        '..',
      ],
      'sources': [
        'ts/transport_stream_out.cc',
        'ts/transport_stream_out.h',
      ],
    },
    # Note: If you depend on any of the sub-libraries here, you either need to
    # depend on this to implement the DashToHlsDefaultDiagnosticCallback
    # function, or, implement it yourself. Otherwise, the project will fail to
    # link.
    {
      'target_name': 'DashToHlsDefaultDiagnosticCallback',
      'type': 'static_library',
      'xcode_settings': {
        'GCC_PREFIX_HEADER': 'DashToHls_osx.pch',
        'CLANG_CXX_LIBRARY': 'libc++',
      },
      'sources': [
        'dash_to_hls_default_diagnostic_callback.mm',
      ],
    }
  ]
}
