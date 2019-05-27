{%- from "kubernetes/map.jinja" import common with context -%}


/srv/kubernetes/manifests/istio:
  archive.extracted:
    - source: https://github.com/istio/istio/releases/download/{{ common.addons.istio.version }}/istio-{{ common.addons.istio.version }}-linux.tar.gz
    - skip_verify: true
    - user: root
    - group: root
    - archive_format: tar

/srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}/install/kubernetes/helm/:
  archive.extracted:
    - watch:
      - archive: /srv/kubernetes/manifests/istio
    - source: /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}/install/kubernetes/helm/charts/istio-cni-{{ common.addons.istio.cni_version }}.tgz
    - skip_verify: true
    - user: root
    - group: root
    - archive_format: tar

/usr/local/bin/istioctl:
  file.copy:
    - source: /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}/bin/istioctl
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - archive: /srv/kubernetes/manifests/istio
    - unless: cmp -s /usr/local/bin/istioctl /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}/bin/istioctl

/srv/kubernetes/manifests/istio/certificate.yaml:
  file.managed:
    - require:
      - archive: /srv/kubernetes/manifests/istio
    - source: salt://kubernetes/ingress/istio/templates/certificate.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/istio/ingress.yaml:
  file.managed:
    - require:
      - archive: /srv/kubernetes/manifests/istio 
    - source: salt://kubernetes/ingress/istio/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/istio/namespace.yaml:
  file.managed:
    - require:
      - archive: /srv/kubernetes/manifests/istio
    - source: salt://kubernetes/ingress/istio/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644

istio-namespace:
  cmd.run:
    - unless: kubectl get namespace istio-system
    - name: |
        kubectl create namespace istio-system

istio:
  cmd.run: 
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}
    - whatch:
      - cmd: kubernetes-istio-namespace 
      - archive: /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}/install/kubernetes/helm/
    - name: |       
        helm template install/kubernetes/helm/istio \
          --name istio \
          --namespace istio-system \
          -f install/kubernetes/helm/istio/values-istio-demo.yaml \
          --set tracing.enabled=true \
          --set istio_cni.enabled=true \
          --set kiali.enabled=true \
          --set gateways.istio-ingressgateway.sds.enabled=true \
          --set global.k8sIngress.enabled=true \
          --set global.k8sIngress.enableHttps=true \
          --set global.k8sIngress.gatewayName=ingressgateway \
          --set istio_cni.enabled=true | kubectl apply --namespace istio-system -f -

istio-gateway:
  cmd.run:
    - watch:
      - cmd: kubernetes-istio-install
    - name: | 
        kubectl apply -f /srv/kubernetes/manifests/istio/certificate.yaml
        kubectl -n istio-system \
        patch gateway istio-autogenerated-k8s-ingress --type=json \
        -p='[{"op": "replace", "path": "/spec/servers/0/tls", "value": {"httpsRedirect": true}}]'
        kubectl -n istio-system \
        patch gateway istio-autogenerated-k8s-ingress --type=json \
        -p='[{"op": "replace", "path": "/spec/servers/1/tls", "value": {"credentialName": "istio-ingressgateway-certs", "mode": "SIMPLE", "privateKey": "sds", "serverCertificate": "sds"}}]'
        kubectl apply -f /srv/kubernetes/manifests/istio/ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

istio-bookinfo:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}
    - watch:
      - cmd: kubernetes-istio-gateway-install
      - file: /srv/kubernetes/manifests/istio/namespace.yaml
    - name: | 
        kubectl apply -f /srv/kubernetes/manifests/istio/namespace.yaml
        kubectl apply -n bookinfo -f samples/bookinfo/platform/kube/bookinfo.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
