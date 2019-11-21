package report

import (
	"encoding/json"
	"fmt"
	"sort"

	"github.com/rancher/security-scan/pkg/kb-summarizer/summarizer"
	"github.com/sirupsen/logrus"
)

type Check struct {
	ID          string              `yaml:"id" json:"id"`
	Text        string              `json:"description"`
	Remediation string              `json:"remediation"`
	State       summarizer.State    `json:"state"`
	NodeType    summarizer.NodeType `json:"node_type"`
	Nodes       []string            `json:"nodes,omitempty"`
}

type Group struct {
	ID     string   `yaml:"id" json:"id"`
	Text   string   `json:"description"`
	Checks []*Check `json:"checks"`
}

type Report struct {
	Version string                           `json:"-"`
	Total   int                              `json:"total"`
	Fail    int                              `json:"fail"`
	Pass    int                              `json:"pass"`
	Skip    int                              `json:"skip"`
	Nodes   map[summarizer.NodeType][]string `json:"nodes"`
	Results []*Group                         `json:"results"`
}

func mapCheck(intCheck *summarizer.CheckWrapper, nodeType summarizer.NodeType) *Check {
	return &Check{
		ID:          intCheck.ID,
		Text:        intCheck.Text,
		Remediation: intCheck.Remediation,
		State:       intCheck.State,
		NodeType:    nodeType,
		Nodes:       intCheck.Nodes,
	}
}

func mapGroup(intGroup *summarizer.GroupWrapper, nodeType summarizer.NodeType) *Group {
	extGroup := &Group{
		ID:     intGroup.ID,
		Text:   intGroup.Text,
		Checks: []*Check{},
	}
	for _, check := range intGroup.Checks {
		extCheck := mapCheck(check, nodeType)
		extGroup.Checks = append(extGroup.Checks, extCheck)
	}
	return extGroup
}

func mapReport(internalReport *summarizer.SummarizedReport) (*Report, error) {
	externalReport := &Report{
		Results: []*Group{},
	}
	for nodeType, groups := range internalReport.Results {
		for _, group := range groups {
			extGroup := mapGroup(group, nodeType)
			externalReport.Results = append(externalReport.Results, extGroup)
		}
	}
	sort.Slice(externalReport.Results, func(i, j int) bool {
		return externalReport.Results[i].ID < externalReport.Results[j].ID
	})
	externalReport.Total = internalReport.Total
	externalReport.Pass = internalReport.Pass
	externalReport.Fail = internalReport.Fail
	externalReport.Skip = internalReport.Skip
	externalReport.Nodes = internalReport.Nodes

	return externalReport, nil
}

func Generate(data []byte) ([]byte, error) {
	internalReport := &summarizer.SummarizedReport{}
	err := json.Unmarshal(data, &internalReport)
	if err != nil {
		return nil, fmt.Errorf("error unmarshalling data into internal report: %v", err)
	}
	logrus.Infof("internalReport: %+v", internalReport)
	report, err := mapReport(internalReport)
	logrus.Debugf("report: %v", report)

	extData, err := json.Marshal(report)
	if err != nil {
		return nil, fmt.Errorf("error marshalling internal report struct: %v", err)
	}

	return extData, nil
}
