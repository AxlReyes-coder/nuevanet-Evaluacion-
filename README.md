# NuevaNet - Evaluación Parcial 2 

Solución de infraestructura en AWS con RHEL: automatización, contenedores y respaldos.

## Contenido

| Carpeta | Descripción |
| scripts/procesar_logs.sh | Reporte de errores y compresión de logs antiguos |
| scripts/respaldo.sh | Respaldo completo e incremental con tar |
| app/ | API Flask, Dockerfile y compose para dev y prod |
| cron/crontab.txt | Programación de tareas |
| evidencias/ | Versiones, bitácoras y capturas de pruebas |

## Herramientas y versiones

| Herramienta | Versión |
|---|---|
| Red Hat Enterprise Linux | 9.8 (Plow), kernel 5.14.0-687.10.1.el9_8 |
| Docker | 29.9.0 |
| Docker Compose | v5.6.0 |
| GNU tar | 1.34 |
| GNU bash | 5.1.8 |
| Git | 2.52.0 |
| cronie | 1.5.7 |
| Python (imagen base) | 3.12-slim |
| Flask / Gunicorn | 3.1.0 / 23.0.0 |
| Infraestructura | AWS Academy Learner Lab, EC2 us-east-1 |

## Uso

- Automatización: `./scripts/procesar_logs.sh [directorio]`
- Respaldos: `./scripts/respaldo.sh completo` o `./scripts/respaldo.sh incremental`
- Contenedor dev: `docker compose -f app/docker-compose.dev.yml up -d --build` (puerto 8080)
- Contenedor prod: `docker compose -f app/docker-compose.prod.yml up -d --build` (puerto 80)

## Estrategia de respaldo

Completo semanal (domingo 02:00) más incremental diario (lunes a sábado 02:00), con retención de 14 días.
