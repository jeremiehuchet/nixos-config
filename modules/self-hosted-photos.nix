{ lib, pkgs, config, ... }:

let
  cfg = config.self-hosted.photos;
  secrets = import ../secrets.nix;
  secretFiles = ../secrets;
in {

  options = { self-hosted.photos.enable = lib.mkEnableOption "Self hosted photos cloud"; };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.caesiumclt
    ];

    services.nginx.virtualHosts."photos.huchet.ovh" = {
      forceSSL = true;
      useACMEHost = "huchet.ovh";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.immich.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 5000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };

    services.immich = {
      enable = true;
      package = pkgs.unstable.immich;
      # `null` will give access to all devices.
      accelerationDevices = null;
    };

    # for hardware acceleration
    users.users.immich.extraGroups = [ "video" "render" ];

    services.postgresqlBackup.databases = [ config.services.immich.database.name ];

    systemd.services.immich-upload-optimizer = let
      handbrakeConfigFile = pkgs.writeText "immich-upload-optimizer-handbrake.json" (builtins.toJSON {
        PresetList = [
          {
            AlignAVStart = false;
            AudioCopyMask = [
              "copy:opus"
            ];
            AudioEncoderFallback = "opus";
            AudioLanguageList = [];
            AudioList = [
              {
                AudioBitrate = 128;
                AudioCompressionLevel = 0;
                AudioEncoder = "opus";
                AudioMixdown = "stereo";
                AudioNormalizeMixLevel = false;
                AudioSamplerate = "auto";
                AudioTrackQualityEnable = false;
                AudioTrackQuality = -1;
                AudioTrackGainSlider = 0;
                AudioTrackDRCSlider = 0;
              }
            ];
            AudioSecondaryEncoderMode = true;
            AudioTrackSelectionBehavior = "first";
            ChapterMarkers = false;
            ChildrenArray = [];
            Default = false;
            FileFormat = "av_mkv";
            Folder = false;
            FolderOpen = false;
            Optimize = false;
            Mp4iPodCompatible = false;
            PictureCropMode = 0;
            PictureBottomCrop = 0;
            PictureLeftCrop = 0;
            PictureRightCrop = 0;
            PictureTopCrop = 0;
            PictureDARWidth = 0;
            PictureDeblockPreset = "off";
            PictureDeblockTune = "medium";
            PictureDeblockCustom = "";
            PictureDeinterlaceFilter = "decomb";
            PictureCombDetectPreset = "default";
            PictureCombDetectCustom = "";
            PictureDeinterlacePreset = "default";
            PictureDeinterlaceCustom = "";
            PictureDenoiseCustom = "";
            PictureDenoiseFilter = "off";
            PictureSharpenCustom = "";
            PictureSharpenFilter = "off";
            PictureSharpenPreset = "medium";
            PictureSharpenTune = "none";
            PictureDetelecine = "off";
            PictureDetelecineCustom = "";
            PictureColorspacePreset = "off";
            PictureColorspaceCustom = "";
            PictureChromaSmoothPreset = "off";
            PictureChromaSmoothTune = "none";
            PictureChromaSmoothCustom = "";
            PictureItuPAR = false;
            PictureKeepRatio = true;
            PicturePAR = "auto";
            PicturePARWidth = 0;
            PicturePARHeight = 0;
            PictureUseMaximumSize = true;
            PictureAllowUpscaling = false;
            PictureForceHeight = 0;
            PictureForceWidth = 0;
            PicturePadMode = "none";
            PicturePadTop = 0;
            PicturePadBottom = 0;
            PicturePadLeft = 0;
            PicturePadRight = 0;
            PresetName = "immich-upload-optimizer";
            Type = 1;
            SubtitleAddCC = false;
            SubtitleAddForeignAudioSearch = false;
            SubtitleAddForeignAudioSubtitle = false;
            SubtitleBurnBehavior = "none";
            SubtitleBurnBDSub = false;
            SubtitleBurnDVDSub = false;
            SubtitleLanguageList = [];
            SubtitleTrackSelectionBehavior = "none";
            VideoAvgBitrate = 0;
            VideoColorMatrixCode = 0;
            VideoEncoder = "svt_av1_10bit";
            VideoFramerateMode = "vfr";
            VideoGrayScale = false;
            VideoScaler = "swscale";
            VideoPreset = "5";
            VideoTune = "";
            VideoProfile = "main";
            VideoLevel = "auto";
            VideoOptionExtra = "";
            VideoQualityType = 2;
            VideoQualitySlider = 20;
            VideoMultiPass = true;
            VideoTurboMultiPass = false;
            x264UseAdvancedOptions = false;
            PresetDisabled = false;
            MetadataPassthru = true;
          }
        ];
        VersionMajor = 59;
        VersionMicro = 0;
        VersionMinor = 0;
      });
      tasksConfigFile = pkgs.writeText "immich-upload-optimizer-tasks.yaml" ''
        tasks:
          - name: caesium
            command: caesiumclt --keep-dates --exif --quality=0 --output={{.folder}} {{.folder}}/{{.name}}.{{.extension}}
            extensions:
              - jpeg
              - jpg
              - png
              - tiff
              - tif
              - webp
              - gif
          - name: passthrough-images
            command: ""
            extensions:
              # https://immich.app/docs/features/supported-formats/
              - avif
              - bmp
              - gif
              - heic
              - heif
              - webp
              - insp
              - jxl
              - webp
              - psd
              - raw
              - rw2
              - svg
          - name: handbrake
            command: HandBrakeCLI --preset-import-file ${handbrakeConfigFile} -Z immich-upload-optimizer -i {{.folder}}/{{.name}}.{{.extension}} -o {{.folder}}/{{.name}}-new.mkv && rm {{.folder}}/{{.name}}.{{.extension}}
            extensions:
              - 3gp
              - 3gpp
              - avi
              - flv
              - m4v
              - mkv
              - mts
              - m2ts
              - m2t
              - mp4
              - insv
              - mpg
              - mpe
              - mpeg
              - mov
              - webm
              - wmv
        # Block all other formats from being uploaded.
      '';
    in {
      enable = true;
      description = "Immich proxy optimizing uploads";
      after = ["immich-server.service"];
      requires = ["immich-server.service"];
      path = with pkgs; [
        curl
        caesiumclt
        exiftool
        ffmpeg
        handbrake
        imagemagick
        jq
        libjxl
        bash
      ];
      environment = {
        TMPDIR = "/var/cache/immich-upload-optimizer";
      };
      script = ''
        ${pkgs.immich-upload-optimizer}/bin/immich-upload-optimizer \
            -upstream http://127.0.0.1:2283 \
            -listen 127.0.0.1:2284 \
            -tasks_file ${tasksConfigFile}
      '';
      serviceConfig = {
        DynamicUser = true;
        CacheDirectory = "immich-upload-optimizer";
        Nice = 19;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
      };
    };
  };
}
