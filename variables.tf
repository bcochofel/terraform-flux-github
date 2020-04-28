variable "github_token" {
  type        = string
  description = "GitHub Token"
}

variable "kubectl_context" {
  type        = string
  description = "kubectl context"
  default     = "minikube"
}

variable "slack_url" {
  type        = string
  description = "Slack URL for fluxcloud"
}

variable "slack_channel" {
  type        = string
  description = "Slack channel for fluxcloud"
}

variable "slack_user" {
  type        = string
  description = "Slack user for messages from fluxcloud"
  default     = "Fluxcloud"
}

variable "flux" {
  type = object({
    release_name  = string
    chart_name    = string
    chart_version = string
    namespace     = string
  })
  default = {
    release_name  = "fluxcd"
    chart_name    = "flux"
    chart_version = "1.3.0"
    namespace     = "flux"
  }
}

variable "flux_options" {
  type = object({
    git_url                       = string
    git_branch                    = string
    git_path                      = string
    git_pollInterval              = string
    sync_state                    = string
    syncGarbageCollection_enabled = bool
    prometheus_enabled            = bool
  })
  default = {
    git_url                       = "git@github.com:bcochofel/content-gitops.git"
    git_branch                    = "master"
    git_path                      = "workloads"
    git_pollInterval              = "1m"
    sync_state                    = "secret"
    syncGarbageCollection_enabled = true
    prometheus_enabled            = true
  }
}

variable "flux_values_file" {
  type    = string
  default = "values.yaml"
}
