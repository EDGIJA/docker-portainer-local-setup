#!/bin/bash
# fix-portainer.sh
# Script para arreglar Portainer con ambos puertos HTTP (9000) y HTTPS (9443)
# Autor: Edgi
# Fecha: $(date '+%Y-%m-%d')

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Banner
echo "════════════════════════════════════════════════════════"
echo "🔧 PORTAINER FIX SCRIPT"
echo "════════════════════════════════════════════════════════"
echo "Este script recreará Portainer con ambos puertos:"
echo "  • HTTP:  localhost:9000"
echo "  • HTTPS: localhost:9443"
echo "════════════════════════════════════════════════════════"
echo

# Verificar si Docker está funcionando
log "Verificando Docker..."
if ! docker --version &> /dev/null; then
    error "Docker no está instalado o no está funcionando"
    exit 1
fi
success "Docker está funcionando"

# Verificar si el contenedor Portainer existe
log "Verificando contenedor Portainer actual..."
if docker ps -a --format "table {{.Names}}" | grep -q "^portainer$"; then
    warning "Encontrado contenedor Portainer existente"
    
    # Mostrar configuración actual
    log "Configuración actual de puertos:"
    docker port portainer 2>/dev/null || echo "  No hay puertos mapeados"
    
    echo
    read -p "¿Quieres recrear el contenedor? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        log "Procediendo a recrear el contenedor..."
        
        # Detener contenedor
        log "Deteniendo contenedor Portainer..."
        docker stop portainer || true
        success "Contenedor detenido"
        
        # Remover contenedor
        log "Removiendo contenedor Portainer..."
        docker rm portainer || true
        success "Contenedor removido"
    else
        warning "Operación cancelada por el usuario"
        exit 0
    fi
else
    log "No se encontró contenedor Portainer existente"
fi

# Verificar si los puertos están libres
log "Verificando disponibilidad de puertos..."

check_port() {
    local port=$1
    if ss -tlnp | grep ":$port " > /dev/null; then
        error "Puerto $port está ocupado:"
        ss -tlnp | grep ":$port "
        return 1
    else
        success "Puerto $port está libre"
        return 0
    fi
}

ports_ok=true
check_port 9000 || ports_ok=false
check_port 9443 || ports_ok=false

if [ "$ports_ok" = false ]; then
    echo
    warning "Algunos puertos están ocupados. ¿Quieres continuar de todas formas?"
    read -p "Esto podría causar conflictos (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        error "Operación cancelada debido a puertos ocupados"
        exit 1
    fi
fi

# Crear volumen de datos si no existe
log "Verificando volumen de datos..."
if ! docker volume ls | grep -q "portainer_data"; then
    log "Creando volumen portainer_data..."
    docker volume create portainer_data
    success "Volumen creado"
else
    success "Volumen portainer_data ya existe"
fi

# Crear el nuevo contenedor con ambos puertos
log "Creando nuevo contenedor Portainer con ambos puertos..."

docker run -d \
    --name portainer \
    --restart=always \
    -p 9000:9000 \
    -p 9443:9443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

if [ $? -eq 0 ]; then
    success "Contenedor Portainer creado exitosamente"
else
    error "Error al crear el contenedor Portainer"
    exit 1
fi

# Esperar a que el contenedor esté listo
log "Esperando a que Portainer esté listo..."
sleep 5

# Verificar que el contenedor esté ejecutándose
if docker ps | grep -q "portainer"; then
    success "Contenedor Portainer está ejecutándose"
else
    error "El contenedor no está ejecutándose"
    log "Mostrando logs del contenedor..."
    docker logs portainer --tail 20
    exit 1
fi

# Verificar configuración de puertos
log "Verificando configuración de puertos..."
docker port portainer

# Probar conectividad
log "Probando conectividad..."

test_endpoint() {
    local url=$1
    local name=$2
    
    log "Probando $name ($url)..."
    if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url" | grep -q "200\|30[0-9]"; then
        success "$name está respondiendo"
        return 0
    else
        warning "$name no está respondiendo aún (podría necesitar más tiempo)"
        return 1
    fi
}

echo
log "Esperando a que los servicios estén listos..."
sleep 10

# Probar ambos endpoints
test_endpoint "http://localhost:9000" "HTTP endpoint"
test_endpoint "https://localhost:9443" "HTTPS endpoint" || true

# Mostrar resumen final
echo
echo "════════════════════════════════════════════════════════"
echo "🎉 PORTAINER CONFIGURADO EXITOSAMENTE"
echo "════════════════════════════════════════════════════════"
echo "Acceso disponible en:"
echo "  🌐 HTTP:  http://localhost:9000"
echo "  🔒 HTTPS: https://localhost:9443"
echo
echo "Configuración del contenedor:"
docker ps --filter "name=portainer" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
echo
echo "Volumen de datos: portainer_data"
echo "Auto-restart: habilitado"
echo "════════════════════════════════════════════════════════"

# Mostrar logs recientes
echo
log "Últimos logs del contenedor:"
docker logs portainer --tail 10

echo
success "✨ ¡Script completado exitosamente!"
echo "💡 Tip: Usa HTTPS (puerto 9443) para mayor seguridad"
echo "🔧 Si necesitas ejecutar este script nuevamente: ./scripts/fix-portainer.sh"
