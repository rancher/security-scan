package summarizer

import (
	"github.com/sirupsen/logrus"
	"io/ioutil"

	"encoding/json"
	"fmt"
	kb "github.com/aquasecurity/kube-bench/check"
	"os/exec"
	"path/filepath"
)

const (
	DEFAULT_OUTPUT_FILE_NAME = "report.json"
)

type Summarizer struct {
	InputDirectory   string
	OutputDirectory  string
	FailuresOnly     bool
	summarizedReport *SummarizedReport
	groupsMap        map[string]*GroupWrapper
	checksMaps       map[string]*CheckWrapper
}

type CheckWrapper struct {
	ID          string                 `yaml:"id" json:"test_number"`
	Text        string                 `json:"test_desc"`
	Audit       string                 `json:"-"`
	Type        string                 `json:"-"`
	Commands    []*exec.Cmd            `json:"-"`
	Tests       map[string]interface{} `json:"-"`
	Set         bool                   `json:"-"`
	Remediation string                 `json:"-"`
	TestInfo    []string               `json:"test_info"`
	State       kb.State               `json:"status"`
	ActualValue string                 `json:"-"`
	Scored      bool                   `json:"-"`
	Hosts       []string               `json:"hosts"`
}

type GroupWrapper struct {
	ID     string          `yaml:"id" json:"section"`
	Pass   int             `json:"pass"`
	Fail   int             `json:"fail"`
	Warn   int             `json:"warn"`
	Info   int             `json:"info"`
	Text   string          `json:"desc"`
	Checks []*CheckWrapper `json:"results"`
}

type SummarizedReport struct {
	Version string          `json:"-"`
	Groups  []*GroupWrapper `json:"tests"`
	kb.Summary
}

func NewSummarizer(inputDir, outputDir string, failuresOnly bool) *Summarizer {
	return &Summarizer{
		InputDirectory:  inputDir,
		OutputDirectory: outputDir,
		FailuresOnly:    failuresOnly,
		summarizedReport: &SummarizedReport{
			Groups: []*GroupWrapper{},
		},
		groupsMap:  map[string]*GroupWrapper{},
		checksMaps: map[string]*CheckWrapper{},
	}
}

func (s *Summarizer) processOneResultFileForHost(results *kb.Controls, hostname string) {
	for _, group := range results.Groups {
		for _, check := range group.Checks {
			logrus.Infof("id: %v %v", check.ID, check.State)
			if check.Scored {
				if s.FailuresOnly && check.State != kb.FAIL {
					continue
				}
				logrus.Infof("check: %+v", check)
				g := s.groupsMap[group.ID]
				if g == nil {
					logrus.Infof("group not found in map: %v", group.ID)
					g = &GroupWrapper{
						ID:     group.ID,
						Text:   group.Text,
						Checks: []*CheckWrapper{},
					}
					s.groupsMap[group.ID] = g
					s.summarizedReport.Groups = append(s.summarizedReport.Groups, g)
				}

				c := s.checksMaps[check.ID]
				if c == nil {
					logrus.Infof("check not found in map: %v", check.ID)
					c = &CheckWrapper{
						ID:          check.ID,
						Text:        check.Text,
						Remediation: check.Remediation,
						TestInfo:    check.TestInfo,
						State:       check.State,
						Hosts:       []string{},
					}
					s.checksMaps[check.ID] = c
					g.Checks = append(g.Checks, c)

					switch check.State {
					case kb.FAIL:
						g.Fail++
						s.summarizedReport.Fail++
					case kb.WARN:
						g.Warn++
						s.summarizedReport.Warn++
					case kb.INFO:
						g.Info++
						s.summarizedReport.Info++
					default:
						logrus.Errorf("error shouldn't be here check=%+v", check)
					}
				}
				c.Hosts = append(c.Hosts, hostname)
			}
		}
	}
}

func (s *Summarizer) summarizeForHost(hostname string) error {
	logrus.Debugf("summarizeForHost: %v", hostname)

	hostDir := fmt.Sprintf("%v/%v", s.InputDirectory, hostname)
	resultFiles, err := filepath.Glob(fmt.Sprintf("%v/*.json", hostDir))
	if err != nil {
		return err
	}

	for _, fileName := range resultFiles {
		// Load one result file
		// Marshal it into the results
		contents, err := ioutil.ReadFile(filepath.Clean(fileName))
		if err != nil {
			return fmt.Errorf("error reading file %+v: %v", fileName, err)
		}

		results := &kb.Controls{}
		err = json.Unmarshal(contents, results)
		if err != nil {
			return fmt.Errorf("error unmarshalling: %v", err)
		}
		logrus.Debugf("results: %+v", results)

		s.processOneResultFileForHost(results, hostname)
	}
	return nil
}

func (s *Summarizer) save() error {
	data, err := json.MarshalIndent(s.summarizedReport, "", " ")
	if err != nil {
		return fmt.Errorf("error marshaling: %v", err)
	}

	outputFilePath := fmt.Sprintf("%s/%s", s.OutputDirectory, DEFAULT_OUTPUT_FILE_NAME)
	err = ioutil.WriteFile(outputFilePath, data, 0644)
	if err != nil {
		return fmt.Errorf("error writing report file: %v", err)
	}

	return nil
}

func (s *Summarizer) Summarize() error {
	logrus.Infof("summarize")
	logrus.Debugf("inputDir: %v", s.InputDirectory)

	// Walk through the host folders
	hostsDir, err := ioutil.ReadDir(s.InputDirectory)
	if err != nil {
		return fmt.Errorf("error listing directory: %v", err)
	}

	for _, hostDir := range hostsDir {
		if !hostDir.IsDir() {
			continue
		}
		hostname := hostDir.Name()
		logrus.Debugf("hostDir: %v", hostname)

		if err := s.summarizeForHost(hostname); err != nil {
			return fmt.Errorf("error summarizeForHost: %v", hostname)
		}
	}

	return s.save()
}

func (s *Summarizer) printSummaryReport() error {
	bytes, err := json.Marshal(s.summarizedReport)
	if err != nil {
		return fmt.Errorf("error marshalling summary report: %v", err)
	}

	txt := string(bytes)
	logrus.Debugf("txt: %+v", txt)
	return nil
}
