# github provider
provider "github" {
  token      = var.github_token
  individual = true
}

# kubernetes provider
provider "kubernetes" {
  config_context = var.kubectl_context
}

# helm provider
provider "helm" {
  kubernetes {
    config_context = var.kubectl_context
  }
}

# create SSH key for Flux
resource "tls_private_key" "github_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# add SSH public key to github
resource "github_user_ssh_key" "flux_ssh_key" {
  title = "Flux generated by Terraform"
  key   = tls_private_key.github_ssh_key.public_key_openssh
}

# create k8s namespace for flux
resource "kubernetes_namespace" "flux" {
  metadata {
    name = var.flux.namespace
  }
}

# create kubernetes secret for SSH key
resource "kubernetes_secret" "flux-github" {
  metadata {
    name      = "flux-ssh-key"
    namespace = kubernetes_namespace.flux.id
  }

  type = "Opaque"

  data = {
    identity = tls_private_key.github_ssh_key.private_key_pem
  }
}

# fluxcd helm repository
data "helm_repository" "fluxcd" {
  name = "fluxcd"
  url  = "https://charts.fluxcd.io"
}

# install flux helm chart
resource "helm_release" "flux" {
  name       = var.flux.release_name
  repository = data.helm_repository.fluxcd.metadata[0].name
  chart      = var.flux.chart_name
  version    = var.flux.chart_version

  namespace = kubernetes_namespace.flux.id

  values = [
    "${templatefile("${path.module}/values.tmpl", {
      slack_url      = var.slack_url,
      slack_channel  = var.slack_channel,
      slack_username = var.slack_user,
      github_url     = var.flux_options.git_url
    })}"
  ]

  set {
    name  = "git.secretName"
    value = kubernetes_secret.flux-github.metadata[0].name
  }

  set {
    name  = "git.url"
    value = var.flux_options.git_url
  }

  set {
    name  = "git.branch"
    value = var.flux_options.git_branch
  }

  set {
    name  = "git.path"
    value = var.flux_options.git_path
  }

  set {
    name  = "git.pollInterval"
    value = var.flux_options.git_pollInterval
  }

  set {
    name  = "sync.state"
    value = var.flux_options.sync_state
  }

  set {
    name  = "syncGarbageCollection.enabled"
    value = var.flux_options.syncGarbageCollection_enabled
  }

  set {
    name  = "prometheus.enabled"
    value = var.flux_options.prometheus_enabled
  }
}
