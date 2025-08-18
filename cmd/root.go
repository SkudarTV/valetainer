package cmd

import (
	"fmt"
	"os"
	"valetainer/internal/cli/create"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use: "valetainer",
	Run: func(cmd *cobra.Command, args []string) {

	},
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "Oops. An error while executing Valetainer '%s'\n", err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.AddCommand(create.NewCommand())
}
