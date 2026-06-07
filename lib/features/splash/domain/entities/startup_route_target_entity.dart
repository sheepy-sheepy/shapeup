class StartupRouteTargetEntity {
  const StartupRouteTargetEntity(
    this.path, {
    this.extra,
    this.startOtpCooldown = false,
  });

  final String path;
  final Object? extra;
  final bool startOtpCooldown;
}
