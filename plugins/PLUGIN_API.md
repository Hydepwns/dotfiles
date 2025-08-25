# Plugin API Documentation

## Plugin Structure

A dotfiles plugin is a directory containing:

```
my-plugin/
├── plugin.toml          # Plugin metadata
├── init.sh             # Plugin initialization script  
├── functions.sh        # Plugin functions
├── commands.sh         # CLI commands (optional)
├── config/            # Configuration templates
├── templates/         # File templates
└── README.md          # Plugin documentation
```

## Plugin Metadata (plugin.toml)

```toml
[plugin]
name = "my-plugin"
version = "1.0.0"
description = "My awesome plugin"
author = "Plugin Author"
license = "MIT"
homepage = "https://github.com/author/my-plugin"

[requirements]
bash_version = "4.0"
dotfiles_version = "1.0.0"
dependencies = ["git", "curl"]
plugins = ["base-plugin"]

[hooks]
pre_load = "validate_environment"
post_load = "setup_completion"
pre_unload = "cleanup_resources"

[commands]
my_command = "commands/my_command.sh"
another_cmd = "commands/another.sh"
```

## Plugin Functions

Plugins can define these special functions:

### Required Functions
- `plugin_init()` - Initialize plugin
- `plugin_info()` - Return plugin information

### Optional Functions  
- `plugin_validate()` - Validate plugin can be loaded
- `plugin_cleanup()` - Clean up resources
- `plugin_help()` - Show plugin help
- `plugin_config()` - Handle configuration

### Hook Functions
- `plugin_pre_load()` - Called before loading
- `plugin_post_load()` - Called after loading  
- `plugin_pre_unload()` - Called before unloading

## Plugin API Functions

Available to plugins:

- `plugin_log_info(message)` - Log info message
- `plugin_log_error(message)` - Log error message
- `plugin_get_config(key)` - Get configuration value
- `plugin_set_config(key, value)` - Set configuration value
- `plugin_register_command(name, script)` - Register CLI command
- `plugin_register_hook(hook, function)` - Register hook function

## Environment Variables

- `PLUGIN_NAME` - Current plugin name
- `PLUGIN_DIR` - Plugin directory path
- `PLUGIN_CONFIG_DIR` - Plugin config directory
- `DOTFILES_ROOT` - Dotfiles root directory

## Example Plugin

```bash
#!/usr/bin/env bash
# functions.sh

plugin_init() {
    plugin_log_info "Initializing example plugin"
    return 0
}

plugin_info() {
    echo "name=example-plugin"
    echo "version=1.0.0" 
    echo "description=Example plugin for demonstration"
}

my_custom_function() {
    local arg="$1"
    echo "Plugin function called with: $arg"
}

plugin_register_command "example" "$PLUGIN_DIR/commands/example.sh"
```
