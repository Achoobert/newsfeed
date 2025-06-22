package main

import (
	"fmt"
	"net/url"
)

func isValidURL(urlStr string) bool {
	if urlStr == "" {
		return false
	}
	
	parsed, err := url.Parse(urlStr)
	if err != nil {
		return false
	}
	
	// Require a scheme (http/https)
	if parsed.Scheme == "" {
		return false
	}
	
	// Require a host
	if parsed.Host == "" {
		return false
	}
	
	return true
}

func main() {
	fmt.Printf("Empty string: %v\n", isValidURL(""))
	fmt.Printf("example.com: %v\n", isValidURL("example.com"))
	fmt.Printf("https://example.com: %v\n", isValidURL("https://example.com"))
	fmt.Printf("https://: %v\n", isValidURL("https://"))
	fmt.Printf("http://: %v\n", isValidURL("http://"))
	fmt.Printf("spaces: %v\n", isValidURL("https://example.com with spaces"))
} 