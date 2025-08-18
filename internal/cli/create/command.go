package create

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/spf13/cobra"
)

func NewCommand() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "create",
		Short: "Create a site",
		RunE:  runCreate,
	}
	return cmd
}

func runCreate(cmd *cobra.Command, args []string) error {
	// Step Determine if user is root
	userId := os.Getuid()
	if userId == 0 {
		fmt.Println("/!\\ You started this command with sudo ! Please re-run without. Exiting...")
		return nil
	}

	// Step Determine site directory
	pwd, err := os.Getwd()
	if err != nil {
		return err
	}

	_, err = exec.Command("ls", fmt.Sprintf("%s/public/", pwd)).Output()
	hasSubPublicFolder := err == nil

	siteDirectory := pwd
	if hasSubPublicFolder {
		siteDirectory = pwd + "/public"
		fmt.Println("Sub public directory detected:", siteDirectory)
	}

	//Step Detect Docker or Podman
	resultDocker, errDocker := exec.Command("docker", "--version").Output()
	resultPodman, errPodman := exec.Command("podman", "--version").Output()

	containerEngine, containerEngineVersion, err := determineDockerOrPodman(string(resultDocker), errDocker, string(resultPodman), errPodman)
	if err != nil {
		fmt.Println("No containerization engine detected between Docker and Podman. Exiting...")
		return nil
	}

	fmt.Println(fmt.Sprintf("Current user UID: %d", userId))
	fmt.Println(fmt.Sprintf("Using %s as containerization engine", containerEngineVersion))

	_ = containerEngine

	return nil
}

func determineDockerOrPodman(docker string, dockerErr error, podman string, podmanErr error) (engine string, version string, err error) {
	if dockerErr == nil && len(docker) > 0 {
		if strings.Contains(strings.ToLower(docker), "docker") {
			return "docker", docker, nil
		}
		if strings.Contains(strings.ToLower(docker), "podman") {
			return "podman", docker, nil
		}
	}

	if podmanErr == nil && len(podman) > 0 {
		if strings.Contains(strings.ToLower(podman), "podman") {
			return "podman", podman, nil
		}
		if strings.Contains(strings.ToLower(podman), "docker") {
			return "docker", podman, nil
		}
	}

	return "", "", errors.New("no containerization engine detected between Docker and Podman")
}
