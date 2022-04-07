{ fetchurl, fetchgit, linkFarm, runCommand, gnutar }: rec {
  offline_cache = linkFarm "offline" packages;
  packages = [
    {
      name = "https___registry.npmjs.org__cspotcode_source_map_consumer___source_map_consumer_0.8.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org__cspotcode_source_map_consumer___source_map_consumer_0.8.0.tgz";
        url  = "https://registry.npmjs.org/@cspotcode/source-map-consumer/-/source-map-consumer-0.8.0.tgz";
        sha512 = "41qniHzTU8yAGbCp04ohlmSrZf8bkf/iJsl3V0dRGsQN/5GFfx+LbCSsCpp2gqrqjTVg/K6O8ycoV35JIwAzAg==";
      };
    }
    {
      name = "https___registry.npmjs.org__cspotcode_source_map_support___source_map_support_0.7.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org__cspotcode_source_map_support___source_map_support_0.7.0.tgz";
        url  = "https://registry.npmjs.org/@cspotcode/source-map-support/-/source-map-support-0.7.0.tgz";
        sha512 = "X4xqRHqN8ACt2aHVe51OxeA2HjbcL4MqFqXkrmQszJ1NOUuUu5u6Vqx/0lZSVNku7velL5FC/s5uEAj1lsBMhA==";
      };
    }
    {
      name = "https___registry.npmjs.org__tsconfig_node10___node10_1.0.8.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org__tsconfig_node10___node10_1.0.8.tgz";
        url  = "https://registry.npmjs.org/@tsconfig/node10/-/node10-1.0.8.tgz";
        sha512 = "6XFfSQmMgq0CFLY1MslA/CPUfhIL919M1rMsa5lP2P097N2Wd1sSX0tx1u4olM16fLNhtHZpRhedZJphNJqmZg==";
      };
    }
    {
      name = "https___registry.npmjs.org__tsconfig_node12___node12_1.0.9.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org__tsconfig_node12___node12_1.0.9.tgz";
        url  = "https://registry.npmjs.org/@tsconfig/node12/-/node12-1.0.9.tgz";
        sha512 = "/yBMcem+fbvhSREH+s14YJi18sp7J9jpuhYByADT2rypfajMZZN4WQ6zBGgBKp53NKmqI36wFYDb3yaMPurITw==";
      };
    }
    {
      name = "https___registry.npmjs.org__tsconfig_node14___node14_1.0.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org__tsconfig_node14___node14_1.0.1.tgz";
        url  = "https://registry.npmjs.org/@tsconfig/node14/-/node14-1.0.1.tgz";
        sha512 = "509r2+yARFfHHE7T6Puu2jjkoycftovhXRqW328PDXTVGKihlb1P8Z9mMZH04ebyajfRY7dedfGynlrFHJUQCg==";
      };
    }
    {
      name = "https___registry.npmjs.org__tsconfig_node16___node16_1.0.2.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org__tsconfig_node16___node16_1.0.2.tgz";
        url  = "https://registry.npmjs.org/@tsconfig/node16/-/node16-1.0.2.tgz";
        sha512 = "eZxlbI8GZscaGS7kkc/trHTT5xgrjH3/1n2JDwusC9iahPKWMRvRjJSAN5mCXviuTGQ/lHnhvv8Q1YTpnfz9gA==";
      };
    }
    {
      name = "https___registry.npmjs.org__types_command_line_args___command_line_args_5.2.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org__types_command_line_args___command_line_args_5.2.0.tgz";
        url  = "https://registry.npmjs.org/@types/command-line-args/-/command-line-args-5.2.0.tgz";
        sha512 = "UuKzKpJJ/Ief6ufIaIzr3A/0XnluX7RvFgwkV89Yzvm77wCh1kFaFmqN8XEnGcN62EuHdedQjEMb8mYxFLGPyA==";
      };
    }
    {
      name = "https___registry.npmjs.org__types_node___node_17.0.23.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org__types_node___node_17.0.23.tgz";
        url  = "https://registry.npmjs.org/@types/node/-/node-17.0.23.tgz";
        sha512 = "UxDxWn7dl97rKVeVS61vErvw086aCYhDLyvRQZ5Rk65rZKepaFdm53GeqXaKBuOhED4e9uWq34IC3TdSdJJ2Gw==";
      };
    }
    {
      name = "https___registry.npmjs.org_acorn_walk___acorn_walk_8.2.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_acorn_walk___acorn_walk_8.2.0.tgz";
        url  = "https://registry.npmjs.org/acorn-walk/-/acorn-walk-8.2.0.tgz";
        sha512 = "k+iyHEuPgSw6SbuDpGQM+06HQUa04DZ3o+F6CSzXMvvI5KMvnaEqXe+YVe555R9nn6GPt404fos4wcgpw12SDA==";
      };
    }
    {
      name = "https___registry.npmjs.org_acorn___acorn_8.7.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_acorn___acorn_8.7.0.tgz";
        url  = "https://registry.npmjs.org/acorn/-/acorn-8.7.0.tgz";
        sha512 = "V/LGr1APy+PXIwKebEWrkZPwoeoF+w1jiOBUmuxuiUIaOHtob8Qc9BTrYo7VuI5fR8tqsy+buA2WFooR5olqvQ==";
      };
    }
    {
      name = "https___registry.npmjs.org_ansi_colors___ansi_colors_4.1.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_ansi_colors___ansi_colors_4.1.1.tgz";
        url  = "https://registry.npmjs.org/ansi-colors/-/ansi-colors-4.1.1.tgz";
        sha512 = "JoX0apGbHaUJBNl6yF+p6JAFYZ666/hhCGKN5t9QFjbJQKUU/g8MNbFDbvfrgKXvI1QpZplPOnwIo99lX/AAmA==";
      };
    }
    {
      name = "https___registry.npmjs.org_ansi_regex___ansi_regex_2.1.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_ansi_regex___ansi_regex_2.1.1.tgz";
        url  = "https://registry.npmjs.org/ansi-regex/-/ansi-regex-2.1.1.tgz";
        sha1 = "w7M6te42DYbg5ijwRorn7yfWVN8=";
      };
    }
    {
      name = "https___registry.npmjs.org_aproba___aproba_1.2.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_aproba___aproba_1.2.0.tgz";
        url  = "https://registry.npmjs.org/aproba/-/aproba-1.2.0.tgz";
        sha512 = "Y9J6ZjXtoYh8RnXVCMOU/ttDmk1aBjunq9vO0ta5x85WDQiQfUF9sIPBITdbiiIVcBo03Hi3jMxigBtsddlXRw==";
      };
    }
    {
      name = "https___registry.npmjs.org_are_we_there_yet___are_we_there_yet_1.1.7.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_are_we_there_yet___are_we_there_yet_1.1.7.tgz";
        url  = "https://registry.npmjs.org/are-we-there-yet/-/are-we-there-yet-1.1.7.tgz";
        sha512 = "nxwy40TuMiUGqMyRHgCSWZ9FM4VAoRP4xUYSTv5ImRog+h9yISPbVH7H8fASCIzYn9wlEv4zvFL7uKDMCFQm3g==";
      };
    }
    {
      name = "https___registry.npmjs.org_arg___arg_4.1.3.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_arg___arg_4.1.3.tgz";
        url  = "https://registry.npmjs.org/arg/-/arg-4.1.3.tgz";
        sha512 = "58S9QDqG0Xx27YwPSt9fJxivjYl432YCwfDMfZ+71RAqUrZef7LrKQZ3LHLOwCS4FLNBplP533Zx895SeOCHvA==";
      };
    }
    {
      name = "https___registry.npmjs.org_array_back___array_back_3.1.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_array_back___array_back_3.1.0.tgz";
        url  = "https://registry.npmjs.org/array-back/-/array-back-3.1.0.tgz";
        sha512 = "TkuxA4UCOvxuDK6NZYXCalszEzj+TLszyASooky+i742l9TqsOdYCMJJupxRic61hwquNtppB3hgcuq9SVSH1Q==";
      };
    }
    {
      name = "https___registry.npmjs.org_base64_js___base64_js_1.5.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_base64_js___base64_js_1.5.1.tgz";
        url  = "https://registry.npmjs.org/base64-js/-/base64-js-1.5.1.tgz";
        sha512 = "AKpaYlHn8t4SVbOHCy+b5+KKgvR4vrsD8vbvrbiQJps7fKDTkjkDry6ji0rUJjC0kzbNePLwzxq8iypo41qeWA==";
      };
    }
    {
      name = "https___registry.npmjs.org_bl___bl_4.1.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_bl___bl_4.1.0.tgz";
        url  = "https://registry.npmjs.org/bl/-/bl-4.1.0.tgz";
        sha512 = "1W07cM9gS6DcLperZfFSj+bWLtaPGSOHWhPiGzXmvVJbRLdG82sH/Kn8EtW1VqWVA54AKf2h5k5BbnIbwF3h6w==";
      };
    }
    {
      name = "https___registry.npmjs.org_buffer___buffer_5.7.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_buffer___buffer_5.7.1.tgz";
        url  = "https://registry.npmjs.org/buffer/-/buffer-5.7.1.tgz";
        sha512 = "EHcyIPBQ4BSGlvjB16k5KgAJ27CIsHY/2JBmCRReo48y9rQ3MaUzWX3KVlBa4U7MyX02HdVj0K7C3WaB3ju7FQ==";
      };
    }
    {
      name = "https___registry.npmjs.org_chownr___chownr_1.1.4.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_chownr___chownr_1.1.4.tgz";
        url  = "https://registry.npmjs.org/chownr/-/chownr-1.1.4.tgz";
        sha512 = "jJ0bqzaylmJtVnNgzTeSOs8DPavpbYgEr/b0YL8/2GO3xJEhInFmhKMUnEJQjZumK7KXGFhUy89PrsJWlakBVg==";
      };
    }
    {
      name = "https___registry.npmjs.org_code_point_at___code_point_at_1.1.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_code_point_at___code_point_at_1.1.0.tgz";
        url  = "https://registry.npmjs.org/code-point-at/-/code-point-at-1.1.0.tgz";
        sha1 = "DQcLTQQ6W+ozovGkDi7bPZpMz3c=";
      };
    }
    {
      name = "https___registry.npmjs.org_command_line_args___command_line_args_5.2.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_command_line_args___command_line_args_5.2.1.tgz";
        url  = "https://registry.npmjs.org/command-line-args/-/command-line-args-5.2.1.tgz";
        sha512 = "H4UfQhZyakIjC74I9d34fGYDwk3XpSr17QhEd0Q3I9Xq1CETHo4Hcuo87WyWHpAF1aSLjLRf5lD9ZGX2qStUvg==";
      };
    }
    {
      name = "https___registry.npmjs.org_console_control_strings___console_control_strings_1.1.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_console_control_strings___console_control_strings_1.1.0.tgz";
        url  = "https://registry.npmjs.org/console-control-strings/-/console-control-strings-1.1.0.tgz";
        sha1 = "PXz0Rk22RG6mRL9LOVB/mFEAjo4=";
      };
    }
    {
      name = "https___registry.npmjs.org_core_util_is___core_util_is_1.0.3.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_core_util_is___core_util_is_1.0.3.tgz";
        url  = "https://registry.npmjs.org/core-util-is/-/core-util-is-1.0.3.tgz";
        sha512 = "ZQBvi1DcpJ4GDqanjucZ2Hj3wEO5pZDS89BWbkcrvdxksJorwUDDZamX9ldFkp9aw2lmBDLgkObEA4DWNJ9FYQ==";
      };
    }
    {
      name = "https___registry.npmjs.org_create_require___create_require_1.1.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_create_require___create_require_1.1.1.tgz";
        url  = "https://registry.npmjs.org/create-require/-/create-require-1.1.1.tgz";
        sha512 = "dcKFX3jn0MpIaXjisoRvexIJVEKzaq7z2rZKxf+MSr9TkdmHmsU4m2lcLojrj/FHl8mk5VxMmYA+ftRkP/3oKQ==";
      };
    }
    {
      name = "https___registry.npmjs.org_decompress_response___decompress_response_4.2.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_decompress_response___decompress_response_4.2.1.tgz";
        url  = "https://registry.npmjs.org/decompress-response/-/decompress-response-4.2.1.tgz";
        sha512 = "jOSne2qbyE+/r8G1VU+G/82LBs2Fs4LAsTiLSHOCOMZQl2OKZ6i8i4IyHemTe+/yIXOtTcRQMzPcgyhoFlqPkw==";
      };
    }
    {
      name = "https___registry.npmjs.org_deep_extend___deep_extend_0.6.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_deep_extend___deep_extend_0.6.0.tgz";
        url  = "https://registry.npmjs.org/deep-extend/-/deep-extend-0.6.0.tgz";
        sha512 = "LOHxIOaPYdHlJRtCQfDIVZtfw/ufM8+rVj649RIHzcm/vGwQRXFt6OPqIFWsm2XEMrNIEtWR64sY1LEKD2vAOA==";
      };
    }
    {
      name = "https___registry.npmjs.org_delegates___delegates_1.0.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_delegates___delegates_1.0.0.tgz";
        url  = "https://registry.npmjs.org/delegates/-/delegates-1.0.0.tgz";
        sha1 = "hMbhWbgZBP3KWaDvRM2HDTElD5o=";
      };
    }
    {
      name = "https___registry.npmjs.org_detect_libc___detect_libc_1.0.3.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_detect_libc___detect_libc_1.0.3.tgz";
        url  = "https://registry.npmjs.org/detect-libc/-/detect-libc-1.0.3.tgz";
        sha1 = "+hN8S9aY7fVc1c0CrFWfkaTEups=";
      };
    }
    {
      name = "https___registry.npmjs.org_diff___diff_4.0.2.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_diff___diff_4.0.2.tgz";
        url  = "https://registry.npmjs.org/diff/-/diff-4.0.2.tgz";
        sha512 = "58lmxKSA4BNyLz+HHMUzlOEpg09FV+ev6ZMe3vJihgdxzgcwZ8VoEEPmALCZG9LmqfVoNMMKpttIYTVG6uDY7A==";
      };
    }
    {
      name = "https___registry.npmjs.org_end_of_stream___end_of_stream_1.4.4.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_end_of_stream___end_of_stream_1.4.4.tgz";
        url  = "https://registry.npmjs.org/end-of-stream/-/end-of-stream-1.4.4.tgz";
        sha512 = "+uw1inIHVPQoaVuHzRyXd21icM+cnt4CzD5rW+NC1wjOUSTOs+Te7FOv7AhN7vS9x/oIyhLP5PR1H+phQAHu5Q==";
      };
    }
    {
      name = "https___registry.npmjs.org_enquirer___enquirer_2.3.6.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_enquirer___enquirer_2.3.6.tgz";
        url  = "https://registry.npmjs.org/enquirer/-/enquirer-2.3.6.tgz";
        sha512 = "yjNnPr315/FjS4zIsUxYguYUPP2e1NK4d7E7ZOLiyYCcbFBiTMyID+2wvm2w6+pZ/odMA7cRkjhsPbltwBOrLg==";
      };
    }
    {
      name = "https___registry.npmjs.org_expand_template___expand_template_2.0.3.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_expand_template___expand_template_2.0.3.tgz";
        url  = "https://registry.npmjs.org/expand-template/-/expand-template-2.0.3.tgz";
        sha512 = "XYfuKMvj4O35f/pOXLObndIRvyQ+/+6AhODh+OKWj9S9498pHHn/IMszH+gt0fBCRWMNfk1ZSp5x3AifmnI2vg==";
      };
    }
    {
      name = "https___registry.npmjs.org_find_replace___find_replace_3.0.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_find_replace___find_replace_3.0.0.tgz";
        url  = "https://registry.npmjs.org/find-replace/-/find-replace-3.0.0.tgz";
        sha512 = "6Tb2myMioCAgv5kfvP5/PkZZ/ntTpVK39fHY7WkWBgvbeE+VHd/tZuZ4mrC+bxh4cfOZeYKVPaJIZtZXV7GNCQ==";
      };
    }
    {
      name = "https___registry.npmjs.org_fs_constants___fs_constants_1.0.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_fs_constants___fs_constants_1.0.0.tgz";
        url  = "https://registry.npmjs.org/fs-constants/-/fs-constants-1.0.0.tgz";
        sha512 = "y6OAwoSIf7FyjMIv94u+b5rdheZEjzR63GTyZJm5qh4Bi+2YgwLCcI/fPFZkL5PSixOt6ZNKm+w+Hfp/Bciwow==";
      };
    }
    {
      name = "https___registry.npmjs.org_gauge___gauge_2.7.4.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_gauge___gauge_2.7.4.tgz";
        url  = "https://registry.npmjs.org/gauge/-/gauge-2.7.4.tgz";
        sha1 = "LANAXHU4w51+s3sxcCLjJfsBi/c=";
      };
    }
    {
      name = "https___registry.npmjs.org_github_from_package___github_from_package_0.0.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_github_from_package___github_from_package_0.0.0.tgz";
        url  = "https://registry.npmjs.org/github-from-package/-/github-from-package-0.0.0.tgz";
        sha1 = "l/tdlr/eiXMxPyDoKI75oWf6ZM4=";
      };
    }
    {
      name = "https___registry.npmjs.org_has_unicode___has_unicode_2.0.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_has_unicode___has_unicode_2.0.1.tgz";
        url  = "https://registry.npmjs.org/has-unicode/-/has-unicode-2.0.1.tgz";
        sha1 = "4Ob+aijPUROIVeCG0Wkedx3iqLk=";
      };
    }
    {
      name = "https___registry.npmjs.org_ieee754___ieee754_1.2.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_ieee754___ieee754_1.2.1.tgz";
        url  = "https://registry.npmjs.org/ieee754/-/ieee754-1.2.1.tgz";
        sha512 = "dcyqhDvX1C46lXZcVqCpK+FtMRQVdIMN6/Df5js2zouUsqG7I6sFxitIC+7KYK29KdXOLHdu9zL4sFnoVQnqaA==";
      };
    }
    {
      name = "https___registry.npmjs.org_inherits___inherits_2.0.4.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_inherits___inherits_2.0.4.tgz";
        url  = "https://registry.npmjs.org/inherits/-/inherits-2.0.4.tgz";
        sha512 = "k/vGaX4/Yla3WzyMCvTQOXYeIHvqOKtnqBduzTHpzpQZzAskKMhZ2K+EnBiSM9zGSoIFeMpXKxa4dYeZIQqewQ==";
      };
    }
    {
      name = "https___registry.npmjs.org_ini___ini_1.3.8.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_ini___ini_1.3.8.tgz";
        url  = "https://registry.npmjs.org/ini/-/ini-1.3.8.tgz";
        sha512 = "JV/yugV2uzW5iMRSiZAyDtQd+nxtUnjeLt0acNdw98kKLrvuRVyB80tsREOE7yvGVgalhZ6RNXCmEHkUKBKxew==";
      };
    }
    {
      name = "https___registry.npmjs.org_is_fullwidth_code_point___is_fullwidth_code_point_1.0.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_is_fullwidth_code_point___is_fullwidth_code_point_1.0.0.tgz";
        url  = "https://registry.npmjs.org/is-fullwidth-code-point/-/is-fullwidth-code-point-1.0.0.tgz";
        sha1 = "754xOG8DGn8NZDr4L95QxFfvAMs=";
      };
    }
    {
      name = "https___registry.npmjs.org_isarray___isarray_1.0.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_isarray___isarray_1.0.0.tgz";
        url  = "https://registry.npmjs.org/isarray/-/isarray-1.0.0.tgz";
        sha1 = "u5NdSFgsuhaMBoNJV6VKPgcSTxE=";
      };
    }
    {
      name = "https___registry.npmjs.org_lodash.camelcase___lodash.camelcase_4.3.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_lodash.camelcase___lodash.camelcase_4.3.0.tgz";
        url  = "https://registry.npmjs.org/lodash.camelcase/-/lodash.camelcase-4.3.0.tgz";
        sha1 = "soqmKIorn8ZRA1x3EfZathkDMaY=";
      };
    }
    {
      name = "https___registry.npmjs.org_make_error___make_error_1.3.6.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_make_error___make_error_1.3.6.tgz";
        url  = "https://registry.npmjs.org/make-error/-/make-error-1.3.6.tgz";
        sha512 = "s8UhlNe7vPKomQhC1qFelMokr/Sc3AgNbso3n74mVPA5LTZwkB9NlXf4XPamLxJE8h0gh73rM94xvwRT2CVInw==";
      };
    }
    {
      name = "https___registry.npmjs.org_mimic_response___mimic_response_2.1.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_mimic_response___mimic_response_2.1.0.tgz";
        url  = "https://registry.npmjs.org/mimic-response/-/mimic-response-2.1.0.tgz";
        sha512 = "wXqjST+SLt7R009ySCglWBCFpjUygmCIfD790/kVbiGmUgfYGuB14PiTd5DwVxSV4NcYHjzMkoj5LjQZwTQLEA==";
      };
    }
    {
      name = "https___registry.npmjs.org_minimist___minimist_1.2.6.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_minimist___minimist_1.2.6.tgz";
        url  = "https://registry.npmjs.org/minimist/-/minimist-1.2.6.tgz";
        sha512 = "Jsjnk4bw3YJqYzbdyBiNsPWHPfO++UGG749Cxs6peCu5Xg4nrena6OVxOYxrQTqww0Jmwt+Ref8rggumkTLz9Q==";
      };
    }
    {
      name = "https___registry.npmjs.org_mkdirp_classic___mkdirp_classic_0.5.3.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_mkdirp_classic___mkdirp_classic_0.5.3.tgz";
        url  = "https://registry.npmjs.org/mkdirp-classic/-/mkdirp-classic-0.5.3.tgz";
        sha512 = "gKLcREMhtuZRwRAfqP3RFW+TK4JqApVBtOIftVgjuABpAtpxhPGaDcfvbhNvD0B8iD1oUr/txX35NjcaY6Ns/A==";
      };
    }
    {
      name = "https___registry.npmjs.org_nan___nan_2.15.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_nan___nan_2.15.0.tgz";
        url  = "https://registry.npmjs.org/nan/-/nan-2.15.0.tgz";
        sha512 = "8ZtvEnA2c5aYCZYd1cvgdnU6cqwixRoYg70xPLWUws5ORTa/lnw+u4amixRS/Ac5U5mQVgp9pnlSUnbNWFaWZQ==";
      };
    }
    {
      name = "https___registry.npmjs.org_napi_build_utils___napi_build_utils_1.0.2.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_napi_build_utils___napi_build_utils_1.0.2.tgz";
        url  = "https://registry.npmjs.org/napi-build-utils/-/napi-build-utils-1.0.2.tgz";
        sha512 = "ONmRUqK7zj7DWX0D9ADe03wbwOBZxNAfF20PlGfCWQcD3+/MakShIHrMqx9YwPTfxDdF1zLeL+RGZiR9kGMLdg==";
      };
    }
    {
      name = "https___registry.npmjs.org_node_abi___node_abi_2.30.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_node_abi___node_abi_2.30.1.tgz";
        url  = "https://registry.npmjs.org/node-abi/-/node-abi-2.30.1.tgz";
        sha512 = "/2D0wOQPgaUWzVSVgRMx+trKJRC2UG4SUc4oCJoXx9Uxjtp0Vy3/kt7zcbxHF8+Z/pK3UloLWzBISg72brfy1w==";
      };
    }
    {
      name = "https___registry.npmjs.org_npmlog___npmlog_4.1.2.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_npmlog___npmlog_4.1.2.tgz";
        url  = "https://registry.npmjs.org/npmlog/-/npmlog-4.1.2.tgz";
        sha512 = "2uUqazuKlTaSI/dC8AzicUck7+IrEaOnN/e0jd3Xtt1KcGpwx30v50mL7oPyr/h9bL3E4aZccVwpwP+5W9Vjkg==";
      };
    }
    {
      name = "https___registry.npmjs.org_number_is_nan___number_is_nan_1.0.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_number_is_nan___number_is_nan_1.0.1.tgz";
        url  = "https://registry.npmjs.org/number-is-nan/-/number-is-nan-1.0.1.tgz";
        sha1 = "CXtgK1NCKlIsGvuHkDGDNpQaAR0=";
      };
    }
    {
      name = "https___registry.npmjs.org_object_assign___object_assign_4.1.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_object_assign___object_assign_4.1.1.tgz";
        url  = "https://registry.npmjs.org/object-assign/-/object-assign-4.1.1.tgz";
        sha1 = "IQmtx5ZYh8/AXLvUQsrIv7s2CGM=";
      };
    }
    {
      name = "https___registry.npmjs.org_once___once_1.4.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_once___once_1.4.0.tgz";
        url  = "https://registry.npmjs.org/once/-/once-1.4.0.tgz";
        sha1 = "WDsap3WWHUsROsF9nFC6753Xa9E=";
      };
    }
    {
      name = "https___registry.npmjs.org_prebuild_install___prebuild_install_6.1.4.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_prebuild_install___prebuild_install_6.1.4.tgz";
        url  = "https://registry.npmjs.org/prebuild-install/-/prebuild-install-6.1.4.tgz";
        sha512 = "Z4vpywnK1lBg+zdPCVCsKq0xO66eEV9rWo2zrROGGiRS4JtueBOdlB1FnY8lcy7JsUud/Q3ijUxyWN26Ika0vQ==";
      };
    }
    {
      name = "https___registry.npmjs.org_process_nextick_args___process_nextick_args_2.0.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_process_nextick_args___process_nextick_args_2.0.1.tgz";
        url  = "https://registry.npmjs.org/process-nextick-args/-/process-nextick-args-2.0.1.tgz";
        sha512 = "3ouUOpQhtgrbOa17J7+uxOTpITYWaGP7/AhoR3+A+/1e9skrzelGi/dXzEYyvbxubEF6Wn2ypscTKiKJFFn1ag==";
      };
    }
    {
      name = "https___registry.npmjs.org_pump___pump_3.0.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_pump___pump_3.0.0.tgz";
        url  = "https://registry.npmjs.org/pump/-/pump-3.0.0.tgz";
        sha512 = "LwZy+p3SFs1Pytd/jYct4wpv49HiYCqd9Rlc5ZVdk0V+8Yzv6jR5Blk3TRmPL1ft69TxP0IMZGJ+WPFU2BFhww==";
      };
    }
    {
      name = "https___registry.npmjs.org_rc___rc_1.2.8.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_rc___rc_1.2.8.tgz";
        url  = "https://registry.npmjs.org/rc/-/rc-1.2.8.tgz";
        sha512 = "y3bGgqKj3QBdxLbLkomlohkvsA8gdAiUQlSBJnBhfn+BPxg4bc62d8TcBW15wavDfgexCgccckhcZvywyQYPOw==";
      };
    }
    {
      name = "https___registry.npmjs.org_readable_stream___readable_stream_2.3.7.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_readable_stream___readable_stream_2.3.7.tgz";
        url  = "https://registry.npmjs.org/readable-stream/-/readable-stream-2.3.7.tgz";
        sha512 = "Ebho8K4jIbHAxnuxi7o42OrZgF/ZTNcsZj6nRKyUmkhLFq8CHItp/fy6hQZuZmP/n3yZ9VBUbp4zz/mX8hmYPw==";
      };
    }
    {
      name = "https___registry.npmjs.org_readable_stream___readable_stream_3.6.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_readable_stream___readable_stream_3.6.0.tgz";
        url  = "https://registry.npmjs.org/readable-stream/-/readable-stream-3.6.0.tgz";
        sha512 = "BViHy7LKeTz4oNnkcLJ+lVSL6vpiFeX6/d3oSH8zCW7UxP2onchk+vTGB143xuFjHS3deTgkKoXXymXqymiIdA==";
      };
    }
    {
      name = "https___registry.npmjs.org_safe_buffer___safe_buffer_5.1.2.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_safe_buffer___safe_buffer_5.1.2.tgz";
        url  = "https://registry.npmjs.org/safe-buffer/-/safe-buffer-5.1.2.tgz";
        sha512 = "Gd2UZBJDkXlY7GbJxfsE8/nvKkUEU1G38c1siN6QP6a9PT9MmHB8GnpscSmMJSoF8LOIrt8ud/wPtojys4G6+g==";
      };
    }
    {
      name = "https___registry.npmjs.org_semver___semver_5.7.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_semver___semver_5.7.1.tgz";
        url  = "https://registry.npmjs.org/semver/-/semver-5.7.1.tgz";
        sha512 = "sauaDf/PZdVgrLTNYHRtpXa1iRiKcaebiKQ1BJdpQlWH2lCvexQdX55snPFyK7QzpudqbCI0qXFfOasHdyNDGQ==";
      };
    }
    {
      name = "https___registry.npmjs.org_set_blocking___set_blocking_2.0.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_set_blocking___set_blocking_2.0.0.tgz";
        url  = "https://registry.npmjs.org/set-blocking/-/set-blocking-2.0.0.tgz";
        sha1 = "BF+XgtARrppoA93TgrJDkrPYkPc=";
      };
    }
    {
      name = "https___registry.npmjs.org_signal_exit___signal_exit_3.0.7.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_signal_exit___signal_exit_3.0.7.tgz";
        url  = "https://registry.npmjs.org/signal-exit/-/signal-exit-3.0.7.tgz";
        sha512 = "wnD2ZE+l+SPC/uoS0vXeE9L1+0wuaMqKlfz9AMUo38JsyLSBWSFcHR1Rri62LZc12vLr1gb3jl7iwQhgwpAbGQ==";
      };
    }
    {
      name = "https___registry.npmjs.org_simple_concat___simple_concat_1.0.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_simple_concat___simple_concat_1.0.1.tgz";
        url  = "https://registry.npmjs.org/simple-concat/-/simple-concat-1.0.1.tgz";
        sha512 = "cSFtAPtRhljv69IK0hTVZQ+OfE9nePi/rtJmw5UjHeVyVroEqJXP1sFztKUy1qU+xvz3u/sfYJLa947b7nAN2Q==";
      };
    }
    {
      name = "https___registry.npmjs.org_simple_get___simple_get_3.1.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_simple_get___simple_get_3.1.1.tgz";
        url  = "https://registry.npmjs.org/simple-get/-/simple-get-3.1.1.tgz";
        sha512 = "CQ5LTKGfCpvE1K0n2us+kuMPbk/q0EKl82s4aheV9oXjFEz6W/Y7oQFVJuU6QG77hRT4Ghb5RURteF5vnWjupA==";
      };
    }
    {
      name = "https___registry.npmjs.org_string_decoder___string_decoder_1.1.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_string_decoder___string_decoder_1.1.1.tgz";
        url  = "https://registry.npmjs.org/string_decoder/-/string_decoder-1.1.1.tgz";
        sha512 = "n/ShnvDi6FHbbVfviro+WojiFzv+s8MPMHBczVePfUpDJLwoLT0ht1l4YwBCbi8pJAveEEdnkHyPyTP/mzRfwg==";
      };
    }
    {
      name = "https___registry.npmjs.org_string_width___string_width_1.0.2.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_string_width___string_width_1.0.2.tgz";
        url  = "https://registry.npmjs.org/string-width/-/string-width-1.0.2.tgz";
        sha1 = "EYvfW4zcUaKn5w0hHgfisLmxB9M=";
      };
    }
    {
      name = "https___registry.npmjs.org_strip_ansi___strip_ansi_3.0.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_strip_ansi___strip_ansi_3.0.1.tgz";
        url  = "https://registry.npmjs.org/strip-ansi/-/strip-ansi-3.0.1.tgz";
        sha1 = "ajhfuIU9lS1f8F0Oiq+UJ43GPc8=";
      };
    }
    {
      name = "https___registry.npmjs.org_strip_json_comments___strip_json_comments_2.0.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_strip_json_comments___strip_json_comments_2.0.1.tgz";
        url  = "https://registry.npmjs.org/strip-json-comments/-/strip-json-comments-2.0.1.tgz";
        sha1 = "PFMZQukIwml8DsNEhYwobHygpgo=";
      };
    }
    {
      name = "https___registry.npmjs.org_tar_fs___tar_fs_2.1.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_tar_fs___tar_fs_2.1.1.tgz";
        url  = "https://registry.npmjs.org/tar-fs/-/tar-fs-2.1.1.tgz";
        sha512 = "V0r2Y9scmbDRLCNex/+hYzvp/zyYjvFbHPNgVTKfQvVrb6guiE/fxP+XblDNR011utopbkex2nM4dHNV6GDsng==";
      };
    }
    {
      name = "https___registry.npmjs.org_tar_stream___tar_stream_2.2.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_tar_stream___tar_stream_2.2.0.tgz";
        url  = "https://registry.npmjs.org/tar-stream/-/tar-stream-2.2.0.tgz";
        sha512 = "ujeqbceABgwMZxEJnk2HDY2DlnUZ+9oEcb1KzTVfYHio0UE6dG71n60d8D2I4qNvleWrrXpmjpt7vZeF1LnMZQ==";
      };
    }
    {
    name = "tree-sitter-nix.git";
    path =
      let
        repo = fetchgit {
          url = "ssh://git@github.com/cstrahan/tree-sitter-nix.git";
          rev = "470b15a60520ff7b86f51732b8d8f1118c86041e";
          sha256 = "1hl0mpy0i6r160v6v3nflrdi5fnmd8i5zbx963h5nj9fg4srkb5r";
        };
      in
        runCommand "tree-sitter-nix.git" { buildInputs = [gnutar]; } ''
          # Set u+w because tar-fs can't unpack archives with read-only dirs
          # https://github.com/mafintosh/tar-fs/issues/79
          tar cf $out --mode u+w -C ${repo} .
        '';
  }
    {
      name = "https___registry.npmjs.org_tree_sitter___tree_sitter_0.20.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_tree_sitter___tree_sitter_0.20.0.tgz";
        url  = "https://registry.npmjs.org/tree-sitter/-/tree-sitter-0.20.0.tgz";
        sha512 = "tqTdtD1T2cN4aEES0sZCjKTQrc9Ls8H/iYlzpskhGy8yCwNPKBIbK9YuuCg/AxACr8RAY4wMoeCigM1X/A79yg==";
      };
    }
    {
      name = "https___registry.npmjs.org_ts_node___ts_node_10.7.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_ts_node___ts_node_10.7.0.tgz";
        url  = "https://registry.npmjs.org/ts-node/-/ts-node-10.7.0.tgz";
        sha512 = "TbIGS4xgJoX2i3do417KSaep1uRAW/Lu+WAL2doDHC0D6ummjirVOXU5/7aiZotbQ5p1Zp9tP7U6cYhA0O7M8A==";
      };
    }
    {
      name = "https___registry.npmjs.org_tunnel_agent___tunnel_agent_0.6.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_tunnel_agent___tunnel_agent_0.6.0.tgz";
        url  = "https://registry.npmjs.org/tunnel-agent/-/tunnel-agent-0.6.0.tgz";
        sha1 = "J6XeoGs2sEoKmWZ3SykIaPD8QP0=";
      };
    }
    {
      name = "https___registry.npmjs.org_typescript___typescript_4.6.3.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_typescript___typescript_4.6.3.tgz";
        url  = "https://registry.npmjs.org/typescript/-/typescript-4.6.3.tgz";
        sha512 = "yNIatDa5iaofVozS/uQJEl3JRWLKKGJKh6Yaiv0GLGSuhpFJe7P3SbHZ8/yjAHRQwKRoA6YZqlfjXWmVzoVSMw==";
      };
    }
    {
      name = "https___registry.npmjs.org_typical___typical_4.0.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_typical___typical_4.0.0.tgz";
        url  = "https://registry.npmjs.org/typical/-/typical-4.0.0.tgz";
        sha512 = "VAH4IvQ7BDFYglMd7BPRDfLgxZZX4O4TFcRDA6EN5X7erNJJq+McIEp8np9aVtxrCJ6qx4GTYVfOWNjcqwZgRw==";
      };
    }
    {
      name = "https___registry.npmjs.org_util_deprecate___util_deprecate_1.0.2.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_util_deprecate___util_deprecate_1.0.2.tgz";
        url  = "https://registry.npmjs.org/util-deprecate/-/util-deprecate-1.0.2.tgz";
        sha1 = "RQ1Nyfpw3nMnYvvS1KKJgUGaDM8=";
      };
    }
    {
      name = "https___registry.npmjs.org_v8_compile_cache_lib___v8_compile_cache_lib_3.0.0.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_v8_compile_cache_lib___v8_compile_cache_lib_3.0.0.tgz";
        url  = "https://registry.npmjs.org/v8-compile-cache-lib/-/v8-compile-cache-lib-3.0.0.tgz";
        sha512 = "mpSYqfsFvASnSn5qMiwrr4VKfumbPyONLCOPmsR3A6pTY/r0+tSaVbgPWSAIuzbk3lCTa+FForeTiO+wBQGkjA==";
      };
    }
    {
      name = "https___registry.npmjs.org_wide_align___wide_align_1.1.5.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_wide_align___wide_align_1.1.5.tgz";
        url  = "https://registry.npmjs.org/wide-align/-/wide-align-1.1.5.tgz";
        sha512 = "eDMORYaPNZ4sQIuuYPDHdQvf4gyCF9rEEV/yPxGfwPkRodwEgiMUUXTx/dex+Me0wxx53S+NgUHaP7y3MGlDmg==";
      };
    }
    {
      name = "https___registry.npmjs.org_wrappy___wrappy_1.0.2.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_wrappy___wrappy_1.0.2.tgz";
        url  = "https://registry.npmjs.org/wrappy/-/wrappy-1.0.2.tgz";
        sha1 = "tSQ9jz7BqjXxNkYFvA0QNuMKtp8=";
      };
    }
    {
      name = "https___registry.npmjs.org_yn___yn_3.1.1.tgz";
      path = fetchurl {
        name = "https___registry.npmjs.org_yn___yn_3.1.1.tgz";
        url  = "https://registry.npmjs.org/yn/-/yn-3.1.1.tgz";
        sha512 = "Ux4ygGWsu2c7isFWe8Yu1YluJmqVhxqK2cLXNQA5AcC3QfbGNpM7fu0Y8b/z16pXLnFxZYvWhd3fhBY9DLmC6Q==";
      };
    }
  ];
}
