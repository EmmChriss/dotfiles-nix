{...}: {
  networking.wg-quick.interfaces.protonvpn = {
    autostart = false;
    dns = ["10.2.0.1"];
    privateKeyFile = "/root/protonvpn.key";
    address = ["10.2.0.2/32"];
    # listenPort = 51820;
    # listenPort = 5182;

    peers = [
      {
        allowedIPs = ["0.0.0.0/0" "::/0"];
        publicKey = "GdVK8Ws3Zn65hDwau9lnhrCJhr8MtK9Tm2CvFL6WeCM=";
        endpoint = "185.100.234.7:51820";
      }
    ];
  };
}
