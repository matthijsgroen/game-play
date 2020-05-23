const ShipControls = "ShipControls";

Crafty.c(ShipControls, {
  init() {
    this.bind("NewDirection", direction => {
      if (this.disableControls) return;
      if (
        (direction.x === -1 && !this.xFlipped) ||
        (direction.x === 1 && this.xFlipped)
      ) {
        if (this.appliedEntityState !== "reverse") {
          this.showState("reverse");
        }
      } else {
        if (this.appliedEntityState !== "flying") {
          this.showState("flying");
        }
      }
    });
  },

  controlPrimary(onOff) {
    if (this.disableControls) return;
    onOff ? this.showState("shooting") : this.showState("noShooting");
  },

  controlSecondary(onOff) {
    if (this.disableControls) return;
    if (!this.hasLaser) return;
    onOff ? this.showState("laserShooting") : this.showState("noLaserShooting");
  },
  controlSwitch() {},
  controlBlock() {}
});

export default ShipControls;
