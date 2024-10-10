# rb-theron-sim

![Version: 0.0.5](https://img.shields.io/badge/Version-0.0.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Robotnik RB-THERON Simulation on ROS2

**Homepage:** <https://github.com/fluidos-project/robotic-logistics-use-case>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Guillem Gari | <ggari@robotnik.es> | <https://github.com/ggari-robotnik> |

## Source Code

* <https://github.com/fluidos-project/robotic-logistics-use-case>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| containers.environment.production | bool | `true` | Removes the debug features. |
| ros.discovery | string | `"subnet"` | Middleware automatic discovery range. Allowed values: `localhost` `subnet`, `off` or `system_default`. |
| ros.distro | string | `"humble"` | ROS distribution. Allowed values: `humble` or `iron`. |
| ros.gazebo.map | string | `"opil_factory"` | Map to use in the simulation. |
| ros.images.simulation.flavor | string | `"rb-theron-gazebo"` | flavor tag for simulation image |
| ros.images.simulation.project | string | `"robotnik"` | project for simulation image |
| ros.images.simulation.registry | string | `"docker.io"` | registry for simulation image |
| ros.images.simulation.repository | string | `"robotnik-simulations"` | repository for simulation image |
| ros.images.simulation.version | string | `"0.3.0-rc07"` | version tag for simulation image |
| ros.images.zenoh.project | string | `"robotnik"` | project for zenoh-router image. ignored if `ros.rwm` is not `rmw_zenoh_cpp` |
| ros.images.zenoh.registry | string | `"docker.io"` | registry for zenoh-router image. ignored if `ros.rwm` is not `rmw_zenoh_cpp` |
| ros.images.zenoh.repository | string | `"zenoh-rmw"` | repository for zenoh-router image. ignored if `ros.rwm` is not `rmw_zenoh_cpp` |
| ros.images.zenoh.version | string | `"0.0.1-rc00"` | version tag for zenoh-router image. ignored if `ros.rwm` is not `rmw_zenoh_cpp` |
| ros.rmw | string | `"rmw_cyclonedds_cpp"` | ROS MiddleWare Implementation. Allowed values: `rmw_cyclonedds_cpp` `rmw_fastrtps_cpp`, or `rmw_zenoh_cpp`. zenoh is only available in distro `iron` or above |
| services.gazebo.name | string | `"robots-gazebo"` | Gazebo service name. |
| services.gazebo.port | int | `11345` | Gazebo service port. |
| services.zenoh.name | string | `"zenoh-router"` | Zenoh router service name. ignored if `ros.rwm` is not `rmw_zenoh_cpp` |
| services.zenoh.port | int | `7447` | Zenoh router service port. ignored if `ros.rwm` is not `rmw_zenoh_cpp` |
| services.zenoh.proto | string | `"TCP"` | Zenoh router service protocol. ignored if `ros.rwm` is not `rmw_zenoh_cpp` |
