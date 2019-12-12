package main

import (
	"fmt"
	"os"

	"github.com/rancher/security-scan/pkg/kb-summarizer/summarizer"
	"github.com/sirupsen/logrus"
	"github.com/urfave/cli"
)

const (
	K8SVersionFlag       = "k8s-version"
	BenchmarkVersionFlag = "benchmark-version"
	ControlsDirFlag      = "controls-dir"
	EtcdControlsDirFlag  = "etcd-controls-dir"
	InputDirFlag         = "input-dir"
	OutputDirFlag        = "output-dir"
	OutputFileNameFlag   = "output-filename"
	FailuresOnlyFlag     = "failures-only"
	SkipConfigFileFlag   = "skip-config-file"
	SkipConfigFileEnvVar = "SKIP_CONFIG_FILE"
)

var (
	VERSION = "v0.0.0-dev"
)

func main() {
	logrus.SetLevel(logrus.DebugLevel)

	app := cli.NewApp()
	app.Name = "kb-summarizer"
	app.Version = VERSION
	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:  K8SVersionFlag,
			Value: "",
		},
		cli.StringFlag{
			Name:  BenchmarkVersionFlag,
			Value: "",
		},
		cli.StringFlag{
			Name:  ControlsDirFlag,
			Value: summarizer.DefaultControlsDirectory,
		},
		cli.StringFlag{
			Name:  EtcdControlsDirFlag,
			Value: summarizer.EtcdDefaultControlsDirectory,
		},
		cli.StringFlag{
			Name:  InputDirFlag,
			Value: "",
		},
		cli.StringFlag{
			Name:  OutputDirFlag,
			Value: "",
		},
		cli.StringFlag{
			Name:  OutputFileNameFlag,
			Value: summarizer.DefaultOutputFileName,
		},
		cli.StringFlag{
			Name:   SkipConfigFileFlag,
			EnvVar: SkipConfigFileEnvVar,
			Value:  "",
		},
		cli.BoolFlag{
			Name: FailuresOnlyFlag,
		},
	}
	app.Action = run

	if err := app.Run(os.Args); err != nil {
		logrus.Fatal(err)
	}
}

func run(c *cli.Context) error {
	logrus.Info("Running Summarizer")
	k8sversion := c.String(K8SVersionFlag)
	benchmarkVersion := c.String(BenchmarkVersionFlag)
	controlsDir := c.String(ControlsDirFlag)
	etcdControlsDir := c.String(EtcdControlsDirFlag)
	inputDir := c.String(InputDirFlag)
	outputDir := c.String(OutputDirFlag)
	outputFilename := c.String(OutputFileNameFlag)
	failuresOnly := c.Bool(FailuresOnlyFlag)
	skipConfigFile := c.String(SkipConfigFileFlag)
	if k8sversion == "" && benchmarkVersion == "" {
		return fmt.Errorf("error: either of the flags %v, %v not specified", K8SVersionFlag, BenchmarkVersionFlag)
	}
	if k8sversion != "" && benchmarkVersion != "" {
		return fmt.Errorf("error: both flags %v, %v can not be specified at the same time", K8SVersionFlag, BenchmarkVersionFlag)
	}
	if controlsDir == "" {
		return fmt.Errorf("error: %v not specified", ControlsDirFlag)
	}
	if etcdControlsDir == "" {
		return fmt.Errorf("error: %v not specified", EtcdControlsDirFlag)
	}
	if inputDir == "" {
		return fmt.Errorf("error: %v not specified", InputDirFlag)
	}
	if outputDir == "" {
		return fmt.Errorf("error: %v not specified", OutputDirFlag)
	}
	s, err := summarizer.NewSummarizer(
		k8sversion,
		benchmarkVersion,
		controlsDir,
		etcdControlsDir,
		inputDir,
		outputDir,
		outputFilename,
		skipConfigFile,
		failuresOnly,
	)
	if err != nil {
		return fmt.Errorf("error creating summarizer: %v", err)
	}
	if err := s.Summarize(); err != nil {
		return fmt.Errorf("error summarizing: %v", err)
	}
	return nil
}
