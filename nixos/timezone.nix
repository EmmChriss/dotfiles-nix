{ lib, ... }:

{
  #
  # Automatically set timezone
  #

  # Set default timeZone to home time
  time.timeZone = lib.mkDefault "Europe/Bucharest";

  # # SOLUTION 2 with caveats: https://github.com/NixOS/nixpkgs/issues/68489#issuecomment-2513915247
  # as of 2024-12-13: tzupdate is receiving fixes; needs manual intervention
  # services.tzupdate.enable = true;

  # SOLUTION 1: https://github.com/NixOS/nixpkgs/issues/68489#issuecomment-2435134486
  # Enable automatic timezone updates 
  services.automatic-timezoned.enable = true;
  # Force enable required geoclue2 DemoAgent, since GNOME disables it: https://github.com/NixOS/nixpkgs/issues/68489#issuecomment-1484030107
  services.geoclue2.enableDemoAgent = lib.mkForce true;
  # Use beacondb.net since Mozilla Location Service is retired: https://github.com/NixOS/nixpkgs/issues/321121
  services.geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";
}
