terraform_apps_components:
  2   external_ips:
  3     repo: git@git.umms.med.umich.edu:devops/sds-roles/terraform_apps/external_ips.git
  4     supported_versions:
  5       - 2.0.0
  6   cross_project:
  7     repo: git@git.umms.med.umich.edu:devops/sds-roles/terraform_apps/cross_project.git
  8     supported_versions:
  9       - 2.0.0
 10   artifact_registry:
 11     repo: git@git.umms.med.umich.edu:devops/sds-roles/terraform_apps/artifact_registry.git
 12     supported_versions:
 13       - 2.0.0
 14   project_config:
 15     repo: git@git.umms.med.umich.edu:devops/sds-roles/terraform_apps/project_config.git
 16     supported_versions:
 17       - 2.0.1
 18   velero:
 19     repo: git@git.umms.med.umich.edu:devops/terraform_apps/velero.git
 20     supported_versions:
 21       - 2.0.0
