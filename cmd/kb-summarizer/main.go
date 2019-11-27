package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"strings"

	"github.com/rancher/security-scan/pkg/kb-summarizer/summarizer"
	"github.com/sirupsen/logrus"
	"github.com/urfave/cli"
)

const (
	K8SVersionFlag       = "k8s-version"
	ControlsDirFlag      = "controls-dir"
	EtcdControlsDirFlag  = "etcd-controls-dir"
	InputDirFlag         = "input-dir"
	OutputDirFlag        = "output-dir"
	OutputFileNameFlag   = "output-filename"
	FailuresOnlyFlag     = "failures-only"
	SkipFlag             = "skip"
	SkipFlagEnvVar       = "SKIP"
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
			Name:   SkipFlag,
			EnvVar: SkipFlagEnvVar,
			Value:  "",
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

type SkipConfig struct {
	Skip []string `json:"skip"`
}

func getSkipInfo(skipStr, skipConfigFileStr string) (string, error) {
	if skipStr != "" {
		return skipStr, nil
	}
	if skipConfigFileStr == "" {
		return "", nil
	}
	data, err := ioutil.ReadFile(skipConfigFileStr)
	if err != nil {
		return "", fmt.Errorf("error reading file %v: %v", skipConfigFileStr, err)
	}
	skipConfig := &SkipConfig{}
	err = json.Unmarshal(data, skipConfig)
	if err != nil {
		return "", fmt.Errorf("error unmarshalling config file %v: %v", skipConfigFileStr, err)
	}
	return strings.Join(skipConfig.Skip, ","), nil
}

func run(c *cli.Context) error {
	logrus.Info("Running Summarizer")
	version := c.String(K8SVersionFlag)
	controlsDir := c.String(ControlsDirFlag)
	etcdControlsDir := c.String(EtcdControlsDirFlag)
	inputDir := c.String(InputDirFlag)
	outputDir := c.String(OutputDirFlag)
	outputFilename := c.String(OutputFileNameFlag)
	failuresOnly := c.Bool(FailuresOnlyFlag)
	skipStr := c.String(SkipFlag)
	skipConfigFileStr := c.String(SkipConfigFileFlag)
	skip, err := getSkipInfo(skipStr, skipConfigFileStr)
	if err != nil {
		return err
	}
	logrus.Infof("skip: %+v", skip)
	if version == "" {
		return fmt.Errorf("error: %v not specified", K8SVersionFlag)
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
		version,
		controlsDir,
		etcdControlsDir,
		inputDir,
		outputDir,
		outputFilename,
		skip,
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
