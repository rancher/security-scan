security-scan
========
Please submit any new inquiries in the [compliance-operator](https://github.com/rancher/compliance-operator) repo.
For the current branch strategy related to the `security-scan`, please refer to  [Branches and Releases](https://github.com/rancher/compliance-operator?tab=readme-ov-file#branches-and-releases)

This repo has all the stuff needed for running compliance scans in Rancher Manager.

Multi-purpose repo:
- Packaging for all the components needed for compliance scans (sonobuoy, kube-bench)
- kube-bench-summarizer
- plugin script for sonobuoy tool (a different script is passed using command)

The corresponding docker image (rancher/security-scan) is used in the system charts.

## Building
`make`

Tag the image to personal docker hub repo

`docker tag rancher/security-scan:<MAKE TAG OUTPUT> <DOCKER_HUB_USER>/security-scan:dev`

Push docker tag

`docker push <DOCKER_HUB_USER>/security-scan:dev`

On Rancher install the Compliance app, changing the Values YAML to point to your image
```
image:
...
    securityScan:
        repository: <DOCKER_HUB_USER>/security-scan
        tag: dev
```


## License
Copyright (c) 2025 SUSE LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
