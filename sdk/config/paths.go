package config

import (
	"os"
	"path/filepath"
)

const MainConfigFile = "config.json"

const SitesDir = "Sites"
const DnsDir = "Dns"
const AddonsDir = "Addons"

var Dirs = []string{
	SitesDir, DnsDir, AddonsDir,
}

func GetPath() string {
	userConfigPath, _ := os.UserConfigDir()
	configPath := filepath.Join(userConfigPath, "valetainer")

	return configPath
}

func GetPathOfConfigFile() string {
	return filepath.Join(GetPath(), MainConfigFile)
}

func GetPathOf(dir string) string {
	return filepath.Join(GetPath(), dir)
}
