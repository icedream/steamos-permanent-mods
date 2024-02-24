package main

import (
	"log"
	"os"

	"github.com/alecthomas/kingpin/v2"
	"github.com/icedream/steammutator/internal"
)

var (
	cli        = kingpin.New("steammutator", "Command line tool to assist with system modifications on SteamOS")
	cmdPrepare = cli.Command("prepare", "Prepares this SteamOS installation for permanent system modifications")
)

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() (err error) {
	cmd := kingpin.MustParse(cli.Parse(os.Args[1:]))

	steamos, err := internal.New()
	if err != nil {
		return
	}

	switch cmd {
	case cmdPrepare.FullCommand(): // prepare
		if err = steamos.PreparePacmanKeys(); err != nil {
			return
		}
		var packageNames []string
		packageNames, err = steamos.ReinstallPartialPackages()
		if err != nil {
			return
		}
		log.Printf("%d packages have been reinstalled: %v", len(packageNames), packageNames)

	default:
		cli.FatalUsage("Unknown command: %s", cmd)
	}

	return
}
