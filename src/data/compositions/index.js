import battleShip from "./BattleShip.composition.json";
import bulletCannon from "./BulletCannon.composition.json";
import dino from "./Dino.composition.json";
import drone from "./Drone.composition.json";
import droneShip from "./DroneShip.composition.json";
import introShip from "./IntroShip.composition.json";
import ocean from "./Ocean.composition.json";
import shipHatch from "./ShipHatch.composition.json";

const compositions = {
  ...battleShip,
  ...bulletCannon,
  ...dino,
  ...drone,
  ...droneShip,
  ...introShip,
  ...ocean,
  ...shipHatch
};

export default compositions;
