package create

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strings"
	"valetainer/sdk/config"

	"github.com/spf13/cobra"
)

type ContainerizationEngine struct {
	name    string
	version string
}

type ArgsValidated struct {
	PhpVersion             string
	MariaDBVersion         string
	SiteHostname           string
	ContainerizationEngine ContainerizationEngine
	UserId                 int
}

// HostnameRegex only match whole string, example:
//
//	"mysite.test" -> valid
//	"mysite"      -> valid
//	"4226"        -> valid
//	"some phrase" -> invalid
//	".test"       -> invalid
//	"test."       -> invalid
const HostnameRegex = "(^[A-Za-z0-9]+(?:\\.[A-Za-z0-9]+)*$)"

const (
	DefaultPhpVersion     = "8.4"
	DefaultMariaDBVersion = "11.8.2"
)

var (
	arguments ArgsValidated

	phpVersionUsage     = fmt.Sprintf("select a PHP version, default is PHP %s", DefaultPhpVersion)
	mariaDBVersionUsage = fmt.Sprintf("select a MariaDB version, default is MariaDB %s", DefaultMariaDBVersion)
)

func Get() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "create <mysite.test>",
		Short:   "Deploy a local site",
		Args:    cobra.ExactArgs(1),
		PreRunE: PreRun,
		RunE:    Run,
	}

	cmd.Flags().String("php", DefaultPhpVersion, phpVersionUsage)
	cmd.Flags().String("mariadb", DefaultMariaDBVersion, mariaDBVersionUsage)

	return cmd
}

func PreRun(cmd *cobra.Command, args []string) error {
	// Step Determine if user is root
	userId := os.Getuid()
	if userId == 0 {
		return fmt.Errorf("you started this command with sudo ! Please re-run without")
	}
	arguments.UserId = userId

	// Step Detect Docker or Podman
	engines, err := FindContainerizationEngines()
	if err != nil {
		return err
	}

	preference := "docker" // Later the preference can be a user setting
	engine, present := engines[preference]
	if present == false {
		engine, present = engines["docker"]
	}
	if present == false {
		engine, present = engines["podman"]
	}
	if present == false {
		return fmt.Errorf("unknown error")
	}

	// Step check args
	// Later, check if the given PHP/Maria/... version is an existing docker image with by example :
	// podman manifest inspect docker.io/php:8.1
	phpVersion, err := cmd.Flags().GetString("php")
	if err != nil {
		return err
	}
	mariadbVersion, err := cmd.Flags().GetString("mariadb")
	if err != nil {
		return err
	}

	siteHostname, _ := strings.CutSuffix(args[0], ".test")
	siteHostname = strings.ToValidUTF8(siteHostname, "")
	if matched, err := regexp.Match(HostnameRegex, []byte(siteHostname)); err != nil || matched == false {
		return fmt.Errorf("\"http://%s.test\" isn't a valid site URL", siteHostname)
	}

	arguments = ArgsValidated{
		PhpVersion:             phpVersion,
		MariaDBVersion:         mariadbVersion,
		SiteHostname:           siteHostname,
		ContainerizationEngine: engine,
		UserId:                 userId,
	}

	return nil
}

func Run(*cobra.Command, []string) error {
	fmt.Println(arguments) // TODO Debug to remove

	fmt.Println(fmt.Sprintf("Current user UID: %d", arguments.UserId))
	fmt.Println(fmt.Sprintf("Using %s as containerization engine", arguments.ContainerizationEngine.name))

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

	// TODO Step Load config files
	config.SetupConfigFile()

	return nil
}

func FindContainerizationEngines() (engines map[string]ContainerizationEngine, err error) {
	engines = make(map[string]ContainerizationEngine)

	dockerRes, dockerErr := exec.Command("docker", "--version").Output()
	podmanRes, podmanErr := exec.Command("podman", "--version").Output()
	docker := strings.Trim(string(dockerRes), "\n ")
	podman := strings.Trim(string(podmanRes), "\n ")

	// Check for Docker or Podman which is maybe aliased as Docker
	if dockerErr == nil && len(docker) > 0 {
		if strings.Contains(strings.ToLower(docker), "docker") {
			engines["docker"] = ContainerizationEngine{name: "docker", version: docker}
		} else if strings.Contains(strings.ToLower(docker), "podman") {
			engines["podman"] = ContainerizationEngine{name: "podman", version: docker}
		}
	}

	// Check for Podman or Docker which is maybe aliased as Podman
	if podmanErr == nil && len(podman) > 0 {
		if strings.Contains(strings.ToLower(podman), "podman") {
			engines["podman"] = ContainerizationEngine{name: "podman", version: podman}
		} else if strings.Contains(strings.ToLower(podman), "docker") {
			engines["docker"] = ContainerizationEngine{name: "docker", version: podman}
		}
	}

	if len(engines) == 0 {
		return engines, errors.New("no containerization engine detected between Docker and Podman")
	}
	return engines, nil
}
