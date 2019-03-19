{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - kubernetes.charts.keycloak
{%- if charts.get('mailhog', {'enabled': False}).enabled %}
  - kubernetes.charts.mailhog
{%- endif -%}
{%- if charts.get('spinnaker', {'enabled': False}).enabled %}
  - kubernetes.charts.spinnaker
{%- endif -%}
{%- if charts.get('harbor', {'enabled': False}).enabled %}
  - kubernetes.charts.harbor
{%- endif -%}
{%- if charts.get('vistio', {'enabled': False}).enabled %}
  - kubernetes.charts.vistio
{%- endif -%}
{%- if charts.get('concourse', {'enabled': False}).enabled %}
  - kubernetes.charts.concourse
{%- endif -%}
