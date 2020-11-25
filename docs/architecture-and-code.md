## Licenses.yml
Although the version of ORT (0.1.0-SNAPSHOT) has not been changed between Oct 2020 and Nov 2020 the structure of the licenses file has been updated. 
This file is used in OSCake to determine if a license is marked as "instanced" or not.

#### Version before Nov 2020: Licenses.yml
```
license_sets:
- id: "copyleft"
- id: "copyleft-limited"
- id: "permissive"
- id: "public-domain"
- id: "instanced"
licenses:
- id: "AGPL-1.0"
  sets:
  - "copyleft"
  - "instanced"
  ....
``` 
#### Updated Version: license-classifications.yml
"categories" can be used now instead of "license_sets" - due to the change, the use of the former version leads to a runtime error
```
categories:
- name: "copyleft"
- name: "strong-copyleft"
- name: "include-source-code-offer-in-notice-file"
  description: >-
    A marker category that indicates that the licenses assigned to it require that the source code of the packages
    needs to be provided.

categorizations:
- id: "AGPL-1.0"
  categories:
  - "copyleft"
  ....
```
