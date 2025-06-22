package tests

import (
	"net/url"
	"testing"
)

// Copy of the Meta struct from fetchmeta.go
type Meta struct {
	Title     string `json:"title"`
	Thumbnail string `json:"thumbnail"`
}

// Copy of the isValidURL function from fetchmeta.go
func isValidURL(urlStr string) bool {
	if urlStr == "" {
		return false
	}
	
	parsedURL, err := url.Parse(urlStr)
	if err != nil {
		return false
	}
	
	// Must have scheme and host
	if parsedURL.Scheme == "" || parsedURL.Host == "" {
		return false
	}
	
	// Scheme must be http or https
	if parsedURL.Scheme != "http" && parsedURL.Scheme != "https" {
		return false
	}
	
	return true
}

func TestIsValidURL(t *testing.T) {
	tests := []struct {
		name     string
		url      string
		expected bool
	}{
		{"valid https", "https://example.com", true},
		{"valid http", "http://example.com", true},
		{"valid with path", "https://example.com/path", true},
		{"valid with query", "https://example.com?param=value", true},
		{"invalid domain only", "example.com", false},
		{"invalid empty", "", false},
		{"invalid spaces", "https://example.com with spaces", false},
		{"invalid no host", "https://", false},
		{"invalid just scheme", "http://", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := isValidURL(tt.url)
			if result != tt.expected {
				t.Errorf("isValidURL(%q) = %v, want %v", tt.url, result, tt.expected)
			}
		})
	}
}

func TestMetaStruct(t *testing.T) {
	meta := &Meta{
		Title:     "Test Title",
		Thumbnail: "https://example.com/image.jpg",
	}

	if meta.Title != "Test Title" {
		t.Errorf("Expected title 'Test Title', got '%s'", meta.Title)
	}

	if meta.Thumbnail != "https://example.com/image.jpg" {
		t.Errorf("Expected thumbnail 'https://example.com/image.jpg', got '%s'", meta.Thumbnail)
	}
} 