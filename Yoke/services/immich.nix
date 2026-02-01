{ config, pkgs, lib, inputs, ... }: {
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    user = "immich";
    group = "personalfiles"; # chmod 740, immich files shoudn't be edited externally :(
    openFirewall = true;
    mediaLocation = "/mnt/pool1/PersonalFiles/Media/immich";
    machine-learning = {
      enable = true;
    };
    accelerationDevices = null; # allow all
    environment = {
      IMMICH_ALLOW_SETUP = "false";
    };
    
    # Exported from UI, immich is awesome!
    settings = builtins.fromJSON ''
      {
        "backup": {
          "database": {
            "cronExpression": "0 01 * * *",
            "enabled": true,
            "keepLastAmount": 14
          }
        },
        "ffmpeg": {
          "accel": "vaapi",
          "accelDecode": false,
          "acceptedAudioCodecs": [
            "aac",
            "mp3",
            "libopus"
          ],
          "acceptedContainers": [
            "mov",
            "ogg",
            "webm"
          ],
          "acceptedVideoCodecs": [
            "av1",
            "h264",
            "vp9"
          ],
          "bframes": -1,
          "cqMode": "auto",
          "crf": 35,
          "gopSize": 0,
          "maxBitrate": "0",
          "preferredHwDevice": "auto",
          "preset": "medium",
          "refs": 0,
          "targetAudioCodec": "aac",
          "targetResolution": "1080",
          "targetVideoCodec": "av1",
          "temporalAQ": false,
          "threads": 6,
          "tonemap": "hable",
          "transcode": "required",
          "twoPass": false
        },
        "image": {
          "colorspace": "p3",
          "extractEmbedded": false,
          "fullsize": {
            "enabled": false,
            "format": "jpeg",
            "quality": 80
          },
          "preview": {
            "format": "webp",
            "quality": 80,
            "size": 1440
          },
          "thumbnail": {
            "format": "webp",
            "quality": 77,
            "size": 200
          }
        },
        "job": {
          "backgroundTask": {
            "concurrency": 5
          },
          "faceDetection": {
            "concurrency": 2
          },
          "library": {
            "concurrency": 5
          },
          "metadataExtraction": {
            "concurrency": 5
          },
          "migration": {
            "concurrency": 5
          },
          "notifications": {
            "concurrency": 5
          },
          "ocr": {
            "concurrency": 1
          },
          "search": {
            "concurrency": 5
          },
          "sidecar": {
            "concurrency": 5
          },
          "smartSearch": {
            "concurrency": 2
          },
          "thumbnailGeneration": {
            "concurrency": 3
          },
          "videoConversion": {
            "concurrency": 1
          },
          "workflow": {
            "concurrency": 5
          }
        },
        "library": {
          "scan": {
            "cronExpression": "0 0 * * *",
            "enabled": true
          },
          "watch": {
            "enabled": false
          }
        },
        "logging": {
          "enabled": true,
          "level": "log"
        },
        "machineLearning": {
          "availabilityChecks": {
            "enabled": true,
            "interval": 30000,
            "timeout": 2000
          },
          "clip": {
            "enabled": true,
            "modelName": "ViT-L-16-SigLIP2-256__webli"
          },
          "duplicateDetection": {
            "enabled": true,
            "maxDistance": 0.001
          },
          "enabled": true,
          "facialRecognition": {
            "enabled": true,
            "maxDistance": 0.5,
            "minFaces": 3,
            "minScore": 0.7,
            "modelName": "buffalo_l"
          },
          "ocr": {
            "enabled": true,
            "maxResolution": 1000,
            "minDetectionScore": 0.5,
            "minRecognitionScore": 0.8,
            "modelName": "LATIN__PP-OCRv5_mobile"
          },
          "urls": [
            "http://localhost:3003"
          ]
        },
        "map": {
          "darkStyle": "https://tiles.immich.cloud/v1/style/dark.json",
          "enabled": true,
          "lightStyle": "https://tiles.immich.cloud/v1/style/light.json"
        },
        "metadata": {
          "faces": {
            "import": true
          }
        },
        "newVersionCheck": {
          "enabled": true
        },
        "nightlyTasks": {
          "clusterNewFaces": true,
          "databaseCleanup": true,
          "generateMemories": true,
          "missingThumbnails": true,
          "startTime": "00:00",
          "syncQuotaUsage": true
        },
        "notifications": {
          "smtp": {
            "enabled": false,
            "from": "",
            "replyTo": "",
            "transport": {
              "host": "",
              "ignoreCert": false,
              "password": "",
              "port": 587,
              "secure": false,
              "username": ""
            }
          }
        },
        "oauth": {
          "autoLaunch": false,
          "autoRegister": true,
          "buttonText": "Login with OAuth",
          "clientId": "",
          "clientSecret": "",
          "defaultStorageQuota": null,
          "enabled": false,
          "issuerUrl": "",
          "mobileOverrideEnabled": false,
          "mobileRedirectUri": "",
          "profileSigningAlgorithm": "none",
          "roleClaim": "immich_role",
          "scope": "openid email profile",
          "signingAlgorithm": "RS256",
          "storageLabelClaim": "preferred_username",
          "storageQuotaClaim": "immich_quota",
          "timeout": 30000,
          "tokenEndpointAuthMethod": "client_secret_post"
        },
        "passwordLogin": {
          "enabled": true
        },
        "reverseGeocoding": {
          "enabled": true
        },
        "server": {
          "externalDomain": "",
          "loginPageMessage": "",
          "publicUsers": true
        },
        "storageTemplate": {
          "enabled": true,
          "hashVerificationEnabled": true,
          "template": "{{y}}/{{y}}-{{MM}}/{{y}}-{{MM}}-{{dd}}-{{filename}}"
        },
        "templates": {
          "email": {
            "albumInviteTemplate": "",
            "albumUpdateTemplate": "",
            "welcomeTemplate": ""
          }
        },
        "theme": {
          "customCss": ""
        },
        "trash": {
          "days": 31,
          "enabled": true
        },
        "user": {
          "deleteDelay": 7
        }
      }
    '';
  };

  services.yaiiu-immich-proxy = {
    enable = true;
    port = 2282;
    immichUrl = "http://localhost:${toString config.services.immich.port}";
    openFirewall = true;
  };

  users.users.immich.extraGroups = [ "personalfiles" "viddownload" ];


}