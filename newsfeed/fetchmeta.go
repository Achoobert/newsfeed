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
	Title     string `json:"title"`
	Thumbnail string `json:"thumbnail"`
}

func isValidURL(urlStr string) bool {
	_, err := url.Parse(urlStr)
	return err == nil
}

func fetchOpenGraph(url string) (*Meta, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)
	html := string(body)

	meta := &Meta{}

	titleRe := regexp.MustCompile(`<title>(.*?)</title>`)
	ogTitleRe := regexp.MustCompile(`property=["']og:title["'] content=["'](.*?)["']`)
	ogImageRe := regexp.MustCompile(`property=["']og:image["'] content=["'](.*?)["']`)

	if m := ogTitleRe.FindStringSubmatch(html); len(m) > 1 {
		meta.Title = m[1]
	} else if m := titleRe.FindStringSubmatch(html); len(m) > 1 {
		meta.Title = m[1]
	}
	if m := ogImageRe.FindStringSubmatch(html); len(m) > 1 {
		meta.Thumbnail = m[1]
	}

	return meta, nil
}

func fetchYTDLP(url string) (*Meta, error) {
	if !isValidURL(url) {
		return nil, fmt.Errorf("invalid URL format")
	}
	
	if !strings.Contains(url, "youtube.com") && !strings.Contains(url, "youtu.be") {
		return nil, fmt.Errorf("URL is not a YouTube URL")
	}
	
	cmd := exec.Command("yt-dlp", "--print", "%(title)s\n%(thumbnail)s", url)
	out, err := cmd.Output()
	if err != nil {
		return nil, err
	}
	lines := strings.SplitN(string(out), "\n", 3)
	if len(lines) < 2 {
		return nil, fmt.Errorf("yt-dlp output incomplete")
	}
	return &Meta{Title: lines[0], Thumbnail: lines[1]}, nil
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
	if err != nil || meta.Title == "" {
		if strings.Contains(url, "youtube.com") || strings.Contains(url, "youtu.be") {
			meta, err = fetchYTDLP(url)
		}
	}
	if meta == nil {
		meta = &Meta{}
	}
	json.NewEncoder(os.Stdout).Encode(meta)
} 