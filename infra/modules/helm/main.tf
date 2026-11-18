resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"

  create_namespace = true
  namespace        = "traefik"

  depends_on = [
    helm_release.kube_prometheus_stack,
    helm_release.cert_manager,
    var.eks_access_policy_association_arn
  ]

  values = [
    file("${path.module}/values/traefik.yaml")
  ]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  create_namespace = true
  namespace        = "cert-manager"

  values = [
    templatefile("${path.module}/values/cert-manager.yaml", { 
      cert_manager_role_arn = var.cert_manager_role_arn
    })]

  depends_on = [ 
    var.eks_access_policy_association_arn
  ]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"

  create_namespace = true
  namespace        = "external-dns"

  values = [
    templatefile("${path.module}/values/external-dns.yaml", {
      external_dns_role_arn = var.external_dns_role_arn
    })]

  depends_on = [
    helm_release.traefik,
    var.eks_access_policy_association_arn
  ]
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  timeout    = 900

  create_namespace = true
  namespace        = "external-secrets"

  depends_on = [ 
    var.eks_access_policy_association_arn
  ]
}

resource "helm_release" "reloader" {
  name       = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"

  create_namespace = true
  namespace        = "reloader"

  depends_on = [ 
    var.eks_access_policy_association_arn
   ]
}

resource "helm_release" "argo_cd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  timeout    = 600

  create_namespace = true
  namespace        = "argo-cd"

  values = [
    file("${path.module}/values/argocd.yaml")
  ]

  depends_on = [ 
    helm_release.traefik,
    var.eks_access_policy_association_arn
   ]
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  create_namespace = true
  namespace        = "monitoring"

  values = [
    file("${path.module}/values/kube-prometheus-stack.yaml")
  ]

  timeout = 900
  wait    = true

  depends_on = [
    var.eks_access_policy_association_arn
   ]
}