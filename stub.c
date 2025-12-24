// Stub librustdesk.so for Android
// This provides minimal implementations so the Flutter app can start

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// Simple stub functions - just return empty/error values
void* rustdesk_init() {
    return NULL;
}

void rustdesk_cleanup(void* handle) {
    // Do nothing
}

const char* rustdesk_get_version() {
    return "1.4.4-stub";
}

int rustdesk_start_session(const char* id) {
    return -1; // Error
}

void rustdesk_stop_session(int session_id) {
    // Do nothing
}

const char* rustdesk_get_error() {
    return "Stub implementation - Rust library not built";
}

// Add more stub functions as needed
// This is just a minimal implementation to allow the app to start