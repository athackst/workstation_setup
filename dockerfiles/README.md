# dockerfiles

These are base docker images for developing code.

## Build crystal docker images

This builds basic and development environments for ros2 without extra dependencies.

```bash
make docker_ros2_crystal
```

Use them as a reference to create the development and base docker files for docker-based ros development

## FAQ

__Q: Why build code inside a docker?__

> Re-creatable building environment that can be duplicated in Continuous Integration or sent to others to duplicate issues.
