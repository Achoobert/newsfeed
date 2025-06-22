package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strings"
	"os/exec"
)

type Meta struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	Thumbnail   string `json:"thumbnail"`
	SiteName    string `json:"site_name"`
	Favicon     string `json:"favicon"`
	URL         string `json:"url"`
}

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

func fetchOpenGraph(urlStr string) (*Meta, error) {
	resp, err := http.Get(urlStr)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)
	html := string(body)

	meta := &Meta{URL: urlStr}

	// Regular expressions for different metadata types
	titleRe := regexp.MustCompile(`<title>(.*?)</title>`)
	ogTitleRe := regexp.MustCompile(`property=["']og:title["'] content=["'](.*?)["']`)
	ogDescRe := regexp.MustCompile(`property=["']og:description["'] content=["'](.*?)["']`)
	ogImageRe := regexp.MustCompile(`property=["']og:image["'] content=["'](.*?)["']`)
	ogSiteNameRe := regexp.MustCompile(`property=["']og:site_name["'] content=["'](.*?)["']`)
	
	// Favicon patterns
	faviconRe := regexp.MustCompile(`<link[^>]*rel=["'](?:shortcut )?icon["'][^>]*href=["']([^"']+)["']`)
	appleTouchIconRe := regexp.MustCompile(`<link[^>]*rel=["']apple-touch-icon["'][^>]*href=["']([^"']+)["']`)

	// Extract title (OpenGraph first, then regular title)
	if m := ogTitleRe.FindStringSubmatch(html); len(m) > 1 {
		meta.Title = m[1]
	} else if m := titleRe.FindStringSubmatch(html); len(m) > 1 {
		meta.Title = m[1]
	}

	// Extract description
	if m := ogDescRe.FindStringSubmatch(html); len(m) > 1 {
		meta.Description = m[1]
	}

	// Extract thumbnail/image
	if m := ogImageRe.FindStringSubmatch(html); len(m) > 1 {
		meta.Thumbnail = m[1]
	}

	// Extract site name
	if m := ogSiteNameRe.FindStringSubmatch(html); len(m) > 1 {
		meta.SiteName = m[1]
	}

	// Extract favicon (try multiple patterns)
	if m := faviconRe.FindStringSubmatch(html); len(m) > 1 {
		meta.Favicon = m[1]
	} else if m := appleTouchIconRe.FindStringSubmatch(html); len(m) > 1 {
		meta.Favicon = m[1]
	}

	// If no favicon found, try common favicon locations
	if meta.Favicon == "" {
		parsedURL, _ := url.Parse(urlStr)
		baseURL := fmt.Sprintf("%s://%s", parsedURL.Scheme, parsedURL.Host)
		meta.Favicon = baseURL + "/favicon.ico"
	}

	return meta, nil
}

func isYTDLPInstalled() bool {
	_, err := exec.LookPath("yt-dlp")
	return err == nil
}

func fetchYTDLP(url string) (*Meta, error) {
	if !isValidURL(url) {
		return nil, fmt.Errorf("invalid URL format")
	}
	
	if !strings.Contains(url, "youtube.com") && !strings.Contains(url, "youtu.be") {
		return nil, fmt.Errorf("URL is not a YouTube URL")
	}
	
	if !isYTDLPInstalled() {
		return nil, fmt.Errorf("yt-dlp not installed")
	}
	
	// Try with different yt-dlp options to bypass bot detection
	cmd := exec.Command("yt-dlp", "--no-check-certificates", "--print", "%(title)s\n%(thumbnail)s\n%(description)s", url)
	out, err := cmd.Output()
	if err != nil {
		// If that fails, try with user-agent
		cmd = exec.Command("yt-dlp", "--user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36", "--print", "%(title)s\n%(thumbnail)s\n%(description)s", url)
		out, err = cmd.Output()
		if err != nil {
			return nil, err
		}
	}
	
	lines := strings.SplitN(string(out), "\n", 4)
	if len(lines) < 3 {
		return nil, fmt.Errorf("yt-dlp output incomplete")
	}
	
	// Clean up description (remove newlines, truncate if too long)
	description := strings.ReplaceAll(lines[2], "\n", " ")
	if len(description) > 200 {
		description = description[:200] + "..."
	}
	
	return &Meta{
		Title:       lines[0],
		Thumbnail:   lines[1],
		Description: description,
		SiteName:    "YouTube",
		URL:         url,
	}, nil
}

func fetchYouTubeFallback(url string) (*Meta, error) {
	// Extract video ID from YouTube URL
	videoID := ""
	if strings.Contains(url, "youtube.com/watch?v=") {
		parts := strings.Split(url, "v=")
		if len(parts) > 1 {
			videoID = strings.Split(parts[1], "&")[0]
		}
	} else if strings.Contains(url, "youtu.be/") {
		parts := strings.Split(url, "youtu.be/")
		if len(parts) > 1 {
			videoID = strings.Split(parts[1], "?")[0]
		}
	}
	
	if videoID == "" {
		return nil, fmt.Errorf("could not extract video ID")
	}
	
	// Generate thumbnail URL (this usually works even when yt-dlp fails)
	thumbnailURL := fmt.Sprintf("https://i.ytimg.com/vi/%s/maxresdefault.jpg", videoID)
	
	// Try to fetch the thumbnail to see if it exists
	resp, err := http.Head(thumbnailURL)
	if err != nil || resp.StatusCode != 200 {
		// Fallback to medium quality thumbnail
		thumbnailURL = fmt.Sprintf("https://i.ytimg.com/vi/%s/hqdefault.jpg", videoID)
	}
	
	return &Meta{
		Title:       "", // We can't get title without yt-dlp
		Thumbnail:   thumbnailURL,
		Description: "",
		SiteName:    "YouTube",
		URL:         url,
	}, nil
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "Usage: fetchmeta.go <url>")
		os.Exit(1)
	}
	url := os.Args[1]
	
	if !isValidURL(url) {
		fmt.Fprintln(os.Stderr, "Error: Invalid URL format")
		os.Exit(1)
	}
	
	meta, err := fetchOpenGraph(url)
	if err != nil {
		meta = &Meta{URL: url}
	}
	
	// Try YouTube fallback if OpenGraph didn't get rich metadata and URL is YouTube
	if (meta.Thumbnail == "" || meta.Title == "" || meta.Description == "") && (strings.Contains(url, "youtube.com") || strings.Contains(url, "youtu.be")) {
		// First try yt-dlp
		if ytMeta, err := fetchYTDLP(url); err == nil {
			if meta.Title == "" {
				meta.Title = ytMeta.Title
			}
			if meta.Thumbnail == "" {
				meta.Thumbnail = ytMeta.Thumbnail
			}
			if meta.Description == "" {
				meta.Description = ytMeta.Description
			}
			if meta.SiteName == "" {
				meta.SiteName = ytMeta.SiteName
			}
		} else {
			// If yt-dlp fails, try fallback method
			fmt.Fprintf(os.Stderr, "Warning: yt-dlp failed for %s: %v\n", url, err)
			if fallbackMeta, err := fetchYouTubeFallback(url); err == nil {
				if meta.Thumbnail == "" {
					meta.Thumbnail = fallbackMeta.Thumbnail
				}
				if meta.SiteName == "" {
					meta.SiteName = fallbackMeta.SiteName
				}
			}
		}
	}
	
	json.NewEncoder(os.Stdout).Encode(meta)
} 