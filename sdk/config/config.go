package config

import (
	"os"
	"path/filepath"
)

var Dirs = []string{"Sites", "Dns"}

func GetPath() string {
	userConfigPath, _ := os.UserConfigDir()
	configPath := filepath.Join(userConfigPath, "valetainer")

	return configPath
}

func GetPathOf(dir string) string {
	return filepath.Join(GetPath(), dir)
}
