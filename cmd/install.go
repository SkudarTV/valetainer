package cmd

import (
	"fmt"
	"os"
	"valetainer/sdk/config"

	"github.com/spf13/cobra"
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
	_ = os.MkdirAll(config.GetPath(), 0774)

	for _, dir := range config.Dirs {
		fmt.Println(dir, config.GetPathOf(dir))
		_ = os.Mkdir(config.GetPathOf(dir), 0774)
	}
}
