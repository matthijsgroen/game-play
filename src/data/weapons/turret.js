export default {
  "cannon.gun": {
    aiming: {
      offsetAimAngle: 0,
      sight: 95,
      resetOnDeactivation: true,
      rotateSpeed: 60,
      range: [70, -2]
    },
    spawnRhythm: {
      initialDelay: [500, 150],
      burst: [5, 7],
      shotDelay: [150, 100],
      burstDelay: [1000, 400],
      spawns: [
        ["bullet", {}],
        ["muzzleFlash", {}]
      ]
    },
    spawnables: {
      bullet: {
        spawnPosition: [0, 0.5],
        velocity: [400, 500],
        composition: "weapons.bullet",
        queue: [{ duration: 4000, audio: ["gun-shot", { volume: 0.8 }] }],
        damage: [
          {
            velocity: [-10e3, -15e3],
            affects: "health",
            duration: [2, 4],
            name: "Laser"
          }
        ],
        collisions: {
          PlayerShip: {
            spawns: [["spark", {}]]
          },
          WaterCollision: {
            spawns: [["splash", {}]]
          }
        }
      },
      muzzleFlash: {
        spawnPosition: [0, 0.5],
        attached: true,
        velocity: 0,
        composition: "weapons.muzzleFlash",
        queue: [{ duration: 400 }]
      },
      spark: {
        spawnPosition: "outside",
        velocity: 0,
        composition: "weapons.solidHit",
        queue: [{ duration: 100, audio: "laser-hit" }]
      },
      splash: {
        spawnPosition: "outside",
        velocity: 0,
        composition: "weapons.waterHit",
        queue: [{ duration: 305 }]
      }
    }
  },
  "cannon.laser": {
    aiming: {
      offsetAimAngle: 0,
      sight: 95,
      resetOnDeactivation: true,
      rotateSpeed: 60,
      range: [70, -2]
    },
    spawnRhythm: {
      initialDelay: [500, 150],
      burst: 1,
      shotDelay: 6000,
      burstDelay: 1,
      spawns: [
        ["laser", { angle: 0 }],
        ["laser", { angle: 20 }],
        ["laser", { angle: -20 }],
        ["laser", { angle: 40 }],
        ["laser", { angle: -40 }]
      ]
    },
    spawnables: {
      laser: {
        spawnPosition: [0, 0.5],
        velocity: 500, //2500,
        composition: "weapons.laser",
        queue: [
          {
            duration: 1250 // 240
          },
          { velocity: 0 },
          { duration: 3000 }
        ],
        damage: [
          {
            velocity: [-10e3, -15e3],
            affects: "health",
            duration: [2, 4],
            name: "Laser"
          }
        ],
        collisions: {
          PlayerShip: {
            remove: false
          },
          WaterCollision: {
            spawns: [["splash", {}]],
            remove: false
          }
        }
      },
      spark: {
        spawnPosition: "outside",
        velocity: 0,
        composition: "weapons.solidHit",
        queue: [{ duration: 100, audio: "laser-hit" }]
      },
      splash: {
        spawnPosition: "outside",
        velocity: 0,
        composition: "weapons.waterHit",
        queue: [{ duration: 305 }]
      }
    }
  },
  "turret.bullet": {
    spawnRhythm: {
      initialDelay: [1500, 150],
      burst: [3, 9],
      shotDelay: [150, 90],
      burstDelay: [3000, 400],
      spawns: [
        ["bullet", {}],
        ["muzzleFlash", {}]
      ]
    },
    spawnables: {
      bullet: {
        spawnPosition: [0, 0.5],
        velocity: [250, 300],
        composition: "weapons.bullet",
        queue: [{ duration: 4000 }],
        collisions: {
          SolidCollision: {
            spawns: [["spark", {}]]
          },
          WaterCollision: {
            spawns: [["splash", {}]]
          }
        }
      },
      muzzleFlash: {
        spawnPosition: [0, 0.5],
        attached: true,
        velocity: 0,
        composition: "weapons.muzzleFlash",
        queue: [{ duration: 400 }]
      },
      spark: {
        spawnPosition: "outside",
        velocity: 0,
        composition: "weapons.solidHit",
        queue: [{ duration: 100 }]
      },
      splash: {
        spawnPosition: "outside",
        velocity: 0,
        composition: "weapons.waterHit",
        queue: [{ duration: 305 }]
      }
    }
  },
  "turret.doubleBullet": {
    spawnRhythm: {
      initialDelay: [1500, 150],
      burst: [3, 9],
      shotDelay: [150, 90],
      burstDelay: [3000, 400],
      spawns: [
        ["bullet", { angle: -2 }],
        ["bullet", { angle: 2 }],
        ["muzzleFlash", {}]
      ]
    },
    spawnables: {
      bullet: {
        spawnPosition: [0, 0.5],
        velocity: [250, 300],
        composition: "weapons.bullet",
        queue: [{ duration: 4000 }],
        collisions: {
          SolidCollision: {
            spawns: [["spark", {}]]
          },
          WaterCollision: {
            spawns: [["splash", {}]]
          }
        }
      },
      muzzleFlash: {
        spawnPosition: [0, 0.5],
        attached: true,
        velocity: 0,
        composition: "weapons.muzzleFlash",
        queue: [{ duration: 400 }]
      },
      spark: {
        spawnPosition: "outside",
        velocity: 0,
        composition: "weapons.solidHit",
        queue: [{ duration: 100 }]
      },
      splash: {
        spawnPosition: "outside",
        velocity: 0,
        composition: "weapons.waterHit",
        queue: [{ duration: 305 }]
      }
    }
  }
};