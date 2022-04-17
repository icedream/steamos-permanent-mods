package internal

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/Jguer/go-alpm/v2"
	"github.com/ssoroka/slice"
)

// TODO - maybe turn this dynamic for other uses?
const basePath = "/"

type SteamOS struct {
	alpmHandle *alpm.Handle
}

func New() (steamos *SteamOS, err error) {
	alpmHandle, err := alpm.Initialize(basePath, filepath.Join(basePath, "var", "lib", "pacman"))
	if err != nil {
		return
	}

	steamos = new(SteamOS)
	steamos.alpmHandle = alpmHandle
	return
}

func (steamos *SteamOS) passthroughCommand(name string, args ...string) *exec.Cmd {
	// TODO - look up command via basePath?
	cmd := exec.Command(name, args...)
	cmd.Stderr = os.Stderr
	cmd.Stdout = os.Stdout
	return cmd
}

func (steamos *SteamOS) passthroughWithInputCommand(name string, args ...string) *exec.Cmd {
	cmd := steamos.passthroughCommand(name, args...)
	cmd.Stdin = os.Stdin
	return cmd
}

/*
Readonly enables or disables file system immutability through the
steamos-readonly command.
*/
func (steamos *SteamOS) Readonly(action SteamOSReadonlyCommand) (err error) {
	err = steamos.passthroughCommand("steamos-readonly", string(action)).Run()
	return
}

/*
PreparePacmanKeys initializes the Pacman keyrings needed to install packages.
*/
func (steamos *SteamOS) PreparePacmanKeys() (err error) {
	if err = steamos.passthroughCommand("pacman-key", "--init").Run(); err != nil {
		return
	}

	err = steamos.passthroughCommand("pacman-key", "--populate").Run()
	return
}

/*
ReinstallPartialPackages scans the system through alpm for packages that are
missing some of the files that are supposed to be installed.
*/
func (steamos *SteamOS) ReinstallPartialPackages() (packageNames []string, err error) {
	// NOTE - we can't use go-alpm here as alpm_pkg_mtree_open has not been implemented yet, see https://github.com/Jguer/go-alpm/issues/28

	// query for package names which have modified files
	b := new(bytes.Buffer)
	cmd := steamos.passthroughCommand("pacman", "-Qqk")
	cmd.Stdout = b
	if err = cmd.Run(); err != nil {
		return
	}

	br := bufio.NewReader(b)
	var packageName, packageFilePath string
	packageNames = make([]string, 0)
	for {
		/*
			Example output:

			libxi /usr/share/doc/libXi/
			libxi /usr/share/doc/libXi/encoding.xml
			libxi /usr/share/doc/libXi/inputlib.xml
			libxi /usr/share/doc/libXi/library.xml
		*/
		_, err = fmt.Fscanf(br, "%s %s\n", &packageName, &packageFilePath)
		if err == io.EOF {
			// we reached end of output
			err = nil
			break
		}
		if err != nil {
			// something different went wrong, fail out
			break
		}
		// did we already track this package name?
		if slice.Contains(packageNames, packageName) {
			// yep, skip it
			continue
		}
		packageNames = append(packageNames, packageName)
	}

	// check if any errors happened
	if err != nil {
		// reset output and fail out
		packageNames = nil
		return
	}

	// found any incomplete packages?
	if len(packageNames) > 0 {
		// run reinstall
		err = steamos.passthroughWithInputCommand("pacman", append([]string{"--noconfirm", "-S"}, packageNames...)...).Run()
	}

	return
}
