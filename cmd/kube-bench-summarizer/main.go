package main

import (
	"fmt"
	"os"

	"github.com/rancher/security-scan/cmd/kube-bench-summarizer/summarizer"
	"github.com/sirupsen/logrus"
	"github.com/urfave/cli"
)

const (
	INPUT_DIR_FLAG     = "input-dir"
	OUTPUT_DIR_FLAG    = "output-dir"
	FAILURES_ONLY_FLAG = "failures-only"
)

var (
	VERSION = "v0.0.0-dev"
)

func main() {
	logrus.SetLevel(logrus.DebugLevel)

	app := cli.NewApp()
	app.Name = "kube-bench-summarizer"
	app.Version = VERSION
	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:  INPUT_DIR_FLAG,
			Value: "",
		},
		cli.StringFlag{
			Name:  OUTPUT_DIR_FLAG,
			Value: "",
		},
		cli.BoolFlag{
			Name: FAILURES_ONLY_FLAG,
		},
	}
	app.Action = run

	if err := app.Run(os.Args); err != nil {
		logrus.Fatal(err)
	}
}

func run(c *cli.Context) error {
	logrus.Info("Running Summarizer")
	inputDir := c.String(INPUT_DIR_FLAG)
	outputDir := c.String(OUTPUT_DIR_FLAG)
	failuresOnly := c.Bool(FAILURES_ONLY_FLAG)

	if inputDir == "" {
		return fmt.Errorf("error: %v not specified", INPUT_DIR_FLAG)
	}

	if outputDir == "" {
		return fmt.Errorf("error: %v not specified", OUTPUT_DIR_FLAG)
	}

	s := summarizer.NewSummarizer(
		inputDir,
		outputDir,
		failuresOnly,
	)
	if err := s.Summarize(); err != nil {
		return fmt.Errorf("error summarizing: %v", err)
	}

	return nil
}
