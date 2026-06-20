{ pkgs, secretSrc, ... }:
let
  secrets = import "${secretSrc}/secrets.nix";

  agentmemoryVersion = "0.9.20";
  agentmemoryOpencodeRev = "c2f231fe8bcf9b1fa296ad5ee81267eec94de768";
  agentmemoryOpencodeFile = path: hash: pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rohitg00/agentmemory/${agentmemoryOpencodeRev}/${path}";
    inherit hash;
  };

  mcp-tasks = pkgs.buildGoModule rec {
    pname = "mcp-webdav-tasks";
    version = "0.1";

    src = pkgs.fetchFromGitHub {
      owner = "Mickael-Roger";
      repo = "mcp-webdav-tasks";
      rev = "v${version}";
      sha256 = "sha256-xf2kcfrUfSbzBwweKiqti+JJHyVM0YYk2t2hir25nI0=";
    };

    vendorHash = "sha256-Foyk/KOJQgredlbA1YG2k6k7YEILytTCdSwUrRnlnJg=";
    subPackages = [ "." ];
  };

  opencodeConfigDir = ./config-files/opencode;
  filesInDir = dir:
    pkgs.lib.concatLists (
      pkgs.lib.mapAttrsToList (
        name: type:
          let
            path = dir + "/${name}";
          in
          if type == "directory" then
            filesInDir path
          else if type == "regular" then
            [ path ]
          else
            [ ]
      ) (builtins.readDir dir)
    );
  relativeToOpencodeDir = file:
    pkgs.lib.removePrefix "${toString opencodeConfigDir}/" (toString file);
  opencodeConfigFiles = builtins.listToAttrs (
    map (file: {
      name = "opencode/${relativeToOpencodeDir file}";
      value.source = file;
    }) (filesInDir opencodeConfigDir)
  );
