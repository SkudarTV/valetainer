package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
	"os"
	"valetainer/sdk/config"
)

var installCmd = &cobra.Command{
	Use:   "install",
	Short: "install valetainer",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Installing...")
		prepareConfigDir()
	},
}

func init() {
	rootCmd.AddCommand(installCmd)
}

func prepareConfigDir() {
	os.MkdirAll(config.GetPath(), 0774)

	for _, dir := range config.Dirs {
		fmt.Println(dir, config.GetPathOf(dir))
		os.Mkdir(config.GetPathOf(dir), 0774)
	}
}
