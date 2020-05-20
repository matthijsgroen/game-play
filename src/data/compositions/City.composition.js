export default {
  "city.horizon": {
    attributes: {
      width: 256,
      height: 160
    },
    sprites: [["coast", { z: -598, horizon: [0.9, 0.8] }]]
  },
  "city.horizonStart": {
    attributes: {
      width: 256,
      height: 160
    },
    sprites: [["coastStart", { z: -598, horizon: [0.9, 0.8] }]]
  },
  "city.cityStart": {
    attributes: {
      width: 512,
      height: 288
    },
    sprites: [["cityStart", { z: -305, horizon: [0.4, 0.4] }]]
  },
  "city.city": {
    attributes: {
      width: 512,
      height: 288
    },
    sprites: [["city", { z: -305, horizon: [0.4, 0.4] }]]
  },
  "city.cityDistance": {
    attributes: {
      width: 256,
      height: 224
    },
    sprites: [["cityDistance", { z: -598, horizon: [0.9, 0.7] }]]
  },
  "city.layer2": {
    attributes: {
      width: 384,
      height: 256
    },
    hitbox: [240, 120, 240, 0, 295, 0, 295, 120],
    sprites: [
      ["cityLayer2", { z: -505, horizon: [0.6, 0.6] }],
      [
        "cityLayer2",
        { z: -505, y: 256, h: 80, crop: [254, 0, 0, 0], horizon: [0.6, 0.6] }
      ]
    ]
  },
  "city.bridge.foot": {
    attributes: {
      width: 512,
      height: 288
    },
    sprites: [["cityBridge", { z: -305, horizon: [0.4, 0.4] }]]
  },
  "city.bridge.deck": {
    attributes: {
      width: 1024,
      height: 192,
      ro: [934, 90]
    },
    hitbox: [0, 0, 1024, 0, 1024, 55, 0, 55],
    spriteAttributes: {
      accentColor: "#2ba04c"
    },
    sprites: [
      ["bridgeDeck", { z: 0, x: 4, key: "deck" }],
      ["bridgeDeck", { z: 1, x: 512, flipX: true }]
    ],
    frames: {
      rotateSmall: {
        attributes: { rotation: -2 }
      },
      rotateDown: {
        attributes: { rotation: -10 }
      }
    }
  },
  "city.bridge.pillar": {
    attributes: {
      width: 192,
      height: 544,
      ro: [96, 544]
    },
    sprites: [["bridgePillar", { z: 0, key: "pillar" }]],
    frames: {
      rotateSmall: {
        attributes: { rotation: -3 }
      },
      rotateDown: {
        attributes: { rotation: 80 },
        pillar: { y: 200 }
      }
    }
  },
  explosion: {
    attributes: { width: 96, height: 96 },
    sprites: [["explosion1", { key: "main" }]],
    animations: {
      default: {
        duration: 350,
        timeline: [
          {
            start: 0.0,
            end: 1.0,
            spriteAnimation: {
              key: "main",
              sprites: [
                "explosion1",
                "explosion2",
                "explosion3",
                "explosion4",
                "explosion5",
                "explosion6",
                "explosion7",
                "explosion8",
                "explosion9",
                "explosion10",
                "explosion11",
                "explosion12",
                "explosion13",
                "explosion14",
                "explosion15",
                "explosion16",
                "explosion17",
                "explosion18",
                "explosion19",
                "explosion20"
              ]
            }
          }
        ]
      }
    }
  }
};