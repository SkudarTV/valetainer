package config

import (
	"fmt"
	"os"
)

// TODO See where to store types

type MainConfig struct {
	preferedContainerizationEngine string
}

type SiteConfig struct {
	name     string
	network  DockerNetworkConfig
	services []ServiceConfig
}
type DockerNetworkConfig struct {
	name string
}

type ServiceConfig struct {
	internalName string
	docker       DockerServiceConfig
}
type DockerServiceConfig struct {
	image string
	//tag string
	volumes      []string
	ports        []int
	capabilities []string
}
type DockerPortConfig struct {
	bindInterface string
	inside        int
	outsite       int
}

func SetupConfigFile() {
	configPath := GetPathOfConfigFile()

	configFileExists, err := os.Stat(configPath)
	fmt.Println(err, configFileExists)
	if err != nil {
		// TODO Create file and init default values
	}
}

func GetConfigFile() {
	// TODO read config file
	// see how to handle JSON and return maybe an helper object
	// Like the config file we will surelly add/remov/update datas into it from every commands run
	// So having utility functions can be really convenient
}
