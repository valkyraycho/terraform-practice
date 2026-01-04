package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAsgExample(t *testing.T) {
	t.Parallel()

	clusterName := fmt.Sprintf("test-%s", random.UniqueId())
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/asg",
		Vars: map[string]any{
			"cluster_name": clusterName,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	asgName := terraform.Output(t, terraformOptions, "asg_name")
	if asgName == "" {
		t.Fatal("asg_name output should not be empty")
	}

}
