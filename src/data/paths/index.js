export default {
  playerLiftOff: [
    { x: 0.2, y: 0.6 },
    { x: 0.19, y: 0.56 },
    { x: 0.2, y: 0.55 }
  ],
  "intro.HeliLiftOff": [
    { x: 0.3, y: 0.6 },
    { x: 0.32, y: 0.46 },
    { x: 0.3, y: 0.35 },
    { x: 0.15, y: 0.4 },
    { x: -0.25, y: 0.35 }
  ],
  "intro.HeliBackground": [
    { x: -0.3, y: 0.3 },
    { x: 0.1, y: 0.37 },
    { x: 0.4, y: 0.3 }
  ],
  "intro.HeliBackgroundCrash": [
    { x: 0.4, y: 0.3 },
    { x: 0.35, y: 0.35, events: [[0.9, { event: "Escape1" }]] },
    { x: 0.45, y: 0.4 },
    { x: 0.5, y: 0.3 },
    { x: 0.45, y: 0.2, events: [[0.5, { event: "Escape2" }]] },
    { x: 0.4, y: 0.25 },
    { x: 1.2, y: 0.2 }
  ],
  "intro.DroneBackground": [
    { x: 1.1, y: 0.3 },
    { x: 0.9, y: 0.2 },
    { x: 0.7, y: 0.3, events: [[0, { setState: ["shoot", 0] }]] },
    {
      x: 0.7,
      y: 0.47,
      events: [
        [0.6, { setState: ["turned", 0] }],
        [0.7, { setState: ["eyeMove", 0] }]
      ]
    },
    { x: 0.8, y: 0.3 },
    { x: 0.95, y: 0.15 },
    { x: 1.2, y: 0.1 }
  ],
  "drone.straight": [
    { x: 1.1, y: 0.5 },
    { x: -0.1, y: 0.5 }
  ],
  "drone.pattern1": [
    { x: 1.1, y: 0.5 },
    { x: 0.9, y: 0.2 },
    { x: 0.7, y: 0.8 },
    { x: 0.5, y: 0.2 },
    { x: 0.3, y: 0.8 },
    { x: 0.1, y: 0.5, events: [[0.2, { setState: ["turned", 500] }]] },
    { x: 0.3, y: 0.2, events: [[0.9, { setState: ["turned", 500] }]] },
    { x: 0.9, y: 0.5 },
    { x: -0.1, y: 0.6 }
  ],
  "drone.pattern2": [
    { x: 1.1, y: 0.5 },
    { x: 0.5, y: 0.7 },
    { x: 0.1, y: 0.5, events: [[0.1, { setState: ["turned", 500] }]] },
    { x: 0.3, y: 0.2 },
    { x: 0.8, y: 0.2, events: [[0.6, { setState: ["turned", 500] }]] },
    { x: 0.9, y: 0.4 },
    { x: 0.4, y: 0.5 },
    { x: -0.1, y: 0.2 }
  ],
  "drone.pattern3": [
    { x: 0.5, y: -0.1 },
    { x: 0.5, y: 0.2 },
    { x: 0.7, y: 0.31 },
    { x: 0.8, y: 0.5 },
    { x: 0.5, y: 0.5 },
    { x: -0.1, y: 0.3 }
  ],
  "drone.pattern4": [
    { x: 0.5, y: 1.11 },
    { x: 0.5, y: 0.8 },
    { x: 0.7, y: 0.8 },
    { x: 0.93, y: 0.69 },
    { x: 0.8, y: 0.5 },
    { x: 0.5, y: 0.5 },
    { x: -0.1, y: 0.7 }
  ],
  "drone.pattern5": [
    { x: -0.2, y: 0.5, events: [[0.0, { setState: ["turned", 0] }]] },
    { x: 0.5, y: 0.8 },
    { x: 0.93, y: 0.69, events: [[0.0, { setState: ["turned", 0] }]] },
    { x: 0.8, y: 0.5 },
    { x: 0.5, y: 0.5 },
    { x: -0.1, y: 0.7 }
  ],
  "drone.pattern6": [
    { x: 1.1, y: 0.2 },
    { x: 0.2, y: 0.4, events: [[0.0, { setState: ["turned", 0] }]] },
    { x: 0.6, y: 0.2 },
    { x: 1.1, y: 0.2 }
  ],
  "mineCannon.lowShot": [
    { x: 0.8, y: 0.6, events: [[0.8, { event: "Loose" }]] },
    { x: 0.7, y: 0.6 },
    { x: 0.6, y: 0.9 }
  ],
  "mineCannon.highShot": [
    { x: 0.8, y: 0.6, events: [[0.8, { event: "Loose" }]] },
    { x: 0.6, y: 0.3 },
    { x: 0.3, y: 0.5 },
    { x: 0.1, y: 0.9 }
  ],
  sunrise: [
    { x: 0.9, y: 0.7 },
    { x: 0.8, y: 0.3 },
    { x: 0.4, y: 0.1 }
  ],
  evadePattern: [
    { x: 0.1, y: 0.5 },
    { x: 0.9, y: 0.2 },
    { x: 0.7, y: 0.8 },
    { x: 0.5, y: 0.2 },
    { x: 0.3, y: 0.8 },
    { x: 0.1, y: 0.5 },
    { x: 0.3, y: 0.2 },
    { x: 0.9, y: 0.5 },
    { x: 0.4, y: 0.9 },
    { x: 0.1, y: 0.5 }
  ],
  "heli.pattern1": [
    { x: 1.1, y: 0.5 },
    { x: 0.9, y: 0.4 },
    { x: 0.8, y: 0.2 },
    { x: 0.9, y: 0.1 },
    { x: 0.9, y: 0.3 },
    { x: 0.5, y: 0.3 },
    { x: 0.5, y: 0.1 },
    { x: 0.6, y: 0.3 },
    { x: 0.7, y: 0.7 },
    { x: 0.8, y: 0.5 },
    { x: 0.3, y: 0.3 },
    { x: -0.2, y: 0.1 }
  ]
};
