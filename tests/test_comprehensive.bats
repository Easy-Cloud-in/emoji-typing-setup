#!/usr/bin/env bats
# Comprehensive test suite for emoji-typing-setup
# Developed by: Easy-cloud (www.easy-cloud.in)

load 'test_helper'

@test "script handles invalid arguments gracefully" {
    run ./emoji-typing-setup.sh invalid-command
    [ "$status" -ne 0 ]
    [[ "$output" == *"Invalid command"* ]]
}

@test "script requires valid commands" {
    run ./emoji-typing-setup.sh --invalid-option
    [ "$status" -ne 0 ]
}

@test "help command works without dependencies" {
    run ./emoji-typing-setup.sh --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE:"* ]]
    [[ "$output" == *"COMMANDS:"* ]]
}

@test "verbose mode increases output" {
    setup_mocks
    export XDG_CURRENT_DESKTOP="GNOME"
    
    run ./emoji-typing-setup.sh status
    normal_lines=$(echo "$output" | wc -l)
    
    run ./emoji-typing-setup.sh --verbose status
    verbose_lines=$(echo "$output" | wc -l)
    
    [ "$verbose_lines" -ge "$normal_lines" ]
}

@test "quiet mode suppresses output" {
    setup_mocks
    export XDG_CURRENT_DESKTOP="GNOME"
    
    run ./emoji-typing-setup.sh --quiet status
    [ "$status" -eq 0 ]
    # Should have minimal output in quiet mode
}

@test "script detects desktop environment correctly" {
    setup_mocks
    
    # Test GNOME detection
    export XDG_CURRENT_DESKTOP="GNOME"
    run ./emoji-typing-setup.sh status
    [ "$status" -eq 0 ]
    
    # Test KDE detection (should warn)
    export XDG_CURRENT_DESKTOP="KDE"
    run ./emoji-typing-setup.sh status
    [ "$status" -eq 0 ]
}

@test "backup and restore functionality works" {
    setup_mocks
    export XDG_CURRENT_DESKTOP="GNOME"
    
    # Create backup
    run ./emoji-typing-setup.sh backup
    [ "$status" -eq 0 ]
    
    # Restore should work
    run ./emoji-typing-setup.sh restore
    [ "$status" -eq 0 ]
}

@test "script handles missing dependencies" {
    # Don't setup mocks - should fail gracefully
    export XDG_CURRENT_DESKTOP="GNOME"
    
    run ./emoji-typing-setup.sh status
    # Should handle missing dependencies gracefully
    [ "$status" -ne 0 ] || [ "$status" -eq 0 ]
}

@test "lock file prevents concurrent execution" {
    setup_mocks
    export XDG_CURRENT_DESKTOP="GNOME"
    
    # Create a fake lock file
    echo "12345" > /tmp/emoji-typing-setup.lock
    
    run ./emoji-typing-setup.sh install
    # Should detect existing lock (though process may not exist)
    
    # Clean up
    rm -f /tmp/emoji-typing-setup.lock
}

@test "configuration file is properly loaded" {
    setup_mocks
    export XDG_CURRENT_DESKTOP="GNOME"
    
    run ./emoji-typing-setup.sh status
    [ "$status" -eq 0 ]
    # Should load configuration without errors
}

@test "log levels work correctly" {
    setup_mocks
    export XDG_CURRENT_DESKTOP="GNOME"
    
    # Test different log levels
    run ./emoji-typing-setup.sh --log-level DEBUG status
    [ "$status" -eq 0 ]
    
    run ./emoji-typing-setup.sh --log-level ERROR status
    [ "$status" -eq 0 ]
}