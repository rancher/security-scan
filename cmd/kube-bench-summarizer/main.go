package main

import (
	"os"

	"github.com/rancher/cis-k8s/cmd/kube-bench-summarizer/summarizer"
	"github.com/sirupsen/logrus"
	"github.com/urfave/cli"
)

const (
	INPUT_DIR_FLAG  = "input-dir"
	OUTPUT_DIR_FLAG = "output-dir"
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

	if inputDir == "" {
		logrus.Errorf("error: %v not specified", INPUT_DIR_FLAG)
		return nil
	}

	if outputDir == "" {
		logrus.Errorf("error: %v not specified", OUTPUT_DIR_FLAG)
		return nil
	}

	s := summarizer.NewSummarizer(
		inputDir,
		outputDir,
	)
	if err := s.Summarize(); err != nil {
		logrus.Fatalf("error summarizing: %v", err)
		return err
	}

	return nil
}