in
{
  services.litellm = {
    enable = true;

    host = "127.0.0.1";
    port = 4000;
    openFirewall = true;

    settings = {
      model_list = [
        # Z.ai
        {
          model_name = "glm-5.2";
          litellm_params = {
            model = "openai/GLM-5.2";
            api_base = "https://api.z.ai/api/coding/paas/v4";
            api_key = "${secrets.zai_api_key}";
          };
        }
      
        {
          model_name = "glm-5.1";
          litellm_params = {
            model = "openai/GLM-5.1";
            api_base = "https://api.z.ai/api/coding/paas/v4";
            api_key = "${secrets.zai_api_key}";
          };
        }
      
        {
          model_name = "glm-4.5";
          litellm_params = {
            model = "openai/GLM-4.5";
            api_base = "https://api.z.ai/api/coding/paas/v4";
            api_key = "${secrets.zai_api_key}";
          };
        }

        {
          model_name = "glm-5";
          litellm_params = {
            model = "openai/GLM-5";
            api_base = "https://api.z.ai/api/coding/paas/v4";
            api_key = "${secrets.zai_api_key}";
          };
        }
      
        {
          model_name = "glm-5-turbo";
          litellm_params = {
            model = "openai/GLM-5-Turbo";
            api_base = "https://api.z.ai/api/coding/paas/v4";
            api_key = "${secrets.zai_api_key}";
          };
        }
      
        # OpenAI embeddings
        {
          model_name = "text-embedding-3-small";
          litellm_params = {
            model = "openai/text-embedding-3-small";
            api_key = "${secrets.openai_token}";
          };
        }
      ];

      general_settings = {
        # User/API key for LiteLLM clients.
        master_key = "${secrets.litellm_token}";
      };
    };
  };

  home-manager.users.mickael = {
    xdg.configFile = opencodeConfigFiles // {
      "opencode/opencode.json".text = ''
      {
       "$schema": "https://opencode.ai/config.json",
       "formatter": true,
       "theme": "opencode",
       "plugin": ["./plugins/agentmemory-capture.ts"],
       "autoupdate": false,
       "mcp": {
         "freecad": {
            "type": "local",
            "enabled": true,
            "command": ["uvx", "freecad-mcp"],
         },
          "brave-search": {
            "type": "local",
            "enabled": true,
            "command": ["npx", "-y", "@brave/brave-search-mcp-server", "--transport", "stdio"],
            "environment": {
              "BRAVE_API_KEY": "${secrets.brave_api_key}"
            }
          },
          "tasks": {
            "type": "local",
            "command": ["${mcp-tasks}/bin/mcp-webdav-tasks"],
            "enabled": true,
            "environment": {
              "MCP_WEBDAV_TASKS_SERVER": "https://zimbra1.mail.ovh.net/dav/${secrets.mail.username}/",
              "MCP_WEBDAV_TASKS_USERNAME": "${secrets.mail.username}",
              "MCP_WEBDAV_TASKS_PASSWORD": "${secrets.mail.password}",
            },
          },
          "context7": {
            "type": "remote",
            "url": "https://mcp.context7.com/mcp",
            "enabled": true,
            "headers": {
              "CONTEXT7_API_KEY": "${secrets.context7_api}"
            },
          },
          "n8n": {
            "type": "local",
            "command": ["n8n-mcp"],
            "enabled": true,
            "environment": {
              "MCP_MODE": "stdio",
              "LOG_LEVEL": "error",
              "DISABLE_CONSOLE_OUTPUT": "true",
              "N8N_API_URL": "${secrets.n8n.url}",
              "N8N_API_KEY": "${secrets.n8n.token}"
            }
          },
          "github": {
            "type": "local",
            "command": ["github-mcp-server", "stdio"],
            "enabled": true,
            "environment": {
              "GITHUB_PERSONAL_ACCESS_TOKEN": "${secrets.github_token}",
            }
          },
          "playwright": {
            "type": "local",
            "command": ["${pkgs.playwright-mcp}/bin/mcp-server-playwright"],
            "enabled": true
          },
          "memory": {
            "type": "local",
            "command": ["${pkgs.nodejs_20}/bin/npx", "-y", "@agentmemory/mcp@${agentmemoryVersion}"],
            "enabled": true,
            "environment": {
              "AGENTMEMORY_URL": "http://localhost:3111"
            }
          },
        },
        "tools": {
          "memory_memory_recall": true,
          "memory_memory_compress_file": true,
          "memory_memory_save": true,
          "memory_memory_patterns": false,
          "memory_memory_smart_search": true,
          "memory_memory_file_history": true,
          "memory_memory_sessions": true,
          "memory_memory_timeline": true,
          "memory_memory_profile": true,
          "memory_memory_export": false,
          "memory_memory_relations": true,
          
          "memory_memory_patterns": false,
          "memory_memory_timeline": true,
          "memory_memory_relations": true,
          "memory_memory_graph_query": true,
          "memory_memory_consolidate": false,
          "memory_memory_claude_bridge_sync": false,
          "memory_memory_team_share": false,
          "memory_memory_team_feed": false,
          "memory_memory_audit": false,
          "memory_memory_governance_delete": false,
          "memory_memory_snapshot_create": false,
          "memory_memory_action_create": true,
          "memory_memory_action_update": true,
          "memory_memory_frontier": false,
          "memory_memory_next": true,
          "memory_memory_lease": false,
          "memory_memory_routine_run": false,
          "memory_memory_signal_send": false,
          "memory_memory_signal_read": false,
          "memory_memory_checkpoint": false,
          "memory_memory_mesh_sync": false,
          "memory_memory_sentinel_create": false,
          "memory_memory_sentinel_trigger": false,
          "memory_memory_sketch_create": false,
          "memory_memory_sketch_promote": false,
          "memory_memory_crystallize": false,
          "memory_memory_diagnose": false,
          "memory_memory_heal": false,
          "memory_memory_facet_tag": false,
          "memory_memory_facet_query": false,
          "memory_memory_verify": false,
          "freecad_*": false,
          "n8n_*": false,
          "playwright_*": false,
          "github_*": false,
          "tasks_*": false,
          "brave-search_*": false,
          //Needs OPENCODE_ENABLE_EXA=1 env var
          "websearch": true
        },
        "agent": {
          "agent-builder": {
            "hidden": true
          },
          "freecad": {
            "permission": {
              "freecad_*": "allow",
            }
          },
          "build": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
          },
          "planificator": {
            "permission": {
              "github_*": "allow",
              "playwright_*": "allow",
              "bash": "allow",
              "webfetch": "allow",
              "glob": "allow",
              "write": "deny",
              "edit": "deny",
              "lsp": "allow",
              "task": {
                "agent-*": "allow"
              }
            },
            "tools": {
              "goToDefinition": true,
              "findReferences": true,
              "hover": true,
              "documentSymbol": true,
              "workspaceSymbol": true,
              "goToImplementation": true,
              "prepareCallHierarchy": true,
              "incomingCalls": true,
              "outgoingCall": true
            }
          },
          "explore": {
            "permission": {
              "lsp": "allow",
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "goToDefinition": true,
              "findReferences": true,
              "hover": true,
              "documentSymbol": true,
              "workspaceSymbol": true,
              "goToImplementation": true,
              "prepareCallHierarchy": true,
              "incomingCalls": true,
              "outgoingCall": true
            }
          },
          "review": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "github_*": true,
              "bash": true,
              "webfetch": true,
              "glob": true,
              "write": false,
              "edit": false
            }
          },
          "security-review": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "github_*": true,
              "bash": true,
              "webfetch": true,
              "glob": true,
              "write": false,
              "edit": false
            }
          },
          "git": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "github_*": true,
              "bash": true,
              "webfetch": true,
              "write": false,
              "edit": false
            }
          },
          "n8n": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "n8n_*": true,
              "bash": true,
              "webfetch": true,
              "write": true,
              "edit": true
            }
          },
          "webbrowser": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "playwright_*": true,
              "bash": true,
              "webfetch": true,
            }
          },
          "chat": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "tasks_*": true,
              "websearch_*": false,
              "brave-search_*": true,
              "bash": false,
              "grep": true,
              "webfetch": true,
              "write": true,
              "edit": false
            }
          },
          "memory": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "memory_memory_*": true,
              "websearch_*": true,
              "bash": false,
              "grep": true,
              "webfetch": true,
              "write": true,
              "edit": false
            }
          },
        },
        "lsp": {
          "pyright": {
            "command": ["${pkgs.pyright}/bin/pyright-langserver", "--stdio"]
          },
          "gopls": {
            "command": ["${pkgs.gopls}/bin/gopls"]
          },
          "typescript": {
            "command": ["${pkgs.typescript-language-server}/bin/typescript-language-server"]
          },
          "bash": {
            "command": ["${pkgs.bash-language-server}/bin/bash-language-server"]
          },
          "clangd": {
            "command": ["${pkgs.clang-tools}/bin/clangd"]
          },
          "nixd": {
            "command": ["${pkgs.nixd}/bin/nixd"]
          },
          "yaml-ls": {
            "command": ["${pkgs.yaml-language-server}/bin/yaml-language-server", "--stdio"]
          },
          "openscad-lsp": {
            "command": ["${pkgs.openscad-lsp}/bin/openscad-lsp", "--stdio"],
            "extensions": [".scad"]
          }
        }
      }
    '';

      "opencode/plugins/agentmemory-capture.ts".source = agentmemoryOpencodeFile "plugin/opencode/agentmemory-capture.ts" "sha256-VsnrsNxDLtkv5nlHIkOj/qw43VGYdwCyo9VOTDJiUxI=";
      "opencode/commands/recall.md".source = agentmemoryOpencodeFile "plugin/opencode/commands/recall.md" "sha256-OwVwHbreZeEZJyZZK5Ivqs4mvwtlnzHntUpqWEiA6Xs=";
      "opencode/commands/remember.md".source = agentmemoryOpencodeFile "plugin/opencode/commands/remember.md" "sha256-jifK8lui0vH9eUTwRUyQz5tLX/JAVKkcW66yQgJfpqk=";
    };

    systemd.user.services.agentmemory = {
      Unit = {
        Description = "agentmemory server";
        After = [ "network-online.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.nodejs_20}/bin/npx -y @agentmemory/agentmemory@${agentmemoryVersion}";
        Restart = "on-failure";
        RestartSec = 5;
        Environment = [
          # Auth and endpoint
          "AGENTMEMORY_URL=http://localhost:3111"
          "AGENTMEMORY_VIEWER_URL=http://localhost:3113"
          # MCP/runtime
          "AGENTMEMORY_TOOLS=all"
          # Behaviour flags
          "AGENTMEMORY_AUTO_COMPRESS=true"
          #"AGENTMEMORY_INJECT_CONTEXT=true"
          "CONSOLIDATION_ENABLED=true"
          "CONSOLIDATION_DECAY_DAYS=30"
          "GRAPH_EXTRACTION_ENABLED=true"
          #"GRAPH_EXTRACTION_BATCH_SIZE=8"
          #"AGENTMEMORY_REFLECT=false"
          #"AGENTMEMORY_DROP_STALE_INDEX=false"
          #"AGENTMEMORY_IMAGE_EMBEDDINGS=false"
          # Embeddings
          "EMBEDDING_PROVIDER=openai"
          "OPENAI_API_KEY=${secrets.litellm_token}"
          "OPENAI_BASE_URL=https://server.taila2494.ts.net/"
          "OPENAI_MODEL=glm-4.5"
          "OPENAI_API_KEY_FOR_LLM=true"
          "OPENAI_EMBEDDING_MODEL=text-embedding-3-small"
          #"OPENAI_EMBEDDING_DIMENSIONS=1536"
          # LLM provider, optional
          # "ANTHROPIC_API_KEY=${secrets.anthropic_api_key}"
          # "ANTHROPIC_MODEL=claude-sonnet-4-20250514"
          # "ANTHROPIC_BASE_URL=https://api.anthropic.com"
          # "GEMINI_API_KEY=${secrets.gemini_api_key}"
          # "GEMINI_MODEL=gemini-2.5-flash"
          # "OPENROUTER_API_KEY=${secrets.openrouter_api_key}"
          # "OPENROUTER_MODEL=anthropic/claude-sonnet-4-20250514"
          # "MINIMAX_API_KEY=${secrets.minimax_api_key}"
          # "MINIMAX_MODEL=MiniMax-M2.7"
          "MAX_TOKENS=4096"
          "AGENTMEMORY_LLM_TIMEOUT_MS=60000"
          "AGENTMEMORY_ALLOW_AGENT_SDK=false"
          # Snapshots/export
          "SNAPSHOT_ENABLED=false"
          "SNAPSHOT_DIR=/home/mickael/.agentmemory/snapshots"
          "SNAPSHOT_INTERVAL=3600"
          "USER_ID=mickael"
          "OBSIDIAN_AUTO_EXPORT=true"
          "AGENTMEMORY_EXPORT_ROOT=/data/Obsidian/mickael/Logger/agentmemory/"
          # Debug
          "AGENTMEMORY_DEBUG=0"
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
