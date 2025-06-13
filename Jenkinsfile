@Library('microservice-pipeline') _

def config = [
    serviceName: 'user-service',
    hasUnitTests: !['cloud-config', 'api-gateway', 'service-discovery'].contains('user-service'),
    buildTool: 'maven', 
    dockerContext: '.',
    healthCheckPort: getHealthCheckPort('user-service')
]

microservicePipeline(config)

def getHealthCheckPort(serviceName) {
    def ports = [
        'api-gateway': 8080,
        'service-discovery': 8761,
        'cloud-config': 9296,
        'user-service': 8080,
        'product-service': 8080,
        'order-service': 8080,
        'payment-service': 8080,
        'shipping-service': 8080,
        'favourite-service': 8080,
        'proxy-client': 8900
    ]
    return ports[serviceName] ?: 8080
}