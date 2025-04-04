package summarizer

import (
	"bytes"
	"compress/gzip"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

var (
	testAvNodeMap1 = map[string]string{
		"node1": "permission=644",
		"node2": "permission=640",
		"node3": "permission=600",
	}

	testAvNodeMap2 = map[string]string{
		"node1": "testvalue",
		"node2": "testvalue1",
		"node3": "testvalue2",
	}

	testAvNodeMap3 = map[string]string{
		"node1": "true",
		"node2": "false",
		"node3": "true",
	}
)

func TestSummarizer_handleAvMapData(t *testing.T) {
	gwTestData, err := getGroupWrappersTestData()
	require.Nil(t, err, "error while getting groupwrappers test data")

	avGroupsTestData, err := getAvGroupTestData()
	require.Nil(t, err, "error while getting avgroups test data")

	s := Summarizer{
		fullReport: &SummarizedReport{
			GroupWrappers: gwTestData,
		},
	}

	err = s.handleAvMapData()
	require.Nil(t, err, "failed to update ActualValueMapData for fullReport")

	require.NotEmpty(t, s.fullReport.ActualValueMapData, "empty actualValueMapData found")

	compressedAvMapData, err := base64.StdEncoding.DecodeString(s.fullReport.ActualValueMapData)
	require.Nil(t, err, "error while decoding ActualValueMapData")
	require.NotNil(t, compressedAvMapData, "compressed ActualValueMapData should not be empty")

	r, err := gzip.NewReader(bytes.NewBuffer(compressedAvMapData))
	require.Nil(t, err, "error while reading compressed avMapData")
	defer func() {
		if err := r.Close(); err != nil {
			t.Errorf("failed to close gzip reader: %v", err)
		}
	}()

	avgroupsJSON, err := io.ReadAll(r)
	require.Nil(t, err, "error while reading avMapData json")

	expectedAvGroupsJSON, err := json.Marshal(avGroupsTestData)
	require.Nil(t, err, "error while encoding expected avgroups data")

	// verify ActualValueMapData
	require.Equal(t, string(expectedAvGroupsJSON), string(avgroupsJSON), "avmapData is not correctly encoded")

	// check if ActualValueNodeMap is set to nil for each check
	for _, gw := range s.fullReport.GroupWrappers {
		for _, cw := range gw.CheckWrappers {
			require.Nil(t, cw.ActualValueNodeMap, nil, "ActualValueNodeMap is not set to nil for the check")
		}
	}
}

func TestMapGroupWrappersToActualValueGroups(t *testing.T) {
	gwTestData, err := getGroupWrappersTestData()
	require.Nil(t, err, "error while getting groupwrappers test data")

	avGroupsTestData, err := getAvGroupTestData()
	require.Nil(t, err, "error while getting avgroups test data")

	avgroups := mapGroupWrappersToActualValueGroups(gwTestData)
	avgroupsJSON, err := json.Marshal(avgroups)
	require.Nil(t, err, "error while encoding avgroups data")

	expectedAvGroupsJSON, err := json.Marshal(avGroupsTestData)
	require.Nil(t, err, "error while encoding expected avgroups data")

	assert.EqualValues(t, string(expectedAvGroupsJSON), string(avgroupsJSON), "GroupWrappers are not correctly mapped to ActualValueGroups")
}

func getGroupWrappersTestData() ([]*GroupWrapper, error) {
	groupWrappersTestData := []*GroupWrapper{
		{
			ID:   "1.1",
			Text: "Checks for group 1.1",
			CheckWrappers: []*CheckWrapper{
				{
					ID:                 "1.1.1",
					Text:               "Check 1.1.1",
					ActualValueNodeMap: testAvNodeMap1,
				},
				{
					ID:                 "1.1.2",
					Text:               "Check 1.1.2",
					ActualValueNodeMap: testAvNodeMap2,
				},
			},
		},
		{
			ID:   "1.2",
			Text: "Checks for group 1.2",
			CheckWrappers: []*CheckWrapper{
				{
					ID:                 "1.2.1",
					Text:               "Check 1.2.1",
					ActualValueNodeMap: testAvNodeMap2,
				},
			},
		},
		{
			ID:   "2.1",
			Text: "Checks for group 2.1",
			CheckWrappers: []*CheckWrapper{
				{
					ID:                 "2.1.1",
					Text:               "Check 2.1.1",
					ActualValueNodeMap: testAvNodeMap2,
				},
			},
		},
		{
			ID:   "3.1",
			Text: "Checks for group 2.2",
			CheckWrappers: []*CheckWrapper{
				{
					ID:                 "3.2",
					Text:               "Check 3.1",
					ActualValueNodeMap: testAvNodeMap3,
				},
			},
		},
	}

	groupWrappersTestDataJSON, err := json.Marshal(groupWrappersTestData)
	if err != nil {
		return nil, fmt.Errorf("error while json encoding group wrappers test data: %w", err)
	}

	testData := []*GroupWrapper{}

	err = json.Unmarshal(groupWrappersTestDataJSON, &testData)
	if err != nil {
		return nil, fmt.Errorf("error while json decoding group wrappers test data: %w", err)
	}

	return testData, nil
}

func getAvGroupTestData() ([]*ActualValueGroup, error) {
	avGroupsTestData := []*ActualValueGroup{
		{
			ID:   "1.1",
			Text: "Checks for group 1.1",
			ActualValueChecks: []*ActualValueCheck{
				{
					ID:                 "1.1.1",
					Text:               "Check 1.1.1",
					ActualValueNodeMap: testAvNodeMap1,
				},
				{
					ID:                 "1.1.2",
					Text:               "Check 1.1.2",
					ActualValueNodeMap: testAvNodeMap2,
				},
			},
		},
		{
			ID:   "1.2",
			Text: "Checks for group 1.2",
			ActualValueChecks: []*ActualValueCheck{
				{
					ID:                 "1.2.1",
					Text:               "Check 1.2.1",
					ActualValueNodeMap: testAvNodeMap2,
				},
			},
		},
		{
			ID:   "2.1",
			Text: "Checks for group 2.1",
			ActualValueChecks: []*ActualValueCheck{
				{
					ID:                 "2.1.1",
					Text:               "Check 2.1.1",
					ActualValueNodeMap: testAvNodeMap2,
				},
			},
		},
		{
			ID:   "3.1",
			Text: "Checks for group 2.2",
			ActualValueChecks: []*ActualValueCheck{
				{
					ID:                 "3.2",
					Text:               "Check 3.1",
					ActualValueNodeMap: testAvNodeMap3,
				},
			},
		},
	}

	groupWrappersTestDataJSON, err := json.Marshal(avGroupsTestData)
	if err != nil {
		return nil, fmt.Errorf("error while json encoding group wrappers test data: %w", err)
	}

	testData := []*ActualValueGroup{}

	err = json.Unmarshal(groupWrappersTestDataJSON, &testData)
	if err != nil {
		return nil, fmt.Errorf("error while json decoding group wrappers test data: %w", err)
	}

	return testData, nil
}
