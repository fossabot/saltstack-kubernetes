{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

{% if storage.get('rook_ceph', {'enabled': False}).enabled %}
ceph-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/rook-ceph-grafana-dashboard-configmap.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/rook-ceph-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
{% endif %}

{% if storage.get('rook_edgefs', {'enabled': False}).enabled %}
edgefs-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/rook-edgefs-grafana-dashboard-configmap.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/rook-edgefs-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
{% endif %}

{% if common.addons.get('nats_operator', {'enabled': False}).enabled %}
nats-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/nats-grafana-dashboard-configmap.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/nats-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
{% endif %}

{% if common.addons.get('nginx', {'enabled': False}).enabled %}
nginx-ingress-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/nginx-ingress-grafana-dashboard-configmap.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/nginx-ingress-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
{% endif %}

{% if common.addons.get('traefik', {'enabled': False}).enabled %}
traefik-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/traefik-grafana-dashboard-configmap.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/traefik-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
{% endif %}

{% if common.addons.get('cert_manager', {'enabled': False}).enabled %}
traefik-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/cert-manager-grafana-dashboard-configmap.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/cert-manager-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
{% endif %}

{% if charts.get('openfaas', {'enabled': False}).enabled %}
openfaas-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/openfaas-grafana-dashboard-configmap.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/openfaas-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
{% endif %}

kube-prometheus-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/grafana-deployment.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/grafana-deployment.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}