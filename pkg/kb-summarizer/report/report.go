package report

import (
	"encoding/json"
	"fmt"
	"log/slog"
	"os/exec"
	"sort"

	"github.com/rancher/security-scan/pkg/kb-summarizer/summarizer"
)

type NodeType string

const (
	NodeTypeEtcd   NodeType = "etcd"
	NodeTypeMaster NodeType = "master"
	NodeTypeNode   NodeType = "node"
)

type State string

const (
	Pass          State = "pass"
	Fail          State = "fail"
	Skip          State = "skip"
	Mixed         State = "mixed"
	Warn          State = "warn"
	NotApplicable State = "notApplicable"
)

type Check struct {
	ID                 string            `yaml:"id" json:"id"`
	Text               string            `json:"description"`
	Remediation        string            `json:"remediation"`
	State              State             `json:"state"`
	NodeType           []NodeType        `json:"node_type"`
	Nodes              []string          `json:"nodes,omitempty"`
	Audit              string            `json:"audit"`
	AuditConfig        string            `json:"audit_config"`
	TestInfo           []string          `json:"test_info"`
	Commands           []*exec.Cmd       `json:"commands"`
	ConfigCommands     []*exec.Cmd       `json:"config_commands"`
	ActualValueNodeMap map[string]string `json:"actual_value_per_node"`
	ExpectedResult     string            `json:"expected_result"`
	TestType           string            `json:"test_type"`
	Scored             bool              `json:"scored"`
}

type Group struct {
	ID     string   `yaml:"id" json:"id"`
	Text   string   `json:"description"`
	Checks []*Check `json:"checks"`
}

type Report struct {
	Version       string                `json:"version"`
	Total         int                   `json:"total"`
	Pass          int                   `json:"pass"`
	Fail          int                   `json:"fail"`
	Skip          int                   `json:"skip"`
	Warn          int                   `json:"warn"`
	NotApplicable int                   `json:"notApplicable"`
	Nodes         map[NodeType][]string `json:"nodes"`
	Results       []*Group              `json:"results"`
	// ActualValueMapData is the base64-encoded gzipped-compressed avmap data of all checks.
	ActualValueMapData string `json:"actual_value_map_data"`
}

func nodeTypeMapper(nodeType summarizer.NodeType) NodeType {
	switch nodeType {
	case summarizer.NodeTypeEtcd:
		return NodeTypeEtcd
	case summarizer.NodeTypeMaster:
		return NodeTypeMaster
	case summarizer.NodeTypeNode:
		return NodeTypeNode
	}
	return NodeTypeNode
}

func mapState(state summarizer.State) State {
	switch state {
	case summarizer.Pass:
		return Pass
	case summarizer.Fail:
		return Fail
	case summarizer.Skip:
		return Skip
	case summarizer.Mixed:
		return Mixed
	case summarizer.Warn:
		return Warn
	case summarizer.NotApplicable:
		return NotApplicable
	}
	return Fail
}

func mapNodeType(nodeType []summarizer.NodeType) []NodeType {
	var extNodeType []NodeType
	for _, nt := range nodeType {
		extNodeType = append(extNodeType, nodeTypeMapper(nt))
	}
	return extNodeType
}

func mapCheck(intCheck *summarizer.CheckWrapper) *Check {
	return &Check{
		ID:                 intCheck.ID,
		Text:               intCheck.Text,
		Remediation:        intCheck.Remediation,
		State:              mapState(intCheck.State),
		NodeType:           mapNodeType(intCheck.NodeType),
		Nodes:              intCheck.Nodes,
		Audit:              intCheck.Audit,
		AuditConfig:        intCheck.AuditConfig,
		TestInfo:           intCheck.TestInfo,
		Commands:           intCheck.Commands,
		ConfigCommands:     intCheck.ConfigCommands,
		ActualValueNodeMap: intCheck.ActualValueNodeMap,
		ExpectedResult:     intCheck.ExpectedResult,
		TestType:           intCheck.Type,
		Scored:             intCheck.Scored,
	}
}

func mapGroup(intGroup *summarizer.GroupWrapper) *Group {
	extGroup := &Group{
		ID:     intGroup.ID,
		Text:   intGroup.Text,
		Checks: []*Check{},
	}
	for _, check := range intGroup.CheckWrappers {
		extCheck := mapCheck(check)
		extGroup.Checks = append(extGroup.Checks, extCheck)
	}
	return extGroup
}

func mapNodes(intNodes map[summarizer.NodeType][]string) map[NodeType][]string {
	extNodes := map[NodeType][]string{}
	for k, v := range intNodes {
		extNodes[nodeTypeMapper(k)] = v
	}
	return extNodes
}

func mapReport(internalReport *summarizer.SummarizedReport) (*Report, error) {
	externalReport := &Report{
		Results: []*Group{},
	}
	for _, group := range internalReport.GroupWrappers {
		extGroup := mapGroup(group)
		externalReport.Results = append(externalReport.Results, extGroup)
	}
	sort.Slice(externalReport.Results, func(i, j int) bool {
		return externalReport.Results[i].ID < externalReport.Results[j].ID
	})
	externalReport.Version = internalReport.Version
	externalReport.Total = internalReport.Total
	externalReport.Pass = internalReport.Pass
	externalReport.Fail = internalReport.Fail
	externalReport.Skip = internalReport.Skip
	externalReport.Warn = internalReport.Warn
	externalReport.NotApplicable = internalReport.NotApplicable
	externalReport.Nodes = mapNodes(internalReport.Nodes)
	externalReport.ActualValueMapData = internalReport.ActualValueMapData
	return externalReport, nil
}

func GetJSONBytes(data []byte) ([]byte, error) {
	internalReport := &summarizer.SummarizedReport{}
	err := json.Unmarshal(data, &internalReport)
	if err != nil {
		return nil, fmt.Errorf("error unmarshalling data into internal report: %w", err)
	}
	slog.Debug("internal report", "data", internalReport)
	report, err := mapReport(internalReport)
	if err != nil {
		return nil, fmt.Errorf("error mapping report: %w", err)
	}

	slog.Debug("mapped report", "data", report)
	extData, err := json.Marshal(report)
	if err != nil {
		return nil, fmt.Errorf("error marshalling internal report struct: %w", err)
	}

	return extData, nil
}

func Get(data []byte) (*Report, error) {
	internalReport := &summarizer.SummarizedReport{}
	err := json.Unmarshal(data, &internalReport)
	if err != nil {
		return nil, fmt.Errorf("error unmarshalling data into internal report: %w", err)
	}
	return mapReport(internalReport)
}
