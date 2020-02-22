package main

import (
	"fmt"
	"os"

	"github.com/rancher/security-scan/pkg/kb-summarizer/summarizer"
	"github.com/sirupsen/logrus"
	"github.com/urfave/cli"
)

const (
	K8SVersionFlag                = "k8s-version"
	BenchmarkVersionFlag          = "benchmark-version"
	ControlsDirFlag               = "controls-dir"
	InputDirFlag                  = "input-dir"
	OutputDirFlag                 = "output-dir"
	OutputFileNameFlag            = "output-filename"
	FailuresOnlyFlag              = "failures-only"
	UserSkipConfigFileFlag        = "user-skip-config-file"
	UserSkipConfigFileEnvVar      = "USER_SKIP_CONFIG_FILE"
	DefaultSkipConfigFileFlag     = "default-skip-config-file"
	DefaultSkipConfigFileEnvVar   = "DEFAULT_SKIP_CONFIG_FILE"
	NotApplicableConfigFileFlag   = "not-applicable-config-file"
	NotApplicableConfigFileEnvVar = "NOT_APPLICABLE_CONFIG_FILE"
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
			Name:   UserSkipConfigFileFlag,
			EnvVar: UserSkipConfigFileEnvVar,
			Value:  "",
		},
		cli.StringFlag{
			Name:   DefaultSkipConfigFileFlag,
			EnvVar: DefaultSkipConfigFileEnvVar,
			Value:  "",
		},
		cli.StringFlag{
			Name:   NotApplicableConfigFileFlag,
			EnvVar: NotApplicableConfigFileEnvVar,
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
	inputDir := c.String(InputDirFlag)
	outputDir := c.String(OutputDirFlag)
	outputFilename := c.String(OutputFileNameFlag)
	failuresOnly := c.Bool(FailuresOnlyFlag)
	userSkipConfigFile := c.String(UserSkipConfigFileFlag)
	defaultSkipConfigFile := c.String(DefaultSkipConfigFileFlag)
	notApplicableConfigFile := c.String(NotApplicableConfigFileFlag)
	if k8sversion == "" && benchmarkVersion == "" {
		return fmt.Errorf("error: either of the flags %v, %v not specified", K8SVersionFlag, BenchmarkVersionFlag)
	}
	if k8sversion != "" && benchmarkVersion != "" {
		return fmt.Errorf("error: both flags %v, %v can not be specified at the same time", K8SVersionFlag, BenchmarkVersionFlag)
	}
	if controlsDir == "" {
		return fmt.Errorf("error: %v not specified", ControlsDirFlag)
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
		inputDir,
		outputDir,
		outputFilename,
		userSkipConfigFile,
		defaultSkipConfigFile,
		notApplicableConfigFile,
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
